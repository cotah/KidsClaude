"""
Aplicação principal FastAPI.
Configuração de middleware, rotas, CORS e lifecycle events.
"""

import structlog
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from app.core.config import settings
from app.core.dependencies import limiter
from app.db.client import init_database, close_database
from app.api import auth, children, lessons, chat, parents, health
# Importes para registrar endpoints nas rotas spec-corretas (corrige prefixos)
from app.api.chat import usage_heartbeat, list_child_sessions
from app.api.lessons import attempt_challenge
from app.schemas.chat import HeartbeatResponse, SessionListResponse
from app.schemas.lessons import ChallengeAttemptResponse

# Configuração de logging estruturado
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Context manager para startup/shutdown da aplicação.
    Inicializa conexões e recursos no startup.
    """
    # Startup
    logger.info("Iniciando aplicação", env=settings.env)
    try:
        await init_database()
        logger.info("Banco de dados conectado")
    except Exception as e:
        logger.error("Falha ao conectar banco", error=str(e))
        raise

    yield

    # Shutdown
    logger.info("Encerrando aplicação")
    try:
        await close_database()
        logger.info("Conexões de banco fechadas")
    except Exception as e:
        logger.error("Erro ao fechar banco", error=str(e))


# Criação da aplicação
# redirect_slashes=False evita 307 entre /v1/x e /v1/x/ - importante porque o
# BFF proxy do frontend usa fetch() que pode strippar o Authorization header
# em redirects, transformando 200 em 401 silenciosamente.
app = FastAPI(
    title="Aprendizagem API",
    description="API backend para app educacional de IA para crianças",
    version="1.0.0",
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
    lifespan=lifespan,
    redirect_slashes=False,
)

# Rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin] if settings.is_production else ["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "DELETE"],
    allow_headers=["*"],
    expose_headers=["X-RateLimit-Remaining", "X-RateLimit-Reset"]
)


# Middleware de logging de requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log de todas as requisições HTTP."""
    start_time = structlog.get_logger().info

    # Log da requisição
    logger.info(
        "Request iniciada",
        method=request.method,
        url=str(request.url),
        client_ip=request.client.host if request.client else "unknown"
    )

    # Executa request
    try:
        response = await call_next(request)

        # Log da resposta
        logger.info(
            "Request concluída",
            method=request.method,
            url=str(request.url),
            status_code=response.status_code,
            client_ip=request.client.host if request.client else "unknown"
        )

        return response

    except Exception as e:
        # Log de erro
        logger.error(
            "Request falhou",
            method=request.method,
            url=str(request.url),
            error=str(e),
            client_ip=request.client.host if request.client else "unknown"
        )
        raise


# Inclusão das rotas
app.include_router(
    auth.router,
    prefix="/v1/auth",
    tags=["Autenticação"]
)

app.include_router(
    children.router,
    prefix="/v1/children",
    tags=["Crianças"]
)

app.include_router(
    lessons.router,
    prefix="/v1/lessons",
    tags=["Lições"]
)

app.include_router(
    chat.router,
    prefix="/v1/chat",
    tags=["Chat"]
)

app.include_router(
    parents.router,
    prefix="/v1/parents",
    tags=["Pais"]
)

app.include_router(
    health.router,
    prefix="/v1",
    tags=["Sistema"]
)

# Rotas adicionais nos caminhos exigidos pela spec (secoes 7.4, 7.5, 7.7).
# Os handlers continuam em chat.py / lessons.py; apenas registramos aliases
# nos prefixos corretos. Os caminhos antigos permanecem ativos para nao
# quebrar testes existentes durante a transicao.

usage_router = APIRouter()
usage_router.post(
    "/heartbeat",
    response_model=HeartbeatResponse,
    summary="Heartbeat de tempo de uso da crianca",
)(usage_heartbeat)
app.include_router(usage_router, prefix="/v1/usage", tags=["Uso"])

challenges_router = APIRouter()
challenges_router.post(
    "/{challenge_id}/attempt",
    response_model=ChallengeAttemptResponse,
    summary="Tentativa de desafio",
)(attempt_challenge)
app.include_router(challenges_router, prefix="/v1/challenges", tags=["Desafios"])

children_sessions_router = APIRouter()
children_sessions_router.get(
    "/{child_id}/sessions",
    response_model=SessionListResponse,
    summary="Lista sessoes de chat de uma crianca",
)(list_child_sessions)
app.include_router(children_sessions_router, prefix="/v1/children", tags=["Criancas"])


@app.get("/")
async def root():
    """
    Endpoint raiz com informações básicas da API.
    """
    return {
        "service": "Aprendizagem API",
        "version": "1.0.0",
        "environment": settings.env,
        "docs": "/docs" if not settings.is_production else "disabled"
    }


# Handler de erros não tratados
@app.exception_handler(500)
async def internal_server_error_handler(request: Request, exc: Exception):
    """Handler para erros 500 não tratados."""
    logger.error(
        "Erro interno não tratado",
        method=request.method,
        url=str(request.url),
        error=str(exc),
        error_type=type(exc).__name__
    )

    return {
        "error": {
            "code": "INTERNAL_ERROR",
            "message": "Erro interno do servidor"
        }
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.is_development,
        log_level=settings.log_level
    )