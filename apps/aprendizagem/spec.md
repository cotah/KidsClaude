# Spec Tecnico — App "aprendizagem"

> Especificacao tecnica completa do app que ensina criancas (6-18 anos) a usar Claude e assistentes de IA de forma divertida, visual e segura.
> Documento e a fonte unica da verdade para os agentes backend, frontend, qa e deploy.
> Todo codigo e identificadores em ingles. Comentarios e textos de produto em portugues do Brasil.

---

## 1. Visao geral

O **aprendizagem** e um aplicativo web educacional que ensina criancas de 6 a 12 anos a conversar e cocriar com assistentes de IA (especificamente Claude). A experiencia combina licoes interativas curtas, desafios gamificados e um chat seguro com prompts guiados, num ambiente colorido e protagonizado por um mascote. Pais e responsaveis tem uma area separada para criar perfis das criancas, acompanhar progresso, ver transcricoes resumidas e definir limites diarios de uso. A proposta de valor e dupla: a crianca aprende uma habilidade essencial do seculo XXI brincando, e o pai tem visibilidade e controle total sobre o que acontece.

---

## 2. Personas

### 2.1 Crianca pequena — 6 a 8 anos (le pouco)
- **Objetivos:** brincar, ganhar recompensas visuais, falar com o mascote, sentir orgulho de si mesma.
- **Dores:** texto longo cansa, instrucoes complexas confundem, perde interesse rapido, nao sabe digitar bem.
- **Fluxos chave:**
  1. Entrar com avatar (sem digitar email/senha) → escolher trilha → assistir licao animada → tocar em botoes de prompt pronto → ver resposta da Claude com audio TTS opcional → ganhar XP e badge.
  2. Repetir desafio para subir de nivel.
- **Restricoes UX:** fontes >= 18px, botoes grandes (min 56px), narração opcional em todas as telas, leitura em voz alta dos prompts antes do envio.

### 2.2 Crianca maior — 9 a 12 anos (le bem)
- **Objetivos:** aprender de verdade, criar projetos pequenos com IA, mostrar resultado para amigos/pais, competir consigo mesma (streaks).
- **Dores:** acha conteudo de "criancinha" desinteressante, quer mais autonomia, quer entender como a IA "pensa".
- **Fluxos chave:**
  1. Entrar com avatar → escolher trilha avancada → ler licao + interagir → usar prompts guiados com slots editaveis (preencher palavras) → revisar resposta da Claude → tentar variacao livre dentro de limites → ganhar XP e desbloquear conquistas.
- **Restricoes UX:** permite leve customizacao de prompt, tom mais "maker", visual ainda divertido mas menos infantilizado.

### 2.3 Pai/Responsavel
- **Objetivos:** garantir que a crianca aprenda algo util, ter certeza que o conteudo e seguro, controlar tempo de tela.
- **Dores:** medo de exposicao a conteudo inapropriado, falta de tempo para acompanhar, desconfianca de IA com criancas.
- **Fluxos chave:**
  1. Cadastro com email/senha → criar perfil de cada filho (nome, idade, avatar, PIN opcional) → definir limite diario → acompanhar dashboard (progresso, badges, tempo, transcricoes resumidas) → receber alertas de seguranca.

---

## 3. Funcionalidades (escopo)

### Autenticacao
- `[MVP]` Cadastro de pai por email + senha (Supabase Auth).
- `[MVP]` Login de pai por email + senha.
- `[MVP]` Reset de senha por email.
- `[MVP]` Login de crianca por selecao de avatar + PIN de 4 digitos opcional (PIN definido pelo pai).
- `[v2]` Login social do pai (Google).
- `[v2]` Magic link.

### Perfil da crianca
- `[MVP]` Pai cria/edita/deleta perfis de filhos (nome curto, idade, avatar, PIN).
- `[MVP]` Cada perfil tem nivel, XP, streak, badges.
- `[MVP]` Limite diario de minutos por perfil.
- `[v2]` Foto customizada (upload) — no MVP usar set fixo de avatares ilustrados.

### Licoes
- `[MVP]` Catalogo de licoes organizado em trilhas por faixa etaria (6-8 e 9-12).
- `[MVP]` Cada licao tem: titulo, descricao curta, video/animacao curto, blocos de texto curtos com ilustracao, 1 atividade pratica.
- `[MVP]` Marcacao de progresso (nao iniciada / em andamento / concluida).
- `[MVP]` Pelo menos 12 licoes seed no MVP (6 por faixa etaria).
- `[v2]` Recomendacao adaptativa de proxima licao.

### Desafios
- `[MVP]` Cada licao termina com 1 desafio (multipla escolha visual OU completar prompt).
- `[MVP]` Tentativa registra acerto/erro e gera XP.
- `[MVP]` Crianca pode tentar de novo.
- `[v2]` Desafios cronometrados.

### Chat com Claude (prompts guiados)
- `[MVP]` Catalogo de prompts pre-aprovados por licao (ex: "Me conte uma historia de aventura sobre um(a) ___ no/na ___").
- `[MVP]` Para faixa 6-8: prompt totalmente fechado (so toca no botao).
- `[MVP]` Para faixa 9-12: prompt com slots editaveis (palavras dentro de limites de tamanho/whitelist).
- `[MVP]` Toda mensagem da crianca passa pelo filtro de moderacao de entrada.
- `[MVP]` Toda resposta da Claude passa pelo filtro de moderacao de saida.
- `[MVP]` Sessao de chat sempre vinculada a uma licao.
- `[MVP]` Historico salvo para visualizacao do pai.
- `[v2]` Modo "exploracao livre" para 11-12 anos com supervisao.

### Painel dos pais
- `[MVP]` Lista de filhos com cards de progresso.
- `[MVP]` Detalhe por filho: licoes concluidas, XP total, badges, tempo na semana, ultimas sessoes de chat com resumo curto.
- `[MVP]` Configurar limite diario de minutos.
- `[MVP]` Ver transcricao integral de qualquer sessao.
- `[MVP]` Receber alerta in-app quando moderacao bloquear conteudo (input ou output).
- `[v2]` Relatorio semanal por email.
- `[v2]` Exportar dados (LGPD).

