"""
Schemas comuns: erros, saúde, responses padrão.
"""

from pydantic import BaseModel
from typing import Dict, Any, Optional, List
from datetime import date


class ErrorDetail(BaseModel):
    code: str
    message: str
    details: Optional[Dict[str, Any]] = None


class ErrorResponse(BaseModel):
    error: ErrorDetail


class HealthCheckResponse(BaseModel):
    status: str
    version: str = "1.0.0"
    db: str  # 'healthy', 'error'
    anthropic: str  # 'healthy', 'error'


class UsageEntry(BaseModel):
    date: date
    minutes_used: int


class UsageResponse(BaseModel):
    usage: List[UsageEntry]


class SafetyEvent(BaseModel):
    id: str
    kind: str  # 'input_blocked', 'output_blocked', 'session_terminated'
    details: Dict[str, Any]
    session_id: Optional[str]
    created_at: str

    class Config:
        from_attributes = True


class SafetyEventsResponse(BaseModel):
    events: List[SafetyEvent]