"""
Utilitários de segurança: autenticação, JWT, hashing.
Implementa autenticação dupla: parent (Supabase) e child (backend).
"""

import jwt
import bcrypt
import structlog
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from passlib.context import CryptContext
from jwt import PyJWKClient

from app.core.config import settings

logger = structlog.get_logger()

# Cliente JWKS singleton (cacheia chaves por 1h internamente).
# PyJWKClient e' mais robusto para ES256 do que python-jose 3.3.0,
# que tem bugs conhecidos de verificacao ECDSA.
_jwks_client: PyJWKClient | None = None


def _get_jwks_client() -> PyJWKClient:
    """Retorna (e inicializa lazy) o cliente JWKS do projeto Supabase."""
    global _jwks_client
    if _jwks_client is None:
        jwks_url = (
            f"{settings.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"
        )
        _jwks_client = PyJWKClient(
            jwks_url,
            cache_keys=True,
            lifespan=3600,  # cache de 1h
        )
        logger.info("JWKS client initialized", url=jwks_url)
    return _jwks_client

# Context para hashing de passwords (PINs)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class AuthError(HTTPException):
    """Exceção customizada para erros de autenticação."""

    def __init__(self, message: str = "Authentication failed"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": {"code": "UNAUTHORIZED", "message": message}}
        )


def hash_pin(pin: str) -> str:
    """
    Gera hash bcrypt de um PIN de 4 dígitos.
    Cost factor 10 é suficiente para PINs.
    """
    return pwd_context.hash(pin)


def verify_pin(pin: str, hashed: str) -> bool:
    """Verifica PIN contra hash bcrypt."""
    return pwd_context.verify(pin, hashed)


def verify_supabase_jwt(token: str) -> Dict[str, Any]:
    """
    Verifica JWT emitido pelo Supabase Auth.
    Tokens Supabase usam ES256 (ECDSA P-256). Usamos PyJWKClient que faz
    o fetch da JWKS, escolhe a chave certa pelo kid do header e cacheia
    automaticamente. Logs estruturados em cada falha pra facilitar debug
    via Railway logs.
    """
    try:
        jwks_client = _get_jwks_client()
        signing_key = jwks_client.get_signing_key_from_jwt(token)

        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["ES256"],
            options={
                "verify_aud": False,  # Supabase nao usa aud padrao
                "verify_iss": False,  # iss varia (ex: /auth/v1 sufixo)
            },
        )

        role = payload.get("role")
        if role != "authenticated":
            logger.warning("JWT role check failed", role=role)
            raise AuthError("Token invalido: role incorreto")

        return payload

    except jwt.ExpiredSignatureError:
        logger.info("JWT expired")
        raise AuthError("Token expirado")
    except jwt.PyJWKClientError as e:
        logger.error("JWKS fetch/parse failed", error=str(e))
        raise AuthError(f"Erro ao buscar chave de verificacao: {str(e)}")
    except jwt.InvalidTokenError as e:
        logger.warning("JWT verification failed", error=str(e))
        raise AuthError(f"Token invalido: {str(e)}")
    except Exception as e:
        # Catch-all defensivo - sem isso uma excecao inesperada vira 500
        # generico no FastAPI; aqui logamos e retornamos 401 explicito.
        logger.exception("Unexpected error in verify_supabase_jwt", error=str(e))
        raise AuthError(f"Falha de autenticacao: {str(e)}")


def create_child_jwt(child_id: str, parent_id: str) -> str:
    """
    Cria JWT específico para criança.
    Separado do Supabase, com TTL configurável e role=child.
    """
    now = datetime.now(timezone.utc)
    exp_time = now + timedelta(hours=settings.child_jwt_ttl_hours)

    payload = {
        "sub": child_id,  # Subject = ID da criança
        "parent_id": parent_id,
        "role": "child",
        "iat": now,
        "exp": exp_time,
        "iss": "aprendizagem-backend"
    }

    return jwt.encode(payload, settings.child_jwt_secret, algorithm="HS256")


def verify_child_jwt(token: str) -> Dict[str, Any]:
    """
    Verifica JWT de criança emitido pelo próprio backend.
    Retorna payload com child_id, parent_id etc.
    """
    try:
        payload = jwt.decode(
            token,
            settings.child_jwt_secret,
            algorithms=["HS256"],
            issuer="aprendizagem-backend"
        )

        # Valida que é token de criança
        if payload.get("role") != "child":
            raise AuthError("Token inválido: não é token de criança")

        return payload
    except jwt.ExpiredSignatureError:
        raise AuthError("Sessão da criança expirada")
    except jwt.InvalidTokenError as e:
        raise AuthError(f"Token de criança inválido: {str(e)}")


def extract_bearer_token(authorization: Optional[str]) -> str:
    """
    Extrai token do header Authorization: Bearer <token>.
    Levanta AuthError se formato inválido.
    """
    if not authorization:
        raise AuthError("Header Authorization obrigatório")

    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise AuthError("Formato deve ser: Bearer <token>")
        return token
    except ValueError:
        raise AuthError("Formato inválido do header Authorization")


def get_current_timestamp() -> datetime:
    """Retorna timestamp atual em UTC para uso consistente."""
    return datetime.now(timezone.utc)