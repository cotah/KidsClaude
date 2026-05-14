"""
Schemas para operações com crianças: CRUD, progresso, badges.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import date, datetime


class ChildCreateRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=30)
    # username e' obrigatorio: e' o login da crianca em /crianca. Formato:
    # 3-30 chars, lowercase + digitos + hifen. Sem maiusculas, espacos ou
    # acentos pra evitar problemas de teclado mobile e login case-sensitive.
    username: str = Field(..., min_length=3, max_length=30, pattern=r'^[a-z0-9-]+$')
    age: int = Field(..., ge=6, le=16)
    avatar_id: str = Field(..., min_length=1)
    pin: Optional[str] = Field(None, pattern=r'^\d{4}$')
    daily_limit_minutes: Optional[int] = Field(30, ge=5, le=180)

    @validator('name')
    def validate_name(cls, v):
        """Remove espaços extras e valida."""
        return v.strip()


class ChildUpdateRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=30)
    username: Optional[str] = Field(None, min_length=3, max_length=30, pattern=r'^[a-z0-9-]+$')
    age: Optional[int] = Field(None, ge=6, le=16)
    avatar_id: Optional[str] = None
    pin: Optional[str] = Field(None, pattern=r'^\d{4}$')
    daily_limit_minutes: Optional[int] = Field(None, ge=5, le=180)

    @validator('name')
    def validate_name(cls, v):
        """Remove espaços extras."""
        return v.strip() if v else None


class ChildResponse(BaseModel):
    id: str
    parent_id: str
    name: str
    # Optional pra dados antigos sem username (pre migration 006). Backfill
    # nao e' automatico - dashboard mostra "definir username" se vier None.
    username: Optional[str] = None
    age: int
    avatar_id: str
    daily_limit_minutes: int
    level: int
    xp: int
    streak_days: int
    last_active_date: Optional[date]
    created_at: datetime
    # Indica se a crianca tem PIN configurado (hash nunca volta para o cliente).
    # Frontend usa para decidir se mostra o keypad ou faz auto-login.
    pin_set: bool = False

    class Config:
        from_attributes = True


class ChildProgressEntry(BaseModel):
    lesson_id: str
    status: str  # 'not_started', 'in_progress', 'completed'
    xp_earned: int
    started_at: Optional[datetime]
    completed_at: Optional[datetime]


class ChildProgressResponse(BaseModel):
    progress: List[ChildProgressEntry]


class BadgeInfo(BaseModel):
    id: str
    code: str
    name: str
    description: str
    icon: str
    awarded_at: datetime


class LessonCompleteResponse(BaseModel):
    xp_total: int
    level: int
    badges_unlocked: List[BadgeInfo]
    stage_unlocked: Optional[int] = None


class DashboardChildCard(BaseModel):
    id: str
    name: str
    age: int
    avatar_id: str
    xp: int
    level: int
    streak_days: int
    today_minutes: int
    recent_badges: List[BadgeInfo]
    alerts_count: int


class ParentDashboardResponse(BaseModel):
    children: List[DashboardChildCard]