"""
Utilitários de segurança: autenticação, JWT, hashing.
Implementa autenticação dupla: parent (Supabase) e child (backend).
"""

import json
import bcrypt
import httpx
import jwt
import structlog
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from jwt import PyJWKClient
from jwt.algorithms import ECAlgorithm
from redis import Redis as SyncRedis
from redis.exceptions import RedisError

from app.core.config import settings

logger = structlog.get_logger()

# Cliente JWKS singleton em memoria (PyJWKClient cacheia 1h internamente).
# Usado como fallback quando Redis nao tem o JWKS doc.
_jwks_client: PyJWKClient | None = None

# Cliente Redis SINCRONO (verify_supabase_jwt e' sync, chamado de
# dependencies do FastAPI). False = ja' tentou e falhou (nao re-tenta
# pra evitar reconnect-storm). None = ainda nao tentou.
_jwks_redis: SyncRedis | bool | None = None
_JWKS_REDIS_KEY = "jwks:supabase"
_JWKS_TTL_SECONDS = 3600


def _get_jwks_url() -> str:
    return f"{settings.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"


def _get_jwks_client() -> PyJWKClient:
    """Retorna (e inicializa lazy) o cliente JWKS do projeto Supabase."""
    global _jwks_client
    if _jwks_client is None:
        _jwks_client = PyJWKClient(
            _get_jwks_url(),
            cache_keys=True,
            lifespan=_JWKS_TTL_SECONDS,
        )
        logger.info("JWKS client initialized", url=_get_jwks_url())
    return _jwks_client


def _get_jwks_redis() -> Optional[SyncRedis]:
    """Cliente Redis sync pra cache do JWKS. None se REDIS_URL off ou ping falhou."""
    global _jwks_redis
    if _jwks_redis is False:
        return None
    if _jwks_redis is not None:
        return _jwks_redis
    if not settings.redis_url:
        _jwks_redis = False
        return None
    try:
        client = SyncRedis.from_url(
            settings.redis_url,
            decode_responses=True,
            socket_connect_timeout=3,
            socket_timeout=3,
        )
        client.ping()
        _jwks_redis = client
        logger.info("JWKS Redis cache habilitado")
        return client
    except (RedisError, OSError) as e:
        logger.warning("JWKS Redis indisponivel - fallback PyJWKClient", error=str(e))
        _jwks_redis = False
        return None


def _fetch_and_store_jwks() -> Optional[Dict[str, Any]]:
    """Baixa JWKS doc do Supabase e armazena no Redis com TTL. Retorna o doc."""
    try:
        with httpx.Client(timeout=5.0) as c:
            resp = c.get(_get_jwks_url())
            resp.raise_for_status()
            doc = resp.json()
    except (httpx.HTTPError, ValueError) as e:
        logger.warning("Falha ao baixar JWKS pra Redis - fallback PyJWKClient", error=str(e))
        return None

    rc = _get_jwks_redis()
    if rc:
        try:
            rc.set(_JWKS_REDIS_KEY, json.dumps(doc), ex=_JWKS_TTL_SECONDS)
        except RedisError as e:
            logger.warning("Falha ao salvar JWKS no Redis", error=str(e))
    return doc


def _signing_key_from_redis(token: str) -> Optional[Any]:
    """
    Tenta resolver a signing key via Redis. None se cache miss, kid nao
    bate, ou Redis off. Caller faz fallback pro PyJWKClient.
    """
    rc = _get_jwks_redis()
    if not rc:
        return None

    # 1) Tenta cache
    try:
        cached = rc.get(_JWKS_REDIS_KEY)
    except RedisError as e:
        logger.warning("JWKS Redis get falhou - fallback", error=str(e))
        return None

    if cached:
        try:
            doc = json.loads(cached)
        except json.JSONDecodeError:
            doc = None
    else:
        # Cache miss: baixa e armazena (best-effort).
        doc = _fetch_and_store_jwks()

    if not doc or "keys" not in doc:
        return None

    # 2) Pega kid do header do token e procura a jwk correspondente.
    try:
        header = jwt.get_unverified_header(token)
    except jwt.InvalidTokenError:
        return None
    kid = header.get("kid")
    if not kid:
        return None

    jwk = next((k for k in doc["keys"] if k.get("kid") == kid), None)
    if not jwk:
        # kid nao bate - JWKS pode ter rotacionado, invalida cache pra forcar refresh
        try:
            rc.delete(_JWKS_REDIS_KEY)
        except RedisError:
            pass
        return None

    # 3) Constroi a signing key (ES256 = EC algorithm)
    try:
        return ECAlgorithm.from_jwk(json.dumps(jwk))
    except Exception as e:
        logger.warning("Falha ao construir signing key do JWK em cache", error=str(e))
        return None

# Bcrypt direto (sem passlib). passlib 1.7.4 explode com bcrypt 4.x:
# "module 'bcrypt' has no attribute '__about__'" porque a 4.x removeu
# esse atributo e passlib usa para detectar versao. Como so' precisamos
# hash + verify de um PIN curto, bcrypt nativo cobre sem passlib.
_BCRYPT_ROUNDS = 10  # custo razoavel para um PIN de 4 digitos


class AuthError(HTTPException):
    """Exceção customizada para erros de autenticação."""

    def __init__(self, message: str = "Authentication failed"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": {"code": "UNAUTHORIZED", "message": message}}
        )


def hash_pin(pin: str) -> str:
    """Gera hash bcrypt de um PIN de 4 digitos. Cost 10 e' suficiente."""
    salt = bcrypt.gensalt(rounds=_BCRYPT_ROUNDS)
    return bcrypt.hashpw(pin.encode("utf-8"), salt).decode("utf-8")


def verify_pin(pin: str, hashed: str) -> bool:
    """Verifica PIN contra hash bcrypt. Retorna False se hash invalido."""
    try:
        return bcrypt.checkpw(pin.encode("utf-8"), hashed.encode("utf-8"))
    except (ValueError, TypeError):
        return False


def verify_supabase_jwt(token: str) -> Dict[str, Any]:
    """
    Verifica JWT emitido pelo Supabase Auth.
    Tokens Supabase usam ES256 (ECDSA P-256). Estrategia em 2 camadas:
      1) Redis cache do JWKS doc (TTL 1h) - resolve kid via Redis sync.
         Compartilhado entre workers, sobrevive restart.
      2) Fallback PyJWKClient (cache em memoria por processo) se Redis
         off ou kid nao bate (rotacao de chave).
    Logs estruturados em cada falha pra facilitar debug via Railway logs.
    """
    try:
        # Tentativa 1: Redis cache
        signing_key = _signing_key_from_redis(token)
        if signing_key is not None:
            key_material = signing_key
        else:
            # Tentativa 2: PyJWKClient (mantem cache em memoria interno)
            jwks_client = _get_jwks_client()
            key_material = jwks_client.get_signing_key_from_jwt(token).key

        payload = jwt.decode(
            token,
            key_material,
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