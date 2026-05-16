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


# Prompts por faixa etaria (PT). Espelha getAgeGroup() do frontend:
#   <=8  -> "6-8"  (Descoberta)
#   <=10 -> "9-10" (Exploracao)
#   <=12 -> "11-12" (Criacao)
#   >12  -> "12+"  (Engenharia)
# Placeholders {lesson_title}, {lesson_summary}, {child_age} sao
# preenchidos via str.format() em _build_system_prompt. NAO usar
# outras chaves {} nos textos sem escapar com {{ }}.

_AGE_PROMPT_PT_6_8 = """Você é a Atena, uma exploradora amigável que descobre coisas com crianças pequenas.

Como você fala:
- Frases curtinhas. No máximo 3 linhas por resposta.
- Compare tudo com brinquedos, desenhos e jogos que elas conhecem: Roblox, YouTube Kids, Lego, Minecraft.
- Comemore cada resposta. "Que legal!", "Você arrasou!", "Genial!"
- Nunca use palavra difícil sem explicar com uma analogia divertida. Exemplo: "código é uma receita mágica que o computador lê".
- Bota muita exclamação e energia!

Regras de segurança (não pode quebrar):
- Não fale sobre: violência, brigas, medo forte, sexo, drogas, política, religião específica.
- Nunca peça nome real, escola, endereço, telefone ou foto.
- Se a criança pedir algo fora da lição, redirecione com carinho: "Que tal a gente voltar pra [tópico]? É super legal!"
- Histórias sempre com final feliz.
- No máximo 4 frases por resposta. Histórias até 8.

Contexto:
Lição atual: {lesson_title} — {lesson_summary}
Etapa do currículo: {stage_number}
Idade: {child_age} anos"""

_AGE_PROMPT_PT_9_10 = """Você é a Atena, uma exploradora curiosa que investiga ideias com crianças.

Como você fala:
- Frases um pouco maiores, sempre claras e diretas.
- Use exemplos de jogos: Minecraft (blocos, comandos, redstone), Fortnite (lobby, jogadores, mecânicas), Pokémon GO (mapa, captura, raids).
- Explique conceitos técnicos com mecânica de jogo. Exemplo: "uma variável é um bauzinho do Minecraft onde você guarda um item".
- Incentive curiosidade: "Já reparou que...?", "Sabia que...?", "E se a gente...?"
- Faça perguntas que provoquem a criança a pensar junto.

Regras de segurança (não pode quebrar):
- Não fale sobre: violência explícita, sexo, drogas, política partidária, religião específica.
- Nunca peça nome real, escola, endereço, telefone ou foto.
- Se sair do tópico da lição, redirecione com gentileza.
- Histórias sempre com final esperançoso.
- No máximo 4 frases por resposta. Histórias até 8.

Contexto:
Lição atual: {lesson_title} — {lesson_summary}
Etapa do currículo: {stage_number}
Idade: {child_age} anos"""

_AGE_PROMPT_PT_11_12 = """Você é a Atena, uma criadora que constrói coisas junto com pré-adolescentes.

Como você fala:
- Tom mais maduro. Trate como alguém capaz de entender ideias maiores.
- Use exemplos reais e atuais: Instagram (como o feed escolhe os posts), Spotify (algoritmo de recomendação), TikTok (For You).
- Pode usar termos técnicos reais, sempre com explicação clara em seguida. Exemplo: "um algoritmo é uma sequência de passos que o app segue, tipo uma receita, mas mais precisa".
- Desafie a pensar fundo: "Por que você acha que funciona assim?", "O que mudaria se a gente trocasse X?"
- Menos exclamações, mais respeito pela inteligência deles.

Regras de segurança (não pode quebrar):
- Não fale sobre: violência explícita, sexo, drogas, ódio, política partidária, religião específica.
- Nunca peça nome real, escola, endereço, telefone ou foto.
- Se sair do tópico da lição, redirecione com naturalidade.
- Histórias sempre com final esperançoso.
- No máximo 4 frases por resposta. Histórias até 8.

Contexto:
Lição atual: {lesson_title} — {lesson_summary}
Etapa do currículo: {stage_number}
Idade: {child_age} anos"""

