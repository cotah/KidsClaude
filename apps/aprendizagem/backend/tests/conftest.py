"""
Configurações compartilhadas dos testes.
Fixtures, mocks e setup do banco de teste.
"""

import os
import pytest
import asyncio
import asyncpg
from httpx import AsyncClient
from unittest.mock import AsyncMock, MagicMock, patch

# Setup test environment variables before ANY import
os.environ["SUPABASE_URL"] = "https://test-project.supabase.co"
os.environ["SUPABASE_SERVICE_ROLE_KEY"] = "test-service-role-key"
os.environ["SUPABASE_JWT_SECRET"] = "test-jwt-secret-for-unit-testing-only"
os.environ["ANTHROPIC_API_KEY"] = "sk-ant-test-key-for-unit-testing"
os.environ["CHILD_JWT_SECRET"] = "test-child-jwt-secret-256bit-long-enough-for-testing-purposes-here"
os.environ["ENV"] = "development"

# Mock Supabase client before import
import sys
from unittest.mock import MagicMock
mock_supabase_client = MagicMock()

# Apply the patch before importing app modules
original_create_client = None
try:
    import supabase
    original_create_client = supabase.create_client
    supabase.create_client = MagicMock(return_value=mock_supabase_client)
except ImportError:
    pass

# Now safe to import app components
from app.main import app
from app.core.config import settings
from app.db.client import get_db_client
from app.services.claude_client import ClaudeClient

# Restore original if needed
if original_create_client:
    supabase.create_client = original_create_client


# Mock database functions for testing
@pytest.fixture(autouse=True)
async def mock_database_operations():
    """Mock database operations to avoid real DB connections in tests."""
    # passlib.pwd_context foi removido quando trocamos para bcrypt direto.
    # Patchamos hash_pin / verify_pin no proprio modulo security em vez de
    # tentar acessar atributos legados que estouravam AttributeError.
    with patch('app.db.client.init_database', new_callable=AsyncMock) as mock_init, \
         patch('app.db.client.close_database', new_callable=AsyncMock) as mock_close, \
         patch('app.db.client.DatabaseClient.init_pool', new_callable=AsyncMock) as mock_pool_init, \
         patch('app.db.client.DatabaseClient.close_pool', new_callable=AsyncMock) as mock_pool_close, \
         patch('app.core.security.hash_pin') as mock_hash, \
         patch('app.core.security.verify_pin') as mock_verify:

        # Setup simple hash/verify mocks for testing with randomness
        import random
        import string
        mock_hash.side_effect = lambda x: f"hashed_{x}_{''.join(random.choices(string.ascii_letters, k=8))}"
        mock_verify.side_effect = lambda plain, hashed: hashed.startswith(f"hashed_{plain}_")

        yield {
            'init_database': mock_init,
            'close_database': mock_close,
            'init_pool': mock_pool_init,
            'close_pool': mock_pool_close,
            'hash': mock_hash,
            'verify': mock_verify
        }


@pytest.fixture(scope="session")
def event_loop():
    """Event loop para testes async."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
async def client():
    """Cliente HTTP de teste."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac


@pytest.fixture
def mock_db():
    """Mock do cliente de banco de dados."""
    mock_client = MagicMock()
    mock_client.execute_query = AsyncMock()
    mock_client.execute_non_query = AsyncMock()
    return mock_client


@pytest.fixture
def mock_claude():
    """Mock do cliente Claude."""
    mock_client = MagicMock()
    mock_client.chat_with_child = AsyncMock(return_value="Resposta de teste da Atena!")
    mock_client.classify_content = AsyncMock(return_value='{"categoria": "seguro", "motivo": "conteúdo apropriado"}')
    mock_client.generate_session_summary = AsyncMock(return_value="Criança conversou sobre histórias.")
    mock_client.check_health = AsyncMock(return_value=True)
    return mock_client


@pytest.fixture(autouse=True)
def mock_claude_globally():
    """Mock Claude client globally for all tests."""
    with patch('app.services.claude_client.ClaudeClient') as mock_claude_class:
        mock_claude = mock_claude_class.return_value
        mock_claude.chat_with_child = AsyncMock(return_value="Resposta de teste da Atena!")
        mock_claude.classify_content = AsyncMock(return_value='{"categoria": "seguro", "motivo": "conteúdo apropriado"}')
        mock_claude.generate_session_summary = AsyncMock(return_value="Criança conversou sobre histórias.")
        mock_claude.check_health = AsyncMock(return_value=True)
        yield mock_claude


@pytest.fixture
def sample_parent_data():
    """Dados de exemplo de um pai."""
    return {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "email": "pai@example.com",
        "display_name": "Pai Teste"
    }


@pytest.fixture
def sample_child_data():
    """Dados de exemplo de uma criança."""
    return {
        "id": "550e8400-e29b-41d4-a716-446655440002",
        "parent_id": "550e8400-e29b-41d4-a716-446655440001",
        "name": "João",
        "age": 8,
        "avatar_id": "avatar-01",
        "daily_limit_minutes": 30,
        "level": 1,
        "xp": 0,
        "streak_days": 0,
        "last_active_date": None,
        "pin_hash": None
    }


@pytest.fixture
def sample_lesson_data():
    """Dados de exemplo de uma lição."""
    return {
        "id": "550e8400-e29b-41d4-a716-446655440003",
        "slug": "ola-atena-6-8",
        "title": "Olá, Atena!",
        "description": "Conheça sua nova amiga robô",
        "age_band": "6-8",
        "order_index": 1,
        "content_blocks": [
            {"type": "text", "content": "Oi! Eu sou a Atena!"}
        ],
        "prerequisites": [],
        "xp_reward": 50,
        "is_active": True
    }


@pytest.fixture
def parent_jwt_token(sample_parent_data):
    """Token JWT válido de pai para testes."""
    from app.core.security import create_child_jwt
    # Para testes, usamos um token mock
    return "Bearer mock-parent-jwt-token"


@pytest.fixture
def child_jwt_token(sample_child_data, sample_parent_data):
    """Token JWT válido de criança para testes."""
    from app.core.security import create_child_jwt
    return f"Bearer {create_child_jwt(sample_child_data['id'], sample_parent_data['id'])}"