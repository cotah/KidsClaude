"""
Rotas de autenticação: signup/login de pais, login de crianças.
Integração com Supabase Auth para pais e JWT próprio para crianças.
"""

import structlog
from fastapi import APIRouter, HTTPException, Request, status, Depends
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

from app.schemas.auth import (
    ParentSignupRequest, ParentSignupResponse,
    ParentLoginRequest, ParentLoginResponse,
    PasswordResetRequest, PasswordResetConfirm,
    ParentInfo, ChildLoginRequest, ChildLoginDirectRequest,
    ChildLoginResponse, ApiResponse
)
from app.schemas.common import ErrorResponse
from app.core.config import settings
from app.core.dependencies import ParentAuth, DBClient
from app.core.security import hash_pin, verify_pin, create_child_jwt
from app.core.timezone import user_today
from app.db.client import supabase
from app.services.gamification import GamificationService

logger = structlog.get_logger()
router = APIRouter()

# Rate limiter específico para auth.
# storage_uri=redis_url quando Redis disponivel: limites compartilhados
# entre workers e persistem reinicios. Fallback "memory://" em dev/local
# (por-worker, perde-se em restart). SlowAPI faz parse do scheme sozinho.
limiter = Limiter(
    key_func=get_remote_address,
    storage_uri=settings.redis_url or "memory://",
)


@router.post("/parent/signup", response_model=ParentSignupResponse, status_code=201)
@limiter.limit("5/minute")
async def parent_signup(request: Request, payload: ParentSignupRequest, db: DBClient):
    """
    Cria conta de pai via Supabase Auth.
    Registra também na tabela parents para metadados.

    Nota: o parametro `request: Request` (Starlette) e' obrigatorio para o
    SlowAPI extrair o IP do cliente; o body do request vai em `payload`.
    """
    try:
        # Tenta criar usuário no Supabase
        auth_response = supabase.auth.sign_up({
            "email": payload.email,
            "password": payload.password
        })

        if auth_response.user is None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {"code": "EMAIL_EXISTS", "message": "Email já cadastrado"}}
            )

        user_id = auth_response.user.id

        # Insere na tabela parents - idempotente para signup repetido apos
        # falha intermediaria (ex: rede caiu antes da resposta).
        await db.execute_non_query(
            """
            INSERT INTO parents (id, email, display_name)
            VALUES ($1, $2, $3)
            ON CONFLICT (id) DO NOTHING
            """,
            user_id, payload.email, payload.display_name,
        )

        logger.info("Pai cadastrado", user_id=user_id, email=payload.email)

        return ParentSignupResponse(
            parent_id=user_id,
            access_token=auth_response.session.access_token
        )

    except HTTPException:
        raise
    except Exception as e:
        # Supabase Auth lança exceções com mensagens em texto livre; precisamos
        # inspecionar para distinguir entrada invalida (4xx) de erro interno (5xx).
        # Sem isso, o frontend mostra "Erro interno" mesmo quando o problema e'
        # so o email rejeitado por Supabase ou rate limit estourado.
        err_msg = str(e).lower()
        logger.error("Erro no signup", error=str(e))

        if "rate limit" in err_msg:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail={"error": {"code": "RATE_LIMITED", "message": "Muitas tentativas. Aguarde um momento."}}
            )
        if "invalid" in err_msg:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={"error": {"code": "INVALID_EMAIL", "message": "Email invalido"}}
            )

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": {"code": "SIGNUP_ERROR", "message": "Erro interno"}}
        )


