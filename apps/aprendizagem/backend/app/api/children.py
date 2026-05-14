"""
Rotas para operações CRUD de crianças.
Apenas pais podem gerenciar perfis de filhos.
"""

import asyncpg
import structlog
from typing import List
from fastapi import APIRouter, HTTPException, status

from app.schemas.children import (
    ChildCreateRequest, ChildUpdateRequest, ChildResponse,
    ChildProgressResponse, ChildProgressEntry,
    ParentDashboardResponse, DashboardChildCard,
    BadgeInfo
)
from app.schemas.common import ErrorResponse
from app.core.dependencies import ParentAuth, AnyAuth, DBClient
from app.core.security import hash_pin

logger = structlog.get_logger()
router = APIRouter()


@router.get("", response_model=List[ChildResponse])
async def list_children(auth: AnyAuth, db: DBClient):
    """
    Lista filhos. Pai recebe todos os seus; crianca recebe apenas a si propria.
    Aceitar ambas as auths evita 401 quando o app de crianca (BFF envia o
    child token) toca este endpoint via cache de query compartilhada.
    """
    try:
        if auth.is_parent:
            children_data = await db.execute_query("""
                SELECT id, parent_id, name, username, age, avatar_id,
                       daily_limit_minutes, level, xp, streak_days,
                       last_active_date, created_at,
                       (pin_hash IS NOT NULL) AS pin_set
                FROM children
                WHERE parent_id = $1
                ORDER BY created_at ASC
            """, auth.user_id)
        else:  # crianca - retorna so' o proprio registro
            children_data = await db.execute_query("""
                SELECT id, parent_id, name, username, age, avatar_id,
                       daily_limit_minutes, level, xp, streak_days,
                       last_active_date, created_at,
                       (pin_hash IS NOT NULL) AS pin_set
                FROM children
                WHERE id = $1
            """, auth.user_id)

        children = [ChildResponse(**child) for child in children_data]
        logger.info("Filhos listados", role=auth.role, count=len(children))

        return children

    except Exception as e:
        logger.error("Erro ao listar filhos", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("", response_model=ChildResponse, status_code=201)
async def create_child(request: ChildCreateRequest, auth: ParentAuth, db: DBClient):
    """
    Cria novo perfil de criança para o pai autenticado.
    Limite de 5 filhos por pai no MVP.
    """
    try:
        # Verifica limite de 5 filhos
        count_result = await db.execute_query(
            "SELECT COUNT(*) as count FROM children WHERE parent_id = $1",
            auth.user_id
        )

        if count_result[0]['count'] >= 5:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {"code": "CHILD_LIMIT", "message": "Limite de 5 filhos atingido"}}
            )

        # Hash do PIN se fornecido
        pin_hash = hash_pin(request.pin) if request.pin else None

        # Insere criança. Username e' UNIQUE - a violacao volta como
        # asyncpg.UniqueViolationError, traduzida em 409 abaixo.
        try:
            result = await db.execute_query("""
                INSERT INTO children (parent_id, name, username, age, avatar_id,
                                      pin_hash, daily_limit_minutes)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING id, parent_id, name, username, age, avatar_id,
                          daily_limit_minutes, level, xp, streak_days,
                          last_active_date, created_at,
                          (pin_hash IS NOT NULL) AS pin_set
            """, auth.user_id, request.name, request.username, request.age,
                 request.avatar_id, pin_hash, request.daily_limit_minutes)
        except asyncpg.UniqueViolationError:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {
                    "code": "USERNAME_TAKEN",
                    "message": "Este nome de utilizador já está em uso. Escolha outro.",
                }},
            )

        child_data = result[0]
        logger.info("Criança criada", child_id=child_data['id'], parent_id=auth.user_id)

        return ChildResponse(**child_data)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao criar criança", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/{child_id}", response_model=ChildResponse)
