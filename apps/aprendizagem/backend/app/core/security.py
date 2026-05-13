"""
Utilitários de segurança: autenticação, JWT, hashing.
Implementa autenticação dupla: parent (Supabase) e child (backend).
"""

import time
import jwt
import bcrypt
import httpx
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from passlib.context import CryptContext
from jose import jwt as jose_jwt
from jose.exceptions import ExpiredSignatureError as JoseExpiredSignatureError
from jose.exceptions import JWTError as JoseJWTError

from app.core.config import settings

# Cache do JWKS publico do Supabase: mapeia URL -> (timestamp_monotonic, kid_to_jwk).
# JWKS muda raramente (rotacao de chaves), entao 1h de TTL e' seguro.
_JWKS_CACHE: dict[str, tuple[float, dict[str, dict]]] = {}
_JWKS_TTL_SECONDS = 3600

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


def _get_jwks() -> dict[str, dict]:
    """
    Busca (ou retorna do cache) o JWKS publico do projeto Supabase.
    Endpoint padrao: <supabase_url>/auth/v1/.well-known/jwks.json
    """
    jwks_url = f"{settings.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"
    now = time.monotonic()
    cached = _JWKS_CACHE.get(jwks_url)
    if cached and (now - cached[0]) < _JWKS_TTL_SECONDS:
        return cached[1]

    response = httpx.get(jwks_url, timeout=5.0)
    response.raise_for_status()
    data = response.json()
    keys_by_kid = {
        key["kid"]: key for key in data.get("keys", []) if "kid" in key
    }
    _JWKS_CACHE[jwks_url] = (now, keys_by_kid)
    return keys_by_kid


def verify_supabase_jwt(token: str) -> Dict[str, Any]:
    """
    Verifica JWT emitido pelo Supabase Auth.
    Tokens recentes do Supabase usam ES256 (ECDSA P-256, chave assimetrica);
    a chave publica vem do endpoint JWKS publico do projeto. O secret
    simetrico antigo (SUPABASE_JWT_SECRET / HS256) nao valida ES256.
    """
    try:
        # Le o header sem verificar para descobrir qual kid foi usado.
        header = jose_jwt.get_unverified_header(token)
        kid = header.get("kid")
        if not kid:
            raise AuthError("Token sem kid no header")

        jwks = _get_jwks()
        key_data = jwks.get(kid)
        if not key_data:
            # kid desconhecido pode ser cache stale apos rotacao - retenta uma vez.
            _JWKS_CACHE.clear()
            jwks = _get_jwks()
            key_data = jwks.get(kid)
            if not key_data:
                raise AuthError(f"Chave publica nao encontrada para kid {kid}")

        payload = jose_jwt.decode(
            token,
            key_data,
            algorithms=["ES256"],
            options={"verify_aud": False},  # Supabase nao usa aud no padrao
        )

        if payload.get("role") != "authenticated":
            raise AuthError("Token invalido: role incorreto")

        return payload
    except JoseExpiredSignatureError:
        raise AuthError("Token expirado")
    except JoseJWTError as e:
        raise AuthError(f"Token invalido: {str(e)}")
    except httpx.HTTPError as e:
        raise AuthError(f"Servico de autenticacao indisponivel: {str(e)}")


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