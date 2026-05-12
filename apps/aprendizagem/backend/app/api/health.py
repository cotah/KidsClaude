"""
Health check endpoint para monitoramento.
Verifica status do banco, Claude API e serviços críticos.
"""

import structlog
from fastapi import APIRouter

from app.schemas.common import HealthCheckResponse
from app.db.client import db_client
from app.services.claude_client import ClaudeClient

logger = structlog.get_logger()
router = APIRouter()


@router.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """
    Endpoint de health check para monitoramento.
    Verifica conectividade com banco e Claude API.
    """
    health_status = {
        "status": "ok",
        "version": "1.0.0",
        "db": "unknown",
        "anthropic": "unknown"
    }

    # Verifica banco de dados
    try:
        await db_client.execute_query("SELECT 1")
        health_status["db"] = "healthy"
        logger.debug("Health check DB: OK")
    except Exception as e:
        health_status["db"] = "error"
        health_status["status"] = "degraded"
        logger.error("Health check DB falhou", error=str(e))

    # Verifica Claude API
    try:
        claude = ClaudeClient()
        is_claude_healthy = await claude.check_health()
        health_status["anthropic"] = "healthy" if is_claude_healthy else "error"

        if not is_claude_healthy:
            health_status["status"] = "degraded"

        logger.debug("Health check Claude: OK" if is_claude_healthy else "FAIL")
    except Exception as e:
        health_status["anthropic"] = "error"
        health_status["status"] = "degraded"
        logger.error("Health check Claude falhou", error=str(e))

    # Status geral
    if health_status["db"] == "error" or health_status["anthropic"] == "error":
        health_status["status"] = "degraded"

    return HealthCheckResponse(**health_status)