@router.post("/parent/login", response_model=ParentLoginResponse)
@limiter.limit("5/minute")
async def parent_login(request: Request, payload: ParentLoginRequest, db: DBClient):
    """
    Autentica pai via Supabase Auth e sincroniza registro local.

    Apos auth bem-sucedida, garante que o pai exista na tabela `parents`
    do Postgres do Railway. Sem isso, GET /v1/auth/parent/me devolve 404
    e POST /v1/children quebra a FK ao tentar associar o filho ao pai
    (parent_id). UPSERT idempotente: cria se nao existir, ignora se existir.

    `request: Request` (Starlette) e' exigido pelo SlowAPI; o body fica em `payload`.
    """
    try:
        auth_response = supabase.auth.sign_in_with_password({
            "email": payload.email,
            "password": payload.password
        })

        if auth_response.user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={"error": {"code": "INVALID_CREDENTIALS", "message": "Email ou senha incorretos"}}
            )

        user_id = auth_response.user.id
        email = auth_response.user.email
        # display_name vem do user_metadata se foi setado no signup; pode faltar.
        user_metadata = getattr(auth_response.user, "user_metadata", None) or {}
        display_name = (
            user_metadata.get("display_name") if isinstance(user_metadata, dict) else None
        )

        # UPSERT do pai no DB local. Mantemos display_name existente caso ja
        # esteja preenchido (so atualiza email se mudou, atualiza updated_at).
        await db.execute_non_query(
            """
            INSERT INTO parents (id, email, display_name)
            VALUES ($1, $2, $3)
            ON CONFLICT (id) DO UPDATE
            SET email = EXCLUDED.email,
                display_name = COALESCE(parents.display_name, EXCLUDED.display_name),
                updated_at = NOW()
            """,
            user_id, email, display_name,
        )

        logger.info("Login pai (synced to local DB)", user_id=user_id, email=email)

        return ParentLoginResponse(
            access_token=auth_response.session.access_token,
            expires_in=auth_response.session.expires_in or 604800  # 7 dias default
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro no login", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": {"code": "INVALID_CREDENTIALS", "message": "Email ou senha incorretos"}}
        )


@router.post("/parent/logout", status_code=204)
async def parent_logout(auth: ParentAuth):
    """
    Logout do pai (invalida token no Supabase).
    """
    try:
        supabase.auth.sign_out()
        logger.info("Logout pai", user_id=auth.user_id)
        return {"ok": True}

    except Exception as e:
        logger.error("Erro no logout", error=str(e))
        # Não falha - logout deve sempre funcionar
        return {"ok": True}


@router.post("/parent/password-reset/request", response_model=ApiResponse)
@limiter.limit("3/minute")
async def password_reset_request(request: Request, payload: PasswordResetRequest):
    """
    Solicita reset de senha via email.
    Sempre retorna 200 para não vazar informação de emails cadastrados.

    `request: Request` (Starlette) e' exigido pelo SlowAPI; o body fica em `payload`.
    """
    try:
        supabase.auth.reset_password_email(payload.email)
        logger.info("Reset solicitado", email=payload.email)

    except Exception as e:
        logger.warning("Erro no reset request", email=payload.email, error=str(e))
        # Não propaga erro por segurança

    return {"ok": True}


@router.post("/parent/password-reset/confirm", response_model=ApiResponse)
async def password_reset_confirm(request: PasswordResetConfirm):
    """
    Confirma reset de senha com token recebido por email.
    """
    try:
        # Supabase confirma via token
        auth_response = supabase.auth.verify_otp({
            "token": request.token,
            "type": "recovery",
            "password": request.new_password
        })

        if not auth_response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"error": {"code": "INVALID_TOKEN", "message": "Token inválido ou expirado"}}
            )

        logger.info("Password reset confirmado", user_id=auth_response.user.id)
        return {"ok": True}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro no reset confirm", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": {"code": "INVALID_TOKEN", "message": "Token inválido ou expirado"}}
        )


