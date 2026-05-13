"""
Cliente do banco de dados.
- Pool asyncpg conectado direto via DATABASE_URL (injetado pelo Railway).
- Cliente Supabase ainda usado para Auth (Supabase Auth para os pais).
"""

import json
import os
import asyncpg
from typing import AsyncGenerator
from supabase import create_client, Client
from app.core.config import settings

# Cliente Supabase (usa service role para bypass RLS)
supabase: Client = create_client(
    supabase_url=settings.supabase_url,
    supabase_key=settings.supabase_service_role_key
)


async def _setup_connection(conn: asyncpg.Connection) -> None:
    """
    Hook chamado em cada nova conexao do pool. Registra dois codecs:

    1) UUID -> str: sem isso, asyncpg devolve uuid.UUID e Pydantic 2
       (modo strict) rejeita schemas com `id: str`, gerando 500 em
       endpoints como GET /v1/auth/parent/me.

    2) JSONB <-> dict/list (via json.dumps/json.loads): por default
       asyncpg trata JSONB como texto bruto, entao colunas como
       lessons.content_blocks vinham como string e ContentBlock(**str)
       estourava TypeError. Com este codec, JSONB e' (de)serializado
       automaticamente em ambas as direcoes, cobrindo todas as rotas
       que tocam content_blocks, question, correct_answer, slots,
       safety_events.details e similares.
    """
    await conn.set_type_codec(
        "uuid",
        encoder=str,
        decoder=str,
        schema="pg_catalog",
        format="text",
    )
    await conn.set_type_codec(
        "jsonb",
        encoder=json.dumps,
        decoder=json.loads,
        schema="pg_catalog",
        format="text",
    )
    await conn.set_type_codec(
        "json",
        encoder=json.dumps,
        decoder=json.loads,
        schema="pg_catalog",
        format="text",
    )


class DatabaseClient:
    """Wrapper para operações de banco com connection pooling."""

    def __init__(self):
        self._pool: asyncpg.Pool | None = None

    async def init_pool(self):
        """Inicializa connection pool AsyncPG usando DATABASE_URL bruto."""
        if self._pool is None:
            database_url = os.environ.get("DATABASE_URL")
            if not database_url:
                raise RuntimeError(
                    "DATABASE_URL environment variable is not set. "
                    "Railway injects this automatically when a Postgres plugin is attached."
                )

            # Usa a URL exatamente como vem do Railway, sem reconstrucao.
            self._pool = await asyncpg.create_pool(
                database_url,
                min_size=2,
                max_size=10,
                command_timeout=30,
                init=_setup_connection,
            )

    async def close_pool(self):
        """Fecha connection pool."""
        if self._pool:
            await self._pool.close()
            self._pool = None

    async def get_connection(self) -> asyncpg.Connection:
        """Obtém conexão do pool."""
        if self._pool is None:
            await self.init_pool()
        return await self._pool.acquire()

    async def release_connection(self, conn: asyncpg.Connection):
        """Libera conexão de volta ao pool."""
        await self._pool.release(conn)

    async def execute_query(self, query: str, *args) -> list:
        """Executa query e retorna resultados."""
        conn = await self.get_connection()
        try:
            return await conn.fetch(query, *args)
        finally:
            await self.release_connection(conn)

    async def execute_non_query(self, query: str, *args) -> str:
        """Executa INSERT/UPDATE/DELETE e retorna status."""
        conn = await self.get_connection()
        try:
            return await conn.execute(query, *args)
        finally:
            await self.release_connection(conn)


# Instância global do cliente
db_client = DatabaseClient()


async def get_db_client() -> DatabaseClient:
    """Dependency do FastAPI para injeção do cliente de banco."""
    return db_client


async def init_database():
    """Inicializa conexões do banco. Chamado no startup da aplicação."""
    await db_client.init_pool()


async def close_database():
    """Fecha conexões do banco. Chamado no shutdown da aplicação."""
    await db_client.close_pool()