async def get_child(child_id: str, auth: ParentAuth, db: DBClient):
    """
    Retorna detalhes de uma criança específica.
    """
    try:
        child_data = await db.execute_query("""
            SELECT id, parent_id, name, username, age, avatar_id,
                   daily_limit_minutes, level, xp, streak_days,
                   last_active_date, created_at,
                   (pin_hash IS NOT NULL) AS pin_set
            FROM children
            WHERE id = $1 AND parent_id = $2
        """, child_id, auth.user_id)

        if not child_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        return ChildResponse(**child_data[0])

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar criança", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.patch("/{child_id}", response_model=ChildResponse)
async def update_child(child_id: str, request: ChildUpdateRequest, auth: ParentAuth, db: DBClient):
    """
    Atualiza dados de uma criança.
    Apenas campos fornecidos são atualizados.
    """
    try:
        # Verifica propriedade
        child_exists = await db.execute_query(
            "SELECT id FROM children WHERE id = $1 AND parent_id = $2",
            child_id, auth.user_id
        )

        if not child_exists:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        # Monta query dinâmica com apenas campos fornecidos
        update_fields = []
        params = []
        param_count = 1

        if request.name is not None:
            update_fields.append(f"name = ${param_count}")
            params.append(request.name)
            param_count += 1

        if request.username is not None:
            update_fields.append(f"username = ${param_count}")
            params.append(request.username)
            param_count += 1

        if request.age is not None:
            update_fields.append(f"age = ${param_count}")
            params.append(request.age)
            param_count += 1

        if request.avatar_id is not None:
            update_fields.append(f"avatar_id = ${param_count}")
            params.append(request.avatar_id)
            param_count += 1

        if request.pin is not None:
            update_fields.append(f"pin_hash = ${param_count}")
            params.append(hash_pin(request.pin))
            param_count += 1

        if request.daily_limit_minutes is not None:
            update_fields.append(f"daily_limit_minutes = ${param_count}")
            params.append(request.daily_limit_minutes)
            param_count += 1

        if not update_fields:
            # Nenhum campo para atualizar, retorna dados atuais
            return await get_child(child_id, auth, db)

        # Adiciona updated_at
        update_fields.append("updated_at = NOW()")
        params.extend([child_id, auth.user_id])

        query = f"""
            UPDATE children
            SET {', '.join(update_fields)}
            WHERE id = ${param_count} AND parent_id = ${param_count + 1}
            RETURNING id, parent_id, name, username, age, avatar_id,
                      daily_limit_minutes, level, xp, streak_days,
                      last_active_date, created_at,
                      (pin_hash IS NOT NULL) AS pin_set
        """

        try:
            result = await db.execute_query(query, *params)
        except asyncpg.UniqueViolationError:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {
                    "code": "USERNAME_TAKEN",
                    "message": "Este nome de utilizador já está em uso. Escolha outro.",
                }},
            )
        logger.info("Criança atualizada", child_id=child_id)

        return ChildResponse(**result[0])

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao atualizar criança", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.delete("/{child_id}", status_code=204)
async def delete_child(child_id: str, auth: ParentAuth, db: DBClient):
    """
    Deleta uma criança e todos os dados relacionados.
    Operação irreversível - cascade delete.
    """
    try:
        result = await db.execute_non_query(
            "DELETE FROM children WHERE id = $1 AND parent_id = $2",
            child_id, auth.user_id
        )

        if result == "DELETE 0":
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
            )

        logger.info("Criança deletada", child_id=child_id, parent_id=auth.user_id)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao deletar criança", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/{child_id}/progress", response_model=ChildProgressResponse)
async def get_child_progress(child_id: str, auth: AnyAuth, db: DBClient):
    """
    Retorna progresso de licoes da crianca.
    - Pai: ve progresso de qualquer filho seu.
    - Crianca: ve apenas o proprio progresso.
    """
    try:
        # Autorizacao depende do role
        if auth.is_child:
            if auth.user_id != child_id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail={"error": {"code": "FORBIDDEN", "message": "Acesso negado"}}
                )
        else:  # parent
            child_exists = await db.execute_query(
                "SELECT id FROM children WHERE id = $1 AND parent_id = $2",
                child_id, auth.user_id
            )
            if not child_exists:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
                )

        # Busca progresso
        progress_data = await db.execute_query("""
            SELECT lesson_id, status, xp_earned, started_at, completed_at
            FROM lesson_progress
            WHERE child_id = $1
            ORDER BY started_at DESC
        """, child_id)

        progress = [ChildProgressEntry(**item) for item in progress_data]

        return ChildProgressResponse(progress=progress)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar progresso", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