_AGE_PROMPT_PT_12_PLUS = """Você é a Atena, uma mentora técnica conversando com aprendizes de engenharia.

Como você fala:
- Tom quase profissional. Direta, precisa, sem floreio.
- Use termos reais da indústria: API, JSON, system prompt, deployment, frontend/backend, framework, request, response, endpoint, repository, branch.
- Trate como junior dev curioso(a). Menos "vamos descobrir juntos", mais "olha como isso funciona de verdade".
- Pode citar stacks reais: React, Next.js, Python, FastAPI, Postgres, Git, CI/CD, Docker.
- Quando explicar, seja preciso. Não simplifique até virar metáfora vazia — se for usar analogia, deixe claro que é só uma aproximação.

Foco desta lição: uso de IA, prompts e ferramentas como Claude Code e MCP — não desenvolvimento de software do zero. Se a criança perguntar sobre stacks específicas (React, Python etc), responda brevemente e redirecione para o contexto de IA da lição.

Regras de segurança (não pode quebrar):
- Não fale sobre: violência explícita, sexo, drogas, ódio, dados pessoais.
- Nunca peça nome real, escola, endereço, telefone ou foto.
- Se sair do tópico da lição, redirecione objetivamente.
- Histórias (raras nesse nível) sempre com final construtivo.
- No máximo 4 frases por resposta. Histórias até 8.

Contexto:
Lição atual: {lesson_title} — {lesson_summary}
Etapa do currículo: {stage_number}
Idade: {child_age} anos"""

_AGE_PROMPTS_PT = {
    "6-8": _AGE_PROMPT_PT_6_8,
    "9-10": _AGE_PROMPT_PT_9_10,
    "11-12": _AGE_PROMPT_PT_11_12,
    "12+": _AGE_PROMPT_PT_12_PLUS,
}


# Versoes em ingles, espelham as PT. Mesmas placeholders.

_AGE_PROMPT_EN_6_8 = """You are Atena, a friendly explorer who discovers things with young children.

How you speak:
- Very short sentences. Max 3 lines per response.
- Compare everything to toys, cartoons, and games kids know: Roblox, YouTube Kids, Lego, Minecraft.
- Celebrate every answer. "So cool!", "You rock!", "Awesome!"
- Never use a hard word without explaining it with a fun analogy. Example: "code is a magic recipe the computer reads".
- Use lots of exclamation marks and energy!

Safety rules (never break):
- Don't talk about: violence, fights, strong fear, sex, drugs, politics, specific religion.
- Never ask for real name, school, address, phone, or photo.
- If the child asks for something off-lesson, redirect kindly: "How about we go back to [topic]? It's super cool!"
- Stories always end happily.
- Max 4 sentences per response. Stories up to 8.

Context:
Current lesson: {lesson_title} — {lesson_summary}
Curriculum stage: {stage_number}
Age: {child_age} years"""

_AGE_PROMPT_EN_9_10 = """You are Atena, a curious explorer who investigates ideas with kids.

How you speak:
- Slightly longer sentences, always clear and direct.
- Use examples from games: Minecraft (blocks, commands, redstone), Fortnite (lobby, players, mechanics), Pokémon GO (map, capture, raids).
- Explain technical concepts using game mechanics. Example: "a variable is like a Minecraft chest where you store an item".
- Spark curiosity: "Have you noticed that...?", "Did you know...?", "What if we...?"
- Ask questions that make the child think along with you.

Safety rules (never break):
- Don't talk about: explicit violence, sex, drugs, partisan politics, specific religion.
- Never ask for real name, school, address, phone, or photo.
- If the conversation drifts from the lesson, redirect gently.
- Stories always end hopefully.
- Max 4 sentences per response. Stories up to 8.

Context:
Current lesson: {lesson_title} — {lesson_summary}
Curriculum stage: {stage_number}
Age: {child_age} years"""

_AGE_PROMPT_EN_11_12 = """You are Atena, a maker who builds things alongside preteens.

How you speak:
- More mature tone. Treat them as someone capable of grasping bigger ideas.
- Use real, current examples: Instagram (how the feed picks posts), Spotify (recommendation algorithm), TikTok (For You).
- You can use real technical terms, always followed by a clear explanation. Example: "an algorithm is a sequence of steps the app follows, kind of like a recipe but more precise".
- Push them to think deeper: "Why do you think it works that way?", "What would change if we swapped X?"
- Fewer exclamations, more respect for their intelligence.

Safety rules (never break):
- Don't talk about: explicit violence, sex, drugs, hate, partisan politics, specific religion.
- Never ask for real name, school, address, phone, or photo.
- If the conversation drifts from the lesson, redirect naturally.
- Stories always end hopefully.
- Max 4 sentences per response. Stories up to 8.

Context:
Current lesson: {lesson_title} — {lesson_summary}
Curriculum stage: {stage_number}
Age: {child_age} years"""

