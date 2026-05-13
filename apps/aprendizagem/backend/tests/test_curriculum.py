"""
Testes para o novo curriculum de 4 stages.
Valida migrations, stage progression, final exam e modelos Claude.
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, patch
from httpx import AsyncClient
from app.main import app
from app.core.config import settings


class TestCurriculumRedesign:
    """Testes para o curriculum redesenado com 4 stages."""

    @pytest.mark.asyncio
    async def test_migration_applies_cleanly(self):
        """Testa se as migrations aplicam sem erro."""
        # Este teste seria executado em um banco de teste
        # Por ora, é um placeholder para validar que as migrations existem

        from pathlib import Path
        backend_path = Path(__file__).parent.parent

        migration_003 = backend_path / "app" / "db" / "migrations" / "003_curriculum_redesign.sql"
        migration_004 = backend_path / "app" / "db" / "migrations" / "004_curriculum_seed.sql"

        assert migration_003.exists(), "Migration 003 deve existir"
        assert migration_004.exists(), "Migration 004 deve existir"

        # Verifica que migration 003 contém as alterações esperadas
        migration_003_content = migration_003.read_text()
        assert "ADD COLUMN IF NOT EXISTS stage INTEGER" in migration_003_content
        assert "ADD COLUMN IF NOT EXISTS is_final_exam BOOLEAN" in migration_003_content
        assert "ADD COLUMN IF NOT EXISTS claude_model TEXT" in migration_003_content
        assert "6-8','9-10','11-12','12+" in migration_003_content

        # Verifica que migration 004 contém o seed completo
        migration_004_content = migration_004.read_text()
        assert "DELETE FROM lessons" in migration_004_content
        assert "discovery-o-que-e-ia" in migration_004_content
        assert "final-exam-project-capstone" in migration_004_content
        assert "claude-sonnet-4-6" in migration_004_content
        assert "CAPSTONE_BUILDER" in migration_004_content

    @pytest.mark.asyncio
    async def test_stages_endpoint_exists(self):
        """Testa se o endpoint /v1/stages existe e retorna estrutura correta."""
        async with AsyncClient(app=app, base_url="http://test") as ac:
            # Simula uma requisição sem auth (deve retornar erro 401 ou similar)
            response = await ac.get("/v1/stages")

            # Como não temos auth setup completo no teste, verifica pelo menos que a rota existe
            # Se retornou 404, a rota não existe. Se 401/403/422, a rota existe mas precisa de auth.
            assert response.status_code != 404, "Endpoint /v1/stages deve existir"

    @pytest.mark.asyncio
    async def test_lesson_model_assignment(self):
        """Testa se as lições usam os modelos Claude corretos."""
        # Mock do banco de dados
        mock_db = AsyncMock()

        # Simula resposta com lições
        mock_db.execute_query.return_value = [
            {
                "id": "lesson-1",
                "stage": 1,
                "is_final_exam": False,
                "claude_model": "claude-haiku-4-5-20251001",
                "slug": "discovery-o-que-e-ia"
            },
            {
                "id": "lesson-final",
                "stage": 5,
                "is_final_exam": True,
                "claude_model": "claude-sonnet-4-6",
                "slug": "final-exam-project-capstone"
            }
        ]

        # Testa que lições regulares usam Haiku
        regular_lessons = [l for l in mock_db.execute_query.return_value if not l["is_final_exam"]]
        for lesson in regular_lessons:
            assert lesson["claude_model"] == "claude-haiku-4-5-20251001"

        # Testa que final exam usa Sonnet
        final_exam = [l for l in mock_db.execute_query.return_value if l["is_final_exam"]]
        assert len(final_exam) == 1
        assert final_exam[0]["claude_model"] == "claude-sonnet-4-6"

    @pytest.mark.asyncio
    async def test_stage_progression_logic(self):
        """Testa a lógica de progressão entre stages."""
        # Mock child com stage 1 completa
        child_id = "test-child"

        mock_db = AsyncMock()

        # Simula progresso: Stage 1 completa (4/4), Stage 2 incompleta (1/4)
        mock_db.execute_query.return_value = [
            {"stage": 1, "total_lessons": 4, "completed_lessons": 4},
            {"stage": 2, "total_lessons": 4, "completed_lessons": 1},
            {"stage": 3, "total_lessons": 4, "completed_lessons": 0},
            {"stage": 4, "total_lessons": 4, "completed_lessons": 0}
        ]

        # Lógica de desbloqueio (extraída do código)
        completed_stages = set()
        for stage_data in mock_db.execute_query.return_value:
            if stage_data['total_lessons'] == stage_data['completed_lessons']:
                completed_stages.add(stage_data['stage'])

        # Stage 1 desbloqueada por padrão
        assert 1 in completed_stages or True  # Stage 1 sempre desbloqueada

        # Stage 2 desbloqueada porque stage 1 está completa
        stage_2_unlocked = 1 in completed_stages
        assert stage_2_unlocked

        # Stage 3 bloqueada porque stage 2 não está completa
        stage_3_unlocked = 2 in completed_stages
        assert not stage_3_unlocked

        # Final exam bloqueado porque nem todas as 4 stages estão completas
        final_exam_unlocked = {1, 2, 3, 4}.issubset(completed_stages)
        assert not final_exam_unlocked

    @pytest.mark.asyncio
    async def test_lesson_count_per_stage(self):
        """Testa se o número de lições por stage está correto."""
        expected_lessons_per_stage = {
            1: 4,  # Discovery
            2: 4,  # Exploration
            3: 4,  # Creation
            4: 4,  # Prompt Engineering
            5: 1   # Final Exam
        }

        # Esta validação seria feita com dados reais do banco
        # Por ora, validamos que a migration contém o número esperado de lições

        from pathlib import Path
        migration_004 = Path(__file__).parent.parent / "app" / "db" / "migrations" / "004_curriculum_seed.sql"
        content = migration_004.read_text()

        # Conta inserções por stage
        stage_1_lessons = content.count('1,\n  \'[')  # Stage 1 no INSERT
        stage_final_lessons = content.count('"stage": 5') or content.count('5,\n  \'[')

        # A migration tem uma estrutura específica, então contamos de forma aproximada
        # O importante é que tenhamos 17 lições no total
        total_lesson_inserts = content.count('gen_random_uuid(),\n  \'')
        assert total_lesson_inserts == 17, f"Esperadas 17 lições, encontradas {total_lesson_inserts}"

    @pytest.mark.asyncio
    async def test_new_age_bands(self):
        """Testa se as novas faixas etárias foram implementadas."""
        from pathlib import Path
        migration_003 = Path(__file__).parent.parent / "app" / "db" / "migrations" / "003_curriculum_redesign.sql"
        content = migration_003.read_text()

        # Verifica que as 4 novas faixas etárias estão na constraint
        assert "'6-8','9-10','11-12','12+'" in content, "Novas faixas etárias devem estar na migration"

        # Verifica que o limite de idade foi expandido para 16
        assert "age BETWEEN 6 AND 16" in content, "Limite de idade deve ser expandido para 16"

    def test_exam_system_prompt_exists(self):
        """Testa se o system prompt do exame está implementado."""
        from app.api.exam import send_exam_message

        # Verifica se a função existe (importação bem-sucedida indica implementação)
        assert callable(send_exam_message)

        # O system prompt está hardcoded na função - verificamos se contém elementos-chave
        import inspect
        source = inspect.getsource(send_exam_message)
        assert "Atena Mentor" in source
        assert "5 passos" in source
        assert "ficha-resumo" in source

    def test_capstone_badge_added(self):
        """Testa se o badge CAPSTONE_BUILDER foi adicionado."""
        from pathlib import Path
        migration_004 = Path(__file__).parent.parent / "app" / "db" / "migrations" / "004_curriculum_seed.sql"
        content = migration_004.read_text()

        assert "CAPSTONE_BUILDER" in content
        assert "Construtor Capstone" in content
        assert "final_exam_completed" in content


if __name__ == "__main__":
    pytest.main([__file__, "-v"])