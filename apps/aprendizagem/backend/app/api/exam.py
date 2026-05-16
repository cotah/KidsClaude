"""
Rotas para o exame final (capstone project).
Funcionalidade específica para o projeto final que usa Claude Sonnet.

Cada faixa etaria tem um projeto diferente (assistente de historias,
Pokedex, site, agente de IA) e um system prompt proprio em PT/EN.
Os prompts e mensagens de abertura ficam neste arquivo - cada projeto
e' especifico do exame, nao reusa nada do chat normal.
"""

import structlog
import json
import re
from typing import Dict, Any
from fastapi import APIRouter, HTTPException, Request, status
from datetime import datetime

from app.schemas.lessons import (
    ExamStartResponse, ExamMessageRequest, ExamMessageResponse, ExamSubmitResponse
)
from app.schemas.children import BadgeInfo
from app.core.dependencies import ChildAuth, DBClient
from app.services.claude_client import (
    ClaudeClient,
    _select_age_group,
    _normalize_locale,
)
from app.services.gamification import GamificationService
# Reusa o limite por idade do chat normal - exame nao precisa de regra propria.
from app.api.chat import _max_message_length_for_age

logger = structlog.get_logger()
router = APIRouter()


# Marcador explicito que a Atena escreve ao concluir o projeto. Substitui
# a heuristica antiga de procurar "ficha-resumo"/"parabens" no texto.
# Strippado da resposta antes de mandar pro frontend.
_COMPLETION_MARKER = "PROJETO_COMPLETO"

# Regex pra detectar o bloco entregavel [[ ... ]] na resposta. Cada projeto
# (historia, ficha do Pokemon, prompt do site, system prompt) termina com
# o conteudo final entre [[ ]] - se nao tem brackets, projeto nao esta
# pronto de verdade mesmo que o marker apareca.
_BRACKETS_RE = re.compile(r"\[\[([\s\S]+?)\]\]")

# Limite de mensagens por sessao do exame. Lessons usa 30; o exame tem 5-6
# passos com follow-ups e revisao tecnica (no tier 12+), entao 50 da' folga
# sem virar conversa infinita.
_EXAM_MESSAGE_LIMIT = 50


# --- SYSTEM PROMPTS DO EXAME ---
# 4 projetos x 2 idiomas. Placeholder {child_name} preenchido em
# send_exam_message via .format(). Sem outros placeholders nos textos.

_EXAM_PROMPT_PT_6_8 = """Você é a Atena. Sua missão é guiar {child_name} em 5 passos para criar o prompt perfeito para um assistente de histórias.

Tom: amiga especial que sabe tudo sobre tecnologia, frases curtinhas, muita comemoração. Use o nome {child_name} naturalmente.

Passos em ordem (não pule nenhum):
1. Qual é o personagem favorito de {child_name}?
2. Que tipo de história gosta? (aventura, mistério, comédia)
3. Onde acontece a história? (floresta, espaço, escola mágica)
4. Como quer que a Atena conte? (alegre, dramático, engraçado)
5. Junta tudo e escreve o prompt completo numa frase só.

Ao final, escreve o prompt criado por {child_name} entre [[ ]] e diz PROJETO_COMPLETO.

Segurança: nunca peça nome real, escola, endereço, telefone ou foto. Sem violência, sexo, drogas ou política. Se {child_name} sair do assunto, redirecione com carinho de volta pro projeto."""

_EXAM_PROMPT_PT_9_10 = """Você é a Atena. Guie {child_name} em 5 passos para criar um Pokédex com IA.

Tom: amiga descolada que entende muito de tecnologia, usa mecânica de jogo nas explicações. Use o nome {child_name} naturalmente.

Passos em ordem (não pule nenhum):
1. Peça para {child_name} escolher um Pokémon favorito.
2. Instrua a acessar pokeapi.co/api/v2/pokemon/[nome] e colar o JSON aqui.
3. Faça 3 perguntas sobre os dados do JSON (tipos, peso, habilidades).
4. Peça para {child_name} criar uma "ficha do Pokémon" com o que descobriu.
5. Peça para escrever 1 pergunta que gostaria de fazer à API.

Ao final, mostre a ficha completa entre [[ ]] e diz PROJETO_COMPLETO.

Segurança: nunca peça dados pessoais. Sem violência explícita, sexo, drogas ou política. Se sair do assunto, redirecione com gentileza."""

