# Aprendizagem Backend

Backend FastAPI para o app educacional de IA para crianças e adolescentes (6-18 anos). Sistema completo de chat seguro com Claude, gamificação, e painel para responsáveis.

## Visão Geral

- **Stack**: FastAPI + Python 3.11+ + Supabase + Anthropic Claude
- **Segurança**: Dupla moderação (input/output), RLS, autenticação JWT dual
- **Gamificação**: XP, níveis, badges, streaks
- **Arquitetura**: Clean Architecture com camadas bem separadas

## Estrutura do Projeto

```
app/
├── api/           # Routers FastAPI (auth, children, lessons, chat, parents, health)
├── core/          # Configuração, segurança, dependencies
├── db/            # Cliente Supabase, migrations SQL
├── schemas/       # Pydantic models (request/response)
├── services/      # Business logic (moderation, claude, gamification)
└── safety/        # Blocklist de termos proibidos

tests/             # Testes pytest (cobertura >85%)
migrations/        # Scripts SQL numerados
```

## Configuração Local

### 1. Pré-requisitos

- Python 3.11+
- Projeto Supabase configurado
- Chave API da Anthropic

### 2. Instalação

```bash
# Clone e entre no diretório
cd backend

# Instale dependências
pip install -r requirements.txt

# Ou usando uv (mais rápido)
uv pip install -r requirements.txt
```

### 3. Variáveis de Ambiente

Copie `.env.example` para `.env` e configure:

```bash
cp .env.example .env
```

**Variáveis obrigatórias:**
- `SUPABASE_URL`: URL do projeto Supabase
- `SUPABASE_SERVICE_ROLE_KEY`: Chave de service role (bypass RLS)
- `SUPABASE_JWT_SECRET`: Secret para validar JWTs do Supabase Auth
- `ANTHROPIC_API_KEY`: Chave da API Claude
- `CHILD_JWT_SECRET`: Secret para tokens de crianças (256 bits)

### 4. Migrações do Banco

Execute as migrações SQL na ordem:

```sql
-- No dashboard do Supabase > SQL Editor:
-- 1. Copie e execute: app/db/migrations/001_initial_schema.sql
-- 2. Copie e execute: app/db/migrations/002_seed_data.sql
```

### 5. Executar Localmente

```bash
# Desenvolvimento com reload
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Ou usando uv
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

API estará disponível em: `http://localhost:8000`
Documentação: `http://localhost:8000/docs`

## Testes

```bash
# Todos os testes
pytest

# Com cobertura
pytest --cov=app --cov-report=term-missing

# Apenas testes críticos de segurança
pytest tests/test_security.py -v
```

**Testes obrigatórios (gates de release):**
- Moderação bloqueia termos da blocklist ✓
- Criança não acessa painel de pai ✓
- Limite diário bloqueia atividades ✓
- Frontend não chama Anthropic diretamente ✓
- RLS impede acesso cross-parent ✓

## Arquitetura da API

### Autenticação Dual

1. **Pais**: JWT do Supabase Auth (7 dias TTL)
2. **Crianças**: JWT próprio do backend (4h TTL)

### Endpoints Principais

```
POST /v1/auth/parent/signup           # Cadastro pai
POST /v1/auth/parent/login            # Login pai  
POST /v1/auth/child/login             # Login criança (via pai)

GET  /v1/children                     # Lista filhos (pai)
POST /v1/children                     # Cria filho (pai)

GET  /v1/lessons                      # Lista lições (pai/criança)
POST /v1/lessons/{id}/complete        # Conclui lição (criança)

POST /v1/chat/sessions                # Nova sessão de chat (criança)
POST /v1/chat/sessions/{id}/messages  # Envia mensagem (criança)

GET  /v1/parents/dashboard            # Dashboard do pai
POST /v1/usage/heartbeat              # Registra tempo de uso (criança)
```

### Pipeline de Moderação

**Input (mensagens da criança):**
1. Blocklist de termos proibidos
2. Detecção de PII (CPF, telefone, email, endereço)
3. Limite de tamanho (600 chars)
4. Classificação com Claude (5 categorias)

