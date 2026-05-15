"""
Rotas para chat com Claude via prompts guiados.
Sistema de sessões, mensagens e moderação.
"""

import re
import json
import structlog
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, HTTPException, status, Query

from app.schemas.chat import (
    ChatSessionCreateRequest, ChatSessionCreateResponse,
    MessageSendRequest, MessageSendResponse, AssistantMessage,
    ChatSessionDetailResponse, ChatSession, ChatMessage,
    ChatSessionEndResponse, SessionListResponse, SessionListItem,
    HeartbeatRequest, HeartbeatResponse
)
from app.core.dependencies import ChildAuth, ParentAuth, AnyAuth, DBClient
from app.services.claude_client import ClaudeClient
from app.services.moderation import ModerationService, InputModerationError
from datetime import datetime, date
import pytz

logger = structlog.get_logger()
router = APIRouter()


@router.post("/sessions", response_model=ChatSessionCreateResponse, status_code=201)
async def create_chat_session(
    request: ChatSessionCreateRequest,
    auth: ChildAuth,
    db: DBClient
):
    """
    Cria nova sessão de chat vinculada a uma lição.
    """
    try:
        # Verifica se lição existe
        lesson_data = await db.execute_query(
            "SELECT id, title, description FROM lessons WHERE id = $1 AND is_active = true",
            request.lesson_id
        )

        if not lesson_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Lição não encontrada"}}
            )

        # Cria sessão
        result = await db.execute_query("""
            INSERT INTO chat_sessions (child_id, lesson_id, started_at)
            VALUES ($1, $2, NOW())
            RETURNING id, started_at
        """, auth.user_id, request.lesson_id)

        session_data = result[0]

        logger.info("Sessão de chat criada", child_id=auth.user_id,
                   lesson_id=request.lesson_id, session_id=session_data['id'])

        return ChatSessionCreateResponse(
            session_id=session_data['id'],
            started_at=session_data['started_at']
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao criar sessão", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/sessions/{session_id}", response_model=ChatSessionDetailResponse)
async def get_chat_session(session_id: str, auth: AnyAuth, db: DBClient):
    """
    Retorna detalhes de uma sessão e suas mensagens.
    Criança só vê próprias sessões, pai vê de todos os filhos.
    """
    try:
        # Query com diferentes filtros baseado no role
        if auth.is_child:
            session_filter = "s.child_id = $2"
            filter_param = auth.user_id
        else:  # parent
            session_filter = "c.parent_id = $2"
            filter_param = auth.user_id

        # Busca sessão
        session_data = await db.execute_query(f"""
            SELECT s.id, s.child_id, s.lesson_id, s.started_at, s.ended_at,
                   s.safety_status, s.summary, s.message_count
            FROM chat_sessions s
            JOIN children c ON s.child_id = c.id
            WHERE s.id = $1 AND {session_filter}
        """, session_id, filter_param)

        if not session_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Sessão não encontrada"}}
            )

        session = session_data[0]

        # Busca mensagens da sessão
        messages_data = await db.execute_query("""
            SELECT id, role, content, template_id, moderation_status,
                   moderation_reason, created_at
            FROM chat_messages
            WHERE session_id = $1
            ORDER BY created_at ASC
        """, session_id)

        messages = [ChatMessage(**msg) for msg in messages_data]

        session_obj = ChatSession(**session)

        return ChatSessionDetailResponse(
            session=session_obj,
            messages=messages
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar sessão", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/sessions/{session_id}/messages", response_model=MessageSendResponse)
async def send_message(
    session_id: str,
    request: MessageSendRequest,
    auth: ChildAuth,
    db: DBClient
):
    """
    Envia mensagem na sessão via prompt template.
    Sistema completo de moderação input/output.
    """
    try:
        # Verifica se sessão pertence à criança
        session_data = await db.execute_query("""
            SELECT s.id, s.child_id, s.lesson_id, s.safety_status, s.message_count,
                   l.title, l.description, l.claude_model, c.age
            FROM chat_sessions s
            JOIN lessons l ON s.lesson_id = l.id
            JOIN children c ON s.child_id = c.id
            WHERE s.id = $1 AND s.child_id = $2 AND s.ended_at IS NULL
        """, session_id, auth.user_id)

        if not session_data:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={"error": {"code": "FORBIDDEN", "message": "Sessão não acessível"}}
            )

        session = session_data[0]

        # Verifica limite de mensagens por sessão
        if session['message_count'] >= 30:  # MAX_MESSAGES_PER_SESSION
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail={"error": {"code": "RATE_LIMITED", "message": "Limite de mensagens atingido"}}
            )

        # Decide a fonte do conteudo: template (curado) ou texto livre.
        # Texto livre passa por moderacao COMPLETA; template tem bypass de
        # blocklist porque ja' foi curado por adultos.
        message_content: str
        template_id_for_db: Optional[str]
        bypass = False

        if request.template_id:
            # Modo template: busca, processa slots se houver.
            template_data = await db.execute_query("""
                SELECT id, label, template, slots, age_band
                FROM prompt_templates
                WHERE id = $1
            """, request.template_id)

            if not template_data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={"error": {"code": "NOT_FOUND", "message": "Template não encontrado"}}
                )

            template = template_data[0]
            message_content = template['template']
            if template['slots'] and request.slots:
                message_content = await _process_template_slots(
                    template['template'],
                    template['slots'],
                    request.slots,
                )
            template_id_for_db = template['id']
            bypass = True  # Texto curado, pula blocklist
        elif request.content:
            # Modo texto livre: usa direto, sem bypass.
            content = request.content.strip()
            if not content:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail={"error": {"code": "EMPTY_CONTENT", "message": "Mensagem vazia"}}
                )
            message_content = content
            template_id_for_db = None
            bypass = False  # Texto livre da crianca - moderacao completa
        else:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={"error": {"code": "MISSING_INPUT", "message": "template_id ou content obrigatorio"}}
            )

        # MODERAÇÃO DE INPUT (blocklist depende do tipo da fonte).
        try:
            moderation = ModerationService()
            await moderation.moderate_input(message_content, bypass_blocklist=bypass)
        except InputModerationError as e:
            # Registra mensagem bloqueada (template_id_for_db = None pra texto livre)
            await db.execute_non_query("""
                INSERT INTO chat_messages (session_id, role, content, template_id, moderation_status, moderation_reason)
                VALUES ($1, 'child', $2, $3, 'blocked', $4)
            """, session_id, message_content, template_id_for_db, e.reason)

            # Registra evento de segurança
            await _log_safety_event(db, auth.user_id, session_id, 'input_blocked', {
                'reason': e.reason,
                'category': e.category,
                'content': message_content[:100]
            })

            # Verifica limite de 3 bloqueios
            await _check_session_safety_limit(db, session_id)

            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"error": {"code": "INPUT_BLOCKED", "message": e.reason}}
            )

        # Registra mensagem da criança (template_id_for_db = None pra texto livre)
        await db.execute_non_query("""
            INSERT INTO chat_messages (session_id, role, content, template_id, moderation_status)
            VALUES ($1, 'child', $2, $3, 'passed')
        """, session_id, message_content, template_id_for_db)

        # Chama Claude
        claude = ClaudeClient()
        try:
            assistant_response = await claude.chat_with_child(
                message=message_content,
                lesson_title=session['title'],
                lesson_summary=session['description'],
                child_age=session['age'],
                claude_model=session['claude_model']
            )
        except Exception as e:
            logger.error("Erro na chamada Claude", error=str(e))
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail={"error": {"code": "CLAUDE_UNAVAILABLE", "message": "Serviço temporariamente indisponível"}}
            )

        # MODERAÇÃO DE OUTPUT
        is_safe, filtered_response, block_reason = await moderation.moderate_output(assistant_response)

        moderation_status = 'passed' if is_safe else 'blocked'
        final_response = assistant_response if is_safe else filtered_response

        # Registra resposta do Claude
        message_result = await db.execute_query("""
            INSERT INTO chat_messages (session_id, role, content, moderation_status, moderation_reason)
            VALUES ($1, 'assistant', $2, $3, $4)
            RETURNING id
        """, session_id, final_response, moderation_status, block_reason)

        # Atualiza contador de mensagens
        await db.execute_non_query("""
            UPDATE chat_sessions SET message_count = message_count + 2 WHERE id = $1
        """, session_id)

        # Se output foi bloqueado, registra evento
        if not is_safe:
            await _log_safety_event(db, auth.user_id, session_id, 'output_blocked', {
                'reason': block_reason,
                'original_content': assistant_response[:100],
                'filtered_content': final_response
            })

            # Atualiza safety status da sessão
            await db.execute_non_query("""
                UPDATE chat_sessions
                SET safety_status = CASE
                    WHEN safety_status = 'green' THEN 'yellow'
                    ELSE 'red'
                END
                WHERE id = $1
            """, session_id)

            await _check_session_safety_limit(db, session_id)

        logger.info("Mensagem enviada", child_id=auth.user_id, session_id=session_id,
                   input_safe=True, output_safe=is_safe)

        return MessageSendResponse(
            message_id=message_result[0]['id'],
            assistant_message=AssistantMessage(
                content=final_response,
                moderation_status=moderation_status
            )
        )

    except HTTPException:
        raise
    except Exception as e:
        # logger.exception inclui traceback - critico pra diagnosticar erros
        # do Claude/moderacao em producao. detail.error.message inclui o tipo
        # da exception pra o frontend nao mostrar so' "Erro desconhecido".
        logger.exception("Erro ao enviar mensagem", error=str(e), error_type=type(e).__name__)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": {
                "code": "MESSAGE_SEND_ERROR",
                "message": f"Falha ao processar mensagem: {type(e).__name__}",
            }},
        )


