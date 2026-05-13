-- Migration 005: New curriculum content — 16 lessons across 4 stages
--
-- Substitui o conteudo das lessons regulares (stages 1..4) por um curriculo
-- novo fornecido pelo time de produto. Preserva a licao de exame final
-- (is_final_exam = TRUE) seedada na 004 - ela continua existindo, junto com
-- seu desafio e prompt template, porque o exame e' um eixo separado.
--
-- Limpeza em ordem reversa de FK, escopada a NON-final-exam lessons:
--   challenge_attempts -> challenges -> prompt_templates -> lesson_progress
--   -> chat_messages -> chat_sessions -> lessons (regular)
--
-- Strings usam dollar quoting ($$...$$) para evitar escapar aspas simples
-- dentro das frases (ex.: 'tomada magica da internet').
--
-- XP por stage (lesson.xp_reward):
--   stage 1: 50, stage 2: 75, stage 3: 100, stage 4: 125
-- Cada challenge vale +10 XP adicional.

BEGIN;

-- ============================================================
-- 1) LIMPEZA - so' das lessons regulares (preserva o final exam)
-- ============================================================
DELETE FROM challenge_attempts
 WHERE challenge_id IN (
   SELECT c.id FROM challenges c
   JOIN lessons l ON c.lesson_id = l.id
   WHERE l.is_final_exam = FALSE
 );

DELETE FROM challenges
 WHERE lesson_id IN (SELECT id FROM lessons WHERE is_final_exam = FALSE);

DELETE FROM prompt_templates
 WHERE lesson_id IN (SELECT id FROM lessons WHERE is_final_exam = FALSE);

DELETE FROM lesson_progress
 WHERE lesson_id IN (SELECT id FROM lessons WHERE is_final_exam = FALSE);

DELETE FROM chat_messages
 WHERE session_id IN (
   SELECT id FROM chat_sessions
   WHERE lesson_id IN (SELECT id FROM lessons WHERE is_final_exam = FALSE)
 );

DELETE FROM chat_sessions
 WHERE lesson_id IN (SELECT id FROM lessons WHERE is_final_exam = FALSE);

DELETE FROM lessons WHERE is_final_exam = FALSE;

-- ============================================================
-- 2) LESSONS - 16 licoes (4 por stage)
-- ============================================================

