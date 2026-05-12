"""
Cliente para Anthropic Claude API.
Implementa prompt caching e system prompt específico para crianças.
"""

import asyncio
from typing import Dict, Any, List
import structlog
from anthropic import AsyncAnthropic
from anthropic.types import MessageParam

from app.core.config import settings

logger = structlog.get_logger()


class ClaudeClient:
    """Cliente para interações com Claude."""

    def __init__(self):
        self.client = AsyncAnthropic(api_key=settings.anthropic_api_key)
        self.model = settings.anthropic_model

    def _build_system_prompt(self, lesson_title: str, lesson_summary: str, child_age: int) -> str:
        """
        Constrói system prompt com cache.
        Parte fixa (regras) usa cache, parte variável (contexto) não.
        """
        # Bloco fixo com regras (será cacheado)
        fixed_rules = """Você é a Atena, um assistente amigável que conversa com crianças de 6 a 12 anos.

Regras inegociáveis:
- Use linguagem simples, frases curtas, tom alegre e acolhedor.
- Nunca discuta: violência explícita, sexo, drogas, suicídio/auto-lesão, ódio, política partidária, religião específica, dados pessoais.
- Se a criança pedir algo fora dos tópicos da lição atual, redirecione com gentileza.
- Nunca peça dados pessoais (nome real, escola, endereço, telefone, foto).
- Responda em português do Brasil.
- Use no máximo 4 frases por resposta. Se for história, no máximo 8.
- Quando contar história, sempre tenha final feliz ou esperançoso.
- Seja sempre positiva e encorajadora."""

        # Contexto variável (lesson + idade)
        context = f"""
Contexto da lição atual: {lesson_title} — {lesson_summary}
Idade da criança: {child_age} anos"""

        return fixed_rules + context

    async def chat_with_child(
        self,
        message: str,
        lesson_title: str,
        lesson_summary: str,
        child_age: int,
        conversation_history: List[MessageParam] = None
    ) -> str:
        """
        Envia mensagem para Claude com contexto de criança.
        Usa prompt caching na primeira mensagem da sessão.
        """
        try:
            system_prompt = self._build_system_prompt(lesson_title, lesson_summary, child_age)

            # Monta histórico de conversação
            messages = conversation_history or []
            messages.append({"role": "user", "content": message})

            # Configuração com cache (ephemeral)
            cache_config = {
                "type": "ephemeral"
            }

            response = await self.client.messages.create(
                model=self.model,
                max_tokens=200,  # Respostas curtas para crianças
                temperature=0.7,  # Criatividade moderada
                system=system_prompt,
                messages=messages,
                extra_headers={
                    "anthropic-beta": "prompt-caching-2024-07-31"
                } if conversation_history is None else {},  # Cache apenas na primeira
                cache_control=cache_config if conversation_history is None else None
            )

            content = response.content[0].text if response.content else ""
            logger.info("Resposta do Claude gerada", length=len(content), age=child_age)
            return content

        except Exception as e:
            logger.error("Erro na chamada Claude", error=str(e))
            raise

    async def classify_content(self, classification_prompt: str) -> str:
        """
        Usa Claude para classificação de conteúdo (moderação).
        Modelo mais rápido e resposta estruturada.
        """
        try:
            response = await self.client.messages.create(
                model=self.model,
                max_tokens=100,  # Resposta JSON pequena
                temperature=0,  # Classificação determinística
                system="Você é um classificador de conteúdo para segurança infantil. Responda apenas com JSON válido conforme solicitado.",
                messages=[{"role": "user", "content": classification_prompt}]
            )

            content = response.content[0].text if response.content else "{}"
            logger.debug("Classificação realizada", content=content[:100])
            return content

        except Exception as e:
            logger.error("Erro na classificação Claude", error=str(e))
            raise

    async def generate_session_summary(self, messages: List[Dict[str, Any]]) -> str:
        """
        Gera resumo de 2-3 frases de uma sessão de chat.
        Para visualização dos pais.
        """
        try:
            # Formata mensagens para o prompt
            conversation_text = "\n".join([
                f"{msg['role']}: {msg['content']}"
                for msg in messages
                if msg['role'] in ['child', 'assistant']
            ])

            prompt = f"""Resuma esta conversa entre uma criança e a Atena em 2-3 frases para os pais:

{conversation_text}

Foque no que a criança aprendeu ou explorou. Use tom informativo mas positivo."""

            response = await self.client.messages.create(
                model=self.model,
                max_tokens=80,
                temperature=0.3,
                system="Você gera resumos concisos de conversas educacionais para pais acompanharem o aprendizado dos filhos.",
                messages=[{"role": "user", "content": prompt}]
            )

            summary = response.content[0].text if response.content else "Conversa educacional realizada."
            logger.info("Resumo gerado", length=len(summary))
            return summary

        except Exception as e:
            logger.error("Erro ao gerar resumo", error=str(e))
            return "Conversa educacional realizada."

    async def check_health(self) -> bool:
        """Verifica se Claude API está funcionando."""
        try:
            await self.client.messages.create(
                model=self.model,
                max_tokens=10,
                messages=[{"role": "user", "content": "Hi"}]
            )
            return True
        except Exception as e:
            logger.error("Health check Claude falhou", error=str(e))
            return False