@router.post("/sessions/{session_id}/end", response_model=ChatSessionEndResponse)
async def end_chat_session(session_id: str, auth: ChildAuth, db: DBClient):
    """
    Encerra sessão de chat e gera resumo.
    """
    try:
        # Verifica propriedade
        session_data = await db.execute_query("""
            SELECT id, child_id, safety_status FROM chat_sessions
            WHERE id = $1 AND child_id = $2 AND ended_at IS NULL
        """, session_id, auth.user_id)

        if not session_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Sessão não encontrada"}}
            )

        # Busca mensagens para gerar resumo
        messages_data = await db.execute_query("""
            SELECT role, content FROM chat_messages
            WHERE session_id = $1 AND moderation_status = 'passed'
            ORDER BY created_at
        """, session_id)

        # Gera resumo
        claude = ClaudeClient()
        try:
            summary = await claude.generate_session_summary(messages_data)
        except Exception as e:
            logger.warning("Falha ao gerar resumo", error=str(e))
            summary = "Conversa educacional realizada."

        # Encerra sessão
        await db.execute_non_query("""
            UPDATE chat_sessions
            SET ended_at = NOW(), summary = $1
            WHERE id = $2
        """, summary, session_id)

        logger.info("Sessão encerrada", child_id=auth.user_id, session_id=session_id)

        return ChatSessionEndResponse(
            summary=summary,
            safety_status=session_data[0]['safety_status']
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao encerrar sessão", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/children/{child_id}/sessions", response_model=SessionListResponse)
async def list_child_sessions(
    child_id: str,
    auth: ParentAuth,
    db: DBClient,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0)
):
    """
    Lista sessões de chat de uma criança (para pais).
    """
    try:
        # Verifica propriedade
        child_data = await db.execute_query(
            "SELECT id FROM children WHERE id = $1 AND parent_id = $2",
            child_id, auth.user_id
        )

        if not child_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        # Busca sessões
        sessions_data = await db.execute_query("""
            SELECT s.id, s.lesson_id, l.title as lesson_title, s.started_at,
                   s.ended_at, s.safety_status, s.summary, s.message_count
            FROM chat_sessions s
            JOIN lessons l ON s.lesson_id = l.id
            WHERE s.child_id = $1
            ORDER BY s.started_at DESC
            LIMIT $2 OFFSET $3
        """, child_id, limit, offset)

        # Conta total
        total_result = await db.execute_query(
            "SELECT COUNT(*) as total FROM chat_sessions WHERE child_id = $1",
            child_id
        )
        total = total_result[0]['total']

        sessions = [SessionListItem(**session) for session in sessions_data]

        return SessionListResponse(
            sessions=sessions,
            total=total,
            limit=limit,
            offset=offset
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao listar sessões", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/usage/heartbeat", response_model=HeartbeatResponse)
async def usage_heartbeat(request: HeartbeatRequest, auth: ChildAuth, db: DBClient):
    """
    Registra tempo de uso ativo da criança.
    Verifica limite diário e bloqueia se necessário.
    """
    try:
        # Data atual no timezone configurado
        timezone = pytz.timezone("America/Sao_Paulo")
        today = datetime.now(timezone).date()

        # Busca limite diário da criança
        child_data = await db.execute_query(
            "SELECT daily_limit_minutes FROM children WHERE id = $1",
            auth.user_id
        )

        if not child_data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

        daily_limit = child_data[0]['daily_limit_minutes']

        # Atualiza uso diário
        minutes_to_add = request.seconds / 60.0

        result = await db.execute_query("""
            INSERT INTO daily_usage (child_id, usage_date, minutes_used)
            VALUES ($1, $2, $3)
            ON CONFLICT (child_id, usage_date)
            DO UPDATE SET minutes_used = daily_usage.minutes_used + $3, updated_at = NOW()
            RETURNING minutes_used
        """, auth.user_id, today, minutes_to_add)

        current_minutes = result[0]['minutes_used']
        is_blocked = current_minutes >= daily_limit

        logger.info("Heartbeat registrado", child_id=auth.user_id,
                   minutes_today=current_minutes, limit=daily_limit, blocked=is_blocked)

        return HeartbeatResponse(
            minutes_today=int(current_minutes),
            limit=daily_limit,
            blocked=is_blocked
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro no heartbeat", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Helper functions

async def _process_template_slots(template: str, slot_definitions: List[Dict], slot_values: Dict[str, str]) -> str:
    """Processa template substituindo slots por valores validados."""
    processed = template

    for slot_def in slot_definitions:
        slot_name = slot_def['name']
        max_length = slot_def.get('max_length', 30)
        allowed_chars = slot_def.get('allowed_chars', '^[A-Za-zÀ-ÿ0-9 ]+$')

        if slot_name in slot_values:
            value = slot_values[slot_name].strip()

            # Validações
            if len(value) > max_length:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail={"error": {"code": "VALIDATION_ERROR", "message": f"Slot '{slot_name}' muito longo"}}
                )

            if not re.match(allowed_chars, value):
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail={"error": {"code": "VALIDATION_ERROR", "message": f"Caracteres inválidos em '{slot_name}'"}}
                )

            processed = processed.replace(f"{{{{{slot_name}}}}}", value)

    return processed


