"""
Sistema de gamificação: XP, níveis, badges, streaks.
Implementa lógica de recompensas e desbloqueio de conquistas.
"""

import math
from datetime import date, datetime, timedelta, timezone
from typing import Dict, List, Tuple, Optional
import structlog
import pytz

from app.core.config import settings
from app.db.client import DatabaseClient

logger = structlog.get_logger()


class GamificationService:
    """Serviço de gamificação com XP, níveis e badges."""

    def __init__(self, db: DatabaseClient):
        self.db = db
        self.timezone = pytz.timezone(settings.timezone)

    def calculate_level_from_xp(self, xp: int) -> int:
        """
        Calcula nível baseado no XP total.
        Fórmula: nível n exige 100 * n * (n+1) / 2 XP.
        """
        if xp <= 0:
            return 1

        # Resolve equação quadrática: 100 * n * (n+1) / 2 <= xp
        # Simplificando: n^2 + n - (2*xp/100) <= 0
        discriminant = 1 + 8 * xp / 100
        if discriminant < 0:
            return 1

        n = (-1 + math.sqrt(discriminant)) / 2
        return max(1, int(n))

    def calculate_xp_for_level(self, level: int) -> int:
        """Calcula XP total necessário para um nível."""
        if level <= 1:
            return 0
        return 100 * level * (level + 1) // 2

    def get_level_name(self, level: int) -> str:
        """Retorna nome temático do nível."""
        level_names = [
            "Curioso",           # 1
            "Explorador",        # 2
            "Inventor",          # 3
            "Pesquisador",       # 4
            "Mestre dos Prompts", # 5
            "Aprendiz Maker",    # 6
            "Construtor",        # 7
            "Cientista",         # 8
            "Sábio",            # 9
            "Lendário"          # 10+
        ]
        if level <= 0:
            return "Iniciante"
        elif level <= len(level_names):
            return level_names[level - 1]
        else:
            return "Lendário"

    async def award_xp(self, child_id: str, xp_amount: int, source: str) -> Dict[str, any]:
        """
        Concede XP e verifica mudança de nível.
        Retorna dict com novo total, nível e badges desbloqueados.
        """
        try:
            # Busca XP e nível atual
            current_data = await self.db.execute_query(
                "SELECT xp, level FROM children WHERE id = $1",
                child_id
            )

            if not current_data:
                raise ValueError(f"Criança {child_id} não encontrada")

            current_xp = current_data[0]['xp']
            current_level = current_data[0]['level']
            new_xp = current_xp + xp_amount
            new_level = self.calculate_level_from_xp(new_xp)

            # Atualiza XP e nível
            await self.db.execute_non_query(
                "UPDATE children SET xp = $1, level = $2, updated_at = NOW() WHERE id = $3",
                new_xp, new_level, child_id
            )

            # Verifica badges desbloqueados
            new_badges = await self._check_and_award_badges(child_id, {
                'xp_gained': xp_amount,
                'total_xp': new_xp,
                'level_up': new_level > current_level,
                'new_level': new_level,
                'source': source
            })

            logger.info("XP concedido", child_id=child_id, amount=xp_amount,
                       new_total=new_xp, new_level=new_level, source=source)

            return {
                'xp_total': new_xp,
                'level': new_level,
                'level_name': self.get_level_name(new_level),
                'level_up': new_level > current_level,
                'badges_unlocked': new_badges
            }

        except Exception as e:
            logger.error("Erro ao conceder XP", error=str(e), child_id=child_id)
            raise

    async def update_streak(self, child_id: str) -> int:
        """
        Atualiza streak diário da criança.
        Retorna novo valor do streak.
        """
        try:
            today = datetime.now(self.timezone).date()

            # Busca dados atuais
            current_data = await self.db.execute_query(
                "SELECT streak_days, last_active_date FROM children WHERE id = $1",
                child_id
            )

            if not current_data:
                raise ValueError(f"Criança {child_id} não encontrada")

            current_streak = current_data[0]['streak_days']
            last_active = current_data[0]['last_active_date']

            if last_active is None:
                # Primeira atividade
                new_streak = 1
            elif last_active == today:
                # Já ativo hoje, mantém streak
                new_streak = current_streak
            elif last_active == today - timedelta(days=1):
                # Ativo ontem, incrementa streak
                new_streak = current_streak + 1
            else:
                # Perdeu streak, reinicia
                new_streak = 1

            # Atualiza dados
            await self.db.execute_non_query(
                "UPDATE children SET streak_days = $1, last_active_date = $2 WHERE id = $3",
                new_streak, today, child_id
            )

            # Verifica badges de streak
            if new_streak > current_streak:
                await self._check_and_award_badges(child_id, {
                    'streak_achieved': new_streak,
                    'source': 'streak'
                })

            logger.info("Streak atualizado", child_id=child_id, new_streak=new_streak)
            return new_streak

        except Exception as e:
            logger.error("Erro ao atualizar streak", error=str(e))
            raise

    async def _check_and_award_badges(self, child_id: str, context: Dict[str, any]) -> List[Dict]:
        """
        Verifica e concede badges baseado no contexto.
        Retorna lista de badges recém-desbloqueados.
        """
        try:
            # Busca badges ainda não conquistados
            available_badges = await self.db.execute_query("""
                SELECT b.id, b.code, b.name, b.description, b.icon, b.unlock_rule
                FROM badges b
                WHERE b.id NOT IN (
                    SELECT badge_id FROM child_badges WHERE child_id = $1
                )
            """, child_id)

            new_badges = []

            for badge_data in available_badges:
                badge_id = badge_data['id']
                unlock_rule = badge_data['unlock_rule']

                if await self._evaluate_badge_rule(child_id, unlock_rule, context):
                    # Concede badge
                    await self.db.execute_non_query(
                        "INSERT INTO child_badges (child_id, badge_id) VALUES ($1, $2)",
                        child_id, badge_id
                    )

                    new_badge = {
                        'id': badge_id,
                        'code': badge_data['code'],
                        'name': badge_data['name'],
                        'description': badge_data['description'],
                        'icon': badge_data['icon'],
                        'awarded_at': datetime.now()
                    }
                    new_badges.append(new_badge)

                    logger.info("Badge desbloqueado", child_id=child_id, badge=badge_data['code'])

            return new_badges

        except Exception as e:
            logger.error("Erro ao verificar badges", error=str(e))
            return []

    async def _evaluate_badge_rule(self, child_id: str, unlock_rule: Dict, context: Dict) -> bool:
        """
        Avalia se regra de desbloqueio de badge foi atendida.
        Diferentes tipos de regras baseadas no unlock_rule.
        """
        rule_type = unlock_rule.get('type')

        if rule_type == 'lesson_completed':
            count_needed = unlock_rule.get('count', 1)
            completed_count = await self.db.execute_query(
                "SELECT COUNT(*) as count FROM lesson_progress WHERE child_id = $1 AND status = 'completed'",
                child_id
            )
            return completed_count[0]['count'] >= count_needed

        elif rule_type == 'messages_sent':
            count_needed = unlock_rule.get('count', 20)
            message_count = await self.db.execute_query(
                "SELECT COUNT(*) as count FROM chat_messages m JOIN chat_sessions s ON m.session_id = s.id WHERE s.child_id = $1 AND m.role = 'child'",
                child_id
            )
            return message_count[0]['count'] >= count_needed

        elif rule_type == 'streak_days':
            count_needed = unlock_rule.get('count', 3)
            return context.get('streak_achieved', 0) >= count_needed

        elif rule_type == 'level_reached':
            level_needed = unlock_rule.get('level', 5)
            return context.get('new_level', 0) >= level_needed

        elif rule_type == 'first_attempt_challenges':
            count_needed = unlock_rule.get('count', 10)
            # Conta desafios acertados na primeira tentativa
            first_attempt_count = await self.db.execute_query("""
                SELECT COUNT(*) as count
                FROM challenge_attempts ca1
                WHERE ca1.child_id = $1
                  AND ca1.is_correct = true
                  AND NOT EXISTS (
                      SELECT 1 FROM challenge_attempts ca2
                      WHERE ca2.child_id = ca1.child_id
                        AND ca2.challenge_id = ca1.challenge_id
                        AND ca2.created_at < ca1.created_at
                  )
            """, child_id)
            return first_attempt_count[0]['count'] >= count_needed

        elif rule_type == 'track_completed':
            # LESSON_MASTER: todas as licoes regulares concluidas (exame final
            # excluido). Antes filtrava por age_band, mas o seed/migrations
            # 003+ trocou as bands para '6-8','9-10','11-12','12+' enquanto
            # esse handler usava '9-12' - o que zerava total e tornava o
            # badge inalcancavel pra 9+. Agora e' age-agnostico.
            total_lessons = await self.db.execute_query(
                "SELECT COUNT(*) as count FROM lessons WHERE is_active = true AND is_final_exam = false"
            )
            completed_lessons = await self.db.execute_query("""
                SELECT COUNT(*) as count FROM lesson_progress lp
                JOIN lessons l ON lp.lesson_id = l.id
                WHERE lp.child_id = $1 AND lp.status = 'completed'
                  AND l.is_active = true AND l.is_final_exam = false
            """, child_id)

            return (
                total_lessons[0]['count'] > 0
                and completed_lessons[0]['count'] >= total_lessons[0]['count']
            )

        elif rule_type == 'different_tracks':
            # CURIOUS_MIND: abriu licoes de pelo menos N stages diferentes.
            # "Abriu" = tem row em lesson_progress (criada no /lessons/{id}/start).
            # Conta DISTINCT l.stage, ignora exame final. Antes nao tinha
            # handler e o badge ficava preso em "always false".
            count_needed = unlock_rule.get('count', 3)
            distinct_stages = await self.db.execute_query("""
                SELECT COUNT(DISTINCT l.stage) as count
                FROM lesson_progress lp
                JOIN lessons l ON lp.lesson_id = l.id
                WHERE lp.child_id = $1 AND l.is_final_exam = false
            """, child_id)
            return distinct_stages[0]['count'] >= count_needed

        elif rule_type == 'story_sessions':
            count_needed = unlock_rule.get('count', 5)
            # Conta sessões em lições que contenham "história" no título
            story_sessions = await self.db.execute_query("""
                SELECT COUNT(*) as count FROM chat_sessions cs
                JOIN lessons l ON cs.lesson_id = l.id
                WHERE cs.child_id = $1
                  AND cs.ended_at IS NOT NULL
                  AND LOWER(l.title) LIKE '%história%'
            """, child_id)
            return story_sessions[0]['count'] >= count_needed

        return False