@router.get("/parent/me", response_model=ParentInfo)
async def get_parent_info(auth: ParentAuth, db: DBClient):
    """
    Retorna informações do pai autenticado.
    """
    try:
        parent_data = await db.execute_query(
            "SELECT id, email, display_name FROM parents WHERE id = $1",
            auth.user_id
        )

        if not parent_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Pai não encontrado"}}
            )

        parent = parent_data[0]
        return ParentInfo(
            id=parent['id'],
            email=parent['email'],
            display_name=parent['display_name']
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar pai", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/child/login-direct", response_model=ChildLoginResponse)
@limiter.limit("5/minute")
async def child_login_direct(request: Request, payload: ChildLoginDirectRequest, db: DBClient):
    """
    Login direto da crianca por username + PIN, sem precisar do device do
    pai logado. Resposta no mesmo formato de child_login pra reuso de
    cookie/session no frontend.

    Mensagem generica em qualquer falha (username inexistente OU PIN errado)
    pra nao vazar quais usernames existem. Rate limit 5/min por IP.
    """
    generic_unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail={"error": {"code": "INVALID_CREDENTIALS", "message": "Utilizador ou PIN incorretos"}},
    )
    try:
        child_data = await db.execute_query(
            """
            SELECT id, parent_id, name, age, avatar_id, pin_hash,
                   xp, level, streak_days, daily_limit_minutes, last_active_date
            FROM children
            WHERE username = $1
            """,
            payload.username,
        )

        if not child_data:
            raise generic_unauthorized

        child = child_data[0]

        # PIN obrigatorio nesse fluxo (sem o pai por perto pra autorizar
        # crianca sem PIN). Crianca sem pin_hash nao consegue login direto.
        if not child['pin_hash']:
            raise generic_unauthorized

        if not verify_pin(payload.pin, child['pin_hash']):
            raise generic_unauthorized

        child_token = create_child_jwt(child['id'], child['parent_id'])

        # Streak: login conta como atividade do dia. Mantemos o trigger de
        # /complete tambem - update_streak e' idempotente por dia (se last_active=hoje
        # nao mexe). Falha nao bloqueia login.
        new_streak = int(child.get('streak_days') or 0)
        try:
            today = user_today(request)
            new_streak = await GamificationService(db).update_streak(child['id'], today=today)
        except Exception as e:
            logger.warning("update_streak falhou no login direto", error=str(e), child_id=child['id'])

        logger.info(
            "Login direto crianca",
            child_id=child['id'],
            username=payload.username,
        )

        return ChildLoginResponse(
            access_token=child_token,
            expires_in=14400,  # 4 horas
            child={
                "id": child['id'],
                "name": child['name'],
                "age": child['age'],
                "avatar_id": child['avatar_id'],
                "xp": int(child.get('xp') or 0),
                "level": int(child.get('level') or 1),
                "streak_days": new_streak,
                "daily_limit_minutes": int(child.get('daily_limit_minutes') or 30),
                "last_active_date": (
                    child['last_active_date'].isoformat()
                    if child.get('last_active_date') else None
                ),
                "pin_set": True,
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro no login direto crianca", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/child/login", response_model=ChildLoginResponse)
@limiter.limit("10/minute")
async def child_login(request: Request, payload: ChildLoginRequest, auth: ParentAuth, db: DBClient):
    """
    Autentica criança via PIN e emite JWT próprio.
    Pai deve estar logado para autorizar login da criança.

    `request: Request` (Starlette) e' exigido pelo SlowAPI; o body fica em `payload`.
    """
    try:
        # Verifica se criança pertence ao pai. Buscamos os campos completos
        # (xp/level/streak/etc.) para devolver na resposta de login, evitando
        # que o frontend trabalhe com undefined no header e barra de XP.
        child_data = await db.execute_query(
            """
            SELECT id, parent_id, name, age, avatar_id, pin_hash,
                   xp, level, streak_days, daily_limit_minutes, last_active_date
            FROM children
            WHERE id = $1
            """,
            payload.child_id
        )

        if not child_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        child = child_data[0]

        # Verifica propriedade (pai é o dono da criança)
        if child['parent_id'] != auth.user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={"error": {"code": "FORBIDDEN", "message": "Acesso negado"}}
            )

        # Verifica PIN se configurado
        if child['pin_hash']:
            if not payload.pin:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail={"error": {"code": "PIN_REQUIRED", "message": "PIN obrigatório"}}
                )

            if not verify_pin(payload.pin, child['pin_hash']):
                # TODO: implementar bloqueio após 3 tentativas erradas
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail={"error": {"code": "INVALID_PIN", "message": "PIN incorreto"}}
                )

        # Cria JWT da criança
        child_token = create_child_jwt(child['id'], auth.user_id)

        # Streak: login conta como atividade do dia. Idempotente por data.
        # Falha nao bloqueia login.
        new_streak = int(child.get('streak_days') or 0)
        try:
            today = user_today(request)
            new_streak = await GamificationService(db).update_streak(child['id'], today=today)
        except Exception as e:
            logger.warning("update_streak falhou no login crianca", error=str(e), child_id=child['id'])

        logger.info("Login criança", child_id=child['id'], parent_id=auth.user_id)

        return ChildLoginResponse(
            access_token=child_token,
            expires_in=14400,  # 4 horas em segundos
            child={
                "id": child['id'],
                "name": child['name'],
                "age": child['age'],
                "avatar_id": child['avatar_id'],
                "xp": int(child.get('xp') or 0),
                "level": int(child.get('level') or 1),
                "streak_days": new_streak,
                "daily_limit_minutes": int(child.get('daily_limit_minutes') or 30),
                "last_active_date": (
                    child['last_active_date'].isoformat()
                    if child.get('last_active_date') else None
                ),
                "pin_set": bool(child.get('pin_hash')),
            }
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro no login criança", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)