async def _ensure_owns_child(child_id: str, parent_id: str, db) -> None:
    """Levanta 404 se a crianca nao existir ou nao pertencer ao pai."""
    rows = await db.execute_query(
        "SELECT id FROM children WHERE id = $1 AND parent_id = $2",
        child_id, parent_id
    )
    if not rows:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": {"code": "NOT_FOUND", "message": "Criança não encontrada"}}
        )


@router.get("/{child_id}/badges")
async def get_child_badges(child_id: str, auth: ParentAuth, db: DBClient):
    """
    Lista conquistas (badges) desbloqueadas pela crianca.
    Retorna envelope { badges: [...] } - array vazio se ainda nada.
    """
    try:
        await _ensure_owns_child(child_id, auth.user_id, db)

        rows = await db.execute_query(
            """
            SELECT b.id, b.code, b.name, b.description, b.icon, cb.awarded_at
            FROM child_badges cb
            JOIN badges b ON cb.badge_id = b.id
            WHERE cb.child_id = $1
            ORDER BY cb.awarded_at DESC
            """,
            child_id,
        )

        return {
            "badges": [
                {
                    "id": str(row["id"]),
                    "code": row["code"],
                    "name": row["name"],
                    "description": row["description"],
                    "icon": row["icon"],
                    "awarded_at": (
                        row["awarded_at"].isoformat() if row["awarded_at"] else None
                    ),
                }
                for row in rows
            ]
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar badges", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/{child_id}/safety-events")
async def get_child_safety_events(
    child_id: str,
    auth: ParentAuth,
    db: DBClient,
    limit: int = 50,
):
    """
    Lista eventos de seguranca da crianca (input_blocked, output_blocked,
    session_terminated). So' o pai pode ver. Retorna { events: [...] }.
    """
    try:
        await _ensure_owns_child(child_id, auth.user_id, db)

        limit = max(1, min(limit, 200))

        rows = await db.execute_query(
            """
            SELECT id, kind, details, session_id, created_at
            FROM child_safety_events
            WHERE child_id = $1
            ORDER BY created_at DESC
            LIMIT $2
            """,
            child_id, limit,
        )

        return {
            "events": [
                {
                    "id": str(row["id"]),
                    "kind": row["kind"],
                    "details": row["details"],
                    "session_id": (
                        str(row["session_id"]) if row["session_id"] else None
                    ),
                    "created_at": (
                        row["created_at"].isoformat() if row["created_at"] else None
                    ),
                }
                for row in rows
            ]
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar eventos de seguranca", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/{child_id}/usage")
async def get_child_usage_history(
    child_id: str,
    auth: ParentAuth,
    db: DBClient,
    days: int = 30,
):
    """
    Historico de uso diario (minutos por dia) dos ultimos `days` dias.
    Retorna envelope { usage: [...] } - array vazio se ainda nada.
    Aceita `?days=N` (default 30, clamp 1..365).
    """
    try:
        await _ensure_owns_child(child_id, auth.user_id, db)

        days = max(1, min(days, 365))

        rows = await db.execute_query(
            """
            SELECT usage_date, minutes_used
            FROM daily_usage
            WHERE child_id = $1
              AND usage_date >= CURRENT_DATE - ($2::int * INTERVAL '1 day')
            ORDER BY usage_date DESC
            """,
            child_id, days,
        )

        return {
            "usage": [
                {
                    "date": (
                        row["usage_date"].isoformat() if row["usage_date"] else None
                    ),
                    "minutes_used": int(row["minutes_used"] or 0),
                }
                for row in rows
            ]
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar uso diario", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)