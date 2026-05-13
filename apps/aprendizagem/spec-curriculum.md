# Spec Tecnico — Curriculum redesign do app "aprendizagem"

> Especificacao tecnica do **novo curriculum** do app "aprendizagem". Este documento e um **delta** sobre o spec original (`spec.md`) e **substitui** as seguintes secoes do original:
> - Secao 6.3 (`lessons` schema) — extensoes de colunas e CHECK constraints novos.
> - Secao 7.3 (Licoes) — endpoints filtrados por stage e endpoints de exam.
> - Secao 8.3 (Rotas da crianca) — `/play` agora renderiza stages, nova rota `/play/stage/[stageId]` e nova `/play/exam`.
> - Secao 11.4 (Catalogo de badges) — nao trocada aqui, **mas o seed antigo de licoes e completamente apagado** (12 antigas saem, 17 novas entram).
> Para tudo que nao aparece aqui (auth, RLS, gamificacao XP/niveis, badges, painel pais, moderacao) o spec original continua valendo sem alteracao.
> Convencoes mantidas: snake_case no banco, identificadores em ingles, textos de produto em portugues do Brasil.
> Documento e a fonte unica da verdade para os agentes backend, frontend e qa nesta refatoracao.

---

## 1. Visao geral do novo curriculum

O curriculum atual (12 licoes flat divididas por faixa etaria 6-8 e 9-12) e substituido por uma **trilha sequencial em 4 stages progressivas + 1 final exam (capstone)**, totalizando **17 licoes**:

| Stage | Tema | Dificuldade | Faixa etaria | Licoes | XP por licao |
|---|---|---|---|---|---|
| 1 | Discovery | Easy | 6-8 | 4 | 50 |
| 2 | Exploration | Medium | 9-10 | 4 | 70 |
| 3 | Creation | Hard | 11-12 | 4 | 100 |
| 4 | Prompt Engineering | Advanced | 12+ | 4 | 150 |
| Final | Project Capstone | Capstone | 12+ | 1 | 500 |

**Logica de progressao:**
- Stage 1 fica **desbloqueada por default** para qualquer crianca nova.
- Stage `N+1` desbloqueia quando **100% das licoes da Stage N** estao com `lesson_progress.status = 'completed'` para aquela crianca.
- O Final Exam desbloqueia quando as 4 stages estao 100% completas.
- A faixa etaria recomendada serve para o frontend mostrar tag visual ("recomendado 9-10 anos"), mas **nao bloqueia nada** — o filtro de bloqueio e puramente o progresso da crianca anterior.

**Modelo Claude por licao:**
- Todas as 16 licoes regulares: `claude-haiku-4-5-20251001` (mantem o modelo padrao do app, custo baixo, latencia menor — ver justificativa na secao 9.1 do spec original).
- Final Exam: **`claude-sonnet-4-6`** — escolhido porque o exame exige raciocinio multi-passo (planejar app em 5 etapas), perguntas socraticas adaptativas e qualidade de planejamento que justifica o custo extra de uma unica sessao pontual por crianca.

---

## 2. Stages e licoes — definicao completa

> Formato por licao:
> - **slug** (kebab-case, unico).
> - **title** (curto, age-appropriate, PT-BR).
> - **description** (1 frase).
> - **content_blocks** — array `jsonb` com 3+ blocos `{type, content}` ou `{type, src, alt}` para imagens. Imagens sao placeholders (a equipe de design ilustra depois).
> - **xp_reward** (int).
> - **challenge** — UM `multiple_choice`: `{question, options: [4 strings]}` + `correct_answer: {answer: 0|1|2|3}` (indice em options).
> - **prompt_template** — UM template guiado. Para 6-8 botao fechado sem slots; para 9-10/11-12 ate 2 slots; para 12+ slots mais sofisticados.
> - **claude_model** — `claude-haiku-4-5-20251001` em todas, exceto Final Exam (`claude-sonnet-4-6`).

### 2.1 Stage 1 — Discovery (Easy) — faixa 6-8

**Objetivo pedagogico:** apresentar o conceito de IA, mostrar que existe um "amigo robo" chamado Claude e ensinar como conversar com ele com seguranca, num formato totalmente narrado e tatil.