_EXAM_PROMPT_PT_11_12 = """Você é a Atena. Guie {child_name} em 6 passos para criar o prompt de um site com IA.

Tom: amiga inteligente que mostra os bastidores das tecnologias reais. Trate {child_name} como capaz, quase adulto. Use o nome naturalmente.

Passos em ordem (não pule nenhum):
1. Sobre o que é o site? Para quem?
2. Quais seções quer? (início, sobre, galeria, contato)
3. Que estilo visual? (dark, colorido, minimalista)
4. Tem funcionalidade especial? (botão, formulário, animação)
5. Precisa funcionar no celular?
6. Junta tudo num prompt completo com os 6 ingredientes do curso e escreve entre [[ ]].

Ao final, diz PROJETO_COMPLETO.

Segurança: nunca peça dados pessoais. Sem violência explícita, sexo, drogas, ódio ou política partidária. Se sair do assunto, redirecione com naturalidade."""

_EXAM_PROMPT_PT_12_PLUS = """Você é a Atena Mentor, mentora técnica peer-to-peer. {child_name} é dev junior curioso(a).

Tom: par profissional, direta, sem floreio. Use o nome {child_name} quando fizer sentido.

Guie {child_name} em 6 passos para criar um system prompt completo de um agente de IA:
1. Qual problema o agente resolve? Para quem?
2. Qual é a persona e o tom do agente?
3. Quais são as regras operacionais? (o que sempre faz, nunca faz)
4. Qual é o formato das respostas?
5. Dá 2 exemplos de interação (few-shot).
6. Escreve o system prompt completo entre [[ ]].

Avalie tecnicamente o resultado e peça uma revisão antes de finalizar. Quando {child_name} aprovar o prompt final entre [[ ]], diz PROJETO_COMPLETO.

Segurança: nunca peça dados pessoais. Sem violência explícita, sexo, drogas, ódio. Foco em IA/prompts/MCP - se {child_name} pedir stack específica (React, Python), responda em 1-2 frases e redirecione pro projeto."""


# --- VERSOES EN ---

_EXAM_PROMPT_EN_6_8 = """You are Atena. Your mission is to guide {child_name} through 5 steps to create the perfect prompt for a story assistant.

Tone: a special friend who knows everything about tech, short sentences, lots of celebration. Use the name {child_name} naturally.

Steps in order (don't skip any):
1. Who is {child_name}'s favorite character?
2. What kind of story does {child_name} like? (adventure, mystery, comedy)
3. Where does the story happen? (forest, space, magic school)
4. How should Atena tell it? (happy, dramatic, funny)
5. Put it all together and write the full prompt in one sentence.

At the end, write the prompt created by {child_name} between [[ ]] and say PROJETO_COMPLETO.

Safety: never ask for real name, school, address, phone, or photo. No violence, sex, drugs, or politics. If {child_name} goes off topic, gently redirect back to the project."""

_EXAM_PROMPT_EN_9_10 = """You are Atena. Guide {child_name} through 5 steps to build an AI Pokédex.

Tone: a cool friend who knows tech, uses game mechanics in explanations. Use the name {child_name} naturally.

Steps in order (don't skip any):
1. Ask {child_name} to pick a favorite Pokémon.
2. Instruct them to visit pokeapi.co/api/v2/pokemon/[name] and paste the JSON here.
3. Ask 3 questions about the JSON data (types, weight, abilities).
4. Ask {child_name} to create a "Pokémon card" with what they discovered.
5. Ask them to write 1 question they'd like to ask the API.

At the end, show the full card between [[ ]] and say PROJETO_COMPLETO.

Safety: never ask for personal data. No explicit violence, sex, drugs, or politics. If they go off topic, redirect gently."""

_EXAM_PROMPT_EN_11_12 = """You are Atena. Guide {child_name} through 6 steps to write the prompt for an AI-powered website.

Tone: a smart friend who shows the behind the scenes of real technologies. Treat {child_name} as capable, almost adult. Use the name naturally.

Steps in order (don't skip any):
1. What is the site about? For whom?
2. What sections do you want? (home, about, gallery, contact)
3. What visual style? (dark, colorful, minimalist)
4. Any special functionality? (button, form, animation)
5. Does it need to work on mobile?
6. Combine everything into a complete prompt using the 6 ingredients from the course, and write it between [[ ]].

At the end, say PROJETO_COMPLETO.

Safety: never ask for personal data. No explicit violence, sex, drugs, hate, or partisan politics. If the topic drifts, redirect naturally."""

