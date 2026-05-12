"""
Utilitários de segurança: autenticação, JWT, hashing.
Implementa autenticação dupla: parent (Supabase) e child (backend).
"""

import jwt
import bcrypt
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from passlib.context import CryptContext

from app.core.config import settings

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
    Usa o secret configurado para validar assinatura.
    """
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            options={"verify_aud": False}  # Supabase não usa aud padrão
        )

        # Verifica se é um token de parent
        if payload.get("role") != "authenticated":
            raise AuthError("Token inválido: role incorreto")

        return payload
    except jwt.ExpiredSignatureError:
        raise AuthError("Token expirado")
    except jwt.InvalidTokenError as e:
        raise AuthError(f"Token inválido: {str(e)}")


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