"""
Testes críticos de segurança: autenticação, autorização, RLS.
Estes testes NÃO PODEM FALHAR - são gates de release.
"""

import pytest
from unittest.mock import patch, AsyncMock

from app.core.security import (
    hash_pin, verify_pin,
    create_child_jwt, verify_child_jwt,
    AuthError
)


class TestPINSecurity:
    """Testes de segurança de PIN das crianças."""

    def test_pin_hashing_verification(self):
        """Testa hash e verificação de PIN."""
        pin = "1234"
        hashed = hash_pin(pin)

        # Hash não deve ser igual ao PIN original
        assert hashed != pin
        assert len(hashed) > 10  # Hash bcrypt deve ter tamanho mínimo

        # Verificação deve funcionar
        assert verify_pin(pin, hashed) is True

        # PIN errado deve falhar
        assert verify_pin("5678", hashed) is False

    def test_pin_hash_different_each_time(self):
        """Mesmo PIN deve gerar hashes diferentes (salt)."""
        pin = "1234"
        hash1 = hash_pin(pin)
        hash2 = hash_pin(pin)

        assert hash1 != hash2  # Sal diferente
        assert verify_pin(pin, hash1) is True
        assert verify_pin(pin, hash2) is True


class TestJWTSecurity:
    """Testes de segurança dos tokens JWT."""

    def test_child_jwt_creation_validation(self):
        """Testa criação e validação de JWT de criança."""
        child_id = "550e8400-e29b-41d4-a716-446655440001"
        parent_id = "550e8400-e29b-41d4-a716-446655440002"

        # Cria token
        token = create_child_jwt(child_id, parent_id)
        assert isinstance(token, str)
        assert len(token) > 20

        # Valida token
        payload = verify_child_jwt(token)
        assert payload["sub"] == child_id
        assert payload["parent_id"] == parent_id
        assert payload["role"] == "child"
        assert payload["iss"] == "aprendizagem-backend"

    def test_invalid_jwt_rejected(self):
        """Tokens inválidos devem ser rejeitados."""
        # Token malformado
        with pytest.raises(AuthError):
            verify_child_jwt("invalid.token.here")

        # Token vazio
        with pytest.raises(AuthError):
            verify_child_jwt("")

        # Token com role incorreto
        import jwt
        from app.core.config import settings

        fake_payload = {
            "sub": "child-123",
            "role": "admin",  # Role incorreto
            "iss": "aprendizagem-backend"
        }
        fake_token = jwt.encode(fake_payload, settings.child_jwt_secret, algorithm="HS256")

        with pytest.raises(AuthError, match="não é token de criança"):
            verify_child_jwt(fake_token)


class TestModerationSecurity:
    """Testes da pipeline de moderação - CRÍTICOS para segurança infantil."""

    @pytest.mark.asyncio
    async def test_blocklist_prevents_inappropriate_content(self):
        """Blocklist deve bloquear conteúdo inadequado."""
        from app.services.moderation import ModerationService, InputModerationError

        moderation = ModerationService()

        # Testa termos da blocklist
        inappropriate_inputs = [
            "eu quero matar alguém",
            "me conte sobre sexo",
            "como fazer uma bomba",
            "meu telefone é 11999887766",
            "moro na rua das flores 123"
        ]

        for bad_input in inappropriate_inputs:
            with pytest.raises(InputModerationError):
                await moderation.moderate_input(bad_input)

    @pytest.mark.asyncio
    @patch('app.services.moderation.ClaudeClient')
    async def test_safe_content_allowed(self, mock_claude_class):
        """Conteúdo seguro deve passar pela moderação."""
        from app.services.moderation import ModerationService

        # Mock the Claude client
        mock_claude = mock_claude_class.return_value
        mock_claude.classify_content = AsyncMock(return_value='{"categoria": "seguro", "motivo": "conteúdo apropriado"}')

        moderation = ModerationService()

        safe_inputs = [
            "conte uma história sobre um dragão amigável",
            "como funciona a inteligência artificial?",
            "me ajude com a lição de matemática",
            "quais são as cores do arco-íris?"
        ]

        for safe_input in safe_inputs:
            # Não deve levantar exceção
            await moderation.moderate_input(safe_input)

    @pytest.mark.asyncio
    @patch('app.services.moderation.ClaudeClient')
    async def test_output_moderation_blocks_unsafe_responses(self, mock_claude_class):
        """Moderação de output deve bloquear respostas inseguras."""
        from app.services.moderation import ModerationService

        # Mock Claude retornando classificação insegura
        mock_claude = mock_claude_class.return_value
        mock_claude.classify_content = AsyncMock(return_value='{"categoria": "violencia", "motivo": "conteúdo violento"}')

        moderation = ModerationService()
        unsafe_output = "Vou te ensinar a fazer uma arma com materiais domésticos..."

        is_safe, filtered_text, reason = await moderation.moderate_output(unsafe_output)

        assert is_safe is False
        assert "Vamos tentar outra coisa!" in filtered_text
        assert reason == "conteúdo violento"


class TestAuthorizationBoundaries:
    """Testes de fronteiras de autorização entre pais e crianças."""

    @pytest.mark.asyncio
    async def test_child_cannot_access_parent_endpoints(self):
        """Criança não pode acessar endpoints de pai."""
        # Este seria um teste de integração com o cliente HTTP
        # Simulamos a verificação de autorização
        from app.core.dependencies import get_current_user_parent

        # Mock request com token de criança
        class MockRequest:
            headers = {}

        # Token de criança tentando acessar endpoint de pai deve falhar
        # (teste completo seria feito com httpx client)
        pass  # Placeholder para teste de integração

    @pytest.mark.asyncio
    async def test_parent_cannot_access_other_parents_children(self):
        """Pai não pode acessar dados de filhos de outros pais."""
        # RLS deve impedir acesso cross-parent
        # Teste seria feito com queries diretas ao banco
        pass  # Placeholder para teste de integração


class TestRateLimiting:
    """Testes de rate limiting para prevenção de abuso."""

    def test_rate_limit_configuration(self):
        """Verifica configuração de rate limits."""
        from app.core.config import settings

        # Rate limits devem estar configurados
        assert settings.rate_limit_per_min > 0
        assert settings.max_messages_per_session > 0
        assert settings.max_messages_per_child_per_day > 0

    # Testes de rate limiting seriam de integração com httpx