_EXAM_PROMPT_EN_12_PLUS = """You are Atena Mentor, a peer-to-peer technical mentor. {child_name} is a curious junior dev.

Tone: professional peer, direct, no fluff. Use the name {child_name} when it fits naturally.

Guide {child_name} through 6 steps to build a complete system prompt for an AI agent:
1. What problem does the agent solve? For whom?
2. What's the agent's persona and tone?
3. What are the operational rules? (always does, never does)
4. What's the response format?
5. Give 2 example interactions (few-shot).
6. Write the complete system prompt between [[ ]].

Evaluate the result technically and request a revision before finalizing. When {child_name} approves the final prompt between [[ ]], say PROJETO_COMPLETO.

Safety: never ask for personal data. No explicit violence, sex, drugs, or hate. Focus on AI/prompts/MCP — if {child_name} asks about a specific stack (React, Python), answer in 1-2 sentences and redirect back to the project."""


_EXAM_PROMPTS_BY_LOCALE: Dict[str, Dict[str, str]] = {
    "pt": {
        "6-8": _EXAM_PROMPT_PT_6_8,
        "9-10": _EXAM_PROMPT_PT_9_10,
        "11-12": _EXAM_PROMPT_PT_11_12,
        "12+": _EXAM_PROMPT_PT_12_PLUS,
    },
    "en": {
        "6-8": _EXAM_PROMPT_EN_6_8,
        "9-10": _EXAM_PROMPT_EN_9_10,
        "11-12": _EXAM_PROMPT_EN_11_12,
        "12+": _EXAM_PROMPT_EN_12_PLUS,
    },
}


# --- BLOCO DE RITMO ---
# Atena estava despejando todos os passos numa unica resposta (especialmente
# no projeto 11-12 de 6 passos). Esse bloco e' anexado ao final de todos
# os 8 prompts para forcar conducao passo-a-passo. Fica como bloco unico
# em vez de embutido em cada um dos 8 templates - facilita iterar a regra
# sem editar 8 vezes. {child_name} interpolado em runtime.

_PACING_PT = """RITMO (regra mais importante - obedeça sempre):
- UM passo por resposta. Nunca faça 2 perguntas ao mesmo tempo.
- Espere {child_name} responder antes de seguir pro próximo passo.
- Só avance pro próximo passo quando o atual tiver uma resposta clara.
- Se a resposta de {child_name} for vaga ou incompleta, peça mais detalhes antes de avançar.
- NÃO resuma nem liste todos os passos de uma vez. Só faça a pergunta do passo atual e espere."""

_PACING_EN = """PACING (most important rule - always obey):
- ONE step per response. Never ask 2 questions at once.
- Wait for {child_name} to answer before moving to the next step.
- Only move to the next step when the current one has a clear answer.
- If {child_name}'s answer is vague or incomplete, ask for more detail before moving on.
- Do NOT summarize or list all steps upfront. Just ask the current step's question and wait."""


_PACING_BY_LOCALE: Dict[str, str] = {
    "pt": _PACING_PT,
    "en": _PACING_EN,
}


# --- MENSAGENS DE ABERTURA ---
# Antes hardcoded no frontend; agora geradas no backend pra alinhar com
# a faixa etaria + locale + nome da crianca. Placeholder {child_name}.

_EXAM_OPENINGS_BY_LOCALE: Dict[str, Dict[str, str]] = {
    "pt": {
        "6-8": "Oi, {child_name}! Chegou a hora do seu projeto especial! Vamos criar juntos um assistente de histórias do seu jeito. Primeira pergunta: qual é o seu personagem favorito de desenho ou jogo?",
        "9-10": "E aí, {child_name}! Você chegou até aqui — isso é incrível! Agora vamos usar uma API de verdade. Qual é o seu Pokémon favorito?",
        "11-12": "Parabéns, {child_name}! Hora de criar seu site com IA. Vamos usar os 6 ingredientes que você aprendeu. Primeira pergunta: sobre o que é o seu site e para quem é?",
        "12+": "Bem-vindo ao projeto final, {child_name}. Hoje você vai criar um system prompt profissional para um agente de IA real. Primeira decisão: qual problema esse agente vai resolver?",
    },
    "en": {
        "6-8": "Hi {child_name}! Time for your special project! Let's build a story assistant together, your way. First question: who's your favorite character from a cartoon or a game?",
        "9-10": "Hey {child_name}! You made it this far — that's amazing! Now we're going to use a real API. What's your favorite Pokémon?",
        "11-12": "Congrats, {child_name}! Time to build your AI-powered website. We'll use the 6 ingredients you learned. First question: what's your site about, and who is it for?",
        "12+": "Welcome to the final project, {child_name}. Today you'll write a professional system prompt for a real AI agent. First decision: what problem will this agent solve?",
    },
}


