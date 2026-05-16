"""
Helper para resolver "hoje" no fuso do usuario.

Frontend (TimezoneInit + BFF) propaga o timezone IANA do navegador
via header X-Timezone. Aqui transformamos esse header em uma date
local. Sem header, cai no settings.timezone (fallback de produto).
"""

from datetime import date, datetime
from typing import Optional

import pytz
import structlog
from fastapi import Request

from app.core.config import settings

logger = structlog.get_logger()


def user_today(request: Optional[Request]) -> date:
    """
    Retorna a date 'hoje' no fuso horario do usuario.

    Le X-Timezone (string IANA tipo 'Europe/Dublin', 'America/Sao_Paulo')
    da request. Fallback: settings.timezone. Se ambos invalidos, cai em
    UTC (ultimo recurso) - melhor um valor consistente do que excecao.
    """
    tz_name: Optional[str] = None
    if request is not None:
        tz_name = request.headers.get("x-timezone")

    candidates = [tz_name, settings.timezone, "UTC"]
    for candidate in candidates:
        if not candidate:
            continue
        try:
            return datetime.now(pytz.timezone(candidate)).date()
        except pytz.UnknownTimeZoneError:
            logger.warning("Timezone invalido, tentando proximo fallback", tz=candidate)
            continue

    # Inacessivel na pratica - UTC sempre existe em pytz.
    return datetime.utcnow().date()
