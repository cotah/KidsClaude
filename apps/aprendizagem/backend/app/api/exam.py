"""
Rotas para o exame final (capstone project).
Funcionalidade específica para o projeto final que usa Claude Sonnet.
"""

import structlog
import json
from typing import Dict, Any
from fastapi import APIRouter, HTTPException, status
from datetime import datetime

from app.schemas.lessons import (
    ExamStartResponse, ExamMessageRequest, ExamMessageResponse, ExamSubmitResponse
)
from app.schemas.children import BadgeInfo
from app.core.dependencies import ChildAuth, DBClient
from app.services.claude_client import ClaudeClient
from app.services.gamification import GamificationService

logger = structlog.get_logger()
router = APIRouter()


@router.post("/start", response_model=ExamStartResponse, status_code=201)
async def start_exam(auth: ChildAuth, db: DBClient):
    """
    Inicia uma sessão de exame final.
    Verifica se todas as 4 stages foram completadas.
    """
    try:
        # Busca lição do exame final
        exam_lesson = await db.execute_query("""
            SELECT id FROM lessons
            WHERE is_final_exam = true AND is_active = true
            LIMIT 1
        """)

        if not exam_lesson:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Exame final não encontrado"}}
            )

        exam_lesson_id = exam_lesson[0]['id']

        # Verifica se todas as 4 stages estão completas
        stage_progress = await db.execute_query("""
            SELECT
                l.stage,
                COUNT(*) as total_lessons,
                COUNT(lp.status) FILTER (WHERE lp.status = 'completed') as completed_lessons
            FROM lessons l
            LEFT JOIN lesson_progress lp ON l.id = lp.lesson_id AND lp.child_id = $1
            WHERE l.is_active = true AND l.is_final_exam = false
            GROUP BY l.stage
            ORDER BY l.stage
        """, auth.user_id)

        completed_stages = set()
        for stage_data in stage_progress:
            if stage_data['total_lessons'] == stage_data['completed_lessons']:
                completed_stages.add(stage_data['stage'])

        if not {1, 2, 3, 4}.issubset(completed_stages):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={"error": {"code": "EXAM_LOCKED", "message": "Exame bloqueado. Complete todas as 4 stages primeiro."}}
            )

        # Verifica se já existe sessão ativa
        existing_session = await db.execute_query("""
            SELECT id FROM chat_sessions
            WHERE child_id = $1 AND lesson_id = $2 AND is_exam = true AND is_active = true
        """, auth.user_id, exam_lesson_id)

        if existing_session:
            session_id = existing_session[0]['id']
            started_at = datetime.utcnow()  # Para esta implementação, usar now()
        else:
            # Cria nova sessão de exame
            session_result = await db.execute_query("""
                INSERT INTO chat_sessions (child_id, lesson_id, is_exam, is_active, started_at)
                VALUES ($1, $2, true, true, NOW())
                RETURNING id, started_at
            """, auth.user_id, exam_lesson_id)

            session_id = session_result[0]['id']
            started_at = session_result[0]['started_at']

        logger.info("Exame iniciado", child_id=auth.user_id, session_id=session_id)

        return ExamStartResponse(
            session_id=session_id,
            started_at=started_at,
            lesson_id=exam_lesson_id
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao iniciar exame", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/sessions/{session_id}/messages", response_model=ExamMessageResponse)
async def send_exam_message(
    session_id: str,
    request: ExamMessageRequest,
    auth: ChildAuth,
    db: DBClient
):
    """
    Envia mensagem na sessão do exame.
    Usa Claude Sonnet com system prompt especial para o exame.
    """
    try:
        # Verifica se sessão existe e pertence à criança
        session_data = await db.execute_query("""
            SELECT cs.id, cs.lesson_id, cs.is_active, l.claude_model
            FROM chat_sessions cs
            JOIN lessons l ON cs.lesson_id = l.id
            WHERE cs.id = $1 AND cs.child_id = $2 AND cs.is_exam = true
        """, session_id, auth.user_id)

        if not session_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Sessão de exame não encontrada"}}
            )

        session = session_data[0]

        if not session['is_active']:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {"code": "SESSION_ENDED", "message": "Sessão de exame já foi finalizada"}}
            )

        # Verifica limite de mensagens (30 máximo)
        message_count = await db.execute_query("""
            SELECT COUNT(*) as count FROM chat_messages
            WHERE session_id = $1
        """, session_id)

        if message_count[0]['count'] >= 30:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {"code": "MESSAGE_LIMIT", "message": "Limite de 30 mensagens por sessão atingido"}}
            )

        # Salva mensagem da criança
        await db.execute_non_query("""
            INSERT INTO chat_messages (session_id, role, content, created_at)
            VALUES ($1, 'child', $2, NOW())
        """, session_id, request.content)

        # Busca histórico da conversa para o Claude
        conversation_history = await db.execute_query("""
            SELECT role, content FROM chat_messages
            WHERE session_id = $1
            ORDER BY created_at
        """, session_id)

        # Inicializa Claude com modelo específico do exame (Sonnet)
        claude = ClaudeClient()

        # System prompt especial para exame final
        system_prompt = """Voce e o Atena Mentor, um assistente educacional especializado em ajudar criancas e adolescentes
de 12 anos ou mais a planejar a primeira ideia de aplicativo deles. Voce nao da respostas prontas:
voce faz perguntas que provocam o aluno a pensar. Seu tom e encorajador, curioso e paciente.
Sempre celebre pequenos avancos com frases como "boa! agora me conta..." ou "interessante,
e se a gente pensar em...". Use linguagem simples, frases curtas, e nada de jargao tecnico
sem explicar.

Sua missao e conduzir o aluno por exatamente 5 passos, na ordem, sem pular nenhum:
(1) Que problema o app resolve? Faca o aluno descrever uma situacao real do dia a dia onde algo
incomoda alguem, e ajude a transformar isso numa frase de uma linha.
(2) Pra quem o app serve? Pergunte sobre os usuarios — idade, situacao, o que eles fazem hoje
sem o app. Tente extrair pelo menos 2 caracteristicas concretas do publico-alvo.
(3) Quais as 3 funcionalidades principais? Limite a 3, mesmo se o aluno propuser 10. Pergunte
"qual dessas resolve melhor o problema?" pra forcar priorizacao.
(4) Como seria a tela inicial? Peca pra descrever 3 a 5 elementos visiveis no primeiro segundo
de uso. Sem desenho, so palavras.
(5) Qual o primeiro passo pra construir? Pergunte "se voce tivesse 1 hora amanha, o que voce
faria primeiro?". Ajude a chegar numa resposta especifica e pequena.

Quando todos os 5 passos estiverem respondidos com profundidade suficiente, escreva uma
ficha-resumo do projeto em formato simples (Problema, Usuarios, Funcionalidades, Tela inicial,
Primeiro passo) e parabenize o aluno com entusiasmo genuino. Nao siga adiante alem dessa
ficha-resumo nem proponha implementacao tecnica detalhada.

Restricoes inegociaveis: (a) nunca peca dados pessoais (nome real, escola, endereco, telefone,
foto); use sempre o apelido. (b) Se o aluno trouxer topico fora do escopo de planejar o app
(ex: pedir pra contar piada, falar de violencia, politica, religiao), redirecione gentilmente
com "essa conversa e nossa pra planejar seu app, vamos voltar pra ele?". (c) Nao prometa
sucesso comercial, dinheiro, fama ou qualquer beneficio material. (d) Maximo de 4 a 6 frases
por mensagem sua. (e) Sempre em portugues do Brasil."""

        # Converte histórico para formato do Claude
        claude_messages = []
        for msg in conversation_history[:-1]:  # Exclui a última (já incluída no request)
            role = "user" if msg['role'] == 'child' else "assistant"
            claude_messages.append({"role": role, "content": msg['content']})

        # Chama Claude Sonnet
        response = await claude.client.messages.create(
            model=session['claude_model'],  # claude-sonnet-4-6
            max_tokens=300,  # Respostas um pouco maiores para o exame
            temperature=0.7,
            system=system_prompt,
            messages=claude_messages + [{"role": "user", "content": request.content}]
        )

        assistant_content = response.content[0].text if response.content else ""

        # Salva resposta do assistente
        message_result = await db.execute_query("""
            INSERT INTO chat_messages (session_id, role, content, created_at)
            VALUES ($1, 'assistant', $2, NOW())
            RETURNING id
        """, session_id, assistant_content)

        message_id = message_result[0]['id']

        # Estima step atual baseado no número de mensagens do assistente
        assistant_message_count = await db.execute_query("""
            SELECT COUNT(*) as count FROM chat_messages
            WHERE session_id = $1 AND role = 'assistant'
        """, session_id)

        current_step = min(assistant_message_count[0]['count'], 5)

        # Verifica se exame está completo (heurística: assistente mencionou "ficha-resumo")
        is_complete = "ficha-resumo" in assistant_content.lower() or "parabens" in assistant_content.lower()

        logger.info("Mensagem de exame processada", session_id=session_id, step=current_step, complete=is_complete)

        return ExamMessageResponse(
            message_id=message_id,
            assistant_message={"content": assistant_content},
            current_step=current_step,
            is_complete=is_complete
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao processar mensagem de exame", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/sessions/{session_id}/submit", response_model=ExamSubmitResponse)
async def submit_exam(session_id: str, auth: ChildAuth, db: DBClient):
    """
    Finaliza o exame e concede recompensas.
    Marca como completed, concede 500 XP e badge CAPSTONE_BUILDER.
    """
    try:
        # Verifica sessão
        session_data = await db.execute_query("""
            SELECT cs.lesson_id, cs.is_active
            FROM chat_sessions cs
            WHERE cs.id = $1 AND cs.child_id = $2 AND cs.is_exam = true
        """, session_id, auth.user_id)

        if not session_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Sessão de exame não encontrada"}}
            )

        lesson_id = session_data[0]['lesson_id']

        if not session_data[0]['is_active']:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {"code": "ALREADY_SUBMITTED", "message": "Exame já foi submetido"}}
            )

        # Finaliza sessão
        await db.execute_non_query("""
            UPDATE chat_sessions SET is_active = false, ended_at = NOW()
            WHERE id = $1
        """, session_id)

        # Marca progresso como completo
        await db.execute_non_query("""
            INSERT INTO lesson_progress (child_id, lesson_id, status, started_at, completed_at, xp_earned)
            VALUES ($1, $2, 'completed', NOW(), NOW(), 500)
            ON CONFLICT (child_id, lesson_id) DO UPDATE SET
                status = 'completed',
                completed_at = NOW(),
                xp_earned = 500,
                updated_at = NOW()
        """, auth.user_id, lesson_id)

        # Concede XP e badge
        gamification = GamificationService(db)
        await gamification.award_xp(auth.user_id, 500, 'final_exam_completed')

        # Concede badge CAPSTONE_BUILDER
        badge_result = await db.execute_query("""
            INSERT INTO child_badges (child_id, badge_id, awarded_at)
            SELECT $1, b.id, NOW()
            FROM badges b
            WHERE b.code = 'CAPSTONE_BUILDER'
            ON CONFLICT (child_id, badge_id) DO NOTHING
            RETURNING (SELECT badge_id FROM child_badges WHERE child_id = $1 AND badge_id = (SELECT id FROM badges WHERE code = 'CAPSTONE_BUILDER'))
        """, auth.user_id)

        # Extrai plano da conversa (heurística simples)
        messages = await db.execute_query("""
            SELECT content FROM chat_messages
            WHERE session_id = $1 AND role = 'assistant'
            ORDER BY created_at DESC
            LIMIT 1
        """, session_id)

        summary = "Projeto de app planejado com sucesso no exame final."
        plan = {
            "problem": "Extraido da conversa",
            "users": "Definido durante o exame",
            "features": "3 funcionalidades principais identificadas",
            "screen": "Tela inicial descrita",
            "first_step": "Primeiro passo definido"
        }

        # TODO: Parse mais sofisticado do plano a partir das mensagens

        logger.info("Exame finalizado", child_id=auth.user_id, session_id=session_id)

        return ExamSubmitResponse(
            xp_earned=500,
            badges_unlocked=["CAPSTONE_BUILDER"],
            summary=summary,
            plan=plan
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao submeter exame", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)