#### Lesson 1.1 — `discovery-o-que-e-ia`
- **title:** "O que e Inteligencia Artificial?"
- **description:** "Vamos descobrir o que e IA com exemplos do dia a dia."
- **xp_reward:** 50
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Voce sabia que existem programas de computador que conseguem conversar com a gente, contar historias e responder perguntas? Eles se chamam Inteligencia Artificial, ou IA pra simplificar."},
    {"type":"image","src":"placeholder-robot-friend.png","alt":"Robo amigavel acenando"},
    {"type":"text","content":"A IA aprende lendo muitos livros, sites e historias. Por isso ela sabe muita coisa! Mas ela nao e magica, e nao e uma pessoa. E como uma calculadora superinteligente."},
    {"type":"animation","content":"placeholder-anim-brain-lighting-up"},
    {"type":"text","content":"Quando voce conversa com uma IA, voce esta usando uma ferramenta. E essa ferramenta pode te ajudar a aprender, criar e brincar."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "O que e Inteligencia Artificial?",
    "options": [
      "Uma pessoa de verdade que vive dentro do computador",
      "Um programa de computador que aprendeu muita coisa",
      "Um brinquedo magico",
      "Um animal robotico"
    ]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {"label":"Oi Claude! Quem e voce?","template":"Oi! Voce pode me contar quem voce e em uma frase bem curtinha?"}
  ```

#### Lesson 1.2 — `discovery-falando-com-claude`
- **title:** "Como falar com o Claude"
- **description:** "Aprenda a fazer perguntas tocando em botoes."
- **xp_reward:** 50
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"O Claude e uma IA que adora conversar! Pra falar com ele, voce escreve uma pergunta ou um pedido. A gente chama isso de prompt."},
    {"type":"image","src":"placeholder-prompt-buttons.png","alt":"Botoes coloridos com perguntas prontas"},
    {"type":"text","content":"Aqui no app, pra facilitar, a gente ja preparou uns botoes coloridos pra voce. E so tocar e o Claude responde!"},
    {"type":"text","content":"Cada botao tem um pedido diferente. Experimenta tocar e ve o que acontece. O Claude vai responder de um jeito gentil e divertido."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Como a gente chama o que voce escreve quando fala com o Claude?",
    "options": ["Mensagem","Prompt","Botao","Pedido secreto"]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {"label":"Me conta uma curiosidade legal!","template":"Me conta uma curiosidade bem legal e curtinha sobre animais, pra uma crianca de 7 anos."}
  ```

#### Lesson 1.3 — `discovery-regras-de-seguranca`
- **title:** "Regras de seguranca com IA"
- **description:** "Coisas importantes pra lembrar quando voce conversa com uma IA."
- **xp_reward:** 50
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Conversar com IA e divertido, mas tem 3 regrinhas importantes que toda crianca precisa saber."},
    {"type":"image","src":"placeholder-shield.png","alt":"Escudo de seguranca"},
    {"type":"text","content":"Regra 1: Nunca conte coisas pessoais. Nada de nome inteiro, endereco, telefone ou nome da escola. Use sempre seu apelido."},
    {"type":"text","content":"Regra 2: Se o Claude disser algo que te deixar confuso ou triste, conta pro seu pai ou sua mae. Sempre."},
    {"type":"text","content":"Regra 3: A IA pode errar! Ela e muito esperta, mas nao sabe tudo. Se algo parecer estranho, pergunta pra um adulto."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Voce pode contar pro Claude o nome da sua escola?",
    "options": ["Sim, sem problema","Nao, e uma informacao pessoal","So se ele pedir","So se for uma escola legal"]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {"label":"Me ensina uma regra de seguranca","template":"Me da uma dica curtinha de seguranca pra criancas que conversam com inteligencia artificial."}
  ```

#### Lesson 1.4 — `discovery-primeira-conversa`
- **title:** "Sua primeira conversa de verdade"
- **description:** "Vamos colocar tudo em pratica e conversar com o Claude!"
- **xp_reward:** 50
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Agora voce ja sabe o que e IA, sabe como falar com o Claude e sabe as regras de seguranca. Bora conversar de verdade!"},
    {"type":"animation","content":"placeholder-anim-chat-bubble-pop"},
    {"type":"text","content":"Toca no botao colorido la embaixo. Voce vai pedir pro Claude te contar uma historia bem legal. Presta atencao, porque vai ter pergunta depois!"},
    {"type":"text","content":"Lembra: o Claude e seu amigo de aprender. E so se divertir!"}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Voce ja pode comecar a conversar com o Claude?",
    "options": ["Ainda nao","So depois de virar adulto","Sim, com prompts seguros","So se o Claude pedir"]
  }
  ```
  `correct_answer: {"answer": 2}`
- **prompt_template:**
  ```json
  {"label":"Me conta uma historia bem curtinha!","template":"Me conta uma historia bem curtinha e feliz pra uma crianca de 7 anos. Maximo 4 frases."}
  ```

---

### 2.2 Stage 2 — Exploration (Medium) — faixa 9-10

**Objetivo pedagogico:** entender como prompts funcionam por dentro, comecar a customizar pedidos com slots, ver um exemplo de API real e descobrir o que e MCP.

#### Lesson 2.1 — `exploration-como-prompts-funcionam`
- **title:** "Como prompts funcionam"
- **description:** "Por que algumas perguntas dao respostas melhores que outras."
- **xp_reward:** 70
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Um prompt e como uma instrucao que voce da pra IA. Quanto mais clara a instrucao, melhor a resposta."},
    {"type":"image","src":"placeholder-prompt-anatomy.png","alt":"Diagrama mostrando partes de um prompt"},
    {"type":"text","content":"Compara essas duas perguntas: 'Conta uma historia' e 'Conta uma historia de 3 frases sobre um dragao que ama brigadeiro'. Qual voce acha que vai dar uma resposta mais legal?"},
    {"type":"text","content":"O segredo e dar contexto: sobre o que, quao longo, qual o estilo. Quanto mais voce diz, mais a IA acerta o que voce quer."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Qual prompt provavelmente da uma resposta melhor?",
    "options": [
      "Fala alguma coisa",
      "Me explica como funciona o ciclo da agua em 3 passos curtos",
      "Conta",
      "Hum"
    ]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {
    "label":"Me explica {{topico}} em 3 passos",
    "template":"Me explica {{topico}} em 3 passos curtos, pra uma crianca de 10 anos.",
    "slots":[{"name":"topico","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]
  }
  ```

#### Lesson 2.2 — `exploration-respostas-melhores`
- **title:** "Conseguindo respostas melhores"
- **description:** "Tres truques pra fazer a IA te entender melhor."
- **xp_reward:** 70
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Truque 1: Diga pra quem e a resposta. Por exemplo, 'explica pra uma crianca de 10 anos' deixa a IA usar palavras mais simples."},
    {"type":"text","content":"Truque 2: Diga o tamanho. 'Em 2 frases', 'em uma lista de 5 itens', 'curto e direto'. Isso evita resposta gigante."},
    {"type":"image","src":"placeholder-three-tricks.png","alt":"Tres truques de prompt ilustrados"},
    {"type":"text","content":"Truque 3: Diga o formato. 'Como uma historia', 'como uma receita', 'como uma poesia'. A IA muda o jeito de responder."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Qual desses NAO e um bom truque pra melhorar prompts?",
    "options": [
      "Dizer pra quem e a resposta",
      "Dizer o tamanho desejado",
      "Escrever tudo em letra maiuscula gritando",
      "Dizer o formato (lista, historia, etc)"
    ]
  }
  ```
  `correct_answer: {"answer": 2}`
- **prompt_template:**
  ```json
  {
    "label":"Me explica {{tema}} como uma {{formato}}",
    "template":"Me explica {{tema}} como uma {{formato}}, em 3 ou 4 frases, pra uma crianca de 10 anos.",
    "slots":[
      {"name":"tema","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},
      {"name":"formato","max_length":20,"allowed_chars":"^[A-Za-zÀ-ÿ ]+$"}
    ]
  }
  ```

#### Lesson 2.3 — `exploration-exemplo-com-api-real`
- **title:** "Um exemplo de verdade: pegando dados de Pokemon"
- **description:** "Vamos ver como programas pegam informacao da internet, usando uma API real de Pokemon."
- **xp_reward:** 70
- **claude_model:** `claude-haiku-4-5-20251001`

> **Decisao:** entre as duas APIs publicas oferecidas, escolhemos a **PokeAPI** (`https://pokeapi.co/api/v2/pokemon/ditto`) ao inves da Open Notify ISS.
> **Justificativa:** o JSON da PokeAPI tem campos visualmente reconheciveis (name, types, abilities, height, weight) que toda crianca de 9-10 anos consegue ler e relacionar com algo familiar (Pokemon e cultura universal). O JSON do ISS tem coordenadas geograficas e timestamp Unix — abstratos demais pra essa idade. Alem disso, a resposta da PokeAPI e estavel, cacheavel e tem uma estrutura amigavel (objeto com chaves nomeadas), perfeita pra introduzir o conceito de "dados estruturados". Limitamos a apresentacao ao Pokemon `ditto` (resposta determinista, sem necessidade de input livre).

- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Sabe quando voce abre um app e ele mostra a previsao do tempo? O app pegou esses dados de algum lugar na internet. Esse 'algum lugar' chama API."},
    {"type":"text","content":"Uma API e como uma janelinha que um site abre pra outros programas pegarem informacao. Vamos ver uma API de Pokemon!"},
    {"type":"image","src":"placeholder-pokeapi-ditto.png","alt":"Captura de tela do JSON do Ditto na PokeAPI"},
    {"type":"text","content":"Quando a gente pede informacao do Ditto na PokeAPI, ela responde com um monte de dados: o nome dele, os tipos, as habilidades, o peso. Tudo organizadinho!"},
    {"type":"text","content":"O Claude consegue ler dados assim e te explicar de um jeito divertido. Bora pedir pra ele descrever o Ditto?"}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "O que e uma API?",
    "options": [
      "Um tipo de Pokemon",
      "Uma janelinha que sites abrem pra outros programas pegarem dados",
      "Um app de jogos",
      "Um robo"
    ]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {
    "label":"Me descreve o Pokemon {{nome}} de um jeito divertido",
    "template":"Me descreve o Pokemon {{nome}} de um jeito divertido em 3 frases, como se fosse pra uma crianca de 10 anos.",
    "slots":[{"name":"nome","max_length":20,"allowed_chars":"^[A-Za-z ]+$"}]
  }
  ```

#### Lesson 2.4 — `exploration-o-que-e-mcp`
- **title:** "O que e MCP (Model Context Protocol)"
- **description:** "Como a IA consegue se conectar com outros programas pra te ajudar mais."
- **xp_reward:** 70
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Imagina se a IA pudesse ver seu calendario, suas notas, ou pegar dados de um site, sem voce precisar copiar e colar?"},
    {"type":"image","src":"placeholder-mcp-bridge.png","alt":"Ilustracao mostrando IA conectada a varios servicos"},
    {"type":"text","content":"O MCP, ou Model Context Protocol, e um padrao que permite a IA conversar diretamente com outros programas. E como dar superpoderes pra ela!"},
    {"type":"text","content":"Por exemplo, com MCP o Claude pode ler um arquivo, buscar algo no Google ou ate criar um desenho. Tudo isso sem precisar sair da conversa."},
    {"type":"text","content":"O MCP foi criado pra que IAs ajudem mais e melhor. E uma ideia recente, e e bem importante!"}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Pra que serve o MCP?",
    "options": [
      "Pra IA conversar com outros programas e servicos",
      "Pra IA cozinhar",
      "Pra desligar o computador",
      "Pra trocar a senha"
    ]
  }
  ```
  `correct_answer: {"answer": 0}`
- **prompt_template:**
  ```json
  {
    "label":"Me explica o que MCP poderia fazer com {{ferramenta}}",
    "template":"Me explica em 3 frases, pra uma crianca de 10 anos, o que o Claude poderia fazer se ele se conectasse com {{ferramenta}} usando MCP.",
    "slots":[{"name":"ferramenta","max_length":25,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]
  }
  ```

---

### 2.3 Stage 3 — Creation (Hard) — faixa 11-12

**Objetivo pedagogico:** sair do papel de "consumidor" e virar "criador" — usar o Claude pra construir coisas reais (textos, planos, ideias), encadear pedidos e atacar problemas do dia a dia.

#### Lesson 3.1 — `creation-construindo-com-claude`
- **title:** "Construindo algo com o Claude"
- **description:** "Como pedir ajuda pra criar algo do zero."
- **xp_reward:** 100
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Ate agora voce conversou e aprendeu. Agora voce vai criar! O Claude e otimo parceiro pra construir coisas: textos, planos, ideias, ate jogos simples."},
    {"type":"image","src":"placeholder-build-with-ai.png","alt":"Crianca e robo construindo juntos"},
    {"type":"text","content":"Quando a gente quer criar algo, o segredo e descrever o objetivo com detalhe. Em vez de 'me ajuda com um projeto', tenta: 'me ajuda a planejar um cartaz sobre reciclagem pra escola'."},
    {"type":"text","content":"O Claude vai te dar uma estrutura, sugerir titulos, ideias de imagens. Voce escolhe o que gosta e refina."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Qual e o segredo pra criar algo bom com a IA?",
    "options": [
      "Falar pouco e deixar ela adivinhar",
      "Descrever o objetivo com detalhe",
      "Pedir tudo em uma palavra so",
      "Nao explicar nada"
    ]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {
    "label":"Me ajuda a criar {{coisa}} sobre {{tema}}",
    "template":"Me ajuda a criar {{coisa}} sobre {{tema}}. Me da uma estrutura em 4 ou 5 partes, com sugestoes pra cada uma.",
    "slots":[
      {"name":"coisa","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},
      {"name":"tema","max_length":40,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}
    ]
  }
  ```

#### Lesson 3.2 — `creation-encadeando-prompts`
- **title:** "Encadeando prompts"
- **description:** "Use varias perguntas em sequencia pra chegar mais longe."
- **xp_reward:** 100
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Encadear prompts e usar uma resposta pra alimentar a proxima pergunta. E como construir uma escada degrau por degrau."},
    {"type":"image","src":"placeholder-prompt-chain.png","alt":"Varios baloes de fala conectados como uma escada"},
    {"type":"text","content":"Exemplo: primeiro voce pede 'me da 5 ideias de redacao'. Depois voce escolhe uma e pergunta 'me ajuda a desenvolver essa daqui em 3 paragrafos'."},
    {"type":"text","content":"Em vez de pedir tudo de uma vez (que confunde a IA), voce vai construindo aos poucos. Cada prompt entrega uma peca do quebra-cabeca."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Encadear prompts significa:",
    "options": [
      "Repetir a mesma pergunta varias vezes",
      "Usar a resposta de um prompt pra alimentar o proximo",
      "Falar baixinho com a IA",
      "Trancar o computador"
    ]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {
    "label":"Me da 5 ideias de {{tipo_de_projeto}}",
    "template":"Me da 5 ideias curtas de {{tipo_de_projeto}}. Numera de 1 a 5. Eu vou escolher uma depois pra desenvolver.",
    "slots":[{"name":"tipo_de_projeto","max_length":40,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]
  }
  ```

#### Lesson 3.3 — `creation-ideia-de-chatbot`
- **title:** "Criando a ideia de um chatbot simples"
- **description:** "Vamos planejar um chatbot que ajuda numa tarefa do dia a dia."
- **xp_reward:** 100
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Um chatbot e um programa que conversa por mensagens. Pode ser pra ajudar a estudar, lembrar tarefas, ou ate sugerir filmes."},
    {"type":"image","src":"placeholder-chatbot-design.png","alt":"Wireframe de um chatbot simples"},
    {"type":"text","content":"Pra planejar um chatbot, voce precisa pensar em: 1) qual problema ele resolve, 2) quem vai usar, 3) que tipo de pergunta ele responde, 4) qual a personalidade dele."},
    {"type":"text","content":"Hoje voce vai usar o Claude pra ajudar a desenhar a ideia de um chatbot. Voce so precisa dizer pra que ele serve!"}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Qual NAO e uma pergunta importante pra planejar um chatbot?",
    "options": [
      "Qual problema ele resolve",
      "Quem vai usar",
      "Qual a cor preferida do programador",
      "Que tipo de pergunta ele responde"
    ]
  }
  ```
  `correct_answer: {"answer": 2}`
- **prompt_template:**
  ```json
  {
    "label":"Me ajuda a planejar um chatbot pra {{publico}} sobre {{assunto}}",
    "template":"Me ajuda a planejar um chatbot que ajuda {{publico}} com {{assunto}}. Me responde com: 1) qual problema ele resolve, 2) 3 perguntas que ele responde, 3) que personalidade ele teria.",
    "slots":[
      {"name":"publico","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},
      {"name":"assunto","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}
    ]
  }
  ```

#### Lesson 3.4 — `creation-resolvendo-problema-real`
- **title:** "Usando o Claude pra resolver um problema real"
- **description:** "Pega um problema do seu dia e ataca com a IA."
- **xp_reward:** 100
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"O Claude pode te ajudar com problemas reais: organizar a mochila pra prova, planejar uma festa, escrever um agradecimento, achar um erro num texto."},
    {"type":"image","src":"placeholder-real-problem.png","alt":"Lista de tarefas com check marks"},
    {"type":"text","content":"O truque e descrever o problema do jeito que voce contaria pra um amigo: o que esta acontecendo, o que voce quer alcancar e o que ja tentou."},
    {"type":"text","content":"Quanto mais contexto, melhor a ajuda. Mas lembra das regras: nada de dados pessoais!"}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Quando voce pede ajuda pra IA com um problema real, o que voce DEVE evitar contar?",
    "options": [
      "O que esta acontecendo",
      "O que voce ja tentou",
      "Seu endereco completo e telefone",
      "O que voce quer alcancar"
    ]
  }
  ```
  `correct_answer: {"answer": 2}`
- **prompt_template:**
  ```json
  {
    "label":"Me ajuda a resolver: {{problema}}",
    "template":"Me ajuda a resolver esse problema: {{problema}}. Me responde com 3 passos praticos que eu posso fazer hoje, sem usar dados pessoais.",
    "slots":[{"name":"problema","max_length":80,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ,.?!]+$"}]
  }
  ```

---

### 2.4 Stage 4 — Prompt Engineering (Advanced) — faixa 12+

**Objetivo pedagogico:** introduzir tecnicas profissionais de prompt engineering num formato acessivel pra adolescente. Saida: aluno consegue formular prompts com role/persona, exemplos few-shot, raciocinio passo-a-passo e system prompts simples.

#### Lesson 4.1 — `prompt-eng-roles-e-personas`
- **title:** "Roles e Personas"
- **description:** "Como dar uma 'persona' pra IA muda completamente a resposta."
- **xp_reward:** 150
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Quando voce comeca um prompt com 'Voce e um professor de historia animado', a IA passa a responder no estilo daquela persona. Isso se chama dar uma role."},
    {"type":"image","src":"placeholder-persona-mask.png","alt":"Mascara de teatro simbolizando personas"},
    {"type":"text","content":"Por que isso importa? Porque a mesma pergunta tem respostas muito diferentes dependendo de quem responde. Um professor explica diferente de um cientista, que explica diferente de um amigo."},
    {"type":"text","content":"Voce define a persona dizendo: o papel ('voce e um X'), o tom ('animado, paciente'), e o publico ('pra um aluno do 7o ano'). Tres ingredientes simples, resposta muito mais util."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Qual desses NAO faz parte de uma boa persona?",
    "options": [
      "O papel ('voce e um cientista')",
      "O tom ('animado, gentil')",
      "O publico ('pra um aluno do 7o ano')",
      "A senha do wifi"
    ]
  }
  ```
  `correct_answer: {"answer": 3}`
- **prompt_template:**
  ```json
  {
    "label":"Voce e um {{persona}} {{tom}}, me explica {{topico}}",
    "template":"Voce e um {{persona}} {{tom}}. Me explica {{topico}} pra um adolescente de 13 anos, em 4 frases curtas.",
    "slots":[
      {"name":"persona","max_length":25,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},
      {"name":"tom","max_length":20,"allowed_chars":"^[A-Za-zÀ-ÿ ]+$"},
      {"name":"topico","max_length":40,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}
    ]
  }
  ```

#### Lesson 4.2 — `prompt-eng-few-shot`
- **title:** "Few-shot examples"
- **description:** "Mostrar exemplos do que voce quer e quase magica."
- **xp_reward:** 150
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Few-shot e dar pra IA alguns exemplos do tipo de resposta que voce quer, antes de pedir o resultado. E como mostrar o gabarito antes da prova."},
    {"type":"image","src":"placeholder-few-shot.png","alt":"Tres exemplos seguidos de uma pergunta"},
    {"type":"text","content":"Por exemplo: 'Transforma essas frases em emojis. Frase: estou feliz. Resposta: cara feliz. Frase: choveu muito. Resposta: nuvem chuvosa. Agora: o gato dormiu.' A IA pega o padrao."},
    {"type":"text","content":"Funciona melhor com 2 ou 3 exemplos. Menos que isso a IA nao pega o padrao; mais que isso voce so esta gastando token a toa."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Quantos exemplos few-shot geralmente sao suficientes?",
    "options": ["Zero","De 2 a 3","Mais de 50","Exatamente 100"]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {
    "label":"Aprende com exemplos e classifica {{nova_frase}}",
    "template":"Vou te dar exemplos de classificacao de frases como 'positivo' ou 'negativo'. Exemplo 1: 'Adorei o filme' -> positivo. Exemplo 2: 'Foi um dia chato' -> negativo. Agora classifica essa: '{{nova_frase}}'. Responde so com a palavra positivo ou negativo.",
    "slots":[{"name":"nova_frase","max_length":80,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ,.?!]+$"}]
  }
  ```

#### Lesson 4.3 — `prompt-eng-chain-of-thought`
- **title:** "Chain of thought"
- **description:** "Pedir pra IA pensar passo a passo melhora a precisao."
- **xp_reward:** 150
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"Chain of thought e pedir pra IA pensar passo a passo antes de responder. E como mostrar o calculo na prova de matematica."},
    {"type":"image","src":"placeholder-thinking-steps.png","alt":"Passos numerados de raciocinio"},
    {"type":"text","content":"E so adicionar 'Pense passo a passo' ou 'Mostre seu raciocinio'. A IA passa a explicar o caminho ate a resposta — e geralmente acerta mais."},
    {"type":"text","content":"Funciona muito bem em problemas de logica, matematica, contagem, ou qualquer coisa que tenha varios passos. Pra perguntas simples, nao precisa."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "Qual frase ativa chain of thought?",
    "options": [
      "Responda super rapido",
      "Pense passo a passo antes de responder",
      "Use poucas palavras",
      "Conta uma piada"
    ]
  }
  ```
  `correct_answer: {"answer": 1}`
- **prompt_template:**
  ```json
  {
    "label":"Pensa passo a passo: {{problema}}",
    "template":"Pensa passo a passo antes de responder. Me mostra cada passo do raciocinio, e no final escreve 'Resposta:' seguido da conclusao. Problema: {{problema}}",
    "slots":[{"name":"problema","max_length":120,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ,.?!+\\-*/=()]+$"}]
  }
  ```

#### Lesson 4.4 — `prompt-eng-system-prompts`
- **title:** "System prompts"
- **description:** "A instrucao mestra que controla todo o comportamento da IA."
- **xp_reward:** 150
- **claude_model:** `claude-haiku-4-5-20251001`
- **content_blocks:**
  ```json
  [
    {"type":"text","content":"O system prompt e tipo o manual da IA. Ele define o papel, as regras, o tom, e o que ela pode ou nao pode fazer. E configurado uma vez e vale pra conversa toda."},
    {"type":"image","src":"placeholder-system-prompt.png","alt":"Documento de regras com cabecalho 'system'"},
    {"type":"text","content":"Em apps profissionais, o system prompt fica escondido do usuario. E o que faz a IA do app de musica ser diferente da IA do app de receitas, mesmo sendo o mesmo modelo por baixo."},
    {"type":"text","content":"Um bom system prompt tem: identidade ('voce e o X'), tarefa ('seu objetivo e Y'), regras ('nunca faca Z') e formato de resposta ('responda em maximo 3 frases')."}
  ]
  ```
- **challenge:**
  ```json
  {
    "question": "O system prompt serve pra:",
    "options": [
      "Definir as regras gerais e a identidade da IA na conversa toda",
      "Trocar a senha do usuario",
      "Imprimir o que a IA disser",
      "Ligar o computador"
    ]
  }
  ```
  `correct_answer: {"answer": 0}`
- **prompt_template:**
  ```json
  {
    "label":"Cria um system prompt pra um assistente de {{area}} com tom {{tom}}",
    "template":"Escreva um system prompt curto (4 a 6 linhas) pra um assistente de {{area}} com tom {{tom}}. Inclua: identidade, tarefa, 2 regras e formato de resposta.",
    "slots":[
      {"name":"area","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},
      {"name":"tom","max_length":20,"allowed_chars":"^[A-Za-zÀ-ÿ ]+$"}
    ]
  }
  ```

---

### 2.5 Final Exam — Project Capstone — faixa 12+

#### Lesson `final-exam-project-capstone`
- **title:** "Projeto Final: planeje seu app dos sonhos"
- **description:** "Conte sua ideia de app pro Claude e construa o plano juntos, em 5 passos."
- **xp_reward:** 500
- **claude_model:** **`claude-sonnet-4-6`**
- **stage:** 5 (ou flag `is_final_exam = true` — ver decisao na secao 3)
- **unlock_rule:** as 4 stages anteriores 100% completas.

**Fluxo do exame:**
1. Crianca abre `/play/exam` e ve uma tela diferente, tipo "console de planejamento", com o Claude apresentando-se como mentor.
2. O Claude (Sonnet 4.6, com system prompt especial — secao 5) conduz a crianca por **5 passos**:
   1. **Que problema seu app resolve?**
   2. **Pra quem ele serve (usuarios)?**
   3. **Quais sao as 3 funcionalidades principais?**
   4. **Como seria a tela inicial dele?**
   5. **Qual seria o primeiro passo pra construir?**
3. A cada passo o Claude faz perguntas socraticas pra ajudar a crianca a refinar a ideia.
4. Ao final, o Claude resume o plano em formato de "ficha do projeto" e parabeniza a crianca.
5. Backend marca o exame como `completed`, credita 500 XP, desbloqueia badge especial `CAPSTONE_BUILDER` (ver secao 8.3), e mostra tela de celebracao.

**content_blocks (tela introdutoria):**
```json
[
  {"type":"text","content":"Voce chegou ao fim do curso! Esta na hora de provar tudo que voce aprendeu construindo o plano de um app dos seus sonhos, junto com o Claude."},
  {"type":"image","src":"placeholder-capstone-stage.png","alt":"Palco com luzes simbolizando o exame final"},
  {"type":"text","content":"Aqui o Claude vai conversar diferente: ele vai te fazer perguntas em vez de te dar respostas prontas. Vai ser voce no comando da ideia."},
  {"type":"text","content":"Vamos passar por 5 etapas: o problema, os usuarios, as funcionalidades, a tela inicial e o primeiro passo. No fim, voce sai com um plano de verdade."},
  {"type":"text","content":"Lembra das regras: sem dados pessoais, sem promessas comerciais. Foca na ideia! Bora?"}
]
```

**challenge:** o exame nao usa o sistema de `challenges` regular; o "desafio" e completar os 5 passos. Pode ser modelado opcionalmente como `kind='multiple_choice'` placeholder com 1 questao auto-completada pelo backend ao concluir o exame, ou — melhor — `challenge_id` pode ser `NULL` pra essa licao especifica (a coluna ja e nullable de fato porque nao ha FK obrigatorio em `lessons` apontando pra `challenges`; o frontend so renderiza challenge se houver). **Decisao: nao criar `challenge` row pra final exam.**

**prompt_template:** o exame nao usa templates fechados — a interacao e conduzida pelo system prompt. Mesmo assim, o frontend pode oferecer 1 botao "Comecar" inicial:
```json
{"label":"Estou pronto, vamos planejar meu app!","template":"Oi! Estou pronto pra planejar meu app dos sonhos. Pode comecar com a primeira pergunta?"}
```

**Restricao adicional:** maximo de 30 mensagens na sessao do exame (mantido o limite global da secao 9.6 do spec original). Se a crianca quiser mais, pode reabrir.

---

## 3. Database schema delta

Esta secao descreve as alteracoes na tabela `lessons` e adjacentes. **Drop+recreate de seed**, nao perda de schema. Migration 100% idempotente.

### 3.1 Alteracoes em `lessons`

```sql
-- Adicionar coluna stage (1 a 4 pra licoes regulares, 5 reservado pra final exam)
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS stage INTEGER NOT NULL DEFAULT 1
  CHECK (stage BETWEEN 1 AND 5);

-- Adicionar flag de final exam (decisao: usar AMBOS — stage=5 E is_final_exam=true,
-- pra deixar a query trivial nos dois eixos, sem ambiguidade)
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS is_final_exam BOOLEAN NOT NULL DEFAULT FALSE;

-- Adicionar claude_model com default Haiku; final exam vai sobrescrever
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS claude_model TEXT NOT NULL
  DEFAULT 'claude-haiku-4-5-20251001';

-- Trocar CHECK constraint de age_band pra aceitar 4 bandas
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_age_band_check;
ALTER TABLE lessons
  ADD CONSTRAINT lessons_age_band_check
  CHECK (age_band IN ('6-8','9-10','11-12','12+'));

-- Atualizar tambem prompt_templates.age_band (mesmo CHECK, mesma migracao)
ALTER TABLE prompt_templates DROP CONSTRAINT IF EXISTS prompt_templates_age_band_check;
ALTER TABLE prompt_templates
  ADD CONSTRAINT prompt_templates_age_band_check
  CHECK (age_band IN ('6-8','9-10','11-12','12+'));

-- Index novo pra acelerar listagem por stage
CREATE INDEX IF NOT EXISTS idx_lessons_stage_active
  ON lessons (stage, is_active, order_index);

-- Garantir unicidade do final exam (so pode existir 1)
CREATE UNIQUE INDEX IF NOT EXISTS uq_lessons_final_exam
  ON lessons (is_final_exam) WHERE is_final_exam = TRUE;
```

> **Decisao registrada:** mantemos o schema original `age_band` como text com CHECK, **mas com 4 valores em vez de 2**. Isso preserva compatibilidade com ja-existente codigo em Pydantic schemas e simplifica a migracao. As bandas ficam: `6-8`, `9-10`, `11-12`, `12+`.

### 3.2 Limpeza do seed antigo e re-seed

```sql
-- ON DELETE CASCADE em challenges, prompt_templates, lesson_progress, chat_sessions
-- ja existe no schema original, entao o DELETE em lessons cascateia naturalmente.
DELETE FROM lessons;

-- INSERT das 16 licoes regulares + 1 final exam = 17 rows
-- (corpo completo do INSERT delegado ao backend-agent, mas o conteudo
-- vem da secao 2 deste spec, que define cada licao por completo)
```

### 3.3 Atualizacao do `children.age` CHECK

```sql
-- A tabela children ainda restringe age entre 6 e 12 (spec original 6.2).
-- Ampliar pra 6 a 16 pra suportar a banda "12+":
ALTER TABLE children DROP CONSTRAINT IF EXISTS children_age_check;
ALTER TABLE children
  ADD CONSTRAINT children_age_check CHECK (age BETWEEN 6 AND 16);
```

### 3.4 Migration script idempotente

O backend-agent deve criar um arquivo `backend/migrations/002_curriculum_redesign.sql` (ou Alembic equivalente) com:
1. Todos os `ALTER TABLE` da secao 3.1.
2. O `ALTER` de `children.age` da 3.3.
3. O `DELETE FROM lessons` (cascade).
4. Os `INSERT INTO lessons (...)` com as 17 linhas.
5. Os `INSERT INTO prompt_templates (...)` ligados a cada lesson_id (via subquery por slug).
6. Os `INSERT INTO challenges (...)` para as 16 licoes regulares (final exam nao cria challenge row).

Toda a migration roda dentro de uma `BEGIN; ... COMMIT;` pra atomicidade. Re-rodar a migration deve dar `0 rows updated` em vez de erro.

---

## 4. Logica de unlock — backend

### 4.1 Regra formal

Para cada crianca `C` e cada licao `L`:
- `is_locked(C, L) = true` se:
  - `L.stage == 1`: nunca, sempre desbloqueada.
  - `L.stage == N` (N entre 2 e 4): existe pelo menos uma licao `L'` com `L'.stage == N-1` e `L'.is_active == true` que `C` NAO completou.
  - `L.is_final_exam == true`: existe pelo menos uma licao `L'` com `L'.is_active == true` e `L'.is_final_exam == false` que `C` NAO completou.

### 4.2 Implementacao sugerida (SQL helper)

```sql
-- Conta licoes incompletas por stage por crianca
CREATE OR REPLACE VIEW v_child_stage_progress AS
SELECT
  c.id AS child_id,
  l.stage AS stage,
  COUNT(*) FILTER (WHERE l.is_active) AS total_lessons,
  COUNT(*) FILTER (WHERE l.is_active AND lp.status = 'completed') AS completed_lessons
FROM children c
CROSS JOIN lessons l
LEFT JOIN lesson_progress lp
  ON lp.child_id = c.id AND lp.lesson_id = l.id
WHERE l.is_final_exam = FALSE
GROUP BY c.id, l.stage;
```

Backend usa essa view (ou recalcula em codigo Python) pra computar `is_locked` por licao em cada request de listagem.

### 4.3 Aplicacao em endpoints

- `POST /v1/lessons/{id}/start`: recalcular `is_locked` no servidor; se `true`, retorna **403** com `{"error": {"code": "LESSON_LOCKED", "message": "Esta licao ainda esta bloqueada. Termine a stage anterior primeiro."}}`. (Distinto de 404 pra nao confundir o frontend.)
- `POST /v1/exam/start`: idem; 403 com `EXAM_LOCKED` se nem todas as 16 estiverem completas.

---

## 5. API endpoints — alteracoes e adicoes

> Base URL: `https://api.aprendizagem.app/v1`. Reutiliza padroes de auth e erros do spec original (secao 7).

### 5.1 Stages

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| GET | /stages | child OR parent | — | 200 lista das 4 stages + final exam metadata |

**Resposta `/stages`:**
```json
{
  "stages": [
    {
      "stage": 1,
      "name": "Discovery",
      "description": "Vamos descobrir o que e IA",
      "age_band_label": "6-8 anos",
      "difficulty": "easy",
      "is_unlocked": true,
      "lessons_total": 4,
      "lessons_completed": 2,
      "is_completed": false
    },
    { "stage": 2, "name": "Exploration", "...": "..." },
    { "stage": 3, "name": "Creation", "...": "..." },
    { "stage": 4, "name": "Prompt Engineering", "...": "..." }
  ],
  "final_exam": {
    "lesson_id": "uuid",
    "is_unlocked": false,
    "is_completed": false,
    "label": "Projeto Final",
    "claude_model": "claude-sonnet-4-6"
  }
}
```

### 5.2 Lessons (alterado)

| Method | Path | Auth | Query | Response |
|---|---|---|---|---|
| GET | /lessons | child OR parent | `?stage=N` (1-4) **ou** `?age_band=6-8` (mantido pra compat) | 200 lista de licoes da stage filtrada, com `is_locked`, `stage`, `claude_model`, `is_final_exam` por item |
| GET | /lessons/{id} | child OR parent | — | 200 detalhes da licao + lock status |
| POST | /lessons/{id}/start | child | — | 201 ou **403 LESSON_LOCKED** se bloqueada |
| POST | /lessons/{id}/complete | child | `{}` | 200 com `xp_total, level, badges_unlocked, stage_unlocked?` (campo novo: se essa conclusao desbloqueou a proxima stage, retorna o numero dela) |

`stage_unlocked` permite ao frontend disparar uma celebracao especial ("Voce desbloqueou a Stage 2!").

### 5.3 Exam (novo)

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | /exam/start | child | — | 201 `{session_id, started_at, lesson_id}` ou **403 EXAM_LOCKED** |
| POST | /exam/sessions/{id}/messages | child | `{content}` | 200 `{message_id, assistant_message:{content}, current_step:1..5, is_complete:bool}` |
| POST | /exam/sessions/{id}/submit | child | — | 200 `{xp_earned: 500, badges_unlocked: ["CAPSTONE_BUILDER"], summary, plan: {problem, users, features, screen, first_step}}` |

> **Nota tecnica do `/exam/sessions/{id}/messages`:**
> - Diferente do chat regular, **aceita texto livre da crianca** (com input moderation reforcada). A interacao e conversacional natural com o Claude (Sonnet 4.6).
> - O backend rastreia `current_step` (1-5) inspecionando o conteudo das mensagens do assistente (heuristica simples: contar quantas das 5 perguntas-chave foram feitas) e, ao detectar a 5a, marca `is_complete=true` no metadata.
> - System prompt **nao cacheado** (volume baixo nao justifica) — usa o template da secao 6 abaixo.
> - Limite: 30 mensagens por sessao.
> - Output moderation continua ativa (mesma da secao 9.4 do spec original).

### 5.4 Compatibilidade

- O endpoint `GET /lessons?age_band=...` continua funcionando, mas o frontend novo nao usa mais — passa a usar `?stage=N`. Mantemos por compat com integracoes externas hipoteticas (deprecated, marcar no OpenAPI).
- `POST /chat/sessions/{id}/messages` (chat regular das 16 licoes) **nao muda**.

---

## 6. System prompt do Final Exam

> Texto completo, em PT-BR, pra ser injetado como `system` na chamada da Anthropic API com modelo `claude-sonnet-4-6` quando a sessao for do exame final. **Nao usa cache** (volume baixo). Comprimento alvo: 3-5 paragrafos.

```
Voce e o Atena Mentor, um assistente educacional especializado em ajudar criancas e adolescentes
de 12 anos ou mais a planejar a primeira ideia de aplicativo deles. Voce nao da respostas prontas:
voce faz perguntas que provocam o aluno a pensar. Seu tom e encorajador, curioso e paciente.
Sempre celebre pequenos avancos com frases como "boa! agora me conta..." ou "interessante,
e se a gente pensar em...". Use linguagem simples, frases curtas, e nada de jargao tecnico
sem explicar.

Sua missao e conduzir o aluno por exatamente 5 passos, na ordem, sem pular nenhum:
(1) Que problema o app resolve? Faca o aluno descrever uma situacao real do dia a dia onde algo
incomoda alguem, e ajude a transformar isso numa frase de uma linha.
(2) Pra quem o app serve? Pergunte sobre os usuarios — idade, situacao, o que eles fazem hoje
sem o app. Tente extrair pelo menos 2 caracteristicas concretas do publico-alvo.
(3) Quais as 3 funcionalidades principais? Limite a 3, mesmo se o aluno propuser 10. Pergunte
"qual dessas resolve melhor o problema?" pra forcar priorizacao.
(4) Como seria a tela inicial? Peca pra descrever 3 a 5 elementos visiveis no primeiro segundo
de uso. Sem desenho, so palavras.
(5) Qual o primeiro passo pra construir? Pergunte "se voce tivesse 1 hora amanha, o que voce
faria primeiro?". Ajude a chegar numa resposta especifica e pequena.

Quando todos os 5 passos estiverem respondidos com profundidade suficiente, escreva uma
ficha-resumo do projeto em formato simples (Problema, Usuarios, Funcionalidades, Tela inicial,
Primeiro passo) e parabenize o aluno com entusiasmo genuino. Nao siga adiante alem dessa
ficha-resumo nem proponha implementacao tecnica detalhada.

Restricoes inegociaveis: (a) nunca peca dados pessoais (nome real, escola, endereco, telefone,
foto); use sempre o apelido. (b) Se o aluno trouxer topico fora do escopo de planejar o app
(ex: pedir pra contar piada, falar de violencia, politica, religiao), redirecione gentilmente
com "essa conversa e nossa pra planejar seu app, vamos voltar pra ele?". (c) Nao prometa
sucesso comercial, dinheiro, fama ou qualquer beneficio material. (d) Maximo de 4 a 6 frases
por mensagem sua. (e) Sempre em portugues do Brasil.
```

---

## 7. Frontend — rotas e telas alteradas

### 7.1 `/play` — agora hub de stages

Substitui o `LessonShelf` flat por um `StageGrid` que renderiza **4 cards de stage + 1 card de final exam**. Cada card mostra:

- Numero da stage (1-4) e nome ("Discovery", "Exploration", etc.).
- Tag de faixa etaria recomendada ("6-8 anos").
- Tag de dificuldade ("Easy" / "Medium" / "Hard" / "Advanced" / "Capstone").
- Barra de progresso (`completed / total`, ex: `2/4`).
- Status visual:
  - **Desbloqueada e nao completada:** card colorido com CTA "Continuar".
  - **Desbloqueada e completada:** card com check verde + "Revisar".
  - **Bloqueada:** card grisalho com cadeado + tooltip "Termine a Stage X primeiro".
- Onclick → navega para `/play/stage/[stageId]`.

O card do **Final Exam** vem visualmente diferenciado (paleta dourada/roxa, icone de coroa, label "Projeto Final"), e segue a mesma logica de lock — bloqueado ate as 4 stages estarem 100%.

Componentes novos:
- `StageCard.tsx` — card individual de stage.
- `StageGrid.tsx` — grid de stages.
- `FinalExamCard.tsx` — card especial.

API consumida: `GET /v1/stages`.

### 7.2 `/play/stage/[stageId]` — nova rota

Lista as 4 licoes da stage selecionada. Cada item:
- Numero da licao (`1.1`, `1.2`, etc.).
- Titulo + descricao.
- XP previsto.
- Status (nao iniciada / em andamento / concluida).
- Onclick → `/play/lesson/[id]` (rota existente).

Header da pagina mostra: nome da stage, barra de progresso, botao "voltar pro hub".

Componentes:
- `StageHeader.tsx`.
- `LessonListItem.tsx` (reuso parcial do antigo card).

API: `GET /v1/lessons?stage=N`.

### 7.3 `/play/lesson/[id]` — sem mudanca grande

Player de licao continua funcionando como antes. **Adicao:** ao montar, faz check de `is_locked`. Se `true` (caso a crianca tenha digitado a URL direto), redireciona pra `/play/stage/[stageId]` com toast "Termine a stage anterior primeiro!".

### 7.4 `/play/exam` — nova rota

Pagina dedicada do final exam. Layout:
- Tela introdutoria com `content_blocks` da licao `final-exam-project-capstone`.
- CTA "Comecar exame" → POST /v1/exam/start.
- Apos start, transiciona pra interface de chat dedicada `ExamChat.tsx`:
  - Indicador de progresso "Passo 1 de 5", "Passo 2 de 5"... no topo.
  - Bubbles de chat (reuso de `ChatBubbles`), mas com avatar diferente do Claude (estilo "mentor").
  - Input de texto livre (com contador de caracteres, max 300 por mensagem).
  - Botao "Enviar" desabilitado enquanto vazio ou enquanto Claude esta respondendo.
- Apos `is_complete=true` chega: mostra ficha-resumo do projeto em card destacado + botao "Concluir exame" → POST /v1/exam/sessions/{id}/submit → tela de celebracao com badge `CAPSTONE_BUILDER` e XP.

Componentes novos:
- `ExamIntro.tsx`.
- `ExamChat.tsx`.
- `ExamProgressBar.tsx` (5 bolinhas).
- `ExamProjectCard.tsx` (ficha-resumo final).
- `ExamCelebration.tsx`.

APIs: `POST /v1/exam/start`, `POST /v1/exam/sessions/{id}/messages`, `POST /v1/exam/sessions/{id}/submit`.

### 7.5 `/play/blocked`, `/play/badges`, `/play/switch-profile`

Sem mudancas.

### 7.6 Estado e navegacao

- Adicionar `useStages()` hook que consome `GET /v1/stages` com `react-query` e `staleTime: 30s` (frequente o suficiente pra refletir progresso).
- `useExamSession(sessionId)` hook similar pro chat do exame.

---

## 8. Gamificacao — adicoes

### 8.1 Badge novo

| code | name | descricao | regra de desbloqueio |
|---|---|---|---|
| CAPSTONE_BUILDER | Construtor Capstone | Completou o Projeto Final do curso | submit do exame com sucesso |

Adicionado ao seed de badges (alem dos 12 ja existentes — secao 11.4 do spec original).

### 8.2 Badge de stage

Opcional `[v2]`: 4 badges adicionais `STAGE_1_DONE`, `STAGE_2_DONE`, `STAGE_3_DONE`, `STAGE_4_DONE`. Nao no MVP desta refatoracao.

### 8.3 XP recalibrado

- Stage 1 licoes: 50 XP cada (4 × 50 = 200).
- Stage 2: 70 (4 × 70 = 280).
- Stage 3: 100 (4 × 100 = 400).
- Stage 4: 150 (4 × 150 = 600).
- Final exam: 500.
- **Total disponivel no curso completo:** 200 + 280 + 400 + 600 + 500 = **1980 XP**.

A formula de niveis (secao 11.2 do spec original) nao muda — completar todo o curriculum leva ~nivel 6 (1500 XP), com sobra pra desafios e streaks.

---

## 9. Compatibilidade com schema/seed atual

Resumo do que precisa acontecer:

1. **Schema:** aplicar `ALTER TABLE`s da secao 3.
2. **Seed:** `DELETE FROM lessons` (CASCADE limpa challenges, prompt_templates, lesson_progress relacionados).
3. **Re-seed:** inserir as 17 novas licoes com seus 16 challenges (final exam nao tem) e 17 prompt_templates (final exam tem 1 botao "Comecar").
4. **Badges:** `INSERT INTO badges` o novo `CAPSTONE_BUILDER`.
5. **Backend:** adicionar codigo dos novos endpoints `/stages` e `/exam/*`, ajustar `/lessons` pra aceitar `?stage=N` e retornar `is_locked`.
6. **Frontend:** trocar `/play` por hub de stages, criar `/play/stage/[stageId]` e `/play/exam`.
7. **Testes:** adicionar suite cobrindo lock progression, exam flow e troca de modelo.

`lesson_progress` da crianca **e perdido pelo cascade** — isso e aceitavel porque o curriculum mudou completamente; nao faz sentido carregar progresso de licoes que nao existem mais. O `xp` acumulado em `children.xp` permanece.

---

## 10. Criterios de pronto (DoD desta refatoracao)

### 10.1 backend-agent
- [ ] Migration `002_curriculum_redesign.sql` (ou Alembic equivalente) aplicada com sucesso, idempotente.
- [ ] Tabela `lessons` tem colunas `stage`, `is_final_exam`, `claude_model` populadas.
- [ ] CHECK constraints atualizados (`age_band` 4 valores, `children.age` 6-16).
- [ ] 17 linhas em `lessons` (16 regulares + 1 final exam) com slugs exatos da secao 2.
- [ ] 16 challenges em `challenges` (1 por licao regular).
- [ ] 17 prompt_templates em `prompt_templates` (1 por licao incluindo final exam).
- [ ] 1 badge `CAPSTONE_BUILDER` em `badges`.
- [ ] Endpoint `GET /v1/stages` retorna estrutura da secao 5.1.
- [ ] Endpoint `GET /v1/lessons?stage=N` filtra corretamente e retorna `is_locked`.
- [ ] Endpoint `POST /v1/lessons/{id}/start` retorna 403 `LESSON_LOCKED` quando bloqueada.
- [ ] Endpoint `POST /v1/exam/start` retorna 403 `EXAM_LOCKED` ate as 4 stages completas.
- [ ] `POST /v1/exam/sessions/{id}/messages` chama Anthropic com `model='claude-sonnet-4-6'` e o system prompt da secao 6.
- [ ] `POST /v1/exam/sessions/{id}/submit` credita 500 XP, desbloqueia `CAPSTONE_BUILDER`, retorna `plan` estruturado.
- [ ] Modelo `claude_model` lido da licao em vez de hardcoded no `claude_client.py` (refactor).
- [ ] Testes unit + integration cobrindo lock progression, exam endpoints e modelo correto chamado (mock respx).
- [ ] Cobertura backend >= 85% mantida.

### 10.2 frontend-agent
- [ ] `/play` renderiza `StageGrid` com 4 stage cards + 1 final exam card, todos consumindo `GET /v1/stages`.
- [ ] Stages bloqueadas aparecem grisalhas com cadeado + tooltip.
- [ ] `/play/stage/[stageId]` lista licoes da stage com status individual.
- [ ] `/play/lesson/[id]` faz lock check ao montar e redireciona se bloqueada.
- [ ] `/play/exam` renderiza intro, transiciona pra `ExamChat` apos start, mostra `ExamProgressBar` com 5 passos.
- [ ] Ao concluir exame, `ExamCelebration` mostra XP, badge e ficha-resumo.
- [ ] Nenhuma referencia a `claude-sonnet-4-6` aparece no bundle (fica so no backend).
- [ ] `npm run build` verde.
- [ ] Testes Playwright cobrindo: navegar `/play` → entrar stage 1 → completar 1 licao → ver progresso atualizar.

### 10.3 qa-agent
- [ ] Smoke test das 17 licoes: cada uma tem `slug, title, content_blocks, prompt_template, claude_model` populados; das 16 regulares tambem `challenge`.
- [ ] Lock progression test: criar crianca nova, verificar Stage 1 desbloqueada / Stage 2 bloqueada; completar 4 licoes da Stage 1, verificar Stage 2 desbloquear.
- [ ] Final exam test: criar crianca, completar tudo, fazer `POST /v1/exam/start`, enviar 5 mensagens simulando os 5 passos, fazer `submit`, validar XP e badge.
- [ ] Verificar que a chamada Anthropic do exame usa `claude-sonnet-4-6` (mock spy).
- [ ] Verificar que as outras licoes ainda usam `claude-haiku-4-5-20251001`.
- [ ] Acessibilidade: novo hub `/play` passa axe-core sem violacoes criticas.
- [ ] Gates do spec original (secao 12.3) continuam passando.

---

## 11. Resumo das decisoes

1. **API publica escolhida na Lesson 2.3:** PokeAPI (Ditto), pelo JSON estruturado e familiar pras criancas, contra o ISS-Now que tem coordenadas abstratas demais pra essa idade.
2. **Modelo do Final Exam:** `claude-sonnet-4-6`, justificado pela necessidade de raciocinio multi-passo, perguntas socraticas adaptativas e qualidade de planejamento. Volume baixo (1 sessao por crianca) absorve o custo.
3. **Estrutura de stage:** coluna `stage INTEGER (1-5)` + flag `is_final_exam BOOLEAN` redundantes mas usadas em conjunto pra evitar ambiguidade nas queries; unique index garante 1 unico final exam.
4. **Age bands ampliadas:** de 2 (`6-8`,`9-12`) para 4 (`6-8`,`9-10`,`11-12`,`12+`); CHECK constraint trocado em `lessons` E em `prompt_templates`; `children.age` ampliado para 6-16.
5. **Unlock:** puramente baseado em progresso (100% da stage anterior `completed`), nao em idade. Faixa etaria e visual/recomendacao, nao gate.
6. **Seed antigo apagado:** `DELETE FROM lessons` em CASCADE; `lesson_progress` da crianca se perde mas `children.xp` permanece.
