"""
Rotas para stages do curriculum.
Endpoint /v1/stages conforme especificação.
"""

import structlog
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, HTTPException, status

from app.schemas.lessons import StagesResponse, StageInfo, FinalExamInfo
from app.core.dependencies import AnyAuth, DBClient

logger = structlog.get_logger()
router = APIRouter()


@router.get("", response_model=StagesResponse)
async def get_stages(auth: AnyAuth, db: DBClient):
    """
    Retorna informações sobre as 4 stages e o exame final.
    Calcula progresso e status de desbloqueio para a criança.
    """
    try:
        # Define informações estáticas das stages
        stage_info = {
            1: {"name": "Discovery", "description": "Vamos descobrir o que e IA", "age_band_label": "6-8 anos", "difficulty": "easy"},
            2: {"name": "Exploration", "description": "Entender como prompts funcionam", "age_band_label": "9-10 anos", "difficulty": "medium"},
            3: {"name": "Creation", "description": "Criar coisas com o Claude", "age_band_label": "11-12 anos", "difficulty": "hard"},
            4: {"name": "Prompt Engineering", "description": "Técnicas avançadas de prompting", "age_band_label": "12+ anos", "difficulty": "advanced"}
        }

        # Busca progresso por stage. Duas queries separadas para evitar passar
        # NULL como child_id (asyncpg pode reclamar do tipo). Pai ve' progresso
        # zerado (so' contagem total de licoes); crianca ve' o proprio progresso.
        if auth.is_child:
            stage_progress = await db.execute_query(
                """
                SELECT
                    l.stage,
                    COUNT(*) AS total_lessons,
                    COUNT(lp.status) FILTER (WHERE lp.status = 'completed') AS completed_lessons
                FROM lessons l
                LEFT JOIN lesson_progress lp
                  ON l.id = lp.lesson_id AND lp.child_id = $1
                WHERE l.is_active = true AND l.is_final_exam = false
                GROUP BY l.stage
                ORDER BY l.stage
                """,
                auth.user_id,
            )
        else:
            stage_progress = await db.execute_query(
                """
                SELECT
                    l.stage,
                    COUNT(*) AS total_lessons,
                    0 AS completed_lessons
                FROM lessons l
                WHERE l.is_active = true AND l.is_final_exam = false
                GROUP BY l.stage
                ORDER BY l.stage
                """
            )

        # Cria mapa de progresso
        progress_map = {}
        completed_stages = set()
        for stage_data in stage_progress:
            stage_num = stage_data['stage']
            total = stage_data['total_lessons']
            completed = stage_data['completed_lessons'] or 0
            progress_map[stage_num] = {"total": total, "completed": completed}
            if total == completed and completed > 0:
                completed_stages.add(stage_num)

        # Monta resposta das stages
        stages = []
        for stage_num in range(1, 5):
            info = stage_info[stage_num]
            progress = progress_map.get(stage_num, {"total": 0, "completed": 0})

            # Stage 1 sempre desbloqueada, outras dependem da anterior estar completa
            is_unlocked = stage_num == 1 or (stage_num - 1) in completed_stages

            stages.append(StageInfo(
                stage=stage_num,
                name=info["name"],
                description=info["description"],
                age_band_label=info["age_band_label"],
                difficulty=info["difficulty"],
                is_unlocked=is_unlocked,
                lessons_total=progress["total"],
                lessons_completed=progress["completed"],
                is_completed=progress["total"] > 0 and progress["total"] == progress["completed"]
            ))

        # Busca informações do exame final
        final_exam_data = await db.execute_query("""
            SELECT id, claude_model FROM lessons
            WHERE is_final_exam = true AND is_active = true
            LIMIT 1
        """)

        if final_exam_data:
            exam_lesson_id = final_exam_data[0]['id']
            claude_model = final_exam_data[0]['claude_model']

            # Verifica se exame foi completado
            exam_completed = False
            if auth.is_child:
                exam_progress = await db.execute_query("""
                    SELECT status FROM lesson_progress
                    WHERE child_id = $1 AND lesson_id = $2
                """, auth.user_id, exam_lesson_id)
                # bool() forca o tipo - sem isso "and" pode devolver lista vazia
                # (falsy) em vez de False e Pydantic v2 rejeita is_completed: bool.
                exam_completed = bool(
                    exam_progress and exam_progress[0]['status'] == 'completed'
                )

            # Exame desbloqueado se todas as 4 stages estão completas
            exam_unlocked = {1, 2, 3, 4}.issubset(completed_stages)

            final_exam = FinalExamInfo(
                lesson_id=exam_lesson_id,
                is_unlocked=exam_unlocked,
                is_completed=exam_completed,
                label="Projeto Final",
                claude_model=claude_model
            )
        else:
            # Fallback se exame não encontrado
            final_exam = FinalExamInfo(
                lesson_id="",
                is_unlocked=False,
                is_completed=False,
                label="Projeto Final",
                claude_model="claude-sonnet-4-6"
            )

        return StagesResponse(stages=stages, final_exam=final_exam)

    except HTTPException:
        raise
    except Exception as e:
        # logger.exception inclui o traceback completo nos logs do Railway.
        # Tambem incluimos `detail` no HTTPException para o frontend mostrar
        # a mensagem real em vez do fallback "Erro desconhecido".
        logger.exception("Erro ao buscar stages", error=str(e), error_type=type(e).__name__)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": {
                "code": "STAGES_ERROR",
                "message": f"Falha ao buscar stages: {type(e).__name__}: {str(e)}",
            }},
        )