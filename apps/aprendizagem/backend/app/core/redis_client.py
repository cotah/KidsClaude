"""
Wrapper Redis assincrono pra cache e rate limit.

Comportamento defensivo: se REDIS_URL nao definido OU conexao falhou,
todas as operacoes viram no-op (get devolve None, set silencioso). O
codigo de aplicacao nao precisa branching - so' tenta o cache; se vier
None, computa e tenta cachear, se falhar segue normal.

Inicializacao lazy + uma unica tentativa: se o ping inicial falhar, marca
client=None pra evitar reconnect-storm a cada request quando Redis ta
down. Restart do worker re-tenta.
"""

import json
import structlog
from typing import Any, Optional

from redis.asyncio import Redis, from_url
from redis.exceptions import RedisError

from app.core.config import settings

logger = structlog.get_logger()

_client: Optional[Redis] = None
_init_attempted: bool = False


async def get_redis() -> Optional[Redis]:
    """
    Retorna client Redis ou None se indisponivel.
    Lazy + memoized: primeira chamada conecta + ping; falha marca como
    None pra todas as chamadas seguintes (sem reconnect ate restart).
    """
    global _client, _init_attempted
    if _init_attempted:
        return _client
    _init_attempted = True

    if not settings.redis_url:
        logger.info("REDIS_URL nao definido - cache desabilitado")
        return None

    try:
        client = from_url(
            settings.redis_url,
            decode_responses=True,
            socket_connect_timeout=3,
            socket_timeout=3,
        )
        await client.ping()
        _client = client
        logger.info("Redis conectado")
    except (RedisError, OSError) as e:
        logger.warning("Redis indisponivel - cache desabilitado", error=str(e))
        _client = None

    return _client


async def get_json(key: str) -> Optional[Any]:
    """
    GET + JSON parse. Devolve None se key nao existir, Redis off, ou erro.
    Nunca propaga excecao - caller assume cache miss e segue.
    """
    client = await get_redis()
    if not client:
        return None
    try:
        raw = await client.get(key)
        if raw is None:
            return None
        return json.loads(raw)
    except (RedisError, json.JSONDecodeError) as e:
        logger.warning("Cache get falhou", key=key, error=str(e))
        return None


async def set_json(key: str, value: Any, ttl: int) -> None:
    """
    JSON serialize + SET com TTL (segundos). Falha silenciosa.
    `default=str` cuida de datetime/UUID via str().
    """
    client = await get_redis()
    if not client:
        return
    try:
        await client.set(key, json.dumps(value, default=str), ex=ttl)
    except (RedisError, TypeError) as e:
        logger.warning("Cache set falhou", key=key, error=str(e))


async def delete(key: str) -> None:
    """DELETE de uma key. Falha silenciosa."""
    client = await get_redis()
    if not client:
        return
    try:
        await client.delete(key)
    except RedisError as e:
        logger.warning("Cache delete falhou", key=key, error=str(e))


async def delete_pattern(pattern: str) -> None:
    """
    SCAN + DELETE por padrao glob (ex: "lessons:*:child:abc-123").
    Usado pra invalidar grupos de keys quando algo muda (ex: licao
    concluida invalida todas as listas de licoes daquela crianca).
    Iterativo via scan_iter pra nao bloquear o Redis.
    """
    client = await get_redis()
    if not client:
        return
    try:
        keys: list[str] = []
        async for key in client.scan_iter(match=pattern, count=100):
            keys.append(key)
        if keys:
            await client.delete(*keys)
    except RedisError as e:
        logger.warning("Cache delete_pattern falhou", pattern=pattern, error=str(e))
