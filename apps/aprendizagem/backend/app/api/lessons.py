"""
Rotas para lições, desafios e progresso.
Acessível por pais e crianças com diferentes permissões.
"""

import structlog
from typing import List, Optional
from fastapi import APIRouter, HTTPException, status, Query

from app.schemas.lessons import (
    LessonListItem, LessonDetail, ContentBlock,
    PromptTemplate, Challenge,
    LessonStartResponse, ChallengeAttemptRequest,
    ChallengeAttemptResponse
)
from app.schemas.children import LessonCompleteResponse, BadgeInfo
from app.core.dependencies import AnyAuth, ChildAuth, DBClient
from app.core import cache
from app.services.gamification import GamificationService

logger = structlog.get_logger()
router = APIRouter()

# TTL longo: lessons nao mudam fora de migrations. is_locked depende de
# progresso da crianca, por isso a key inclui user_id.
_LESSONS_CACHE_TTL = 3600


def _lessons_cache_key(stage: Optional[int], age_band: Optional[str], role: str, user_id: str) -> str:
    return f"lessons:stage:{stage or 'all'}:band:{age_band or 'auto'}:{role}:{user_id}"


@router.get("", response_model=List[LessonListItem])
async def list_lessons(
    auth: AnyAuth,
    db: DBClient,
    age_band: Optional[str] = Query(None, pattern="^(6-8|9-10|11-12|12\\+)$"),
    stage: Optional[int] = Query(None, ge=1, le=5)
):
    """
    Lista lições disponíveis.
    Filtra por faixa etária se especificada.

    Cache Redis 1h (lessons sao quase estaticos). is_locked depende do
    progresso da crianca, entao a key inclui user_id. Invalidado em
    lesson_complete pra refletir desbloqueios sem espera.
    """
    role = "child" if auth.is_child else "parent"
    cache_key = _lessons_cache_key(stage, age_band, role, str(auth.user_id))
    cached = await cache.get_json(cache_key)
    if cached is not None:
        try:
            return [LessonListItem(**item) for item in cached]
        except Exception as e:
            logger.warning("Cache de lessons com shape invalido - recomputando", error=str(e))

    try:
        # Determina faixa etária se não especificada e usuário é criança
        if not age_band and not stage and auth.is_child:
            child_data = await db.execute_query(
                "SELECT age FROM children WHERE id = $1",
                auth.user_id
            )
            if child_data:
                age = child_data[0]['age']
                if age <= 8:
                    age_band = '6-8'
                elif age <= 10:
                    age_band = '9-10'
                elif age <= 12:
                    age_band = '11-12'
                else:
                    age_band = '12+'

        # Monta query com filtro opcional
        where_clause = "WHERE is_active = true"
        params = []

        if age_band:
            where_clause += f" AND age_band = ${len(params) + 1}"
            params.append(age_band)

        if stage:
            where_clause += f" AND stage = ${len(params) + 1}"
            params.append(stage)

        lessons_data = await db.execute_query(f"""
            SELECT id, slug, title, description, xp_reward, order_index, stage,
                   is_final_exam, claude_model, prerequisites
            FROM lessons
            {where_clause}
            ORDER BY stage, order_index
        """, *params)

        # Para crianças, verificar quais lições estão bloqueadas por progressão de stage
        locked_lessons = set()
        if auth.is_child:
            # Busca progresso por stage para determinar bloqueio
            stage_progress = await db.execute_query("""
                SELECT
                    l.stage,
                    COUNT(*) as total_lessons,
                    COUNT(lp.status) FILTER (WHERE lp.status = 'completed') as completed_lessons
                FROM lessons l
                LEFT JOIN lesson_progress lp ON l.id = lp.lesson_id AND lp.child_id = $1
                WHERE l.is_active = true AND l.is_final_exam = false
                GROUP BY l.stage
                ORDER BY l.stage
            """, auth.user_id)

            # Cria mapa de stages completadas
            completed_stages = set()
            for stage_data in stage_progress:
                if stage_data['total_lessons'] == stage_data['completed_lessons']:
                    completed_stages.add(stage_data['stage'])

            # Para o final exam, verifica se todas as 4 stages estão completas
            final_exam_unlocked = {1, 2, 3, 4}.issubset(completed_stages)

            # Determina que lições estão bloqueadas
            for lesson in lessons_data:
                lesson_stage = lesson['stage']

                if lesson['is_final_exam']:
                    # Final exam bloqueado até todas as stages normais estarem completas
                    if not final_exam_unlocked:
                        locked_lessons.add(lesson['id'])
                elif lesson_stage > 1:
                    # Stages 2+ bloqueadas até a stage anterior estar 100% completa
                    if (lesson_stage - 1) not in completed_stages:
                        locked_lessons.add(lesson['id'])

        # Monta resposta
        lessons = []
        for lesson in lessons_data:
            lesson_item = LessonListItem(
                id=lesson['id'],
                slug=lesson['slug'],
                title=lesson['title'],
                description=lesson['description'],
                xp_reward=lesson['xp_reward'],
                order_index=lesson['order_index'],
                stage=lesson['stage'],
                is_final_exam=lesson['is_final_exam'],
                claude_model=lesson['claude_model'],
                prerequisites=lesson['prerequisites'] or [],
                is_locked=lesson['id'] in locked_lessons
            )
            lessons.append(lesson_item)

        logger.info("Lições listadas", count=len(lessons), age_band=age_band)
        # Cache best-effort apos computar.
        await cache.set_json(
            cache_key,
            [item.model_dump(mode="json") for item in lessons],
            ttl=_LESSONS_CACHE_TTL,
        )
        return lessons

    except Exception as e:
        logger.error("Erro ao listar lições", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.get("/{lesson_id}", response_model=LessonDetail)
async def get_lesson_detail(lesson_id: str, auth: AnyAuth, db: DBClient):
    """
    Retorna detalhes completos de uma lição.
    Inclui blocos de conteúdo, desafios e prompt templates.
    """
    try:
        # Busca lição. title_en/content_blocks_en vem da migration 010
        # (NULL pra dados antigos; OK porque o schema marca como Optional).
        lesson_data = await db.execute_query("""
            SELECT id, slug, title, title_en, description, age_band, order_index,
                   content_blocks, content_blocks_en, prerequisites, xp_reward,
                   stage, is_final_exam, claude_model
            FROM lessons
            WHERE id = $1 AND is_active = true
        """, lesson_id)

        if not lesson_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Lição não encontrada"}}
            )

        lesson = lesson_data[0]

        # Busca desafios da lição
        challenges_data = await db.execute_query("""
            SELECT id, kind, question, xp_reward
            FROM challenges
            WHERE lesson_id = $1
        """, lesson_id)

        challenges = [
            Challenge(
                id=ch['id'],
                kind=ch['kind'],
                question=ch['question'],
                xp_reward=ch['xp_reward']
            )
            for ch in challenges_data
        ]

        # Busca prompt templates
        templates_data = await db.execute_query("""
            SELECT id, label, template, slots, age_band, order_index
            FROM prompt_templates
            WHERE lesson_id = $1
            ORDER BY order_index
        """, lesson_id)

        templates = [
            PromptTemplate(
                id=t['id'],
                label=t['label'],
                template=t['template'],
                slots=t['slots'],
                age_band=t['age_band'],
                order_index=t['order_index']
            )
            for t in templates_data
        ]

        # Processa content_blocks (PT default)
        content_blocks = [
            ContentBlock(**block)
            for block in lesson['content_blocks']
        ]
        # Versao em ingles (None pra licoes nao traduzidas)
        content_blocks_en = None
        if lesson.get('content_blocks_en'):
            content_blocks_en = [
                ContentBlock(**block)
                for block in lesson['content_blocks_en']
            ]

        lesson_detail = LessonDetail(
            id=lesson['id'],
            slug=lesson['slug'],
            title=lesson['title'],
            title_en=lesson.get('title_en'),
            description=lesson['description'],
            age_band=lesson['age_band'],
            order_index=lesson['order_index'],
            stage=lesson['stage'],
            is_final_exam=lesson['is_final_exam'],
            claude_model=lesson['claude_model'],
            content_blocks=content_blocks,
            content_blocks_en=content_blocks_en,
            prerequisites=lesson['prerequisites'] or [],
            xp_reward=lesson['xp_reward'],
            challenges=challenges,
            prompt_templates=templates
        )

        return lesson_detail

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao buscar lição", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/{lesson_id}/start", response_model=LessonStartResponse, status_code=201)
async def start_lesson(lesson_id: str, auth: ChildAuth, db: DBClient):
    """
    Inicia uma lição para a criança.
    Cria registro de progresso se não existir.
    """
    try:
        # Verifica se lição existe e busca informações de stage
        lesson_data = await db.execute_query("""
            SELECT id, stage, is_final_exam FROM lessons
            WHERE id = $1 AND is_active = true
        """, lesson_id)

        if not lesson_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Lição não encontrada"}}
            )

        lesson = lesson_data[0]

        # Verifica se a lição está bloqueada por progressão de stage
        if lesson['stage'] > 1 or lesson['is_final_exam']:
            stage_progress = await db.execute_query("""
                SELECT
                    l.stage,
                    COUNT(*) as total_lessons,
                    COUNT(lp.status) FILTER (WHERE lp.status = 'completed') as completed_lessons
                FROM lessons l
                LEFT JOIN lesson_progress lp ON l.id = lp.lesson_id AND lp.child_id = $1
                WHERE l.is_active = true AND l.is_final_exam = false
                GROUP BY l.stage
                ORDER BY l.stage
            """, auth.user_id)

            completed_stages = set()
            for stage_data in stage_progress:
                if stage_data['total_lessons'] == stage_data['completed_lessons']:
                    completed_stages.add(stage_data['stage'])

            # Verifica bloqueio para final exam
            if lesson['is_final_exam']:
                if not {1, 2, 3, 4}.issubset(completed_stages):
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail={"error": {"code": "EXAM_LOCKED", "message": "Exame final bloqueado. Complete todas as 4 stages primeiro."}}
                    )
            # Verifica bloqueio para stages normais
            elif lesson['stage'] > 1:
                if (lesson['stage'] - 1) not in completed_stages:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail={"error": {"code": "LESSON_LOCKED", "message": "Esta lição ainda está bloqueada. Termine a stage anterior primeiro."}}
                    )

        # Verifica se já existe progresso
        existing_progress = await db.execute_query("""
            SELECT id, status FROM lesson_progress
            WHERE child_id = $1 AND lesson_id = $2
        """, auth.user_id, lesson_id)

        if existing_progress and existing_progress[0]['status'] != 'not_started':
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"error": {"code": "ALREADY_STARTED", "message": "Lição já iniciada"}}
            )

        # Cria ou atualiza progresso
        if existing_progress:
            progress_id = existing_progress[0]['id']
            await db.execute_non_query("""
                UPDATE lesson_progress
                SET status = 'in_progress', started_at = NOW(), updated_at = NOW()
                WHERE id = $1
            """, progress_id)
        else:
            result = await db.execute_query("""
                INSERT INTO lesson_progress (child_id, lesson_id, status, started_at)
                VALUES ($1, $2, 'in_progress', NOW())
                RETURNING id
            """, auth.user_id, lesson_id)
            progress_id = result[0]['id']

        logger.info("Lição iniciada", child_id=auth.user_id, lesson_id=lesson_id)

        return LessonStartResponse(
            progress_id=progress_id,
            status='in_progress'
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao iniciar lição", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/{lesson_id}/complete", response_model=LessonCompleteResponse)
async def complete_lesson(lesson_id: str, auth: ChildAuth, db: DBClient):
    """
    Marca lição como concluída e concede XP.
    Verifica badges desbloqueados.
    """
    try:
        # Verifica se progresso existe e não está concluído
        progress_data = await db.execute_query("""
            SELECT id, status, xp_earned FROM lesson_progress
            WHERE child_id = $1 AND lesson_id = $2
        """, auth.user_id, lesson_id)

        if not progress_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Lição não iniciada"}}
            )

        progress = progress_data[0]

        if progress['status'] == 'completed':
            # Já concluída, retorna dados atuais sem conceder XP novamente.
            # xp_earned=0 sinaliza pro frontend que nao houve recompensa nova.
            current_child = await db.execute_query(
                "SELECT xp, level FROM children WHERE id = $1",
                auth.user_id
            )
            return LessonCompleteResponse(
                xp_earned=0,
                xp_total=current_child[0]['xp'],
                level=current_child[0]['level'],
                badges_unlocked=[]
            )

        # Busca XP da lição
        lesson_data = await db.execute_query(
            "SELECT xp_reward FROM lessons WHERE id = $1",
            lesson_id
        )
        xp_reward = lesson_data[0]['xp_reward']

        # Marca como concluída
        await db.execute_non_query("""
            UPDATE lesson_progress
            SET status = 'completed', completed_at = NOW(), xp_earned = $1, updated_at = NOW()
            WHERE id = $2
        """, xp_reward, progress['id'])

        # Verifica se uma nova stage foi desbloqueada após esta conclusão
        lesson_stage_data = await db.execute_query(
            "SELECT stage FROM lessons WHERE id = $1",
            lesson_id
        )
        completed_lesson_stage = lesson_stage_data[0]['stage'] if lesson_stage_data else None

        stage_unlocked = None
        if completed_lesson_stage and completed_lesson_stage < 5:  # Não é final exam
            # Verifica se todas as lições da stage atual estão completas agora
            stage_progress = await db.execute_query("""
                SELECT
                    COUNT(*) as total_lessons,
                    COUNT(lp.status) FILTER (WHERE lp.status = 'completed') as completed_lessons
                FROM lessons l
                LEFT JOIN lesson_progress lp ON l.id = lp.lesson_id AND lp.child_id = $1
                WHERE l.stage = $2 AND l.is_active = true AND l.is_final_exam = false
            """, auth.user_id, completed_lesson_stage)

            if stage_progress:
                progress = stage_progress[0]
                if progress['total_lessons'] == progress['completed_lessons']:
                    # Stage completa - próxima stage (ou final exam) desbloqueada
                    if completed_lesson_stage < 4:
                        stage_unlocked = completed_lesson_stage + 1
                    else:
                        stage_unlocked = 5  # Final exam unlocked

        # Concede XP e verifica badges
        gamification = GamificationService(db)
        result = await gamification.award_xp(auth.user_id, xp_reward, 'lesson_completed')

        # Atualiza streak
        await gamification.update_streak(auth.user_id)

        logger.info("Lição concluída", child_id=auth.user_id, lesson_id=lesson_id, xp=xp_reward, stage_unlocked=stage_unlocked)

        # Invalida caches dependentes do progresso da crianca.
        # Stages: progresso por stage muda. Lessons: is_locked pode mudar
        # quando uma stage e' completada. Falha silenciosa se Redis off.
        await cache.delete(f"stages:child:{auth.user_id}")
        await cache.delete_pattern(f"lessons:*:child:{auth.user_id}")

        # Formata badges desbloqueados
        badges_unlocked = [
            BadgeInfo(**badge) for badge in result['badges_unlocked']
        ]

        return LessonCompleteResponse(
            xp_earned=xp_reward,
            xp_total=result['xp_total'],
            level=result['level'],
            badges_unlocked=badges_unlocked,
            stage_unlocked=stage_unlocked
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro ao concluir lição", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/challenges/{challenge_id}/attempt", response_model=ChallengeAttemptResponse)
async def attempt_challenge(
    challenge_id: str,
    request: ChallengeAttemptRequest,
    auth: ChildAuth,
    db: DBClient
):
    """
    Submete tentativa de desafio.
    Concede XP se correta.
    """
    try:
        # Busca desafio
        challenge_data = await db.execute_query("""
            SELECT id, kind, question, correct_answer, xp_reward
            FROM challenges
            WHERE id = $1
        """, challenge_id)

        if not challenge_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": {"code": "NOT_FOUND", "message": "Desafio não encontrado"}}
            )

        challenge = challenge_data[0]

        # Avalia resposta
        is_correct = False
        if challenge['kind'] == 'multiple_choice':
            correct_index = challenge['correct_answer'].get('answer')
            user_answer = request.answer.get('answer')
            is_correct = user_answer == correct_index

        # Calcula XP (menos na segunda tentativa em diante)
        previous_attempts = await db.execute_query("""
            SELECT COUNT(*) as count FROM challenge_attempts
            WHERE child_id = $1 AND challenge_id = $2
        """, auth.user_id, challenge_id)

        attempt_count = previous_attempts[0]['count']
        xp_earned = 0

        if is_correct:
            if attempt_count == 0:
                xp_earned = challenge['xp_reward']  # Primeira tentativa
            else:
                xp_earned = challenge['xp_reward'] // 2  # Tentativas seguintes

        # Registra tentativa
        await db.execute_non_query("""
            INSERT INTO challenge_attempts (child_id, challenge_id, answer, is_correct, xp_earned)
            VALUES ($1, $2, $3, $4, $5)
        """, auth.user_id, challenge_id, request.answer, is_correct, xp_earned)

        # Concede XP se ganhou
        if xp_earned > 0:
            gamification = GamificationService(db)
            await gamification.award_xp(auth.user_id, xp_earned, 'challenge_completed')

        logger.info("Tentativa de desafio", child_id=auth.user_id, challenge_id=challenge_id,
                   correct=is_correct, xp=xp_earned)

        # Resposta inclui answer correto apenas se errou
        response = ChallengeAttemptResponse(
            is_correct=is_correct,
            xp_earned=xp_earned
        )

        if not is_correct:
            response.correct_answer = challenge['correct_answer']

        return response

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erro na tentativa de desafio", error=str(e))
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)