-- Stage 1: Descobrindo a IA (6-8 anos, 50 XP cada)
INSERT INTO lessons
  (slug, title, description, age_band, stage, order_index, content_blocks,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's1-o-que-e-ia',
  'O que é Inteligência Artificial?',
  'Descubra o que é IA e onde ela aparece no seu dia a dia.',
  '6-8', 1, 1,
  $$[
    {"type": "text", "content": "Você já imaginou ter um amigo que leu TODOS os livros do mundo? Pois é, a Inteligência Artificial é parecida com isso! É um computador que aprendeu lendo bilhões de textos, livros e conversas. Por causa disso, ela consegue conversar com você sobre praticamente qualquer assunto."},
    {"type": "text", "content": "A IA já está na sua vida todos os dias sem você perceber. Quando o YouTube te sugere o próximo vídeo, é IA escolhendo. Quando o autocomplete do celular adivinha a próxima palavra, é IA tentando ajudar. Quando seu filtro de spam separa e-mails ruins, também é IA trabalhando!"},
    {"type": "text", "content": "A IA não é mágica nem coisa de filme assustador. É só matemática muito avançada e muita prática. Em geral é apenas software rodando num servidor, recebendo perguntas e devolvendo respostas. Uma lâmpada comum não pensa, então não é IA. Mas uma lâmpada inteligente que aprende seus horários, essa sim!"}
  ]$$::jsonb,
  50, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-quem-e-claude',
  'Quem é a Claude?',
  'Conheça a Claude, sua amiga IA criada pela Anthropic.',
  '6-8', 1, 2,
  $$[
    {"type": "text", "content": "A Claude é uma Inteligência Artificial criada por uma empresa chamada Anthropic. Ela foi treinada para ser útil, segura e honesta — três valores que guiam tudo o que ela faz. A Claude pode ler, escrever, criar histórias, ajudar com tarefas e até explicar coisas difíceis de forma simples!"},
    {"type": "text", "content": "A Claude tem três superpoderes principais: ler textos muito longos sem se cansar, escrever em vários estilos diferentes, e raciocinar passo a passo sobre problemas complicados. Ela também é boa em explicar conceitos de forma adequada para a sua idade — basta pedir!"},
    {"type": "text", "content": "Uma coisa muito importante sobre a Claude: ela não inventa respostas quando não sabe. Em vez disso, fala com honestidade que não tem certeza. Isso é uma diferença enorme em relação a outras IAs que às vezes inventam coisas. Confiar na honestidade da Claude faz dela uma parceira melhor de aprendizado."}
  ]$$::jsonb,
  50, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-como-conversar-claude',
  'Como Conversar com a Claude',
  'Aprenda a escrever prompts que geram ótimas respostas.',
  '6-8', 1, 3,
  $$[
    {"type": "text", "content": "Conversar com a Claude é simples como mandar uma mensagem para um amigo! Você digita uma pergunta ou pedido — isso se chama PROMPT — e a Claude responde. Quanto mais natural for o seu jeito de escrever, melhor a conversa vai fluir."},
    {"type": "text", "content": "Quanto mais detalhes você colocar no seu prompt, melhor será a resposta. Não basta perguntar 'me conta sobre cachorro'. Diga 'me conta 5 fatos curiosos sobre Golden Retrievers para convencer meus pais a comprar um'. Contexto + objetivo + formato = resposta excelente."},
    {"type": "text", "content": "As regras de ouro para um bom prompt são: seja CLARO sobre o que quer, dê CONTEXTO (quem você é, para que vai usar), e diga o FORMATO (lista, parágrafo, tabela, história). Com essas três coisas, você vira um mestre dos prompts em pouco tempo!"}
  ]$$::jsonb,
  50, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-claude-conta-historias',
  'Claude Conta Histórias!',
  'Use a Claude para criar histórias personalizadas com detalhes seus.',
  '6-8', 1, 4,
  $$[
    {"type": "text", "content": "Uma das coisas mais mágicas da Claude é criar histórias! Ela já leu milhões de livros e contos, então sabe muito sobre como uma boa história funciona: personagens marcantes, conflito interessante, e um final que faz sentido. Você pode pedir histórias sobre qualquer tema que imaginar."},
    {"type": "text", "content": "Para conseguir a melhor história possível, você precisa caprichar no pedido. Dê detalhes: quem é o personagem principal, onde a história acontece, qual o tipo (aventura, mistério, comédia, terror), e como você quer que termine. Quanto mais ingredientes, mais saborosa a história!"},
    {"type": "text", "content": "Você também pode pedir para a Claude CONTINUAR uma história que você começou, ou MUDAR o final de uma que ela criou. Pode pedir versão em poema, versão em quadrinhos, ou versão para ler na hora de dormir. As possibilidades são infinitas — só não dá para imprimir a história em papel automaticamente, isso ela não faz!"}
  ]$$::jsonb,
  50, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- Stage 2: APIs (9-10 anos, 75 XP cada)
INSERT INTO lessons
  (slug, title, description, age_band, stage, order_index, content_blocks,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's2-o-que-e-api',
  'O que é uma API?',
  'Aprenda como programas trocam dados pela internet, usando uma analogia de restaurante.',
  '9-10', 2, 1,
  $$[
    {"type": "text", "content": "API significa Application Programming Interface. Parece complicado, mas você pode chamar de 'tomada mágica da internet'! É um jeito de dois programas se falarem e trocarem informações sem que você precise ver o que acontece por dentro."},
    {"type": "text", "content": "Pensa assim: você está num restaurante e quer pizza. Você não vai direto para a cozinha — você chama o garçom. O garçom leva seu pedido para a cozinha, a cozinha prepara, e o garçom traz a pizza de volta para você. Nessa história, VOCÊ é o aplicativo, o GARÇOM é a API, e a COZINHA é o servidor com todos os dados."},
    {"type": "text", "content": "Existe uma API divertidíssima chamada PokéAPI que tem dados de todos os Pokémons do mundo — completamente grátis! Quando você acessa a URL pokeapi.co/api/v2/pokemon/pikachu no navegador, a API te devolve todos os dados do Pikachu. O mundo tem mais de 24.000 APIs públicas e gratuitas esperando para ser exploradas!"}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-json-lingua-apis',
  'JSON — A Língua das APIs',
  'Entenda o formato JSON que toda API usa para enviar dados.',
  '9-10', 2, 2,
  $$[
    {"type": "text", "content": "Quando uma API responde, ela envia os dados num formato chamado JSON. Parece estranho na primeira vez, mas é muito lógico! JSON é organizado como uma gaveta com etiquetas: cada chave é a etiqueta da gaveta, e cada valor é o que está guardado dentro."},
    {"type": "text", "content": "Por exemplo, os dados do Pikachu em JSON ficam assim: name é 'pikachu', height é 4, weight é 60. Precisa saber o peso? Abre a gaveta 'weight'. Precisa saber o tipo? Abre a gaveta 'types'. Cada informação tem seu lugarzinho organizado!"},
    {"type": "text", "content": "Em JSON existem 4 tipos de coisas. Texto sempre fica entre aspas, como 'pikachu'. Números ficam sem aspas, como 4 ou 60. Listas ficam entre colchetes [], ótimas para vários itens. E objetos ficam entre chaves {}, que podem ter outras gavetas dentro. Com esse mapa, você consegue ler qualquer JSON do mundo!"}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-apis-gratuitas',
  'APIs Gratuitas para Explorar!',
  'Conheça várias APIs públicas que você pode acessar agora mesmo.',
  '9-10', 2, 3,
  $$[
    {"type": "text", "content": "O mundo está cheio de APIs gratuitas incríveis, sem precisar de cadastro nem cartão de crédito. São como bibliotecas públicas da internet: abertas para qualquer pessoa usar o tempo todo! Você já conheceu a PokéAPI, mas existem muitas outras esperando por você."},
    {"type": "text", "content": "Algumas das melhores para explorar: a PokéAPI tem dados de todos os Pokémons. O catfact.ninja/fact devolve um fato aleatório sobre gatos. O REST Countries tem dados de todos os países do mundo — bandeira, capital, população, idioma. E o JokeAPI tem piadas seguras em vários idiomas!"},
    {"type": "text", "content": "O mais legal é que você pode acessar essas URLs diretamente no navegador para ver os dados JSON em tempo real. Tente agora: abra uma aba e acesse pokeapi.co/api/v2/pokemon/charmander. Você vai ver todos os dados do Charmander! Depois, cole esse JSON para a Claude e peça para ela explicar tudo."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-claude-apis-superpoder',
  'Claude + APIs = Superpoder!',
  'Combine APIs com a Claude para transformar dados crus em algo incrível.',
  '9-10', 2, 4,
  $$[
    {"type": "text", "content": "Combinar a Claude com APIs é um superpoder real que poucas pessoas sabem usar! A ideia é simples: você busca dados crus da API e pede para a Claude transformar esses dados em algo incrível e fácil de entender."},
    {"type": "text", "content": "Pensa assim: a API é uma biblioteca gigante em idioma desconhecido. A Claude é sua tradutora e analista particular! Você pode pegar dados de clima e pedir análise em linguagem simples, pegar dados de Pokémons e criar uma Pokédex personalizada, ou usar dados de países para um quiz de geografia!"},
    {"type": "text", "content": "Saber combinar APIs com IA é um dos skills mais valiosos do mercado em 2025. Empresas do mundo inteiro precisam de pessoas que saibam buscar dados de APIs e usá-los de forma inteligente. E você está aprendendo isso agora, com 9 ou 10 anos!"}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- Stage 3: Código e Sites (11-12 anos, 100 XP cada)
INSERT INTO lessons
  (slug, title, description, age_band, stage, order_index, content_blocks,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's3-o-que-e-codigo',
  'O que é Código?',
  'Descubra como linguagens de programação fazem o computador entender você.',
  '11-12', 3, 1,
  $$[
    {"type": "text", "content": "Código é uma linguagem que os computadores entendem. Assim como você usa português para se comunicar com pessoas, programadores usam linguagens de código para dar instruções precisas aos computadores. E ao contrário do português, os computadores seguem as instruções à risca, sem pular etapas!"},
    {"type": "text", "content": "Na web, existe uma tríade sagrada de linguagens. HTML é a estrutura — pensa como o esqueleto do corpo humano. CSS é o visual — como as roupas e o estilo. JavaScript são as ações — como os músculos que movem tudo. Além dessas, Python é muito usada em Inteligência Artificial e análise de dados."},
    {"type": "text", "content": "Mas aqui está a melhor notícia: você NÃO precisa saber toda a linguagem para criar coisas incríveis. Com a Claude, você só precisa saber DESCREVER o que quer. Ela escreve o código, você aprende vendo o resultado. É a forma mais divertida de aprender programação que existe!"}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-claude-escreve-codigo',
  'Claude Escreve Código por Você!',
  'A Claude pode gerar código completo a partir da sua descrição.',
  '11-12', 3, 2,
  $$[
    {"type": "text", "content": "A Claude é uma programadora incrível que escreve em dezenas de linguagens. E ela faz algo que nenhum livro faz: explica cada linha do código que cria, em português. É como ter um professor particular de programação disponível 24 horas!"},
    {"type": "text", "content": "O segredo para conseguir código de qualidade é detalhar bem o pedido. Em vez de 'cria um site', diga o tema, as seções, as cores, se precisa de botões, e se precisa funcionar no celular. Quanto mais específico, mais próximo do resultado que você imagina!"},
    {"type": "text", "content": "Depois de receber o código, você pode testar imediatamente no site CodePen.io — completamente grátis, sem instalar nada. É só copiar o HTML que a Claude criou, colar no CodePen e clicar em Run. E se não gostar de alguma parte, é só pedir ajustes: 'muda o botão para verde', 'aumenta a fonte'."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-receita-site-perfeito',
  'A Receita do Site Perfeito',
  'Aprenda os 6 ingredientes para pedir um site com cara profissional.',
  '11-12', 3, 3,
  $$[
    {"type": "text", "content": "Com a Claude, qualquer pessoa pode criar um site com aparência profissional. Você não precisa saber programar — só precisa saber DESCREVER com detalhes. É o mesmo conceito de prompt que você aprendeu antes, agora aplicado à criação de sites!"},
    {"type": "text", "content": "Existe uma receita de 6 ingredientes para pedir um site perfeito. TEMA: sobre o que é? PÚBLICO: para quem é? SEÇÕES: quais partes quer? CORES: qual estilo visual? EXTRAS: quer animações, efeitos? DISPOSITIVOS: precisa funcionar no celular?"},
    {"type": "text", "content": "Um exemplo fraco: 'Cria um site sobre K-pop'. Um exemplo poderoso: 'Crie um site HTML/CSS/JS sobre a banda BTS com hero animado em neon, galeria com 7 cards dos membros, tema escuro com rosa e roxo, fonte moderna e 100% responsivo para celular'. Veja a diferença!"}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-site-api-app-real',
  'Site + API = App de Verdade!',
  'Combine HTML/CSS/JS com APIs para criar apps funcionais.',
  '11-12', 3, 4,
  $$[
    {"type": "text", "content": "Quando seu site usa uma API para buscar dados em tempo real, ele deixa de ser uma página estática e vira um app de verdade! É exatamente o que grandes empresas fazem: o site da Netflix busca filmes via API, o Google Maps busca rotas via API, o iFood busca restaurantes via API."},
    {"type": "text", "content": "A mágica acontece com JavaScript. Com ele, você pode usar uma função chamada 'fetch' que literalmente busca dados de qualquer API quando alguém usa seu site. A URL da API fica no código, o fetch vai lá, busca os dados em JSON e mostra na tela — tudo automático, tudo em tempo real."},
    {"type": "text", "content": "Um exemplo poderoso: peça para a Claude criar uma Pokédex onde o usuário digita o nome de um Pokémon e o site mostra imagem, nome, tipo, altura e peso usando a PokéAPI. A Claude escreve todo o código com JavaScript + HTML + CSS. Você só descreveu o que queria — e ganhou um app funcional!"}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- Stage 4: Prompt Engineering Avançado (12+ anos, 125 XP cada)
INSERT INTO lessons
  (slug, title, description, age_band, stage, order_index, content_blocks,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's4-prompt-engineering',
  'O que é Prompt Engineering?',
  'Conheça a arte de comunicar com IA de forma estratégica.',
  '12+', 4, 1,
  $$[
    {"type": "text", "content": "Prompt Engineering é a arte de se comunicar com IA de forma estratégica para obter os melhores resultados possíveis. É como saber os códigos secretos que desbloqueiam todo o potencial de uma IA. Não é sobre programar, é sobre comunicar — mas de forma muito precisa e intencional."},
    {"type": "text", "content": "Existem 5 pilares que todo Prompt Engineer precisa dominar. PERSONA: diga para a IA como ela deve se comportar. CONTEXTO: explique toda a situação. OBJETIVO: seja hiper-específico. FORMATO: diga como quer a resposta. EXEMPLOS: mostre o que é bom para você, pois a IA aprende muito rápido com exemplos concretos."},
    {"type": "text", "content": "Prompt Engineering é uma das profissões mais bem-pagas de 2024 e 2025! Nos EUA, salários chegam a 175 mil dólares por ano. No Brasil, a área está crescendo muito rápido. E você está aprendendo isso agora, antes da maioria dos adultos!"}
  ]$$::jsonb,
  125, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-prompts-poderosos-vs-fracos',
  'Prompts Poderosos vs. Fracos',
  'Veja na prática a diferença entre prompts comuns e prompts profissionais.',
  '12+', 4, 2,
  $$[
    {"type": "text", "content": "A diferença entre um prompt fraco e um poderoso não está no tamanho — está nos detalhes certos. Um bom prompt transforma uma resposta mediana em algo extraordinário. E a única forma de internalizar isso é vendo exemplos lado a lado!"},
    {"type": "text", "content": "Compare: fraco seria 'cria um app'. Poderoso seria 'crie um app web HTML/CSS/JS de lista de tarefas para estudantes do ensino médio, com adicionar tarefas com matéria e data de entrega, marcar como feito com animação, filtrar por matéria, visual dark mode moderno, sem frameworks externos'. A diferença é enorme!"},
    {"type": "text", "content": "Existe um teste mental poderoso: pergunte a si mesmo — 'se eu fosse um funcionário recebendo esse pedido, teria informação suficiente para entregar exatamente o que foi pedido, sem precisar adivinhar nada?' Se a resposta for não, complete o prompt. Esse teste melhora toda a sua comunicação!"}
  ]$$::jsonb,
  125, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-system-prompts',
  'System Prompts — Criando Agentes IA',
  'Aprenda a construir agentes de IA com personalidade própria.',
  '12+', 4, 3,
  $$[
    {"type": "text", "content": "System Prompt é uma instrução secreta que você dá para a IA antes da conversa começar. É como criar um personagem com personalidade, regras e objetivos próprios. O usuário final nem vê esse texto, mas ele molda completamente como a IA vai se comportar em toda a conversa!"},
    {"type": "text", "content": "Um System Prompt profissional tem várias partes. A IDENTIDADE define quem é a IA. A PERSONALIDADE define o tom: entusiasmado, formal, técnico, divertido. As REGRAS definem o que ela sempre faz e o que nunca faz. O FORMATO define como ela estrutura as respostas: com emojis? Bullets? Código formatado?"},
    {"type": "text", "content": "Com System Prompts você pode criar: um professor virtual de qualquer matéria, um personagem de game com história própria, um assistente especializado em culinária, ou um bot de atendimento para um negócio real. Empresas como Netflix e Duolingo usam System Prompts para criar assistentes com personalidade única!"}
  ]$$::jsonb,
  125, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-claude-code-mcp',
  'Claude Code e MCP — O Futuro da IA',
  'Descubra como a Claude pode agir no seu computador via Claude Code e MCP.',
  '12+', 4, 4,
  $$[
    {"type": "text", "content": "Claude Code é uma versão especial da Claude que roda diretamente no seu computador, pelo terminal. Ela não só conversa — ela age! Pode ler e criar arquivos, instalar dependências, executar código, encontrar e corrigir bugs automaticamente, e construir projetos inteiros do zero."},
    {"type": "text", "content": "MCP significa Model Context Protocol, criado pela Anthropic em 2024. É um padrão aberto que permite dar ferramentas extras para a Claude: pesquisar na internet, acessar calendário, conectar com GitHub, enviar emails. Com MCP, a Claude pode navegar na web, fazer commits no GitHub, consultar documentos do Google Drive e muito mais!"},
    {"type": "text", "content": "Em 2025, saber usar Claude Code e MCP é um diferencial enorme. Developers que usam essas ferramentas produzem 3 a 5 vezes mais. E você está aprendendo sobre isso agora, com 13 ou 14 anos, no exato momento em que essas tecnologias estão mudando a indústria. Você está no lugar certo, na hora certa!"}
  ]$$::jsonb,
  125, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- ============================================================
-- 3) CHALLENGES - 2 por licao = 32 multiple-choice
-- ============================================================

-- Helper: cada bloco usa subquery (SELECT id FROM lessons WHERE slug=...)
-- para resolver o lesson_id, evitando hardcode de UUIDs.

-- Stage 1
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward) VALUES
((SELECT id FROM lessons WHERE slug = 's1-o-que-e-ia'), 'multiple_choice',
 $${"question": "O que é Inteligência Artificial?", "options": ["Um robô com braços e pernas", "Um computador que aprendeu com bilhões de textos e conversas", "Um vírus de computador muito inteligente", "Um aplicativo que só traduz idiomas"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's1-o-que-e-ia'), 'multiple_choice',
 $${"question": "Qual desses exemplos NÃO é um uso de IA no cotidiano?", "options": ["Autocomplete do celular", "Recomendações do YouTube", "Uma lâmpada elétrica comum", "Filtro de spam no e-mail"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's1-quem-e-claude'), 'multiple_choice',
 $${"question": "Qual empresa criou a Claude?", "options": ["Google", "Microsoft", "Anthropic", "Apple"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's1-quem-e-claude'), 'multiple_choice',
 $${"question": "O que a Claude faz quando não sabe a resposta?", "options": ["Inventa uma resposta", "Fica em silêncio", "Fala com honestidade que não sabe", "Copia de outros sites"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's1-como-conversar-claude'), 'multiple_choice',
 $${"question": "O que é um Prompt?", "options": ["Um tipo de robô", "Tudo que você escreve para a Claude", "O nome do botão de enviar", "Uma linguagem de programação"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's1-como-conversar-claude'), 'multiple_choice',
 $${"question": "Qual desses prompts vai gerar uma resposta melhor?", "options": ["Me conta sobre cachorro", "Cachorro", "Me conta 5 fatos curiosos sobre Golden Retrievers para convencer meus pais a comprar um", "Fala de animal"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's1-claude-conta-historias'), 'multiple_choice',
 $${"question": "Como conseguir a melhor história da Claude?", "options": ["Dizer só faz uma história", "Dar personagens, cenário, tipo de história e final desejado", "Escrever tudo em maiúsculas", "Pedir em inglês"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's1-claude-conta-historias'), 'multiple_choice',
 $${"question": "Qual dessas coisas a Claude NÃO consegue fazer com histórias?", "options": ["Continuar uma história", "Mudar o final", "Imprimir automaticamente em papel", "Escrever no estilo de poema"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10);

-- Stage 2
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward) VALUES
((SELECT id FROM lessons WHERE slug = 's2-o-que-e-api'), 'multiple_choice',
 $${"question": "O que é uma API?", "options": ["Um tipo de vírus de computador", "Um jeito de dois programas se comunicarem e trocarem dados", "Uma linguagem de programação avançada", "Um aplicativo de câmera"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's2-o-que-e-api'), 'multiple_choice',
 $${"question": "Na analogia do restaurante, o que representa a API?", "options": ["O cliente com fome", "A pizza pronta", "O garçom que leva pedidos e traz respostas", "O cardápio do restaurante"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's2-json-lingua-apis'), 'multiple_choice',
 $${"question": "O que é JSON?", "options": ["Uma linguagem de programação para criar jogos", "Um formato organizado de dados que APIs usam para responder", "Um aplicativo para editar fotos", "Um tipo de banco de dados visual"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's2-json-lingua-apis'), 'multiple_choice',
 $${"question": "No JSON, como textos são representados?", "options": ["Com números", "Com colchetes []", "Entre aspas, como 'pikachu'", "Em maiúsculas"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's2-apis-gratuitas'), 'multiple_choice',
 $${"question": "O que acontece quando você acessa catfact.ninja/fact?", "options": ["Abre um jogo de gatos", "A API retorna um fato aleatório sobre gatos em JSON", "Você precisa pagar para ver", "Mostra fotos de gatos"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's2-apis-gratuitas'), 'multiple_choice',
 $${"question": "Como você pode ver dados de uma API sem programar nada?", "options": ["Instalando um programa especial", "Pedindo para a Claude acessar", "Abrindo a URL da API direto no navegador", "Enviando um e-mail para a empresa"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's2-claude-apis-superpoder'), 'multiple_choice',
 $${"question": "Para que serve combinar uma API com a Claude?", "options": ["Para a Claude acessar a internet sozinha", "Para pegar dados brutos da API e transformar em algo útil", "Para criar vírus de computador", "Para baixar músicas"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's2-claude-apis-superpoder'), 'multiple_choice',
 $${"question": "Qual seria um bom uso de Claude + API de clima?", "options": ["Pedir para a Claude criar o clima", "Pegar os dados JSON do clima e pedir para a Claude explicar em linguagem simples", "Usar a API para jogar videogame", "Enviar mensagens automáticas"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10);

-- Stage 3
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward) VALUES
((SELECT id FROM lessons WHERE slug = 's3-o-que-e-codigo'), 'multiple_choice',
 $${"question": "Qual linguagem web é responsável pelo VISUAL de uma página?", "options": ["HTML", "Python", "CSS", "JSON"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's3-o-que-e-codigo'), 'multiple_choice',
 $${"question": "Qual afirmação sobre código e a Claude é VERDADEIRA?", "options": ["Você precisa decorar toda a sintaxe", "Só adultos conseguem pedir código", "Você pode descrever o que quer e a Claude escreve o código", "A Claude só faz código em inglês"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's3-claude-escreve-codigo'), 'multiple_choice',
 $${"question": "Qual site pode ser usado para testar código HTML sem instalar nada?", "options": ["Google Drive", "CodePen.io", "Wikipedia", "YouTube"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's3-claude-escreve-codigo'), 'multiple_choice',
 $${"question": "O que acontece quando você pede um ajuste no código para a Claude?", "options": ["Ela recomeça do zero", "Ela ignora o pedido", "Ela ajusta apenas a parte pedida, mantendo o resto", "Ela cobra por cada alteração"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's3-receita-site-perfeito'), 'multiple_choice',
 $${"question": "Qual é um dos 6 ingredientes da receita do site perfeito?", "options": ["O nome da sua escola", "O PÚBLICO — para quem é o site", "A velocidade da sua internet", "O modelo do seu computador"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's3-receita-site-perfeito'), 'multiple_choice',
 $${"question": "Por que descrever cores e estilo visual no prompt melhora o resultado?", "options": ["Não muda nada", "A Claude só faz sites coloridos com instruções", "Dá contexto preciso para a Claude gerar exatamente o que você imagina", "É obrigatório por regras da Anthropic"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's3-site-api-app-real'), 'multiple_choice',
 $${"question": "O que torna um site um app de verdade?", "options": ["Ter muitas páginas", "Buscar dados em tempo real de uma API", "Ter um ícone bonito", "Funcionar apenas no computador"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's3-site-api-app-real'), 'multiple_choice',
 $${"question": "Qual função do JavaScript busca dados de uma API?", "options": ["print()", "show()", "fetch()", "get()"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10);

-- Stage 4
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward) VALUES
((SELECT id FROM lessons WHERE slug = 's4-prompt-engineering'), 'multiple_choice',
 $${"question": "Qual dos 5 pilares define como a IA deve se comportar?", "options": ["Formato", "Objetivo", "Persona", "Contexto"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's4-prompt-engineering'), 'multiple_choice',
 $${"question": "Por que dar EXEMPLOS em um prompt melhora a resposta?", "options": ["A IA precisa de exemplos para funcionar", "A IA aprende com os exemplos o que é bom para você especificamente", "Exemplos deixam o prompt mais curto", "A Anthropic exige exemplos"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's4-prompts-poderosos-vs-fracos'), 'multiple_choice',
 $${"question": "Qual é o principal problema do prompt 'escreve uma história'?", "options": ["É muito longo", "Usa palavras erradas", "Não dá contexto, tipo, personagens nem formato — a IA precisa adivinhar tudo", "A Claude não sabe escrever histórias"]}$$::jsonb,
 $${"answer": 2}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's4-prompts-poderosos-vs-fracos'), 'multiple_choice',
 $${"question": "O que o teste mental do Prompt Engineering verifica?", "options": ["Se o prompt tem pelo menos 100 palavras", "Se uma pessoa com o pedido teria informação suficiente para entregar sem adivinhar", "Se você usou os 5 pilares na ordem", "Se o prompt está em inglês"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's4-system-prompts'), 'multiple_choice',
 $${"question": "O que um System Prompt faz?", "options": ["Aparece para o usuário como primeira mensagem", "Instrui a IA antes da conversa começar, moldando personalidade e comportamento", "Aumenta a velocidade da IA", "Bloqueia perguntas"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's4-system-prompts'), 'multiple_choice',
 $${"question": "Qual é uma boa aplicação de System Prompt?", "options": ["Fazer a IA fingir que é humana para enganar", "Criar um assistente especializado com personalidade, regras e formato definidos", "Desativar as regras de segurança", "Fazer a IA responder mais rápido"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),

((SELECT id FROM lessons WHERE slug = 's4-claude-code-mcp'), 'multiple_choice',
 $${"question": "O que o Claude Code consegue fazer que a versão web não faz?", "options": ["Conversar em mais idiomas", "Ler e criar arquivos no computador, executar código e construir projetos completos", "Responder mais rápido", "Usar imagens melhores"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10),
((SELECT id FROM lessons WHERE slug = 's4-claude-code-mcp'), 'multiple_choice',
 $${"question": "O que é MCP — Model Context Protocol?", "options": ["Uma linguagem de programação nova", "Um padrão que permite dar ferramentas extras para a IA, como acesso à internet e outros apps", "Um tipo de vírus", "Um curso avançado de programação"]}$$::jsonb,
 $${"answer": 1}$$::jsonb, 10);

-- ============================================================
-- 4) PROMPT TEMPLATES - 1 por licao = 16 templates
-- ============================================================
-- Todos sao "fechados" (sem slots) - mantem simples; a crianca pode
-- elaborar nas mensagens seguintes do chat. age_band casa com a licao.

INSERT INTO prompt_templates (lesson_id, label, template, slots, age_band, order_index) VALUES
((SELECT id FROM lessons WHERE slug = 's1-o-que-e-ia'),
 'Onde uso IA sem perceber?',
 'Oi Claude! Acabei de aprender sobre IA. Você pode me mostrar 3 exemplos de IA que eu uso no meu dia a dia sem perceber?',
 NULL, '6-8', 1),
((SELECT id FROM lessons WHERE slug = 's1-quem-e-claude'),
 'Quem é você, Claude?',
 'Oi Claude! Me conta tudo sobre você: quem te criou, o que você sabe fazer, e o que você NÃO consegue fazer.',
 NULL, '6-8', 1),
((SELECT id FROM lessons WHERE slug = 's1-como-conversar-claude'),
 'Como melhorar meus prompts?',
 'Vamos praticar prompts juntos! Aqui está uma pergunta simples: "me conta sobre o espaço". Você pode me ajudar a transformar esse prompt em algo mais detalhado e poderoso?',
 NULL, '6-8', 1),
((SELECT id FROM lessons WHERE slug = 's1-claude-conta-historias'),
 'Conte uma história pra mim',
 'Crie uma história curta com estes ingredientes: um personagem corajoso, um lugar mágico, um problema para resolver, e um final feliz. Você escolhe os detalhes — me surpreenda!',
 NULL, '6-8', 1),

((SELECT id FROM lessons WHERE slug = 's2-o-que-e-api'),
 'Como funciona uma API?',
 'Me explica como uma API funciona usando a PokéAPI como exemplo. O que acontece passo a passo quando alguém acessa pokeapi.co/api/v2/pokemon/pikachu?',
 NULL, '9-10', 1),
((SELECT id FROM lessons WHERE slug = 's2-json-lingua-apis'),
 'Decifrando um JSON',
 'Me mostra como ficam os dados de um Pokémon (pode ser o Pikachu) em formato JSON e explica o que cada campo significa, um por um, em linguagem que eu entenda.',
 NULL, '9-10', 1),
((SELECT id FROM lessons WHERE slug = 's2-apis-gratuitas'),
 'Me ajuda com este JSON',
 'Eu acessei uma URL de API gratuita e copiei o JSON da resposta. Você pode me explicar cada campo de forma divertida e me dar 3 ideias do que eu poderia fazer com esses dados?',
 NULL, '9-10', 1),
((SELECT id FROM lessons WHERE slug = 's2-claude-apis-superpoder'),
 'Batalha de Pokémons com dados reais',
 'Imagine que eu peguei na PokéAPI os stats reais do Pikachu e do Charizard. Crie uma batalha narrada entre eles, usando ataque, defesa e velocidade para decidir o que acontece. Quem ganharia?',
 NULL, '9-10', 1),

((SELECT id FROM lessons WHERE slug = 's3-o-que-e-codigo'),
 'Decifrando HTML',
 'Aqui está um HTML simples: <html><body><h1>Olá!</h1><p>Sou eu.</p></body></html>. Você pode me explicar o que cada tag faz, como se fosse a primeira vez que eu vejo código?',
 NULL, '11-12', 1),
((SELECT id FROM lessons WHERE slug = 's3-claude-escreve-codigo'),
 'Cria um site pra mim',
 'Crie um site HTML/CSS completo sobre algo que eu amo (você escolhe o tema, pode ser videogame). Use cabeçalho, 3 seções e cores vibrantes. Depois eu vou pedir 2 ajustes pra praticar.',
 NULL, '11-12', 1),
((SELECT id FROM lessons WHERE slug = 's3-receita-site-perfeito'),
 'Receita do site perfeito',
 'Vou usar a receita dos 6 ingredientes. TEMA: meu animal favorito. PÚBLICO: amigos da minha idade. SEÇÕES: hero, galeria, curiosidades. CORES: tema escuro com toques de verde. EXTRAS: animação suave no hover. DISPOSITIVOS: responsivo. Cria!',
 NULL, '11-12', 1),
((SELECT id FROM lessons WHERE slug = 's3-site-api-app-real'),
 'Crie uma Pokédex de verdade',
 'Crie uma Pokédex completa: HTML + CSS + JavaScript onde a pessoa digita o nome de um Pokémon e o site mostra imagem, tipos, altura e peso usando a PokéAPI (fetch). Comente cada parte importante do código.',
 NULL, '11-12', 1),

((SELECT id FROM lessons WHERE slug = 's4-prompt-engineering'),
 'Aplica os 5 pilares neste prompt',
 'Aqui está um prompt fraco: "me ajuda com meu trabalho de escola". Aplique os 5 pilares (Persona, Contexto, Objetivo, Formato, Exemplos) e me mostre a versão poderosa, explicando o que mudou em cada pilar.',
 NULL, '12+', 1),
((SELECT id FROM lessons WHERE slug = 's4-prompts-poderosos-vs-fracos'),
 'Compara 3 versões: fraco, médio, poderoso',
 'Eu quero criar um app de lista de tarefas. Me mostre 3 versões de prompt para isso (fraco, médio, poderoso) e depois explique exatamente o que diferencia cada um e por que o poderoso é tão melhor.',
 NULL, '12+', 1),
((SELECT id FROM lessons WHERE slug = 's4-system-prompts'),
 'Cria um System Prompt pra um agente',
 'Me ajude a criar um System Prompt completo para um personagem original: um detetive de mistérios infantis que adora bolo de chocolate e fala em rimas leves. Inclua identidade, personalidade, regras e formato de resposta.',
 NULL, '12+', 1),
((SELECT id FROM lessons WHERE slug = 's4-claude-code-mcp'),
 'Planeja meu projeto com Claude Code',
 'Eu quero criar um app simples (você sugere o projeto). Me explica passo a passo como eu usaria o Claude Code para construir: que comandos eu daria, que arquivos seriam criados e como o MCP poderia me dar superpoderes nesse projeto.',
 NULL, '12+', 1);

COMMIT;
