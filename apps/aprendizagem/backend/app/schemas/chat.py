"""
Schemas para chat com Claude: sessões, mensagens, moderação.
"""

from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional
from datetime import datetime


class ChatSessionCreateRequest(BaseModel):
    lesson_id: str


class ChatSessionCreateResponse(BaseModel):
    session_id: str
    started_at: datetime


class MessageSendRequest(BaseModel):
    """
    Mensagem da crianca pro chat. Aceita 2 formas:
      - template_id (+ slots opcionais): texto vem do prompt_template
        curado (modo "sugestao clicada"). Bypass de blocklist.
      - content: texto livre digitado pela crianca. Limite REAL depende
        da idade (200/500/1000/2000) e e' aplicado no endpoint a partir
        de session['age']. O max_length=2000 aqui e' so' o teto absoluto
        anti-abuso de payload, nao a regra de produto.
    Pelo menos um dos dois e' obrigatorio. Validacao no endpoint.
    """
    template_id: Optional[str] = None
    slots: Optional[Dict[str, str]] = Field(None, description="Valores para slots do template")
    content: Optional[str] = Field(None, max_length=2000, description="Texto livre digitado pela crianca")


class AssistantMessage(BaseModel):
    content: str
    moderation_status: str  # 'passed', 'blocked'


class MessageSendResponse(BaseModel):
    message_id: str
    assistant_message: AssistantMessage


class ChatMessage(BaseModel):
    id: str
    role: str  # 'child', 'assistant', 'system'
    content: str
    template_id: Optional[str]
    moderation_status: str
    moderation_reason: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class ChatSession(BaseModel):
    id: str
    child_id: str
    lesson_id: str
    started_at: datetime
    ended_at: Optional[datetime]
    safety_status: str
    summary: Optional[str]
    message_count: int

    class Config:
        from_attributes = True


class ChatSessionDetailResponse(BaseModel):
    session: ChatSession
    messages: List[ChatMessage]


class ChatSessionEndResponse(BaseModel):
    summary: str
    safety_status: str


class SessionListItem(BaseModel):
    id: str
    lesson_id: str
    lesson_title: str
    started_at: datetime
    ended_at: Optional[datetime]
    safety_status: str
    summary: Optional[str]
    message_count: int

    class Config:
        from_attributes = True


class SessionListResponse(BaseModel):
    sessions: List[SessionListItem]
    total: int
    limit: int
    offset: int


class HeartbeatRequest(BaseModel):
    seconds: int = Field(..., ge=1, le=3600, description="Segundos de atividade")


class HeartbeatResponse(BaseModel):
    minutes_today: int
    limit: int
    blocked: bool