### Gamificacao
- `[MVP]` XP por licao concluida e desafio acertado.
- `[MVP]` Niveis com nomes tematicos.
- `[MVP]` Streak diario.
- `[MVP]` Catalogo fixo de pelo menos 10 badges.
- `[MVP]` Tela de conquistas.
- `[v2]` Quests diarias dinamicas.
- `[v2]` Eventos sazonais.

---

## 4. User stories e criterios de aceitacao

> Formato: **Como** [persona] **eu quero** [acao] **para** [beneficio]. Criterios em **Given/When/Then** (G/W/T).

### US-01 — Cadastro de pai
**Como** pai/responsavel **eu quero** criar uma conta com email e senha **para** acessar o app e cadastrar meus filhos.
- G/W/T 1: Given email valido e senha com >= 8 chars (1 letra, 1 numero), When envio o formulario, Then conta e criada e recebo redirecionamento para o painel.
- G/W/T 2: Given email ja cadastrado, When envio o formulario, Then recebo erro 409 e mensagem "Email ja cadastrado".
- G/W/T 3: Given senha fraca, When envio, Then recebo erro 422 com lista de regras nao atendidas.
- G/W/T 4: Given dados validos, When conta e criada, Then recebo email de boas-vindas (logado via Supabase Auth).

### US-02 — Login de pai
**Como** pai **eu quero** entrar com email e senha **para** acessar o painel.
- G/W/T 1: Credenciais corretas → JWT emitido (expira em 7 dias) e cookie httpOnly setado.
- G/W/T 2: Credenciais erradas → 401 com mensagem generica "Email ou senha incorretos" (sem revelar qual falhou).
- G/W/T 3: Apos 5 tentativas erradas em 10 min → bloqueio temporario de 15 min (rate limit por IP+email).
- G/W/T 4: Token expirado → 401 e redirect para tela de login.

### US-03 — Criar perfil de filho
**Como** pai **eu quero** criar um perfil para meu filho **para** que ele possa usar o app com configuracoes proprias.
- G/W/T 1: Nome (1-30 chars), idade (6-18), avatar (id de catalogo), PIN opcional (4 digitos numericos) → 201 e perfil aparece na lista.
- G/W/T 2: Idade fora do intervalo → 422.
- G/W/T 3: Pai pode ter no maximo 5 filhos no MVP → 6o cadastro retorna 409.
- G/W/T 4: Apenas o pai dono pode editar/deletar (RLS).

### US-04 — Login de crianca
**Como** crianca **eu quero** entrar tocando no meu avatar **para** comecar a brincar sem precisar digitar muito.
- G/W/T 1: Tela inicial mostra grid de avatares dos filhos do pai logado no dispositivo (sessao do pai ativa).
- G/W/T 2: Toco no avatar; se ha PIN, abre teclado numerico grande; se nao, entra direto.
- G/W/T 3: PIN errado 3x → bloqueio de 5 min para aquele perfil naquele dispositivo.
- G/W/T 4: Sessao de crianca recebe JWT separado (claims: `role=child, child_id=...`) com expiracao de 4 horas.

### US-05 — Listar e iniciar licao
**Como** crianca **eu quero** ver as licoes disponiveis para minha idade **para** escolher qual fazer.
- G/W/T 1: Trilhas filtradas por faixa etaria do perfil (6-8 ou 9-12).
- G/W/T 2: Cada card mostra: icone, titulo, status (nao iniciada/em andamento/concluida), XP previsto.
- G/W/T 3: Toco em "Comecar" → endpoint registra `lesson_progress` com `status=in_progress` e `started_at=now()`.
- G/W/T 4: Licao bloqueada (pre-requisito nao cumprido) mostra cadeado e tooltip "Termine X primeiro".

### US-06 — Concluir licao
**Como** crianca **eu quero** terminar a licao **para** ganhar XP e ver minha barra subir.
- G/W/T 1: Quando todos os blocos forem visualizados e o desafio resolvido, frontend chama `POST /lessons/{id}/complete`.
- G/W/T 2: Backend valida que progresso existe e nao esta concluida → atualiza `status=completed, completed_at=now()` e credita XP.
- G/W/T 3: Resposta inclui novo total de XP, nivel atual, e lista de badges desbloqueados nesta acao.
- G/W/T 4: Tentar concluir uma licao ja concluida nao gera XP duplicado (idempotente).

### US-07 — Conversar com Claude via prompt guiado (faixa 6-8)
**Como** crianca pequena **eu quero** tocar num botao de prompt pronto **para** ver a Claude responder.
- G/W/T 1: Tela mostra 3-5 botoes coloridos com prompts da licao atual.
- G/W/T 2: Ao tocar, frontend chama `POST /chat/sessions/{id}/messages` com `template_id` (sem texto livre).
- G/W/T 3: Backend resolve o template, monta prompt final, chama Claude, passa pelo filtro de saida e devolve resposta.
- G/W/T 4: Se moderacao de saida bloquear, crianca ve "Vamos tentar outra coisa!" e nada da resposta original aparece; evento e logado.

### US-08 — Conversar com Claude com slots editaveis (faixa 9-12)
**Como** crianca maior **eu quero** preencher palavras dentro do prompt **para** personalizar a conversa.
- G/W/T 1: Tela mostra prompt com slots `___` clicaveis.
- G/W/T 2: Ao clicar no slot abre teclado com sugestoes; texto livre limitado a 30 chars e validado contra blocklist.
- G/W/T 3: Conteudo proibido → mensagem "Essa palavra nao e permitida, escolha outra" (filtro de input).
- G/W/T 4: Apos preencher todos os slots, botao "Enviar" libera; mesmo fluxo do US-07 dali em diante.

### US-09 — Pai ve transcricao
**Como** pai **eu quero** abrir uma sessao de chat do meu filho **para** ler exatamente o que aconteceu.
- G/W/T 1: Lista de sessoes mostra: data/hora, licao, duracao, numero de mensagens, indicador de seguranca (verde/amarelo/vermelho).
- G/W/T 2: Detalhe mostra todas as mensagens em ordem cronologica, com etiqueta de origem (crianca/Claude/sistema).
- G/W/T 3: Cada sessao tem um resumo automatico (gerado pela Claude no servidor) com 2-3 frases.
- G/W/T 4: RLS garante que pai so ve transcricoes dos proprios filhos.