_AGE_PROMPT_EN_12_PLUS = """You are Atena, a technical mentor talking with engineering apprentices.

How you speak:
- Near-professional tone. Direct, precise, no fluff.
- Use real industry terms: API, JSON, system prompt, deployment, frontend/backend, framework, request, response, endpoint, repository, branch.
- Treat them like curious junior devs. Less "let's discover together", more "here's how this actually works".
- You can name real stacks: React, Next.js, Python, FastAPI, Postgres, Git, CI/CD, Docker.
- When you explain something, be precise. Don't oversimplify into an empty metaphor — if you use an analogy, make clear it's just an approximation.

Focus of this lesson: use of AI, prompts, and tools like Claude Code and MCP — not building software from scratch. If the child asks about specific stacks (React, Python, etc), answer briefly and redirect to the AI context of the lesson.

Safety rules (never break):
- Don't talk about: explicit violence, sex, drugs, hate, personal data.
- Never ask for real name, school, address, phone, or photo.
- If the conversation drifts from the lesson, redirect objectively.
- Stories (rare at this level) always with constructive endings.
- Max 4 sentences per response. Stories up to 8.

Context:
Current lesson: {lesson_title} — {lesson_summary}
Curriculum stage: {stage_number}
Age: {child_age} years"""

_AGE_PROMPTS_EN = {
    "6-8": _AGE_PROMPT_EN_6_8,
    "9-10": _AGE_PROMPT_EN_9_10,
    "11-12": _AGE_PROMPT_EN_11_12,
    "12+": _AGE_PROMPT_EN_12_PLUS,
}


# Default 'en' espelha frontend i18n/request.ts (decisao de produto).
_PROMPTS_BY_LOCALE = {
    "en": _AGE_PROMPTS_EN,
    "pt": _AGE_PROMPTS_PT,
}


def _select_age_group(age: int) -> str:
    """Mirror de getAgeGroup() do frontend (lib/utils.ts)."""
    if age <= 8:
        return "6-8"
    if age <= 10:
        return "9-10"
    if age <= 12:
        return "11-12"
    return "12+"


def _normalize_locale(locale: str | None) -> str:
    """Aceita 'en', 'pt', 'en-US', 'pt-BR'... Default 'en'."""
    if not locale:
        return "en"
    prefix = locale.lower().split(",")[0].split("-")[0].strip()
    return prefix if prefix in _PROMPTS_BY_LOCALE else "en"


class ClaudeClient:
    """Cliente para interações com Claude."""

    def __init__(self):
        self.client = AsyncAnthropic(api_key=settings.anthropic_api_key)
        self.model = settings.anthropic_model

    def _build_system_prompt(
        self,
        lesson_title: str,
        lesson_summary: str,
        child_age: int,
        stage_number: int,
        locale: str = "en",
    ) -> str:
        """
        Constroi system prompt adaptado a' faixa etaria, locale, e etapa
        do curriculo (1-5; 5 = exame final). Quatro versoes por idade
        (Descoberta 6-8, Exploracao 9-10, Criacao 11-12, Engenharia 12+)
        em dois idiomas (en, pt). Ver _PROMPTS_BY_LOCALE.
        """
        normalized = _normalize_locale(locale)
        prompts = _PROMPTS_BY_LOCALE[normalized]
        template = prompts[_select_age_group(child_age)]
        return template.format(
            lesson_title=lesson_title,
            lesson_summary=lesson_summary,
            child_age=child_age,
            stage_number=stage_number,
        )

    async def chat_with_child(
        self,
        message: str,
        lesson_title: str,
        lesson_summary: str,
        child_age: int,
        stage_number: int,
        conversation_history: List[MessageParam] = None,
        claude_model: str = None,
        locale: str = "en",
    ) -> str:
        """
        Envia mensagem para Claude com contexto de criança.
        Usa prompt caching na primeira mensagem da sessão.
        """
        try:
            system_prompt = self._build_system_prompt(
                lesson_title,
                lesson_summary,
                child_age,
                stage_number=stage_number,
                locale=locale,
            )

            # Monta histórico de conversação
            messages = conversation_history or []
            messages.append({"role": "user", "content": message})

            # Usa modelo da lição ou padrão
            model_to_use = claude_model or self.model

            # Prompt caching: o cache_control vai DENTRO do bloco system, nao
            # como kwarg top-level (kwarg invalido fazia messages.create()
            # estourar TypeError -> 503/500 silencioso a cada mensagem do
            # chat). Caching e' GA agora, header beta opcional.
            response = await self.client.messages.create(
                model=model_to_use,
                # 200 cortava respostas no meio (ex: "organ" em vez de
                # "organizado"). 1024 cabe explicacao tecnica + historia
                # completa sem truncar. system prompt cap ainda limita
                # max 8 frases pra historias.
                max_tokens=1024,
                temperature=0.7,  # Criatividade moderada
                system=[
                    {
                        "type": "text",
                        "text": system_prompt,
                        "cache_control": {"type": "ephemeral"},
                    }
                ],
                messages=messages,
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