def _select_exam_prompt(age: int, locale: str, child_name: str) -> str:
    """System prompt do exame formatado pra (age, locale, child_name).

    Anexa o bloco de RITMO/PACING do mesmo locale ao final, pra Claude
    nao despejar todos os passos numa unica resposta. Ver _PACING_*.
    """
    loc = _normalize_locale(locale)
    group = _select_age_group(age)
    template = _EXAM_PROMPTS_BY_LOCALE[loc][group]
    pacing = _PACING_BY_LOCALE[loc]
    body = template.format(child_name=child_name)
    pacing_body = pacing.format(child_name=child_name)
    return f"{body}\n\n{pacing_body}"


def _select_exam_opening(age: int, locale: str, child_name: str) -> str:
    """Mensagem de abertura formatada pra (age, locale, child_name)."""
    loc = _normalize_locale(locale)
    group = _select_age_group(age)
    template = _EXAM_OPENINGS_BY_LOCALE[loc][group]
    return template.format(child_name=child_name)


def _strip_completion_marker(text: str) -> str:
    """Remove PROJETO_COMPLETO da resposta antes de exibir pra crianca.
    Tolera variacoes de espacamento ao redor."""
    return re.sub(r"\s*" + _COMPLETION_MARKER + r"\s*", " ", text).strip()