### US-10 — Limite diario de tempo
**Como** pai **eu quero** definir um limite de minutos por dia **para** controlar o tempo de tela.
- G/W/T 1: Valor entre 5 e 180 min, default 30.
- G/W/T 2: Frontend conta tempo ativo (heartbeat a cada 60s) e backend agrega em `daily_usage`.
- G/W/T 3: Quando acumulado >= limite, app bloqueia novas acoes e mostra "Volte amanha!".
- G/W/T 4: Reset diario as 00:00 no fuso `America/Sao_Paulo`.

### US-11 — Moderacao bloqueia conteudo
**Como** sistema **eu quero** filtrar inputs e outputs **para** garantir seguranca infantil.
- G/W/T 1: Input com termo da blocklist → 400 e contador de bloqueios incrementa em `child_safety_events`.
- G/W/T 2: Output classificado como impróprio (categorias: violencia/sexual/auto-lesao/odio) → resposta substituida por mensagem segura e evento logado.
- G/W/T 3: 3 bloqueios numa mesma sessao → sessao encerrada automaticamente e alerta criado para o pai.
- G/W/T 4: Painel do pai mostra badge vermelho na sessao com bloqueios.

### US-12 — Ganhar badge
**Como** crianca **eu quero** ver uma animacao quando ganho um badge **para** sentir orgulho.
- G/W/T 1: Acao que dispara badge (ex: 1a licao concluida) → backend retorna badge na resposta da acao.
- G/W/T 2: Frontend exibe modal com animacao confete + nome do badge + descricao.
- G/W/T 3: Badge aparece permanentemente no perfil da crianca.
- G/W/T 4: Mesmo badge nunca e creditado duas vezes (constraint UNIQUE em `child_badges (child_id, badge_id)`).

### US-13 — Streak diario
**Como** crianca **eu quero** ver minha sequencia de dias **para** querer voltar amanha.
- G/W/T 1: Concluir pelo menos 1 atividade no dia incrementa streak.
- G/W/T 2: Pular 1 dia zera o streak (excecao: "freeze" automatico aos sabados se streak >= 7 — `[v2]`).
- G/W/T 3: Streak visivel no header da crianca com icone de fogo.
- G/W/T 4: Marco de streak (3, 7, 30 dias) desbloqueia badge especifico.

### US-14 — Reset de senha do pai
**Como** pai **eu quero** redefinir minha senha **para** recuperar acesso.
- G/W/T 1: Email cadastrado → envio de link via Supabase Auth, validade de 1h.
- G/W/T 2: Email nao cadastrado → resposta sempre 200 (nao revelar existencia), email nao e enviado.
- G/W/T 3: Link valido + nova senha forte → senha trocada e sessoes anteriores invalidadas.
- G/W/T 4: Link expirado → 400 com mensagem clara.

---

## 5. Arquitetura

```
+--------------------+        +-----------------------+        +---------------------+
|  Next.js (Vercel)  |  HTTPS |  FastAPI (Railway)    |  PG    |  Supabase           |
|  - App Router      | <----> |  - Auth bridge        | <----> |  - Postgres + RLS   |
|  - Tailwind        |  JSON  |  - Lesson/Chat APIs   |        |  - Storage (assets) |
|  - Child UI        |        |  - Moderation layer   |        |  - Auth (parent)    |
|  - Parent UI       |        |  - Claude proxy       |        +---------------------+
+--------------------+        |  - Rate limiter       |
         ^                    +-----------------------+
         |                              |
         | (TTS opcional)               | HTTPS
         v                              v
+--------------------+        +-----------------------+
|  Web Speech API    |        |  Anthropic API        |
|  (browser native)  |        |  claude-haiku-4-5     |
+--------------------+        +-----------------------+
```

**Pontos de moderacao (criticos):**
1. **Input filter** no FastAPI antes de qualquer chamada a Claude (blocklist + heuristicas + classificador leve).
2. **Output filter** no FastAPI antes de devolver ao frontend (classificador de categorias inseguras + verificacao de PII).
3. **System prompt blindado** com regras de seguranca infantil reforcadas + cache de prompt.

**Frontend nunca chama Anthropic diretamente.** Toda interacao com a IA passa pelo backend.

---

## 6. Modelo de dados (Supabase / Postgres)

> Convencao: snake_case, PK `id uuid default gen_random_uuid()`, timestamps `created_at` e `updated_at` em todas as tabelas, FKs com `on delete cascade` quando filho logico.
> RLS habilitada em todas as tabelas. Service role do FastAPI bypass RLS para operacoes server-side; clientes nunca tocam Postgres direto no MVP (frontend so fala com FastAPI).

### 6.1 `parents`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK, = `auth.users.id` (Supabase Auth) |
| email | text | unique, not null |
| display_name | text | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

RLS: parent pode ler/atualizar somente `id = auth.uid()`.

### 6.2 `children`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| parent_id | uuid | FK parents.id, on delete cascade, not null |
| name | text | not null, 1-30 chars |
| age | int | check (age between 6 and 12) |
| avatar_id | text | not null (referencia a catalogo estatico) |
| pin_hash | text | nullable (bcrypt) |
| daily_limit_minutes | int | not null default 30, check (5-180) |
| level | int | default 1 |
| xp | int | default 0 |
| streak_days | int | default 0 |
| last_active_date | date | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Index: `idx_children_parent on children(parent_id)`.
RLS: parent ve `parent_id = auth.uid()`.

### 6.3 `lessons`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| slug | text | unique, not null |
| title | text | not null |
| description | text | not null |
| age_band | text | check in ('6-8','9-12') |
| order_index | int | not null |
| content_blocks | jsonb | not null (array de blocos: text/image/video/animation) |
| prerequisites | uuid[] | default '{}' |
| xp_reward | int | not null default 50 |
| is_active | bool | default true |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Index: `idx_lessons_age_active on lessons(age_band, is_active, order_index)`.
RLS: leitura publica (autenticado), escrita so service role.

### 6.4 `lesson_progress`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| child_id | uuid | FK children.id, cascade |
| lesson_id | uuid | FK lessons.id |
| status | text | check in ('not_started','in_progress','completed') |
| started_at | timestamptz | nullable |
| completed_at | timestamptz | nullable |
| xp_earned | int | default 0 |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Unique: `(child_id, lesson_id)`.
Index: `idx_progress_child on lesson_progress(child_id)`.

