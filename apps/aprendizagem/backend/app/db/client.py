"""
Cliente do banco de dados Supabase.
Configura conexão com Postgres via supabase-py e asyncpg.
"""

import asyncpg
from typing import AsyncGenerator
from supabase import create_client, Client
from app.core.config import settings

# Cliente Supabase (usa service role para bypass RLS)
supabase: Client = create_client(
    supabase_url=settings.supabase_url,
    supabase_key=settings.supabase_service_role_key
)


class DatabaseClient:
    """Wrapper para operações de banco com connection pooling."""

    def __init__(self):
        self._pool: asyncpg.Pool | None = None

    async def init_pool(self):
        """Inicializa connection pool AsyncPG."""
        if self._pool is None:
            # Extrai dados de conexão da URL do Supabase
            db_url = settings.supabase_url.replace("https://", "")
            project_ref = db_url.split(".")[0]

            # Constrói string de conexão PostgreSQL
            postgres_url = (
                f"postgresql://postgres.{project_ref}:"
                f"{settings.supabase_service_role_key}@"
                f"aws-0-{settings.supabase_url.split('//')[1].split('.')[0]}.pooler.supabase.com:6543/postgres"
            )

            try:
                self._pool = await asyncpg.create_pool(
                    postgres_url,
                    min_size=2,
                    max_size=10,
                    command_timeout=30
                )
            except Exception:
                # Fallback: usa URL direta sem pooler
                postgres_direct = (
                    f"postgresql://postgres:"
                    f"{settings.supabase_service_role_key}@"
                    f"db.{project_ref}.supabase.co:5432/postgres"
                )
                self._pool = await asyncpg.create_pool(postgres_direct, min_size=1, max_size=5)

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