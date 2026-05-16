"""
Schemas para lições, desafios e progresso.
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime


class ContentBlock(BaseModel):
    type: str  # 'text', 'image', 'video', 'animation'
    content: Optional[str] = None
    src: Optional[str] = None
    alt: Optional[str] = None


class LessonListItem(BaseModel):
    id: str
    slug: str
    title: str
    title_en: Optional[str] = None
    description: str
    description_en: Optional[str] = None
    xp_reward: int
    order_index: int
    stage: int
    is_final_exam: bool
    claude_model: str
    is_locked: bool = False
    prerequisites: List[str] = []

    class Config:
        from_attributes = True


class PromptTemplate(BaseModel):
    id: str
    label: str
    template: str
    slots: Optional[List[Dict[str, Any]]] = None
    age_band: str
    order_index: int


class Challenge(BaseModel):
    id: str
    kind: str  # 'multiple_choice', 'fill_prompt'
    question: Dict[str, Any]
    xp_reward: int


class LessonDetail(BaseModel):
    id: str
    slug: str
    title: str
    # Versao em ingles do titulo + conteudo (migration 010). None pra dados
    # antigos que nao foram traduzidos. Frontend escolhe baseado no locale.
    title_en: Optional[str] = None
    description: str
    description_en: Optional[str] = None
    age_band: str
    order_index: int
    stage: int
    is_final_exam: bool
    claude_model: str
    content_blocks: List[ContentBlock]
    content_blocks_en: Optional[List[ContentBlock]] = None
    prerequisites: List[str]
    xp_reward: int
    challenges: List[Challenge]
    prompt_templates: List[PromptTemplate]

    class Config:
        from_attributes = True


class LessonStartResponse(BaseModel):
    progress_id: str
    status: str


class ChallengeAttemptRequest(BaseModel):
    answer: Dict[str, Any]


class ChallengeAttemptResponse(BaseModel):
    is_correct: bool
    xp_earned: int
    correct_answer: Optional[Dict[str, Any]] = None


class StageInfo(BaseModel):
    stage: int
    name: str
    description: str
    age_band_label: str
    difficulty: str
    is_unlocked: bool
    lessons_total: int
    lessons_completed: int
    is_completed: bool


class FinalExamInfo(BaseModel):
    lesson_id: str
    is_unlocked: bool
    is_completed: bool
    label: str
    claude_model: str


class StagesResponse(BaseModel):
    stages: List[StageInfo]
    final_exam: FinalExamInfo


class ExamStartResponse(BaseModel):
    session_id: str
    started_at: datetime
    lesson_id: str
    # Primeira fala da Atena, adaptada por faixa etaria + locale. Antes
    # era hardcoded no frontend; mover pra ca permite variar tom e
    # idioma sem deploy do frontend.
    opening_message: str


class ExamMessageRequest(BaseModel):
    content: str


class ExamMessageResponse(BaseModel):
    message_id: str
    assistant_message: Dict[str, Any]
    current_step: int
    is_complete: bool


class ExamSubmitResponse(BaseModel):
    xp_earned: int
    badges_unlocked: List[str]
    summary: str
    plan: Dict[str, Any]


class ExamMessage(BaseModel):
    role: str  # 'child' | 'assistant'
    content: str


class ExamActiveSessionResponse(BaseModel):
    """Estado completo de uma sessao de exame ativa pra restaurar a UI
    apos reload. Apresenta todo o historico que estava no DB mais step
    atual + flag de conclusao - frontend usa pra continuar do ponto onde
    parou em vez de comecar do zero (e mostrar conversa que a Atena
    ja viu mas a crianca nao)."""
    session_id: str
    started_at: datetime
    lesson_id: str
    messages: List[ExamMessage]
    current_step: int
    is_complete: bool