### 6.5 `challenges`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| lesson_id | uuid | FK lessons.id, cascade |
| kind | text | check in ('multiple_choice','fill_prompt') |
| question | jsonb | not null (estrutura por kind) |
| correct_answer | jsonb | not null |
| xp_reward | int | default 20 |

### 6.6 `challenge_attempts`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| child_id | uuid | FK children.id, cascade |
| challenge_id | uuid | FK challenges.id |
| answer | jsonb | not null |
| is_correct | bool | not null |
| xp_earned | int | default 0 |
| created_at | timestamptz | default now() |

Index: `idx_attempts_child_chal on challenge_attempts(child_id, challenge_id)`.

### 6.7 `prompt_templates`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| lesson_id | uuid | FK lessons.id |
| label | text | not null (texto do botao) |
| template | text | not null (com placeholders `{{slot_name}}`) |
| slots | jsonb | array de `{name, max_length, allowed_chars}` |
| age_band | text | check in ('6-8','9-12') |
| order_index | int | default 0 |

### 6.8 `chat_sessions`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| child_id | uuid | FK children.id, cascade |
| lesson_id | uuid | FK lessons.id |
| started_at | timestamptz | default now() |
| ended_at | timestamptz | nullable |
| safety_status | text | check in ('green','yellow','red') default 'green' |
| summary | text | nullable (gerado por Claude) |
| message_count | int | default 0 |
| created_at | timestamptz | default now() |

Index: `idx_sessions_child on chat_sessions(child_id, started_at desc)`.

### 6.9 `chat_messages`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| session_id | uuid | FK chat_sessions.id, cascade |
| role | text | check in ('child','assistant','system') |
| template_id | uuid | nullable (FK prompt_templates.id) |
| content | text | not null |
| moderation_status | text | check in ('passed','blocked') default 'passed' |
| moderation_reason | text | nullable |
| token_count | int | nullable |
| created_at | timestamptz | default now() |

Index: `idx_messages_session on chat_messages(session_id, created_at)`.

### 6.10 `badges`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| code | text | unique, not null |
| name | text | not null |
| description | text | not null |
| icon | text | not null (id de catalogo) |
| unlock_rule | jsonb | not null |

### 6.11 `child_badges`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| child_id | uuid | FK children.id, cascade |
| badge_id | uuid | FK badges.id |
| awarded_at | timestamptz | default now() |

Unique: `(child_id, badge_id)`.

### 6.12 `daily_usage`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| child_id | uuid | FK children.id, cascade |
| usage_date | date | not null |
| minutes_used | int | default 0 |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Unique: `(child_id, usage_date)`.
Index: `idx_usage_child_date on daily_usage(child_id, usage_date desc)`.

### 6.13 `child_safety_events`
| coluna | tipo | constraints |
|---|---|---|
| id | uuid | PK |
| child_id | uuid | FK children.id, cascade |
| session_id | uuid | nullable FK chat_sessions.id |
| kind | text | check in ('input_blocked','output_blocked','session_terminated') |
| details | jsonb | not null |
| created_at | timestamptz | default now() |

Index: `idx_safety_child_date on child_safety_events(child_id, created_at desc)`.

### 6.14 RLS — resumo
- `parents`: read/update self.
- `children`, `lesson_progress`, `chat_sessions`, `chat_messages`, `child_badges`, `daily_usage`, `challenge_attempts`, `child_safety_events`: parent ve linhas onde `children.parent_id = auth.uid()` (join).
- `lessons`, `challenges`, `prompt_templates`, `badges`: leitura publica autenticada, escrita restrita ao service role.
- Frontend nao acessa Postgres direto no MVP — todas as policies sao defensivas; o FastAPI usa service role.

---

## 7. API REST (FastAPI)

> Base URL: `https://api.aprendizagem.app/v1`. Todas as respostas em JSON. Autenticacao via header `Authorization: Bearer <jwt>`. Dois tipos de JWT: `parent` (Supabase Auth) e `child` (emitido pelo backend apos login da crianca).

### 7.1 Autenticacao

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| POST | /auth/parent/signup | none | `{email, password, display_name?}` | 201 `{parent_id, access_token}` | 409 email existente, 422 senha fraca |
| POST | /auth/parent/login | none | `{email, password}` | 200 `{access_token, expires_in}` | 401 credencial invalida, 429 rate limit |
| POST | /auth/parent/logout | parent | — | 204 | 401 |
| POST | /auth/parent/password-reset/request | none | `{email}` | 200 `{ok: true}` | sempre 200 |
| POST | /auth/parent/password-reset/confirm | none | `{token, new_password}` | 200 | 400 token invalido, 422 senha fraca |
| GET | /auth/parent/me | parent | — | 200 `{id, email, display_name}` | 401 |
| POST | /auth/child/login | parent | `{child_id, pin?}` | 200 `{access_token, expires_in, child}` | 401 PIN errado, 423 bloqueado |

### 7.2 Filhos (children)

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| GET | /children | parent | — | 200 `[{id,name,age,avatar_id,daily_limit_minutes,level,xp,streak_days}]` | 401 |
| POST | /children | parent | `{name, age, avatar_id, pin?, daily_limit_minutes?}` | 201 `{...}` | 409 limite 5, 422 |
| GET | /children/{id} | parent | — | 200 `{...}` | 403 nao dono, 404 |
| PATCH | /children/{id} | parent | parcial | 200 | 403, 404, 422 |
| DELETE | /children/{id} | parent | — | 204 | 403, 404 |

### 7.3 Licoes

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| GET | /lessons | child OR parent | query `?age_band=6-8` | 200 `[{id,slug,title,description,xp_reward,order_index,is_locked,prerequisites}]` | 401 |
| GET | /lessons/{id} | child OR parent | — | 200 `{...,content_blocks,challenges,prompt_templates}` | 401, 404 |
| GET | /children/{cid}/progress | child(self) OR parent(owner) | — | 200 `[{lesson_id,status,xp_earned,started_at,completed_at}]` | 401, 403 |
| POST | /lessons/{id}/start | child | — | 201 `{progress_id, status:'in_progress'}` | 401, 409 ja iniciada |
| POST | /lessons/{id}/complete | child | `{}` | 200 `{xp_total, level, badges_unlocked:[]}` | 401, 409 ja concluida |

### 7.4 Desafios

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| POST | /challenges/{id}/attempt | child | `{answer}` | 200 `{is_correct, xp_earned, correct_answer?}` | 401, 404 |

