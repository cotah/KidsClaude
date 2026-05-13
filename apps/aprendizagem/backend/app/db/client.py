"""
Cliente do banco de dados.
- Pool asyncpg conectado direto via DATABASE_URL (injetado pelo Railway).
- Cliente Supabase ainda usado para Auth (Supabase Auth para os pais).
"""

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
    Hook chamado em cada nova conexao do pool. Registra um codec custom
    para UUID que retorna `str` em vez de `uuid.UUID`. Sem isso, schemas
    Pydantic com `id: str` recebem objeto UUID e estouram ValidationError
    (Pydantic 2 nao coage UUID -> str automaticamente em modo strict),
    quebrando endpoints como GET /v1/auth/parent/me com 500.
    """
    await conn.set_type_codec(
        "uuid",
        encoder=str,
        decoder=str,
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