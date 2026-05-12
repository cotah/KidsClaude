"""
Configurações da aplicação usando Pydantic Settings.
Carrega variáveis de ambiente e valida tipos.
"""

from typing import Literal
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )

    # Database
    supabase_url: str = Field(..., description="URL do projeto Supabase")
    supabase_service_role_key: str = Field(..., description="Chave de service role do Supabase")
    supabase_jwt_secret: str = Field(..., description="Secret JWT do Supabase")

    # Anthropic
    anthropic_api_key: str = Field(..., description="Chave da API Anthropic")
    anthropic_model: str = Field(
        default="claude-haiku-4-5-20251001",
        description="Modelo Claude para chat"
    )

    # JWT para crianças
    child_jwt_secret: str = Field(..., description="Secret para tokens das crianças")
    child_jwt_ttl_hours: int = Field(default=4, description="TTL em horas para token child")
    parent_jwt_ttl_days: int = Field(default=7, description="TTL em dias para token parent")

    # Segurança e moderação
    moderation_strict: bool = Field(default=True, description="Ativa filtros rigorosos")
    blocklist_path: str = Field(default="app/safety/blocklist.txt", description="Caminho da blocklist")
    rate_limit_per_min: int = Field(default=60, description="Rate limit por minuto por IP")
    max_messages_per_session: int = Field(default=30, description="Máximo de mensagens por sessão")
    max_messages_per_child_per_day: int = Field(default=100, description="Máximo de mensagens por criança/dia")

    # Regional
    timezone: str = Field(default="America/Sao_Paulo", description="Timezone para cálculos de streak")

    # API
    api_base_url: str = Field(default="http://localhost:8000/v1", description="URL base da API")
    frontend_origin: str = Field(default="http://localhost:3000", description="Origin do frontend para CORS")

    # Logs
    log_level: Literal["debug", "info", "warning", "error"] = Field(default="info")
    env: Literal["development", "staging", "production"] = Field(default="development")

    # Sentry (opcional)
    sentry_dsn: str | None = Field(default=None, description="DSN do Sentry para tracking de erros")

    # Health check
    @property
    def is_production(self) -> bool:
        return self.env == "production"

    @property
    def is_development(self) -> bool:
        return self.env == "development"


# Instância global das configurações
settings = Settings()