### 7.5 Chat (proxy Claude com prompts guiados)

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| POST | /chat/sessions | child | `{lesson_id}` | 201 `{session_id, started_at}` | 401, 404 |
| GET | /chat/sessions/{id} | child(owner) OR parent(owner) | — | 200 `{session, messages:[]}` | 401, 403, 404 |
| POST | /chat/sessions/{id}/messages | child | `{template_id, slots?: {slot_name: value}}` | 200 `{message_id, assistant_message:{content, moderation_status}}` | 400 input bloqueado, 401, 403, 422 slot invalido, 503 Claude indisponivel |
| POST | /chat/sessions/{id}/end | child | — | 200 `{summary, safety_status}` | 401, 403 |
| GET | /children/{cid}/sessions | parent | query `?limit=20&offset=0` | 200 `[{...}]` | 401, 403 |

**Nota tecnica do `/chat/sessions/{id}/messages`:**
1. Valida JWT child e checa que `session.child_id == jwt.child_id`.
2. Resolve `template_id` em `prompt_templates`; valida slots contra schema.
3. Roda **input moderation** (blocklist + classificador). Se bloquear: grava `chat_messages` com `moderation_status=blocked`, incrementa contador, retorna 400.
4. Monta mensagem, chama Anthropic com `model=claude-haiku-4-5-20251001` + system prompt (cacheado).
5. Roda **output moderation** na resposta. Se bloquear: substitui por mensagem segura, marca sessao `safety_status=yellow`, loga evento.
6. Persiste mensagens, atualiza `message_count`, retorna ao frontend.

### 7.6 Painel pais

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| GET | /parents/dashboard | parent | — | 200 `{children:[{id,name,xp,level,streak_days,today_minutes,recent_badges:[],alerts_count}]}` | 401 |
| GET | /children/{cid}/usage | parent | query `?from&to` | 200 `[{date, minutes_used}]` | 401, 403 |
| GET | /children/{cid}/safety-events | parent | — | 200 `[...]` | 401, 403 |

### 7.7 Heartbeat (tempo de uso)

| Method | Path | Auth | Request | Response | Erros |
|---|---|---|---|---|---|
| POST | /usage/heartbeat | child | `{seconds}` | 200 `{minutes_today, limit, blocked}` | 401 |

### 7.8 Health & infra

| Method | Path | Auth | Resp |
|---|---|---|---|
| GET | /health | none | 200 `{status:'ok', version, db, anthropic}` |

### 7.9 Padroes de erro

```json
{ "error": { "code": "INPUT_BLOCKED", "message": "Texto contem termo nao permitido", "details": {...} } }
```

Codes principais: `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `VALIDATION_ERROR`, `RATE_LIMITED`, `INPUT_BLOCKED`, `OUTPUT_BLOCKED`, `DAILY_LIMIT_REACHED`, `CLAUDE_UNAVAILABLE`.

---

## 8. Frontend — rotas e telas (Next.js App Router)

> Estrutura `app/` com 2 grupos de rotas: `(parent)` e `(child)`. Middleware redireciona conforme tipo de JWT na cookie. Tailwind com paleta quente (amarelo, laranja, roxo, verde menta) + fonte arredondada (Nunito). Componentes em `components/` separados por dominio.

### 8.1 Rotas publicas
| Rota | Proposito | Componentes | API |
|---|---|---|---|
| `/` | landing simples + CTA cadastro | `Hero`, `Features` | — |
| `/signup` | cadastro pai | `ParentSignupForm` | POST /auth/parent/signup |
| `/login` | login pai | `ParentLoginForm` | POST /auth/parent/login |
| `/forgot-password` | reset | `ResetForm` | /auth/parent/password-reset/* |

### 8.2 Rotas do pai `(parent)`
| Rota | Proposito | Componentes | API |
|---|---|---|---|
| `/dashboard` | visao geral filhos | `ChildCardGrid`, `AlertsBanner` | GET /parents/dashboard |
| `/children/new` | criar filho | `ChildForm`, `AvatarPicker` | POST /children |
| `/children/[id]` | detalhes do filho | `ChildOverview`, `ProgressList`, `BadgeWall`, `UsageChart` | GET /children/{id}, /usage, /progress |
| `/children/[id]/edit` | editar filho | `ChildForm` | PATCH /children/{id} |
| `/children/[id]/sessions` | lista de sessoes de chat | `SessionList` | GET /children/{cid}/sessions |
| `/children/[id]/sessions/[sid]` | transcricao completa | `Transcript`, `SafetyBadge` | GET /chat/sessions/{id} |
| `/children/[id]/safety` | eventos de seguranca | `SafetyTimeline` | GET /children/{cid}/safety-events |
| `/account` | conta do pai | `AccountForm` | GET /auth/parent/me |

UX pai: tom adulto, denso de informacao, charts simples (recharts), sem mascote.

### 8.3 Rotas da crianca `(child)`
| Rota | Proposito | Componentes | API |
|---|---|---|---|
| `/play` | hub | `MascotGreeting`, `LessonShelf`, `XpBar`, `StreakFlame` | GET /lessons, GET /children/{cid}/progress |
| `/play/lesson/[id]` | licao | `LessonPlayer` (blocos sequenciais), `NarrationButton` | GET /lessons/{id}, POST /lessons/{id}/start |
| `/play/lesson/[id]/challenge` | desafio | `ChallengeMC`, `ChallengeFillPrompt` | POST /challenges/{id}/attempt |
| `/play/lesson/[id]/chat` | chat com Claude | `PromptButtonRow` (6-8) ou `PromptSlotEditor` (9-12), `ChatBubbles`, `ClaudeAvatar` | POST /chat/sessions, /messages |
| `/play/lesson/[id]/done` | recompensa | `RewardModal`, `BadgeAnimation`, `XpGainAnimation` | POST /lessons/{id}/complete |
| `/play/badges` | mural de conquistas | `BadgeWall` | (dados ja em cache) |
| `/play/blocked` | tela "volte amanha" | `TimeUpScreen` | — |
| `/play/switch-profile` | trocar perfil | `AvatarGrid` | (volta a /select) |

UX crianca:
- **6-8 anos:** botoes >= 56px, fontes >= 18px, narração TTS automatica nos textos curtos, cores saturadas, mascote sempre visivel, animacoes Lottie em transicoes.
- **9-12 anos:** layout um pouco mais compacto, textos com mais conteudo, slots editaveis no chat, ranking pessoal de badges.

### 8.4 Selecao de perfil
| Rota | Proposito |
|---|---|
| `/select` | grid de avatares dos filhos do pai logado; toca → PIN se houver → `/play`. Componentes: `AvatarGrid`, `PinPad`. |

### 8.5 Estado e fetch
- **State:** Zustand para sessao/cronometro; `@tanstack/react-query` para dados servidor.
- **Auth client:** wrapper `apiClient` injeta JWT do cookie correto; intercepta 401 → redireciona.
- **TTS:** Web Speech API (`SpeechSynthesis`) com voz pt-BR; fallback silencioso.

---

## 9. Integracao com Claude (Anthropic API)

### 9.1 Modelo recomendado: `claude-haiku-4-5-20251001`
**Justificativa:**
- Custo baixo o suficiente para suportar muitas interacoes curtas de criancas sem inviabilizar a economia do app.
- Latencia menor melhora a percepcao de "magia" para criancas pequenas.
- Qualidade mais que suficiente para respostas educacionais curtas e historias guiadas.
- Ainda assim ele e da geracao 4.5, com bom alinhamento de seguranca.
- Em `[v2]`, oferecer Sonnet para licoes avancadas (>= 11 anos) opcionalmente.

### 9.2 System prompt (template, com cache)

```
Voce e o Atena, um assistente amigavel que conversa com criancas de 6 a 18 anos.
Regras inegociaveis:
- Use linguagem simples, frases curtas, tom alegre e acolhedor.
- Nunca discuta: violencia explicita, sexo, drogas, suicidio/auto-lesao, odio, politica partidaria, religiao especifica, dados pessoais.
- Se a crianca pedir algo fora dos topicos da licao atual, redirecione com gentileza.
- Nunca peca dados pessoais (nome real, escola, endereco, telefone, foto).
- Responda em portugues do Brasil.
- Use no maximo 4 frases por resposta. Se for historia, no maximo 8.
- Quando contar historia, sempre tenha final feliz ou esperancoso.

