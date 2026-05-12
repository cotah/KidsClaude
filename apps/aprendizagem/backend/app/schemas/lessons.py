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
    description: str
    xp_reward: int
    order_index: int
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
    description: str
    age_band: str
    order_index: int
    content_blocks: List[ContentBlock]
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