@router.post("/start", response_model=ExamStartResponse, status_code=201)
async def start_exam(auth: ChildAuth, db: DBClient, http_request: Request):
    """
    Inicia uma sessão de exame final.
    Verifica se todas as 4 stages foram completadas e devolve mensagem
    de abertura adaptada pela idade/locale da crianca.
    """
    try:
        # Dados da crianca: precisa de age + name pra escolher prompt e
        # formatar a mensagem de abertura.
        child_data = await db.execute_query(
            "SELECT name, age FROM children WHERE id = $1",
            auth.user_id,
        )
        if not child_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )
        child_name = child_data[0]['name']
        child_age = child_data[0]['age']

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

        # Mensagem de abertura adaptada por idade/locale - antes hardcoded
        # no frontend, agora gerada com o nome real da crianca.
        locale = http_request.headers.get("accept-language", "en")
        opening = _select_exam_opening(child_age, locale, child_name)

        logger.info(
            "Exame iniciado",
            child_id=auth.user_id,
            session_id=session_id,
            age=child_age,
            locale=_normalize_locale(locale),
        )

        return ExamStartResponse(
            session_id=session_id,
            started_at=started_at,
            lesson_id=exam_lesson_id,
            opening_message=opening,
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
    db: DBClient,
    http_request: Request,
):
    """
    Envia mensagem na sessão do exame.
    Usa Claude Sonnet com system prompt adaptado pela idade/locale.
    """
    try:
        # Verifica se sessão existe e pertence à criança, e puxa
        # age/name pra escolher o prompt + max-length.
        session_data = await db.execute_query("""
            SELECT cs.id, cs.lesson_id, cs.is_active, l.claude_model,
                   c.age, c.name AS child_name
            FROM chat_sessions cs
            JOIN lessons l ON cs.lesson_id = l.id
            JOIN children c ON cs.child_id = c.id
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

        # Limite de chars dinamico - mesmas thresholds do chat normal.
        content = (request.content or "").strip()
        if not content:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={"error": {"code": "EMPTY_CONTENT", "message": "Mensagem vazia"}}
            )
        max_len = _max_message_length_for_age(session['age'])
        if len(content) > max_len:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={"error": {
                    "code": "CONTENT_TOO_LONG",
                    "message": f"Mensagem excede {max_len} caracteres",
                }}
            )

        # Verifica limite de mensagens (30 máximo)
        message_count = await db.execute_query("""
            SELECT COUNT(*) as count FROM chat_messages
            WHERE session_id = $1
        """, session_id)

        if message_count[0]['count'] >= _EXAM_MESSAGE_LIMIT:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {
                    "code": "MESSAGE_LIMIT",
                    "message": f"Limite de {_EXAM_MESSAGE_LIMIT} mensagens por sessão atingido",
                }}
            )

        # Salva mensagem da criança
        await db.execute_non_query("""
            INSERT INTO chat_messages (session_id, role, content, created_at)
            VALUES ($1, 'child', $2, NOW())
        """, session_id, content)

        # Busca histórico da conversa para o Claude
        conversation_history = await db.execute_query("""
            SELECT role, content FROM chat_messages
            WHERE session_id = $1
            ORDER BY created_at
        """, session_id)

        # Inicializa Claude com modelo específico do exame (Sonnet)
        claude = ClaudeClient()

        # System prompt adaptado por idade + locale, com nome injetado.
        locale = http_request.headers.get("accept-language", "en")
        system_prompt = _select_exam_prompt(session['age'], locale, session['child_name'])

        # Converte histórico para formato do Claude
        claude_messages = []
        for msg in conversation_history[:-1]:  # Exclui a última (já incluída no request)
            role = "user" if msg['role'] == 'child' else "assistant"
            claude_messages.append({"role": role, "content": msg['content']})

        # Chama Claude Sonnet
        response = await claude.client.messages.create(
            model=session['claude_model'],  # claude-sonnet-4-6
            max_tokens=600,  # Maior pra caber prompt entre [[ ]] + revisao tecnica no 12+
            temperature=0.7,
            system=system_prompt,
            messages=claude_messages + [{"role": "user", "content": content}]
        )

        assistant_content = response.content[0].text if response.content else ""

        # Rubric: marcador precisa vir ACOMPANHADO do entregavel entre [[ ]]
        # senao nao conta como completo. Cobre o caso da Atena anunciar fim
        # do projeto sem realmente escrever o prompt/ficha/system prompt
        # final - sintoma comum quando o modelo "alucina conclusao" sem
        # cumprir o passo de entrega.
        marker_present = _COMPLETION_MARKER in assistant_content
        has_brackets = bool(_BRACKETS_RE.search(assistant_content))
        is_complete = marker_present and has_brackets

        # Remove o marcador antes de exibir + salvar - crianca nao precisa
        # ver "PROJETO_COMPLETO" no balao da Atena.
        display_content = _strip_completion_marker(assistant_content)

        # Marker sem entregavel: nudge na voz da propria Atena pra ela
        # voltar e escrever o projeto entre [[ ]] na proxima resposta.
        # A propria mensagem fica visivel pra crianca pra que ela peca
        # a Atena pra finalizar direito.
        if marker_present and not has_brackets:
            normalized_locale = _normalize_locale(locale)
            if normalized_locale == "pt":
                nudge = " (espera, ainda preciso escrever o projeto entre [[ ]] - me peça pra finalizar!)"
            else:
                nudge = " (hold on — I still need to write the project between [[ ]]. Ask me to finalize!)"
            display_content = display_content + nudge
            logger.warning(
                "PROJETO_COMPLETO sem entregavel [[ ]] - bloqueando completion",
                session_id=session_id,
                age=session['age'],
            )

        # Salva resposta do assistente (sem o marker)
        message_result = await db.execute_query("""
            INSERT INTO chat_messages (session_id, role, content, created_at)
            VALUES ($1, 'assistant', $2, NOW())
            RETURNING id
        """, session_id, display_content)

        message_id = message_result[0]['id']

        # Estima step atual baseado no número de mensagens do assistente.
        # Cap em 5 (projeto 6-8/9-10) ou 6 (11-12/12+) - usamos 6 como teto.
        assistant_message_count = await db.execute_query("""
            SELECT COUNT(*) as count FROM chat_messages
            WHERE session_id = $1 AND role = 'assistant'
        """, session_id)

        current_step = min(assistant_message_count[0]['count'], 6)

        logger.info(
            "Mensagem de exame processada",
            session_id=session_id,
            step=current_step,
            complete=is_complete,
            age=session['age'],
        )

        return ExamMessageResponse(
            message_id=message_id,
            assistant_message={"content": display_content},
            current_step=current_step,
            is_complete=is_complete,
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