async def _log_safety_event(db: DBClient, child_id: str, session_id: str, kind: str, details: Dict[str, Any]):
    """Registra evento de segurança."""
    await db.execute_non_query("""
        INSERT INTO child_safety_events (child_id, session_id, kind, details)
        VALUES ($1, $2, $3, $4)
    """, child_id, session_id, kind, details)


async def _check_session_safety_limit(db: DBClient, session_id: str):
    """
    Verifica se sessão atingiu 3 bloqueios e a encerra se necessário.
    """
    # Conta eventos de bloqueio na sessão
    events_count = await db.execute_query("""
        SELECT COUNT(*) as count FROM child_safety_events
        WHERE session_id = $1 AND kind IN ('input_blocked', 'output_blocked')
    """, session_id)

    if events_count[0]['count'] >= 3:
        # Encerra sessão e marca como red
        await db.execute_non_query("""
            UPDATE chat_sessions
            SET ended_at = NOW(), safety_status = 'red'
            WHERE id = $1
        """, session_id)

        # Registra evento de encerramento
        session_data = await db.execute_query(
            "SELECT child_id FROM chat_sessions WHERE id = $1",
            session_id
        )

        if session_data:
            await _log_safety_event(db, session_data[0]['child_id'], session_id, 'session_terminated', {
                'reason': 'Três bloqueios na mesma sessão',
                'automatic': True
            })

        logger.warning("Sessão encerrada por segurança", session_id=session_id)