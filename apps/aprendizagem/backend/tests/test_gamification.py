"""
Testes do sistema de gamificação: XP, níveis, badges.
"""

import pytest
from unittest.mock import AsyncMock

from app.services.gamification import GamificationService


class TestXPAndLevels:
    """Testes de XP e sistema de níveis."""

    def test_xp_level_calculation(self):
        """Testa fórmula de cálculo de nível por XP."""
        gamification = GamificationService(AsyncMock())

        # Testa níveis conforme fórmula: 100 * n * (n+1) / 2
        test_cases = [
            (0, 1),      # XP 0 = nível 1
            (50, 1),     # XP 50 = nível 1
            (299, 1),    # XP 299 = nível 1 (ainda não chegou a 300)
            (300, 2),    # XP 300 = nível 2
            (600, 3),    # XP 600 = nível 3
            (1000, 4),   # XP 1000 = nível 4
            (4500, 9)    # XP 4500 = nível 9
        ]

        for xp, expected_level in test_cases:
            actual_level = gamification.calculate_level_from_xp(xp)
            assert actual_level == expected_level, f"XP {xp} deveria ser nível {expected_level}, got {actual_level}"

    def test_xp_for_level_calculation(self):
        """Testa cálculo de XP necessário para um nível."""
        gamification = GamificationService(AsyncMock())

        test_cases = [
            (1, 0),      # Nível 1 = 0 XP
            (2, 300),    # Nível 2 = 300 XP
            (3, 600),    # Nível 3 = 600 XP
            (5, 1500),   # Nível 5 = 1500 XP
            (10, 5500)   # Nível 10 = 5500 XP
        ]

        for level, expected_xp in test_cases:
            actual_xp = gamification.calculate_xp_for_level(level)
            assert actual_xp == expected_xp, f"Nível {level} deveria precisar {expected_xp} XP, got {actual_xp}"

    def test_level_names(self):
        """Testa nomes temáticos dos níveis."""
        gamification = GamificationService(AsyncMock())

        expected_names = {
            1: "Curioso",
            5: "Mestre dos Prompts",
            10: "Lendário",
            15: "Lendário"  # Acima do máximo
        }

        for level, expected_name in expected_names.items():
            actual_name = gamification.get_level_name(level)
            assert actual_name == expected_name

    @pytest.mark.asyncio
    async def test_award_xp_updates_level(self):
        """Testa que conceder XP atualiza nível corretamente."""
        # Mock do banco
        mock_db = AsyncMock()
        mock_db.execute_query.side_effect = [
            # Primeiro call: busca XP/nível atual
            [{"xp": 250, "level": 2}],
            # Segundo call: busca badges disponíveis (vazio para simplicidade)
            []
        ]

        gamification = GamificationService(mock_db)

        result = await gamification.award_xp(
            child_id="test-child-id",
            xp_amount=100,
            source="lesson_completed"
        )

        # Deve atualizar para nível 2 (350 XP total)
        assert result["xp_total"] == 350
        assert result["level"] == 2
        assert result["level_up"] is False  # Still level 2, no level up

        # Verifica que UPDATE foi chamado
        mock_db.execute_non_query.assert_called_once()
        update_call = mock_db.execute_non_query.call_args[0]
        assert "UPDATE children SET xp = $1, level = $2" in update_call[0]
        assert update_call[1] == 350  # novo XP
        assert update_call[2] == 2    # novo nível


class TestBadgeSystem:
    """Testes do sistema de badges."""

    @pytest.mark.asyncio
    async def test_first_lesson_badge_unlock(self):
        """Testa desbloqueio do badge 'Primeiros Passos'."""
        mock_db = AsyncMock()

        # Mock: criança tem 1 lição completa
        mock_db.execute_query.side_effect = [
            # Badges disponíveis
            [{
                "id": "badge-id-1",
                "code": "FIRST_STEPS",
                "name": "Primeiros Passos",
                "description": "Completou primeira lição",
                "icon": "first-steps",
                "unlock_rule": {"type": "lesson_completed", "count": 1}
            }],
            # Count de lições completadas
            [{"count": 1}]
        ]

        gamification = GamificationService(mock_db)

        # Simula contexto de conclusão de lição
        context = {"source": "lesson_completed"}

        badges = await gamification._check_and_award_badges("child-id", context)

        assert len(badges) == 1
        assert badges[0]["code"] == "FIRST_STEPS"

        # Verifica que badge foi inserido
        mock_db.execute_non_query.assert_called_once()

    @pytest.mark.asyncio
    async def test_streak_badge_evaluation(self):
        """Testa avaliação de badge de streak."""
        mock_db = AsyncMock()
        gamification = GamificationService(mock_db)

        # Testa regra de streak de 7 dias
        unlock_rule = {"type": "streak_days", "count": 7}
        context = {"streak_achieved": 7}

        result = await gamification._evaluate_badge_rule("child-id", unlock_rule, context)
        assert result is True

        # Streak insuficiente
        context = {"streak_achieved": 5}
        result = await gamification._evaluate_badge_rule("child-id", unlock_rule, context)
        assert result is False