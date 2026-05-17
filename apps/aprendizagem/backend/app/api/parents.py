"""
Rotas do painel de pais: dashboard, uso, eventos de segurança.
"""

import structlog
from typing import List
from datetime import datetime, date
from fastapi import APIRouter, HTTPException, Request, status, Query

from app.schemas.children import ParentDashboardResponse, DashboardChildCard, BadgeInfo
from app.schemas.common import UsageResponse, UsageEntry, SafetyEventsResponse, SafetyEvent
from app.core.dependencies import ParentAuth, DBClient
from app.core.timezone import user_today

logger = structlog.get_logger()
router = APIRouter()


@router.get("/dashboard", response_model=ParentDashboardResponse)
async def get_parent_dashboard(auth: ParentAuth, db: DBClient, http_request: Request):
    """
    Painel principal do pai com resumo de todos os filhos.
    Mostra progresso, badges recentes, alertas de segurança.
    """
    try:
        # "Hoje" no fuso do usuario (X-Timezone do BFF). Sem isso, "today_minutes"
        # nao casa com as rows que o heartbeat escreveu na data local do filho.
        today = user_today(http_request)
        # Busca dados básicos dos filhos
        children_data = await db.execute_query("""
            SELECT id, name, age, avatar_id, xp, level, streak_days
            FROM children
            WHERE parent_id = $1
            ORDER BY created_at ASC
        """, auth.user_id)

        dashboard_children = []

        for child in children_data:
            child_id = child['id']

            # Minutos usados hoje (date computada acima a partir do header)
            usage_data = await db.execute_query("""
                SELECT COALESCE(minutes_used, 0) as minutes_today
                FROM daily_usage
                WHERE child_id = $1 AND usage_date = $2
            """, child_id, today)

            today_minutes = int(usage_data[0]['minutes_today']) if usage_data else 0

            # Badges recentes (últimos 7 dias)
            recent_badges_data = await db.execute_query("""
                SELECT b.id, b.code, b.name, b.description, b.icon, cb.awarded_at
                FROM child_badges cb
                JOIN badges b ON cb.badge_id = b.id
                WHERE cb.child_id = $1 AND cb.awarded_at >= NOW() - INTERVAL '7 days'
                ORDER BY cb.awarded_at DESC
                LIMIT 3
            """, child_id)

            recent_badges = [
                BadgeInfo(**badge) for badge in recent_badges_data
            ]

            # Total de badges desbloqueados (count real, sem limite/janela).
            # recent_badges acima e' apenas os 3 mais recentes dos ultimos 7
            # dias para preview - nao serve como total.
            badges_count_data = await db.execute_query(
                "SELECT COUNT(*) AS total FROM child_badges WHERE child_id = $1",
                child_id,
            )
            badges_count = int(badges_count_data[0]['total']) if badges_count_data else 0

            # Alertas de segurança não vistos (últimos 30 dias)
            alerts_data = await db.execute_query("""
                SELECT COUNT(*) as alerts_count
                FROM child_safety_events
                WHERE child_id = $1 AND created_at >= NOW() - INTERVAL '30 days'
            """, child_id)

            alerts_count = alerts_data[0]['alerts_count']

            # Monta card do filho
            child_card = DashboardChildCard(
                id=child['id'],
                name=child['name'],
                age=child['age'],
                avatar_id=child['avatar_id'],
                xp=child['xp'],
                level=child['level'],
                streak_days=child['streak_days'],
                today_minutes=today_minutes,
                recent_badges=recent_badges,
                badges_count=badges_count,
                alerts_count=alerts_count
            )

            dashboard_children.append(child_card)

        logger.info("Dashboard carregado", parent_id=auth.user_id, children_count=len(dashboard_children))

        return ParentDashboardResponse(children=dashboard_children)

    except Exception as e:
        logger.error("Erro ao carregar dashboard", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/children/{child_id}/usage", response_model=UsageResponse)
async def get_child_usage(
    child_id: str,
    auth: ParentAuth,
    db: DBClient,
    http_request: Request,
    from_date: date = Query(None, description="Data inicial (YYYY-MM-DD)"),
    to_date: date = Query(None, description="Data final (YYYY-MM-DD)")
):
    """
    Histórico de uso diário de uma criança.
    Por padrão, últimos 30 dias.
    """
    try:
        # Verifica propriedade
        child_data = await db.execute_query(
            "SELECT id FROM children WHERE id = $1 AND parent_id = $2",
            child_id, auth.user_id
        )

        if not child_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        # Define intervalo de datas (default "hoje" no fuso do usuario)
        if not to_date:
            to_date = user_today(http_request)

        if not from_date:
            from_date = date(to_date.year, to_date.month, to_date.day - 30)

        # Busca dados de uso
        usage_data = await db.execute_query("""
            SELECT usage_date, minutes_used
            FROM daily_usage
            WHERE child_id = $1
              AND usage_date BETWEEN $2 AND $3
            ORDER BY usage_date DESC
        """, child_id, from_date, to_date)

        usage_entries = [
            UsageEntry(date=row['usage_date'], minutes_used=int(row['minutes_used']))
            for row in usage_data
        ]

        return UsageResponse(usage=usage_entries)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar uso", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/children/{child_id}/safety-events", response_model=SafetyEventsResponse)
async def get_child_safety_events(
    child_id: str,
    auth: ParentAuth,
    db: DBClient,
    limit: int = Query(50, ge=1, le=200)
):
    """
    Lista eventos de segurança de uma criança.
    Ordenados por data mais recente.
    """
    try:
        # Verifica propriedade
        child_data = await db.execute_query(
            "SELECT id FROM children WHERE id = $1 AND parent_id = $2",
            child_id, auth.user_id
        )

        if not child_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        # Busca eventos de segurança
        events_data = await db.execute_query("""
            SELECT id, kind, details, session_id, created_at
            FROM child_safety_events
            WHERE child_id = $1
            ORDER BY created_at DESC
            LIMIT $2
        """, child_id, limit)

        events = [
            SafetyEvent(
                id=event['id'],
                kind=event['kind'],
                details=event['details'],
                session_id=event['session_id'],
                created_at=event['created_at'].isoformat()
            )
            for event in events_data
        ]

        logger.info("Eventos de segurança listados", child_id=child_id, count=len(events))

        return SafetyEventsResponse(events=events)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar eventos de segurança", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)