**Output (respostas da Claude):**
1. Detecção de PII na saída
2. Limite de frases (máx 8)
3. Classificação de conteúdo
4. Substituição por mensagem segura se bloqueado

### Sistema de Gamificação

**XP & Níveis:**
- Fórmula: nível N exige `100 * N * (N+1) / 2` XP
- Lição concluída: 50 XP
- Desafio correto: 20 XP (primeira tentativa), 10 XP (demais)

**Badges (12 no MVP):**
- Primeiros Passos, Aprendiz Rápido, Streak 7 dias, Nível 5, etc.
- Avaliação automática após cada ação

## Deploy (Railway)

### 1. Configuração do Projeto

```bash
# Instalar Railway CLI
curl -fsSL https://railway.app/install.sh | sh

# Login e deploy
railway login
railway link
railway up
```

### 2. Variáveis de Ambiente (Railway Dashboard)

Configure no dashboard Railway:

```
ENV=production
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi...
SUPABASE_JWT_SECRET=super-secret-key
ANTHROPIC_API_KEY=sk-ant-...
CHILD_JWT_SECRET=random-256-bit-string
FRONTEND_ORIGIN=https://aprendizagem.app
```

### 3. Health Check

Configurado automaticamente em `/v1/health`:
- Testa conexão com banco
- Testa API do Claude
- Retorna status: `ok` | `degraded`

## Decisões de Implementação

### 1. Banco de Dados
**Escolha**: Supabase com queries SQL diretas + AsyncPG para performance.
**Alternativa considerada**: ORMs como SQLAlchemy, mas SQL direto oferece mais controle para RLS complexo.

### 2. Autenticação de Crianças
**Escolha**: JWT separado com TTL de 4h.
**Motivação**: Evita complexidade de roles no Supabase Auth e permite expiração mais curta.

### 3. Moderação com Claude
**Escolha**: Usa o mesmo modelo (Haiku) para chat e moderação.
**Motivação**: Consistência e economia vs. usar modelo específico para moderação.

### 4. Cache de Prompt
**Implementado**: Ephemeral cache no system prompt fixo.
**Benefício**: Reduz custo e latência das primeiras mensagens por sessão.

### 5. Rate Limiting
**Escolha**: SlowAPI com limite por IP.
**Configuração**: 60 req/min global, 30 msgs/sessão, 100 msgs/criança/dia.

## Monitoramento

### Logs Estruturados (JSON)
```python
logger.info("Sessão criada", child_id=child_id, lesson_id=lesson_id)
logger.warning("Input bloqueado", reason=reason, child_id=child_id)
```

### Métricas Importantes
- Taxa de bloqueios de moderação
- Tempo de resposta da Claude
- Sessions criadas vs. concluídas
- Badges desbloqueados por dia

### Alertas Críticos
- Claude API indisponível
- Banco de dados inacessível  
- Rate limit de moderação atingido
- Mais de 5% de inputs bloqueados

## Troubleshooting

### Problema: Claude API 429 (Rate Limited)
```bash
# Verificar logs
railway logs

# Temporariamente desativar modo strict
ENV MODERATION_STRICT=false
```

### Problema: Banco desconectado
```bash
# Testar conexão manual
railway run psql $DATABASE_URL

# Verificar service role key
railway variables
```

### Problema: Moderação muito restritiva
1. Revisar `app/safety/blocklist.txt`
2. Ajustar `MODERATION_STRICT=false` temporariamente
3. Analisar logs de `child_safety_events`

## Contribuição

### Regras de Código
1. **Português**: comentários e docstrings
2. **Inglês**: código, variáveis, função
3. **Type hints**: obrigatório em funções públicas
4. **Testes**: cobertura mínima 85%
5. **Logs**: estruturados com contexto

### Checklist de PR
- [ ] Testes passam (`pytest`)
- [ ] Linting OK (`ruff check`)
- [ ] Cobertura >= 85%
- [ ] Documentação atualizada
- [ ] Variáveis de ambiente em `.env.example`

## Contato

Em caso de dúvidas sobre arquitetura ou implementação, consulte a especificação completa em `../spec.md`.