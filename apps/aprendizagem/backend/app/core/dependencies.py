"""
Dependências do FastAPI: autenticação, rate limiting, db connections.
Define decoradores que serão injetados nas rotas para validação.
"""

from typing import Annotated, Dict, Any
from fastapi import Depends, Header, HTTPException, Request, status
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from app.core.config import settings
from app.core.security import (
    extract_bearer_token,
    verify_supabase_jwt,
    verify_child_jwt,
    AuthError
)
from app.db.client import get_db_client

# Rate limiter global
limiter = Limiter(key_func=get_remote_address)


class AuthContext:
    """Contexto de autenticação com informações do usuário atual."""

    def __init__(self, user_id: str, role: str, raw_payload: Dict[str, Any]):
        self.user_id = user_id
        self.role = role  # "parent" ou "child"
        self.raw_payload = raw_payload

    @property
    def is_parent(self) -> bool:
        return self.role == "parent"

    @property
    def is_child(self) -> bool:
        return self.role == "child"

    @property
    def parent_id(self) -> str:
        """
        Retorna ID do pai responsável.
        Para parent: é o próprio ID. Para child: é parent_id do payload.
        """
        if self.is_parent:
            return self.user_id
        elif self.is_child:
            return self.raw_payload["parent_id"]
        else:
            raise ValueError("Role inválido")

    @property
    def child_id(self) -> str | None:
        """Retorna ID da criança se autenticado como child, senão None."""
        return self.user_id if self.is_child else None


async def get_current_user_parent(
    authorization: Annotated[str | None, Header()] = None,
    db = Depends(get_db_client),
) -> AuthContext:
    """
    Dependency: verifica JWT de pai (Supabase) E garante que o registro
    do pai exista na tabela local `parents` (auto-heal).

    Sem o auto-heal, qualquer pai que se cadastrou via Supabase mas nao
    chegou a inserir no DB local quebra todas as rotas que dependem da
    FK parent_id (POST /v1/children, GET /v1/auth/parent/me, etc).
    O UPSERT com ON CONFLICT DO NOTHING e' barato e idempotente.
    """
    try:
        token = extract_bearer_token(authorization)
        payload = verify_supabase_jwt(token)

        user_id = payload["sub"]
        email = payload.get("email") or ""

        # Auto-heal: cria registro local se ainda nao existir.
        await db.execute_non_query(
            """
            INSERT INTO parents (id, email, display_name)
            VALUES ($1, $2, NULL)
            ON CONFLICT (id) DO NOTHING
            """,
            user_id, email,
        )

        return AuthContext(user_id=user_id, role="parent", raw_payload=payload)

    except AuthError as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": {"code": "UNAUTHORIZED", "message": "Falha na autenticação do responsável"}}
        )


async def get_current_user_child(
    authorization: Annotated[str | None, Header()] = None
) -> AuthContext:
    """
    Dependency: verifica JWT de criança (backend).
    Usado em rotas que exigem autenticação de criança.
    """
    try:
        token = extract_bearer_token(authorization)
        payload = verify_child_jwt(token)

        child_id = payload["sub"]
        return AuthContext(user_id=child_id, role="child", raw_payload=payload)

    except AuthError as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": {"code": "UNAUTHORIZED", "message": "Sessão da criança inválida"}}
        )


async def get_current_user_any(
    authorization: Annotated[str | None, Header()] = None,
    db = Depends(get_db_client),
) -> AuthContext:
    """
    Dependency: aceita JWT de pai OU criança.
    Usado em rotas que podem ser acessadas por ambos (ex: GET /lessons).
    Aplica o mesmo auto-heal de parents quando o token e' de pai.
    """
    try:
        token = extract_bearer_token(authorization)

        # Tenta primeiro como parent, depois como child
        try:
            payload = verify_supabase_jwt(token)
            user_id = payload["sub"]
            email = payload.get("email") or ""
            await db.execute_non_query(
                """
                INSERT INTO parents (id, email, display_name)
                VALUES ($1, $2, NULL)
                ON CONFLICT (id) DO NOTHING
                """,
                user_id, email,
            )
            return AuthContext(user_id=user_id, role="parent", raw_payload=payload)
        except AuthError:
            # Se falhar como parent, tenta como child
            payload = verify_child_jwt(token)
            return AuthContext(user_id=payload["sub"], role="child", raw_payload=payload)

    except AuthError as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": {"code": "UNAUTHORIZED", "message": "Autenticação inválida"}}
        )


def check_daily_limit(child_id: str):
    """
    Middleware dependency: verifica se criança atingiu limite diário.
    Levanta exceção se bloqueada; usada em rotas de criança que consomem tempo.
    """
    # TODO: implementar verificação de limite diário
    # Por ora, retorna sem bloquear (será implementado no service)
    pass


# Dependencies aliases para uso mais limpo
ParentAuth = Annotated[AuthContext, Depends(get_current_user_parent)]
ChildAuth = Annotated[AuthContext, Depends(get_current_user_child)]
AnyAuth = Annotated[AuthContext, Depends(get_current_user_any)]
DBClient = Annotated[Any, Depends(get_db_client)]