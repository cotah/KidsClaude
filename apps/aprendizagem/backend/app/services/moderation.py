"""
Sistema de moderação com duas camadas: input e output.
Implementa blocklist, heurísticas de PII e classificação com Claude.
"""

import re
import json
from typing import Dict, List, Tuple, Any
from pathlib import Path
import structlog

from app.core.config import settings
from app.services.claude_client import ClaudeClient

logger = structlog.get_logger()


class ModerationResult:
    """Resultado de uma verificação de moderação."""

    def __init__(self, is_safe: bool, reason: str = None, category: str = None):
        self.is_safe = is_safe
        self.reason = reason
        self.category = category


class InputModerationError(Exception):
    """Exceção levantada quando input é bloqueado."""

    def __init__(self, reason: str, category: str):
        self.reason = reason
        self.category = category
        super().__init__(f"Input bloqueado: {reason}")


class ModerationService:
    """
    Serviço de moderação com duas camadas.
    Valida tanto entrada (input) quanto saída (output) do Claude.
    """

    def __init__(self):
        self.blocklist = self._load_blocklist()
        self.claude_client = ClaudeClient()
        self.pii_patterns = self._compile_pii_patterns()

    def _load_blocklist(self) -> set:
        """Carrega blocklist de arquivo."""
        try:
            blocklist_path = Path(settings.blocklist_path)
            if blocklist_path.exists():
                with open(blocklist_path, 'r', encoding='utf-8') as f:
                    terms = {
                        line.strip().lower()
                        for line in f
                        if line.strip() and not line.startswith('#')
                    }
                logger.info("Blocklist carregada", count=len(terms))
                return terms
            else:
                logger.warning("Blocklist não encontrada", path=str(blocklist_path))
                return set()
        except Exception as e:
            logger.error("Erro ao carregar blocklist", error=str(e))
            return set()

    def _compile_pii_patterns(self) -> List[Tuple[re.Pattern, str]]:
        """
        Compila padrões regex para detecção de PII.

        Endereco: agora exige numero do imovel apos o nome (ex: "Rua das
        Flores 123") em vez de qualquer "rua + 3 chars". Antes "rua dos
        dados" ou "rua principal" disparavam falso positivo em respostas
        educativas que usam metaforas com "rua".
        """
        patterns = [
            (re.compile(r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b'), "CPF"),
            (re.compile(r'\b\d{11}\b'), "CPF sem formatação"),
            (re.compile(r'\b\(\d{2}\)\s?\d{4,5}-?\d{4}\b'), "Telefone"),
            (re.compile(r'\b\d{2}\s?\d{4,5}-?\d{4}\b'), "Telefone"),
            (re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), "Email"),
            (re.compile(r'\b\d{5}-?\d{3}\b'), "CEP"),
            # Endereco real exige numero do imovel apos o nome.
            (re.compile(r'\brua\s+[A-Za-zÀ-ÿ\s]{3,30},?\s*\d{1,5}\b', re.IGNORECASE), "Endereço"),
            (re.compile(r'\bavenida\s+[A-Za-zÀ-ÿ\s]{3,30},?\s*\d{1,5}\b', re.IGNORECASE), "Endereço"),
            (re.compile(r'\bav\.\s+[A-Za-zÀ-ÿ\s]{3,30},?\s*\d{1,5}\b', re.IGNORECASE), "Endereço"),
        ]
        return patterns

    def _check_blocklist(self, text: str) -> ModerationResult:
        """
        Verifica se texto contém termos da blocklist como PALAVRA INTEIRA.

        Antes usava substring (`term in text`), o que gerava falsos positivos
        catastroficos em portugues:
          - "ass" (EN) bloqueava "passo", "massa", "assim", "classe", etc.
          - "die" (EN) bloqueava "dieta"
          - "war" (EN) bloqueava "swarm"
        Agora cada termo vira regex com word-boundaries (\b) e match
        case-insensitive. Frases (ex: "fazer amor", "matar-se") continuam
        funcionando porque \b casa entre word/non-word chars.
        """
        for term in self.blocklist:
            pattern = r'\b' + re.escape(term) + r'\b'
            if re.search(pattern, text, flags=re.IGNORECASE):
                logger.warning("Termo da blocklist detectado", term=term)
                return ModerationResult(
                    is_safe=False,
                    reason=f"Contém termo não permitido",
                    category="blocklist"
                )
        return ModerationResult(is_safe=True)

    def _check_pii(self, text: str) -> ModerationResult:
        """Verifica se texto contém informações pessoais."""
        for pattern, pii_type in self.pii_patterns:
            if pattern.search(text):
                logger.warning("PII detectado", type=pii_type)
                return ModerationResult(
                    is_safe=False,
                    reason=f"Contém informação pessoal ({pii_type})",
                    category="pii"
                )
        return ModerationResult(is_safe=True)

    def _check_length(self, text: str) -> ModerationResult:
        """Verifica limite de tamanho da mensagem."""
        if len(text) > 600:
            return ModerationResult(
                is_safe=False,
                reason="Mensagem muito longa",
                category="length"
            )
        return ModerationResult(is_safe=True)

    # Apenas estas categorias bloqueiam o conteudo. Categorias inesperadas
    # (ex: "tecnologia", "ciencia", "educacao", "unknown") deixam passar -
    # o classificador as vezes inventa categorias proprias e nao queremos
    # bloquear conteudo educativo por categoria inesperada do modelo.
    HARMFUL_CATEGORIES = {"violencia", "sexual", "auto_lesao", "odio", "pii"}

    async def _classify_content(self, text: str, is_output: bool = False) -> ModerationResult:
        """
        Classifica conteúdo usando Claude em 5 categorias REALMENTE perigosas.
        Para input e output com prompts ligeiramente diferentes.

        Nao bloqueia por categoria inesperada nem por falha de parse - so'
        bloqueia quando categoria E' uma das HARMFUL_CATEGORIES. Conteudo
        educativo sobre AI/APIs/programacao nao deve ser bloqueado por
        cautela excessiva do classificador.
        """
        text_preview = text[:200] if text else ""
        try:
            if is_output:
                prompt = f"""Analise esta resposta destinada a uma criança de 6-12 anos e classifique-a em categorias de segurança:

Texto: "{text}"

Categorias a verificar:
1. violencia: Descrições explícitas de violência, armas, ferimentos
2. sexual: Conteúdo sexual ou anatomia humana inadequada
3. auto_lesao: Menções a suicídio, autolesão, depressão severa
4. odio: Discurso de ódio, preconceito, discriminação
5. pii: Informações pessoais como nomes reais, endereços, telefones

IMPORTANTE: Conteúdo educativo sobre tecnologia, AI, APIs, programação
e ciência é SEMPRE seguro. Não classifique como inseguro só porque é
técnico ou tem termos em inglês como "fetch", "API", "HTML", "code".

Responda apenas com JSON:
{{"categoria": "nome_da_categoria", "motivo": "explicação breve"}}

Se for seguro para crianças (incluindo conteúdo educativo técnico), responda:
{{"categoria": "seguro", "motivo": "apropriado para a idade"}}"""
            else:
                prompt = f"""Analise esta mensagem de uma criança e verifique se contém conteúdo inadequado:

Texto: "{text}"

Categorias problemáticas:
1. violencia: Menções a violência, armas, machucados
2. sexual: Referências sexuais ou anatômicas
3. auto_lesao: Ideias de autolesão ou suicídio
4. odio: Linguagem de ódio ou preconceituosa
5. pii: Dados pessoais como nome completo, endereço, telefone

Responda apenas com JSON:
{{"categoria": "nome_da_categoria", "motivo": "explicação breve"}}

Se for apropriado, responda:
{{"categoria": "seguro", "motivo": "conteúdo apropriado"}}"""

            response = await self.claude_client.classify_content(prompt)
            logger.info(
                "Classify Claude raw response",
                response_preview=response[:200],
                is_output=is_output,
            )

            try:
                result = json.loads(response)
            except json.JSONDecodeError as je:
                # Claude as vezes devolve JSON com texto extra antes/depois.
                # Em vez de bloquear por parse fail, deixa passar e loga.
                logger.warning(
                    "Classify Claude devolveu JSON invalido - deixando passar",
                    response_preview=response[:200],
                    parse_error=str(je),
                )
                return ModerationResult(is_safe=True)

            categoria = result.get("categoria", "unknown")
            motivo = result.get("motivo", "Sem motivo especificado")

            if categoria == "seguro":
                return ModerationResult(is_safe=True)

            # Bloqueio APENAS pra categorias realmente perigosas.
            if categoria in self.HARMFUL_CATEGORIES:
                return ModerationResult(
                    is_safe=False,
                    reason=motivo,
                    category=categoria,
                )

            # Categoria inesperada do classificador - log e' liberacao.
            # Educational content nao deve cair por cautela excessiva.
            logger.warning(
                "Classify Claude devolveu categoria inesperada - deixando passar",
                categoria=categoria,
                motivo=motivo,
                text_preview=text_preview,
            )
            return ModerationResult(is_safe=True)

        except Exception as e:
            # Falha tecnica (rede, timeout, API) NAO deve bloquear conteudo
            # educativo. Mesmo em strict mode, deixa passar e loga - o
            # PII regex e o length check ja' cobrem o que importa.
            logger.error(
                "Erro na classificação Claude - deixando passar",
                error=str(e),
                error_type=type(e).__name__,
                text_preview=text_preview,
            )
            return ModerationResult(is_safe=True)

    async def moderate_input(self, text: str, bypass_blocklist: bool = False) -> None:
        """
        Modera input da criança. Levanta InputModerationError se bloqueado.
        Executa todas as verificações em sequência.

        bypass_blocklist=True pula a checagem de blocklist e a classificacao
        Claude. Usado quando o texto vem de um prompt_template curado por
        adultos (ja' revisado). PII e length continuam ativos pra pegar
        slot values com email/telefone digitados pela crianca.
        """
        # 1. Verificar blocklist (pula se template curado)
        if not bypass_blocklist:
            result = self._check_blocklist(text)
            if not result.is_safe:
                raise InputModerationError(result.reason, result.category)

        # 2. Verificar PII (sempre - pega slot values com dados pessoais)
        result = self._check_pii(text)
        if not result.is_safe:
            raise InputModerationError(result.reason, result.category)

        # 3. Verificar tamanho (sempre)
        result = self._check_length(text)
        if not result.is_safe:
            raise InputModerationError(result.reason, result.category)

        # 4. Classificar com Claude (so' em strict mode E nao-template).
        # Pular Claude pra templates economiza ~1-2s por mensagem e custo.
        if settings.moderation_strict and not bypass_blocklist:
            result = await self._classify_content(text, is_output=False)
            if not result.is_safe:
                raise InputModerationError(result.reason, result.category)

        logger.info("Input aprovado na moderação", length=len(text), bypass=bypass_blocklist)

    async def moderate_output(self, text: str) -> Tuple[bool, str, str]:
        """
        Modera output do Claude destinado à criança.
        Retorna (is_safe, filtered_text, reason).

        Trazido pro modo "permissivo": so' bloqueia conteudo realmente
        perigoso (PII real, classify Claude marcando categoria de risco).
        Length check subiu de 8 -> 25 sentencas e usa regex que ignora
        pontos dentro de URLs/decimais. Logs detalhados pra cada bloqueio
        mostram o excerto do texto e o tipo de check que pegou.
        """
        text_preview = text[:200] if text else ""

        # 1. Verificar PII na saída (regex tighter agora exige numero pra address)
        result = self._check_pii(text)
        if not result.is_safe:
            logger.warning(
                "Output bloqueado por PII",
                reason=result.reason,
                text_preview=text_preview,
                full_length=len(text),
            )
            return False, self._get_safe_replacement(), result.reason

        # 2. Verificar tamanho da resposta. Antes:
        #    re.split(r'[.!?]+', text)  -> 8
        # Quebrava em qualquer ponto - URLs como "pokeapi.co/api/v2/..."
        # viravam 4+ "sentencas" falsas. Cap de 8 era inadequado pra
        # respostas educativas tipo explicar uma API. Agora:
        #    [.!?]+\s+ ou [.!?]+$  -> exige espaco/fim apos pontuacao
        # ignorando pontos no meio de domains/decimais.
        sentence_count = len(re.split(r'[.!?]+\s+|[.!?]+$', text.strip()))
        if sentence_count > 25:
            logger.warning(
                "Output bloqueado por tamanho",
                sentences=sentence_count,
                text_preview=text_preview,
                full_length=len(text),
            )
            return False, self._get_safe_replacement(), "Resposta muito longa"

        # 3. Classificar com Claude. Se a classificacao falhar e nao
        # estivermos em strict mode, _classify_content devolve safe e
        # passa - nao bloqueia educational content por falha tecnica.
        result = await self._classify_content(text, is_output=True)
        if not result.is_safe:
            logger.warning(
                "Output bloqueado por classify Claude",
                category=result.category,
                reason=result.reason,
                text_preview=text_preview,
                full_length=len(text),
            )
            return False, self._get_safe_replacement(), result.reason

        logger.info("Output aprovado", length=len(text), sentences=sentence_count)
        return True, text, None

    def _get_safe_replacement(self) -> str:
        """Retorna mensagem segura para substituir output bloqueado."""
        return "Vamos tentar outra coisa! Toque em outro botão para uma nova conversa. 🌟"