Contexto da licao atual: {{lesson_title}} — {{lesson_summary}}
Idade da crianca: {{child_age}}
```

**Cache:** o bloco fixo (regras + identidade) usa `cache_control: ephemeral` para ser servido do cache entre requisicoes. Apenas `lesson_title`, `lesson_summary` e `child_age` mudam por sessao. A primeira mensagem de cada sessao paga o custo de cache write; as demais leem do cache.

### 9.3 Mecanismo de prompts guiados
- Cada licao tem N `prompt_templates` aprovados manualmente pela equipe pedagogica.
- Para faixa 6-8: template e usado como esta, sem slots.
- Para faixa 9-12: template tem slots tipo `{{personagem}}`, `{{lugar}}`. Cada slot define `max_length` (ex: 30) e `allowed_chars` (ex: `^[A-Za-zÀ-ÿ0-9 ]+$`).
- Backend valida slots, monta mensagem final no formato:
  ```
  user: <mensagem renderizada>
  ```
- O frontend NUNCA envia texto livre direto para a Claude no MVP.

### 9.4 Camadas de seguranca

#### Filtro de input (executado no FastAPI antes da chamada Claude)
1. **Blocklist** — lista de palavras/expressoes proibidas (PT-BR + EN), gerenciada como arquivo `data/blocklist.txt` versionado.
2. **Heuristicas** — detecta padroes de PII (telefone, CPF, email, endereco).
3. **Classificador leve** — chamada rapida a Claude Haiku 4.5 com prompt de classificacao em 5 categorias. Threshold conservador.
4. **Limite de tamanho** — slots tem max_length; mensagem renderizada nao pode exceder 600 chars.

Se qualquer camada falhar → retorna `INPUT_BLOCKED`, salva `chat_messages.moderation_status='blocked'` e gera `child_safety_events`.

#### Filtro de output (executado apos receber resposta da Claude)
1. **Classificador** — mesma chamada de classificacao em 5 categorias (violencia/sexual/auto-lesao/odio/PII).
2. **Verificacao de PII na saida** — regex para garantir que Claude nao "alucinou" dados pessoais.
3. **Verificacao de tom** — se a resposta exceder 8 frases ou conter linguagem inadequada para idade, marca como bloqueada.

Se bloquear:
- Substitui resposta por mensagem segura: "Vamos tentar outra coisa! Toque em outro botao."
- `chat_sessions.safety_status` vira `yellow` (1 ocorrencia) ou `red` (3+ ocorrencias na mesma sessao).
- Cria evento `output_blocked` em `child_safety_events`.
- 3 bloqueios na mesma sessao → encerra sessao automaticamente, status `red`, alerta no painel do pai.

#### Refusal handling
- Se Claude se recusar legitimamente (mesmo apos prompts seguros) → texto e exibido a crianca como mensagem normal (Claude tende a explicar bem para criancas).

#### Escalacao
- Eventos `red` aparecem como banner permanente no `/dashboard` do pai ate ele marcar como visto.

### 9.5 Resumo de sessao
- Quando crianca chama `/end` ou sessao expira por inatividade (10 min), backend pede a Claude um resumo de 2-3 frases das mensagens da sessao. Resumo salvo em `chat_sessions.summary`.

### 9.6 Rate limits Claude
- Maximo 30 mensagens por sessao.
- Maximo 100 mensagens por crianca por dia.
- Throttle por IP via FastAPI middleware.

---

## 10. Seguranca e privacidade infantil

### 10.1 Coleta de dados
- **De criancas:** apenas `name` (apelido, nao precisa ser real), `age`, `avatar_id`, `pin_hash`. NUNCA email, telefone, foto real, geolocalizacao, escola.
- **De pais:** email + senha + opcional `display_name`.
- **Banner explicito** no cadastro: "Use um apelido, nao o nome completo do seu filho".

### 10.2 Consentimento e LGPD
- Cadastro de pai exige checkbox confirmando: (a) maioridade, (b) responsavel legal, (c) leu politica de privacidade.
- Consentimento explicito para uso de IA com a crianca.
- Politica de privacidade mencionando LGPD, base legal "consentimento do responsavel" (art. 14 LGPD para criancas).
- `[v2]` Direito de exportacao e exclusao via UI; no MVP pai pode pedir exclusao via email da equipe (botao "deletar minha conta" deleta cascade).

### 10.3 Pipeline de moderacao
Conforme secao 9.4. Toda mensagem (input e output) e classificada e logada.

### 10.4 Blocklist
Arquivo versionado `backend/app/safety/blocklist.txt` com termos em PT-BR e EN cobrindo:
- Sexo/conteudo adulto.
- Violencia explicita, armas.
- Drogas.
- Suicidio/auto-lesao.
- Discurso de odio.
- PII (formatos comuns).

### 10.5 Rate limits e abuso
- Login pai: 5 tentativas / 10 min por IP+email.
- Login crianca: 3 PIN errado → bloqueio 5 min naquele dispositivo.
- Chat: ver 9.6.
- API global: 60 req/min por IP autenticado.

### 10.6 Limite diario
- Heartbeat a cada 60s incrementa `daily_usage.minutes_used`.
- Backend retorna `blocked: true` quando atinge limite; frontend redireciona para `/play/blocked`.
- Reset 00:00 fuso `America/Sao_Paulo` (job cron diario; alternativa: calculo on-the-fly por data).

### 10.7 Chat sempre auditavel
- Pai sempre pode ler 100% das mensagens.
- Retencao: 90 dias por padrao; pai pode solicitar limpeza imediata.

### 10.8 Seguranca tecnica
- HTTPS obrigatorio.
- JWT child em cookie httpOnly + secure + sameSite=lax.
- Senhas via Supabase Auth (bcrypt).
- PIN da crianca: bcrypt com cost 10.
- Service role key do Supabase **nunca** vai ao cliente — vive no backend.
- Anthropic API key **nunca** vai ao cliente.
- CORS restrito ao dominio de producao.
- CSP no Next.js bloqueia scripts externos nao autorizados.

---

## 11. Gamificacao

### 11.1 XP
- Concluir licao: `lesson.xp_reward` (default 50).
- Acertar desafio: `challenge.xp_reward` (default 20). Nas tentativas seguintes a primeira vale metade.
- Manter streak diario: bonus de 10 XP por dia consecutivo.

### 11.2 Niveis
Formula: nivel `n` exige XP total acumulado de `100 * n * (n+1) / 2` (triangular).
- Nivel 1: 0 XP
- Nivel 2: 100 XP
- Nivel 3: 300 XP
- Nivel 4: 600 XP
- Nivel 5: 1000 XP
- Nivel 6: 1500 XP
- Nivel 7: 2100 XP
- Nivel 8: 2800 XP
- Nivel 9: 3600 XP
- Nivel 10: 4500 XP

Nomes tematicos por nivel: Curioso → Explorador → Inventor → Pesquisador → Mestre dos Prompts → Aprendiz Maker → Construtor → Cientista → Sabio → Lendario.

### 11.3 Streak
- Conta dias **consecutivos** com pelo menos 1 atividade (licao concluida ou desafio acertado).
- Reset se pular um dia.
- Calculado com base no fuso `America/Sao_Paulo`.

### 11.4 Catalogo de badges (MVP, 10+)

| code | name | descricao | regra de desbloqueio |
|---|---|---|---|
| FIRST_STEPS | Primeiros Passos | Completou sua primeira licao | 1a `lesson_progress.completed` |
| QUICK_LEARNER | Aprendiz Rapido | Completou 5 licoes | 5 licoes concluidas |
| LESSON_MASTER | Mestre das Licoes | Completou todas as licoes da sua trilha | 100% da trilha |
| PROMPT_PRO | Mestre dos Prompts | Usou 20 prompts guiados | 20 mensagens enviadas |
| STREAK_3 | Trio Vencedor | Streak de 3 dias | streak_days >= 3 |
| STREAK_7 | Semana Brilhante | Streak de 7 dias | streak_days >= 7 |
| STREAK_30 | Mes de Ouro | Streak de 30 dias | streak_days >= 30 |
| CHALLENGE_ACE | Ase dos Desafios | Acertou 10 desafios na primeira tentativa | contagem |
| CURIOUS_MIND | Mente Curiosa | Explorou 3 trilhas diferentes | join licoes |
| STORYTELLER | Contador de Historias | Criou 5 historias completas no chat | sessoes encerradas com sucesso em licoes de historia |
| LEVEL_5 | Nivel 5 | Alcancou o nivel 5 | level >= 5 |
| LEVEL_10 | Lendario | Alcancou o nivel 10 | level >= 10 |

### 11.5 Quests diarias `[v2]`
- "Termine 1 licao hoje", "Use 3 prompts diferentes hoje" etc., gerando XP extra.

---

## 12. Testes (para o qa-agent)

### 12.1 Backend (FastAPI)
- **Ferramentas:** `pytest`, `pytest-asyncio`, `httpx` (AsyncClient), `pytest-cov`, `respx` (mock Anthropic).
- **Cobertura minima:** 85% linhas, 100% nas funcoes de moderacao e auth.
- **Categorias:**
  - **Unit:** validacoes de schema (Pydantic), regras de XP/nivel, blocklist matcher, hashing de PIN, formula de streak.
  - **Integration:** endpoints com banco de teste (Supabase local ou Postgres dockerizado), com Anthropic mockada.
  - **Security/Moderation (criticos):**
    - Input com termo da blocklist → 400 e evento gravado.
    - Output com classificacao "violencia" → substituido e evento gravado.
    - 3 outputs bloqueados na mesma sessao → sessao encerrada com `red`.
    - Crianca nao consegue ler `chat_messages` de outro filho.
    - Pai nao consegue acessar `/play/*`.
    - JWT child nao consegue chamar `/parents/*`.
    - PIN errado 3x → 423.
    - Rate limit Claude.

### 12.2 Frontend (Next.js)
- **Ferramentas:** `vitest` (unit), `@testing-library/react`, `playwright` (e2e).
- **Cobertura minima:** 70% linhas em componentes de logica.
- **Categorias:**
  - **Unit:** componentes puros (XpBar, BadgeAnimation, PinPad).
  - **Integration:** fluxos de formulario com mock do API client.
  - **E2E (Playwright):** cadastro pai → criar filho → login crianca → fazer licao → chat com prompt → ganhar badge → pai ve transcricao.
  - **Acessibilidade:** axe-core nas paginas principais; checagem de contraste, foco visivel, leitura por screen reader.

### 12.3 Casos que NAO podem falhar (gates de release)
1. Filtro de moderacao bloqueia conteudo da blocklist.
2. Crianca nao acessa o painel do pai.
3. Limite diario bloqueia atividades quando atingido.
4. Frontend nao chama Anthropic diretamente (verificavel: nenhuma referencia a `api.anthropic.com` no bundle do cliente).
5. RLS impede pai A de ver dados de pai B.
6. Senhas/PINs nunca aparecem em logs.

---

## 13. Configuracao e variaveis de ambiente

### 13.1 Tabela completa

| nome | onde usa | exemplo | secret |
|---|---|---|---|
| NEXT_PUBLIC_API_BASE_URL | frontend | https://api.aprendizagem.app/v1 | nao |
| NEXT_PUBLIC_APP_URL | frontend | https://aprendizagem.app | nao |
| NEXT_PUBLIC_SUPABASE_URL | frontend | https://xxx.supabase.co | nao |
| NEXT_PUBLIC_SUPABASE_ANON_KEY | frontend | eyJhbGciOi... | nao (publica por design) |
| SENTRY_DSN | frontend+backend | https://...@sentry.io/123 | parcial |
| API_BASE_URL | backend | https://api.aprendizagem.app/v1 | nao |
| FRONTEND_ORIGIN | backend | https://aprendizagem.app | nao |
| SUPABASE_URL | backend | https://xxx.supabase.co | nao |
| SUPABASE_SERVICE_ROLE_KEY | backend | eyJhbGciOi... | **sim** |
| SUPABASE_JWT_SECRET | backend | super-long-random | **sim** |
| ANTHROPIC_API_KEY | backend | sk-ant-... | **sim** |
| ANTHROPIC_MODEL | backend | claude-haiku-4-5-20251001 | nao |
| CHILD_JWT_SECRET | backend | random-256bit | **sim** |
| CHILD_JWT_TTL_HOURS | backend | 4 | nao |
| PARENT_JWT_TTL_DAYS | backend | 7 | nao |
| MODERATION_STRICT | backend | true | nao |
| BLOCKLIST_PATH | backend | /app/safety/blocklist.txt | nao |
| RATE_LIMIT_PER_MIN | backend | 60 | nao |
| MAX_MESSAGES_PER_SESSION | backend | 30 | nao |
| MAX_MESSAGES_PER_CHILD_PER_DAY | backend | 100 | nao |
| TIMEZONE | backend | America/Sao_Paulo | nao |
| LOG_LEVEL | backend | info | nao |
| ENV | backend+frontend | production / staging / development | nao |

### 13.2 Onde guardar
- **Frontend:** Vercel project env vars; valores `NEXT_PUBLIC_*` ficam no bundle, demais no servidor Next.
- **Backend:** Railway service env vars; `*_SECRET` e `*_KEY` apenas via dashboard (nunca no repo).
- **Local dev:** `.env.local` (frontend) e `.env` (backend), ambos no `.gitignore`. Existe um `.env.example` em cada repo.

---

## 14. Plano de entrega em fases

### Fase 1 — MVP navegavel (release inicial)
- Auth pai (email/senha + reset).
- Auth crianca (avatar + PIN opcional).
- CRUD de filhos.
- 12 licoes seed (6 por faixa etaria).
- Player de licao com blocos basicos (texto + imagem).
- 1 desafio por licao (multipla escolha).
- Chat com prompts guiados (faixa 6-8 fechado, faixa 9-12 com slots).
- Pipeline de moderacao input + output.
- Painel do pai: dashboard, perfis, transcricoes, limite diario.
- Gamificacao: XP, nivel, streak, 10 badges.
- Heartbeat de uso.
- Deploy em Vercel + Railway + Supabase.
- Testes minimos (gates da secao 12.3).

### Fase 2 — Gamificacao completa e UX rica
- Quests diarias.
- Streak freezes nos finais de semana.
- Animacoes Lottie em todas as transicoes.
- Narração TTS automatica para 6-8.
- Mais 12 licoes.
- Desafios `fill_prompt` (preencher prompt).
- Login social do pai (Google).

### Fase 3 — Relatorios para pais e expansao
- Relatorio semanal por email (resumo de progresso).
- Exportacao de dados (LGPD).
- Recomendacao adaptativa de licoes.
- Modo "exploracao livre" 11-12 com supervisao reforcada.
- Eventos sazonais e badges limitados.
- Multilingue (EN).

---

## 15. Definition of Done do MVP

Checklist que o **deploy-agent** usa para decidir se o app esta pronto para producao:

- [ ] Todos os endpoints da secao 7 implementados, documentados (OpenAPI auto pelo FastAPI) e respondendo conforme contratos.
- [ ] Todas as tabelas da secao 6 criadas via migration versionada (Supabase migrations ou Alembic), com RLS habilitada.
- [ ] Seed com 12 licoes, ~24 desafios, ~36 prompt_templates e 12 badges aplicado em producao.
- [ ] Frontend cobre todas as rotas da secao 8, com responsividade mobile+desktop.
- [ ] Pipeline de moderacao (input + output) ativo com `MODERATION_STRICT=true`.
- [ ] Blocklist carregada e testada.
- [ ] Frontend confirmadamente nao chama Anthropic diretamente (auditoria de bundle).
- [ ] Todas as env vars da secao 13 configuradas no Vercel e Railway.
- [ ] Supabase configurado com auth de email habilitada e templates customizados em PT-BR.
- [ ] Testes da secao 12 verdes; cobertura backend >= 85%; gates da 12.3 todos passando.
- [ ] Logs estruturados (JSON) com nivel `info` em prod; sem PII de criancas em logs.
- [ ] Rate limits ativos.
- [ ] Health check `/health` responde 200 incluindo status do Anthropic e do banco.
- [ ] Politica de privacidade publicada com referencia a LGPD.
- [ ] Tela de cadastro tem checkbox de consentimento explicito.
- [ ] CORS restrito ao dominio de producao.
- [ ] Dominios configurados com HTTPS valido.
- [ ] Backup automatico do Supabase ativo (default da plataforma) e verificado.
- [ ] Smoke test manual end-to-end pos-deploy: cadastro pai → cria filho → login crianca → fez licao → chatou → pai viu transcricao.

Quando todos os itens estiverem marcados, o app pode ser publicado.
