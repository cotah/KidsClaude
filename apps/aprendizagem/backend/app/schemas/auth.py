"""
Schemas de autenticação: signup, login, tokens.
Validação de entrada e formatação de saída para endpoints de auth.
"""

from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
import re


class ParentSignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=100)
    display_name: Optional[str] = Field(None, max_length=50)

    @validator('password')
    def validate_password(cls, v):
        """Valida força da senha: pelo menos 1 letra e 1 número."""
        if not re.search(r'[A-Za-z]', v):
            raise ValueError('Senha deve conter pelo menos uma letra')
        if not re.search(r'[0-9]', v):
            raise ValueError('Senha deve conter pelo menos um número')
        return v

    @validator('display_name')
    def validate_display_name(cls, v):
        """Valida nome de exibição."""
        if v and len(v.strip()) < 2:
            raise ValueError('Nome deve ter pelo menos 2 caracteres')
        return v.strip() if v else None


class ParentSignupResponse(BaseModel):
    parent_id: str
    access_token: str


class ParentLoginRequest(BaseModel):
    email: EmailStr
    password: str


class ParentLoginResponse(BaseModel):
    access_token: str
    expires_in: int  # segundos


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str = Field(..., min_length=8, max_length=100)

    @validator('new_password')
    def validate_password(cls, v):
        """Valida força da nova senha."""
        if not re.search(r'[A-Za-z]', v):
            raise ValueError('Senha deve conter pelo menos uma letra')
        if not re.search(r'[0-9]', v):
            raise ValueError('Senha deve conter pelo menos um número')
        return v


class ParentInfo(BaseModel):
    id: str
    email: str
    display_name: Optional[str]


class ChildLoginRequest(BaseModel):
    child_id: str
    pin: Optional[str] = Field(None, pattern=r'^\d{4}$')


class ChildLoginResponse(BaseModel):
    access_token: str
    expires_in: int
    child: dict  # informações básicas da criança


class ApiResponse(BaseModel):
    """Response padrão para endpoints simples."""
    ok: bool = True