-- Migration 004: New Curriculum Seed Data
-- Replaces old 12-lesson curriculum with new 17-lesson 4-stage progression
-- Idempotent: safe to re-run via UPSERT

BEGIN;

-- Limpa em ordem reversa de FK. Tabelas-filho ANTES das pais para nao
-- estourar foreign key violation. challenge_attempts referencia challenges
-- (FK sem CASCADE) e precisa vir antes do DELETE FROM challenges; o resto
-- segue o mesmo principio. chat_messages/chat_sessions ficam escopados
-- por lesson_id para nao apagar sessoes de outras licoes caso existam.
DELETE FROM challenge_attempts;
DELETE FROM challenges;
DELETE FROM prompt_templates;
DELETE FROM lesson_progress;
DELETE FROM chat_messages WHERE session_id IN (SELECT id FROM chat_sessions WHERE lesson_id IN (SELECT id FROM lessons));
DELETE FROM chat_sessions WHERE lesson_id IN (SELECT id FROM lessons);
DELETE FROM lessons;

-- Insert Stage 1: Discovery (Easy) - 6-8 age band, 50 XP each
INSERT INTO lessons (id, slug, title, description, age_band, stage, content_blocks, xp_reward, order_index, is_active, claude_model)
VALUES
(
  gen_random_uuid(),
  'discovery-o-que-e-ia',
  'O que e Inteligencia Artificial?',
  'Vamos descobrir o que e IA com exemplos do dia a dia.',
  '6-8',
  1,
  '[
    {"type":"text","content":"Voce sabia que existem programas de computador que conseguem conversar com a gente, contar historias e responder perguntas? Eles se chamam Inteligencia Artificial, ou IA pra simplificar."},
    {"type":"image","src":"placeholder-robot-friend.png","alt":"Robo amigavel acenando"},
    {"type":"text","content":"A IA aprende lendo muitos livros, sites e historias. Por isso ela sabe muita coisa! Mas ela nao e magica, e nao e uma pessoa. E como uma calculadora superinteligente."},
    {"type":"animation","content":"placeholder-anim-brain-lighting-up"},
    {"type":"text","content":"Quando voce conversa com uma IA, voce esta usando uma ferramenta. E essa ferramenta pode te ajudar a aprender, criar e brincar."}
  ]'::jsonb,
  50,
  1,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'discovery-falando-com-claude',
  'Como falar com o Claude',
  'Aprenda a fazer perguntas tocando em botoes.',
  '6-8',
  1,
  '[
    {"type":"text","content":"O Claude e uma IA que adora conversar! Pra falar com ele, voce escreve uma pergunta ou um pedido. A gente chama isso de prompt."},
    {"type":"image","src":"placeholder-prompt-buttons.png","alt":"Botoes coloridos com perguntas prontas"},
    {"type":"text","content":"Aqui no app, pra facilitar, a gente ja preparou uns botoes coloridos pra voce. E so tocar e o Claude responde!"},
    {"type":"text","content":"Cada botao tem um pedido diferente. Experimenta tocar e ve o que acontece. O Claude vai responder de um jeito gentil e divertido."}
  ]'::jsonb,
  50,
  2,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'discovery-regras-de-seguranca',
  'Regras de seguranca com IA',
  'Coisas importantes pra lembrar quando voce conversa com uma IA.',
  '6-8',
  1,
  '[
    {"type":"text","content":"Conversar com IA e divertido, mas tem 3 regrinhas importantes que toda crianca precisa saber."},
    {"type":"image","src":"placeholder-shield.png","alt":"Escudo de seguranca"},
    {"type":"text","content":"Regra 1: Nunca conte coisas pessoais. Nada de nome inteiro, endereco, telefone ou nome da escola. Use sempre seu apelido."},
    {"type":"text","content":"Regra 2: Se o Claude disser algo que te deixar confuso ou triste, conta pro seu pai ou sua mae. Sempre."},
    {"type":"text","content":"Regra 3: A IA pode errar! Ela e muito esperta, mas nao sabe tudo. Se algo parecer estranho, pergunta pra um adulto."}
  ]'::jsonb,
  50,
  3,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'discovery-primeira-conversa',
  'Sua primeira conversa de verdade',
  'Vamos colocar tudo em pratica e conversar com o Claude!',
  '6-8',
  1,
  '[
    {"type":"text","content":"Agora voce ja sabe o que e IA, sabe como falar com o Claude e sabe as regras de seguranca. Bora conversar de verdade!"},
    {"type":"animation","content":"placeholder-anim-chat-bubble-pop"},
    {"type":"text","content":"Toca no botao colorido la embaixo. Voce vai pedir pro Claude te contar uma historia bem legal. Presta atencao, porque vai ter pergunta depois!"},
    {"type":"text","content":"Lembra: o Claude e seu amigo de aprender. E so se divertir!"}
  ]'::jsonb,
  50,
  4,
  true,
  'claude-haiku-4-5-20251001'
),

-- Insert Stage 2: Exploration (Medium) - 9-10 age band, 70 XP each
(
  gen_random_uuid(),
  'exploration-como-prompts-funcionam',
  'Como prompts funcionam',
  'Por que algumas perguntas dao respostas melhores que outras.',
  '9-10',
  2,
  '[
    {"type":"text","content":"Um prompt e como uma instrucao que voce da pra IA. Quanto mais clara a instrucao, melhor a resposta."},
    {"type":"image","src":"placeholder-prompt-anatomy.png","alt":"Diagrama mostrando partes de um prompt"},
    {"type":"text","content":"Compara essas duas perguntas: ''Conta uma historia'' e ''Conta uma historia de 3 frases sobre um dragao que ama brigadeiro''. Qual voce acha que vai dar uma resposta mais legal?"},
    {"type":"text","content":"O segredo e dar contexto: sobre o que, quao longo, qual o estilo. Quanto mais voce diz, mais a IA acerta o que voce quer."}
  ]'::jsonb,
  70,
  5,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'exploration-respostas-melhores',
  'Conseguindo respostas melhores',
  'Tres truques pra fazer a IA te entender melhor.',
  '9-10',
  2,
  '[
    {"type":"text","content":"Truque 1: Diga pra quem e a resposta. Por exemplo, ''explica pra uma crianca de 10 anos'' deixa a IA usar palavras mais simples."},
    {"type":"text","content":"Truque 2: Diga o tamanho. ''Em 2 frases'', ''em uma lista de 5 itens'', ''curto e direto''. Isso evita resposta gigante."},
    {"type":"image","src":"placeholder-three-tricks.png","alt":"Tres truques de prompt ilustrados"},
    {"type":"text","content":"Truque 3: Diga o formato. ''Como uma historia'', ''como uma receita'', ''como uma poesia''. A IA muda o jeito de responder."}
  ]'::jsonb,
  70,
  6,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'exploration-exemplo-com-api-real',
  'Um exemplo de verdade: pegando dados de Pokemon',
  'Vamos ver como programas pegam informacao da internet, usando uma API real de Pokemon.',
  '9-10',
  2,
  '[
    {"type":"text","content":"Sabe quando voce abre um app e ele mostra a previsao do tempo? O app pegou esses dados de algum lugar na internet. Esse ''algum lugar'' chama API."},
    {"type":"text","content":"Uma API e como uma janelinha que um site abre pra outros programas pegarem informacao. Vamos ver uma API de Pokemon!"},
    {"type":"image","src":"placeholder-pokeapi-ditto.png","alt":"Captura de tela do JSON do Ditto na PokeAPI"},
    {"type":"text","content":"Quando a gente pede informacao do Ditto na PokeAPI, ela responde com um monte de dados: o nome dele, os tipos, as habilidades, o peso. Tudo organizadinho!"},
    {"type":"text","content":"O Claude consegue ler dados assim e te explicar de um jeito divertido. Bora pedir pra ele descrever o Ditto?"}
  ]'::jsonb,
  70,
  7,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'exploration-o-que-e-mcp',
  'O que e MCP (Model Context Protocol)',
  'Como a IA consegue se conectar com outros programas pra te ajudar mais.',
  '9-10',
  2,
  '[
    {"type":"text","content":"Imagina se a IA pudesse ver seu calendario, suas notas, ou pegar dados de um site, sem voce precisar copiar e colar?"},
    {"type":"image","src":"placeholder-mcp-bridge.png","alt":"Ilustracao mostrando IA conectada a varios servicos"},
    {"type":"text","content":"O MCP, ou Model Context Protocol, e um padrao que permite a IA conversar diretamente com outros programas. E como dar superpoderes pra ela!"},
    {"type":"text","content":"Por exemplo, com MCP o Claude pode ler um arquivo, buscar algo no Google ou ate criar um desenho. Tudo isso sem precisar sair da conversa."},
    {"type":"text","content":"O MCP foi criado pra que IAs ajudem mais e melhor. E uma ideia recente, e e bem importante!"}
  ]'::jsonb,
  70,
  8,
  true,
  'claude-haiku-4-5-20251001'
),

-- Insert Stage 3: Creation (Hard) - 11-12 age band, 100 XP each
(
  gen_random_uuid(),
  'creation-construindo-com-claude',
  'Construindo algo com o Claude',
  'Como pedir ajuda pra criar algo do zero.',
  '11-12',
  3,
  '[
    {"type":"text","content":"Ate agora voce conversou e aprendeu. Agora voce vai criar! O Claude e otimo parceiro pra construir coisas: textos, planos, ideias, ate jogos simples."},
    {"type":"image","src":"placeholder-build-with-ai.png","alt":"Crianca e robo construindo juntos"},
    {"type":"text","content":"Quando a gente quer criar algo, o segredo e descrever o objetivo com detalhe. Em vez de ''me ajuda com um projeto'', tenta: ''me ajuda a planejar um cartaz sobre reciclagem pra escola''."},
    {"type":"text","content":"O Claude vai te dar uma estrutura, sugerir titulos, ideias de imagens. Voce escolhe o que gosta e refina."}
  ]'::jsonb,
  100,
  9,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'creation-encadeando-prompts',
  'Encadeando prompts',
  'Use varias perguntas em sequencia pra chegar mais longe.',
  '11-12',
  3,
  '[
    {"type":"text","content":"Encadear prompts e usar uma resposta pra alimentar a proxima pergunta. E como construir uma escada degrau por degrau."},
    {"type":"image","src":"placeholder-prompt-chain.png","alt":"Varios baloes de fala conectados como uma escada"},
    {"type":"text","content":"Exemplo: primeiro voce pede ''me da 5 ideias de redacao''. Depois voce escolhe uma e pergunta ''me ajuda a desenvolver essa daqui em 3 paragrafos''."},
    {"type":"text","content":"Em vez de pedir tudo de uma vez (que confunde a IA), voce vai construindo aos poucos. Cada prompt entrega uma peca do quebra-cabeca."}
  ]'::jsonb,
  100,
  10,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'creation-ideia-de-chatbot',
  'Criando a ideia de um chatbot simples',
  'Vamos planejar um chatbot que ajuda numa tarefa do dia a dia.',
  '11-12',
  3,
  '[
    {"type":"text","content":"Um chatbot e um programa que conversa por mensagens. Pode ser pra ajudar a estudar, lembrar tarefas, ou ate sugerir filmes."},
    {"type":"image","src":"placeholder-chatbot-design.png","alt":"Wireframe de um chatbot simples"},
    {"type":"text","content":"Pra planejar um chatbot, voce precisa pensar em: 1) qual problema ele resolve, 2) quem vai usar, 3) que tipo de pergunta ele responde, 4) qual a personalidade dele."},
    {"type":"text","content":"Hoje voce vai usar o Claude pra ajudar a desenhar a ideia de um chatbot. Voce so precisa dizer pra que ele serve!"}
  ]'::jsonb,
  100,
  11,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'creation-resolvendo-problema-real',
  'Usando o Claude pra resolver um problema real',
  'Pega um problema do seu dia e ataca com a IA.',
  '11-12',
  3,
  '[
    {"type":"text","content":"O Claude pode te ajudar com problemas reais: organizar a mochila pra prova, planejar uma festa, escrever um agradecimento, achar um erro num texto."},
    {"type":"image","src":"placeholder-real-problem.png","alt":"Lista de tarefas com check marks"},
    {"type":"text","content":"O truque e descrever o problema do jeito que voce contaria pra um amigo: o que esta acontecendo, o que voce quer alcancar e o que ja tentou."},
    {"type":"text","content":"Quanto mais contexto, melhor a ajuda. Mas lembra das regras: nada de dados pessoais!"}
  ]'::jsonb,
  100,
  12,
  true,
  'claude-haiku-4-5-20251001'
),

-- Insert Stage 4: Prompt Engineering (Advanced) - 12+ age band, 150 XP each
(
  gen_random_uuid(),
  'prompt-eng-roles-e-personas',
  'Roles e Personas',
  'Como dar uma ''persona'' pra IA muda completamente a resposta.',
  '12+',
  4,
  '[
    {"type":"text","content":"Quando voce comeca um prompt com ''Voce e um professor de historia animado'', a IA passa a responder no estilo daquela persona. Isso se chama dar uma role."},
    {"type":"image","src":"placeholder-persona-mask.png","alt":"Mascara de teatro simbolizando personas"},
    {"type":"text","content":"Por que isso importa? Porque a mesma pergunta tem respostas muito diferentes dependendo de quem responde. Um professor explica diferente de um cientista, que explica diferente de um amigo."},
    {"type":"text","content":"Voce define a persona dizendo: o papel (''voce e um X''), o tom (''animado, paciente''), e o publico (''pra um aluno do 7o ano''). Tres ingredientes simples, resposta muito mais util."}
  ]'::jsonb,
  150,
  13,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'prompt-eng-few-shot',
  'Few-shot examples',
  'Mostrar exemplos do que voce quer e quase magica.',
  '12+',
  4,
  '[
    {"type":"text","content":"Few-shot e dar pra IA alguns exemplos do tipo de resposta que voce quer, antes de pedir o resultado. E como mostrar o gabarito antes da prova."},
    {"type":"image","src":"placeholder-few-shot.png","alt":"Tres exemplos seguidos de uma pergunta"},
    {"type":"text","content":"Por exemplo: ''Transforma essas frases em emojis. Frase: estou feliz. Resposta: 😊. Frase: choveu muito. Resposta: ☔. Agora: o gato dormiu.'' A IA pega o padrao."},
    {"type":"text","content":"Funciona melhor com 2 ou 3 exemplos. Menos que isso a IA nao pega o padrao; mais que isso voce so esta gastando token a toa."}
  ]'::jsonb,
  150,
  14,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'prompt-eng-chain-of-thought',
  'Chain of thought',
  'Pedir pra IA pensar passo a passo melhora a precisao.',
  '12+',
  4,
  '[
    {"type":"text","content":"Chain of thought e pedir pra IA pensar passo a passo antes de responder. E como mostrar o calculo na prova de matematica."},
    {"type":"image","src":"placeholder-thinking-steps.png","alt":"Passos numerados de raciocinio"},
    {"type":"text","content":"E so adicionar ''Pense passo a passo'' ou ''Mostre seu raciocinio''. A IA passa a explicar o caminho ate a resposta — e geralmente acerta mais."},
    {"type":"text","content":"Funciona muito bem em problemas de logica, matematica, contagem, ou qualquer coisa que tenha varios passos. Pra perguntas simples, nao precisa."}
  ]'::jsonb,
  150,
  15,
  true,
  'claude-haiku-4-5-20251001'
),
(
  gen_random_uuid(),
  'prompt-eng-system-prompts',
  'System prompts',
  'A instrucao mestra que controla todo o comportamento da IA.',
  '12+',
  4,
  '[
    {"type":"text","content":"O system prompt e tipo o manual da IA. Ele define o papel, as regras, o tom, e o que ela pode ou nao pode fazer. E configurado uma vez e vale pra conversa toda."},
    {"type":"image","src":"placeholder-system-prompt.png","alt":"Documento de regras com cabecalho ''system''"},
    {"type":"text","content":"Em apps profissionais, o system prompt fica escondido do usuario. E o que faz a IA do app de musica ser diferente da IA do app de receitas, mesmo sendo o mesmo modelo por baixo."},
    {"type":"text","content":"Um bom system prompt tem: identidade (''voce e o X''), tarefa (''seu objetivo e Y''), regras (''nunca faca Z'') e formato de resposta (''responda em maximo 3 frases'')."}
  ]'::jsonb,
  150,
  16,
  true,
  'claude-haiku-4-5-20251001'
),

-- Insert Final Exam: Project Capstone - 12+ age band, 500 XP, uses Sonnet 4.6
(
  gen_random_uuid(),
  'final-exam-project-capstone',
  'Projeto Final: planeje seu app dos sonhos',
  'Conte sua ideia de app pro Claude e construa o plano juntos, em 5 passos.',
  '12+',
  5,
  '[
    {"type":"text","content":"Voce chegou ao fim do curso! Esta na hora de provar tudo que voce aprendeu construindo o plano de um app dos seus sonhos, junto com o Claude."},
    {"type":"image","src":"placeholder-capstone-stage.png","alt":"Palco com luzes simbolizando o exame final"},
    {"type":"text","content":"Aqui o Claude vai conversar diferente: ele vai te fazer perguntas em vez de te dar respostas prontas. Vai ser voce no comando da ideia."},
    {"type":"text","content":"Vamos passar por 5 etapas: o problema, os usuarios, as funcionalidades, a tela inicial e o primeiro passo. No fim, voce sai com um plano de verdade."},
    {"type":"text","content":"Lembra das regras: sem dados pessoais, sem promessas comerciais. Foca na ideia! Bora?"}
  ]'::jsonb,
  500,
  17,
  true,
  'claude-sonnet-4-6'
);

-- Now set the final exam flag on the last lesson
UPDATE lessons SET is_final_exam = true WHERE slug = 'final-exam-project-capstone';

-- Insert challenges for the 16 regular lessons (final exam has no challenge)
WITH lesson_ids AS (
  SELECT id, slug FROM lessons WHERE stage < 5
)
INSERT INTO challenges (id, lesson_id, kind, question, correct_answer, xp_reward)
SELECT
  gen_random_uuid(),
  l.id,
  'multiple_choice',
  CASE
    WHEN l.slug = 'discovery-o-que-e-ia' THEN
      '{"question": "O que e Inteligencia Artificial?", "options": ["Uma pessoa de verdade que vive dentro do computador", "Um programa de computador que aprendeu muita coisa", "Um brinquedo magico", "Um animal robotico"]}'::jsonb
    WHEN l.slug = 'discovery-falando-com-claude' THEN
      '{"question": "Como a gente chama o que voce escreve quando fala com o Claude?", "options": ["Mensagem","Prompt","Botao","Pedido secreto"]}'::jsonb
    WHEN l.slug = 'discovery-regras-de-seguranca' THEN
      '{"question": "Voce pode contar pro Claude o nome da sua escola?", "options": ["Sim, sem problema","Nao, e uma informacao pessoal","So se ele pedir","So se for uma escola legal"]}'::jsonb
    WHEN l.slug = 'discovery-primeira-conversa' THEN
      '{"question": "Voce ja pode comecar a conversar com o Claude?", "options": ["Ainda nao","So depois de virar adulto","Sim, com prompts seguros","So se o Claude pedir"]}'::jsonb
    WHEN l.slug = 'exploration-como-prompts-funcionam' THEN
      '{"question": "Qual prompt provavelmente da uma resposta melhor?", "options": ["Fala alguma coisa", "Me explica como funciona o ciclo da agua em 3 passos curtos", "Conta", "Hum"]}'::jsonb
    WHEN l.slug = 'exploration-respostas-melhores' THEN
      '{"question": "Qual desses NAO e um bom truque pra melhorar prompts?", "options": ["Dizer pra quem e a resposta", "Dizer o tamanho desejado", "Escrever tudo em letra maiuscula gritando", "Dizer o formato (lista, historia, etc)"]}'::jsonb
    WHEN l.slug = 'exploration-exemplo-com-api-real' THEN
      '{"question": "O que e uma API?", "options": ["Um tipo de Pokemon", "Uma janelinha que sites abrem pra outros programas pegarem dados", "Um app de jogos", "Um robo"]}'::jsonb
    WHEN l.slug = 'exploration-o-que-e-mcp' THEN
      '{"question": "Pra que serve o MCP?", "options": ["Pra IA conversar com outros programas e servicos", "Pra IA cozinhar", "Pra desligar o computador", "Pra trocar a senha"]}'::jsonb
    WHEN l.slug = 'creation-construindo-com-claude' THEN
      '{"question": "Qual e o segredo pra criar algo bom com a IA?", "options": ["Falar pouco e deixar ela adivinhar", "Descrever o objetivo com detalhe", "Pedir tudo em uma palavra so", "Nao explicar nada"]}'::jsonb
    WHEN l.slug = 'creation-encadeando-prompts' THEN
      '{"question": "Encadear prompts significa:", "options": ["Repetir a mesma pergunta varias vezes", "Usar a resposta de um prompt pra alimentar o proximo", "Falar baixinho com a IA", "Trancar o computador"]}'::jsonb
    WHEN l.slug = 'creation-ideia-de-chatbot' THEN
      '{"question": "Qual NAO e uma pergunta importante pra planejar um chatbot?", "options": ["Qual problema ele resolve", "Quem vai usar", "Qual a cor preferida do programador", "Que tipo de pergunta ele responde"]}'::jsonb
    WHEN l.slug = 'creation-resolvendo-problema-real' THEN
      '{"question": "Quando voce pede ajuda pra IA com um problema real, o que voce DEVE evitar contar?", "options": ["O que esta acontecendo", "O que voce ja tentou", "Seu endereco completo e telefone", "O que voce quer alcancar"]}'::jsonb
    WHEN l.slug = 'prompt-eng-roles-e-personas' THEN
      '{"question": "Qual desses NAO faz parte de uma boa persona?", "options": ["O papel (''voce e um cientista'')", "O tom (''animado, gentil'')", "O publico (''pra um aluno do 7o ano'')", "A senha do wifi"]}'::jsonb
    WHEN l.slug = 'prompt-eng-few-shot' THEN
      '{"question": "Quantos exemplos few-shot geralmente sao suficientes?", "options": ["Zero","De 2 a 3","Mais de 50","Exatamente 100"]}'::jsonb
    WHEN l.slug = 'prompt-eng-chain-of-thought' THEN
      '{"question": "Qual frase ativa chain of thought?", "options": ["Responda super rapido", "Pense passo a passo antes de responder", "Use poucas palavras", "Conta uma piada"]}'::jsonb
    WHEN l.slug = 'prompt-eng-system-prompts' THEN
      '{"question": "O system prompt serve pra:", "options": ["Definir as regras gerais e a identidade da IA na conversa toda", "Trocar a senha do usuario", "Imprimir o que a IA disser", "Ligar o computador"]}'::jsonb
  END,
  CASE
    WHEN l.slug = 'discovery-o-que-e-ia' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'discovery-falando-com-claude' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'discovery-regras-de-seguranca' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'discovery-primeira-conversa' THEN '{"answer": 2}'::jsonb
    WHEN l.slug = 'exploration-como-prompts-funcionam' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'exploration-respostas-melhores' THEN '{"answer": 2}'::jsonb
    WHEN l.slug = 'exploration-exemplo-com-api-real' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'exploration-o-que-e-mcp' THEN '{"answer": 0}'::jsonb
    WHEN l.slug = 'creation-construindo-com-claude' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'creation-encadeando-prompts' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'creation-ideia-de-chatbot' THEN '{"answer": 2}'::jsonb
    WHEN l.slug = 'creation-resolvendo-problema-real' THEN '{"answer": 2}'::jsonb
    WHEN l.slug = 'prompt-eng-roles-e-personas' THEN '{"answer": 3}'::jsonb
    WHEN l.slug = 'prompt-eng-few-shot' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'prompt-eng-chain-of-thought' THEN '{"answer": 1}'::jsonb
    WHEN l.slug = 'prompt-eng-system-prompts' THEN '{"answer": 0}'::jsonb
  END,
  25 -- Standard challenge XP
FROM lesson_ids l;

-- Insert prompt templates for all 17 lessons
WITH lesson_ids AS (
  SELECT id, slug, age_band FROM lessons
)
INSERT INTO prompt_templates (id, lesson_id, label, template, slots, age_band, order_index)
SELECT
  gen_random_uuid(),
  l.id,
  CASE
    WHEN l.slug = 'discovery-o-que-e-ia' THEN 'Oi Claude! Quem e voce?'
    WHEN l.slug = 'discovery-falando-com-claude' THEN 'Me conta uma curiosidade legal!'
    WHEN l.slug = 'discovery-regras-de-seguranca' THEN 'Me ensina uma regra de seguranca'
    WHEN l.slug = 'discovery-primeira-conversa' THEN 'Me conta uma historia bem curtinha!'
    WHEN l.slug = 'exploration-como-prompts-funcionam' THEN 'Me explica {{topico}} em 3 passos'
    WHEN l.slug = 'exploration-respostas-melhores' THEN 'Me explica {{tema}} como uma {{formato}}'
    WHEN l.slug = 'exploration-exemplo-com-api-real' THEN 'Me descreve o Pokemon {{nome}} de um jeito divertido'
    WHEN l.slug = 'exploration-o-que-e-mcp' THEN 'Me explica o que MCP poderia fazer com {{ferramenta}}'
    WHEN l.slug = 'creation-construindo-com-claude' THEN 'Me ajuda a criar {{coisa}} sobre {{tema}}'
    WHEN l.slug = 'creation-encadeando-prompts' THEN 'Me da 5 ideias de {{tipo_de_projeto}}'
    WHEN l.slug = 'creation-ideia-de-chatbot' THEN 'Me ajuda a planejar um chatbot pra {{publico}} sobre {{assunto}}'
    WHEN l.slug = 'creation-resolvendo-problema-real' THEN 'Me ajuda a resolver: {{problema}}'
    WHEN l.slug = 'prompt-eng-roles-e-personas' THEN 'Voce e um {{persona}} {{tom}}, me explica {{topico}}'
    WHEN l.slug = 'prompt-eng-few-shot' THEN 'Aprende com exemplos e classifica {{nova_frase}}'
    WHEN l.slug = 'prompt-eng-chain-of-thought' THEN 'Pensa passo a passo: {{problema}}'
    WHEN l.slug = 'prompt-eng-system-prompts' THEN 'Cria um system prompt pra um assistente de {{area}} com tom {{tom}}'
    WHEN l.slug = 'final-exam-project-capstone' THEN 'Estou pronto, vamos planejar meu app!'
  END,
  CASE
    WHEN l.slug = 'discovery-o-que-e-ia' THEN 'Oi! Voce pode me contar quem voce e em uma frase bem curtinha?'
    WHEN l.slug = 'discovery-falando-com-claude' THEN 'Me conta uma curiosidade bem legal e curtinha sobre animais, pra uma crianca de 7 anos.'
    WHEN l.slug = 'discovery-regras-de-seguranca' THEN 'Me da uma dica curtinha de seguranca pra criancas que conversam com inteligencia artificial.'
    WHEN l.slug = 'discovery-primeira-conversa' THEN 'Me conta uma historia bem curtinha e feliz pra uma crianca de 7 anos. Maximo 4 frases.'
    WHEN l.slug = 'exploration-como-prompts-funcionam' THEN 'Me explica {{topico}} em 3 passos curtos, pra uma crianca de 10 anos.'
    WHEN l.slug = 'exploration-respostas-melhores' THEN 'Me explica {{tema}} como uma {{formato}}, em 3 ou 4 frases, pra uma crianca de 10 anos.'
    WHEN l.slug = 'exploration-exemplo-com-api-real' THEN 'Me descreve o Pokemon {{nome}} de um jeito divertido em 3 frases, como se fosse pra uma crianca de 10 anos.'
    WHEN l.slug = 'exploration-o-que-e-mcp' THEN 'Me explica em 3 frases, pra uma crianca de 10 anos, o que o Claude poderia fazer se ele se conectasse com {{ferramenta}} usando MCP.'
    WHEN l.slug = 'creation-construindo-com-claude' THEN 'Me ajuda a criar {{coisa}} sobre {{tema}}. Me da uma estrutura em 4 ou 5 partes, com sugestoes pra cada uma.'
    WHEN l.slug = 'creation-encadeando-prompts' THEN 'Me da 5 ideias curtas de {{tipo_de_projeto}}. Numera de 1 a 5. Eu vou escolher uma depois pra desenvolver.'
    WHEN l.slug = 'creation-ideia-de-chatbot' THEN 'Me ajuda a planejar um chatbot que ajuda {{publico}} com {{assunto}}. Me responde com: 1) qual problema ele resolve, 2) 3 perguntas que ele responde, 3) que personalidade ele teria.'
    WHEN l.slug = 'creation-resolvendo-problema-real' THEN 'Me ajuda a resolver esse problema: {{problema}}. Me responde com 3 passos praticos que eu posso fazer hoje, sem usar dados pessoais.'
    WHEN l.slug = 'prompt-eng-roles-e-personas' THEN 'Voce e um {{persona}} {{tom}}. Me explica {{topico}} pra um adolescente de 13 anos, em 4 frases curtas.'
    WHEN l.slug = 'prompt-eng-few-shot' THEN 'Vou te dar exemplos de classificacao de frases como ''positivo'' ou ''negativo''. Exemplo 1: ''Adorei o filme'' -> positivo. Exemplo 2: ''Foi um dia chato'' -> negativo. Agora classifica essa: ''{{nova_frase}}''. Responde so com a palavra positivo ou negativo.'
    WHEN l.slug = 'prompt-eng-chain-of-thought' THEN 'Pensa passo a passo antes de responder. Me mostra cada passo do raciocinio, e no final escreve ''Resposta:'' seguido da conclusao. Problema: {{problema}}'
    WHEN l.slug = 'prompt-eng-system-prompts' THEN 'Escreva um system prompt curto (4 a 6 linhas) pra um assistente de {{area}} com tom {{tom}}. Inclua: identidade, tarefa, 2 regras e formato de resposta.'
    WHEN l.slug = 'final-exam-project-capstone' THEN 'Oi! Estou pronto pra planejar meu app dos sonhos. Pode comecar com a primeira pergunta?'
  END,
  CASE
    WHEN l.slug = 'discovery-o-que-e-ia' THEN NULL
    WHEN l.slug = 'discovery-falando-com-claude' THEN NULL
    WHEN l.slug = 'discovery-regras-de-seguranca' THEN NULL
    WHEN l.slug = 'discovery-primeira-conversa' THEN NULL
    WHEN l.slug = 'exploration-como-prompts-funcionam' THEN '[{"name":"topico","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]'::jsonb
    WHEN l.slug = 'exploration-respostas-melhores' THEN '[{"name":"tema","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},{"name":"formato","max_length":20,"allowed_chars":"^[A-Za-zÀ-ÿ ]+$"}]'::jsonb
    WHEN l.slug = 'exploration-exemplo-com-api-real' THEN '[{"name":"nome","max_length":20,"allowed_chars":"^[A-Za-z ]+$"}]'::jsonb
    WHEN l.slug = 'exploration-o-que-e-mcp' THEN '[{"name":"ferramenta","max_length":25,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]'::jsonb
    WHEN l.slug = 'creation-construindo-com-claude' THEN '[{"name":"coisa","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},{"name":"tema","max_length":40,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]'::jsonb
    WHEN l.slug = 'creation-encadeando-prompts' THEN '[{"name":"tipo_de_projeto","max_length":40,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]'::jsonb
    WHEN l.slug = 'creation-ideia-de-chatbot' THEN '[{"name":"publico","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},{"name":"assunto","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]'::jsonb
    WHEN l.slug = 'creation-resolvendo-problema-real' THEN '[{"name":"problema","max_length":80,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ,.?!]+$"}]'::jsonb
    WHEN l.slug = 'prompt-eng-roles-e-personas' THEN '[{"name":"persona","max_length":25,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},{"name":"tom","max_length":20,"allowed_chars":"^[A-Za-zÀ-ÿ ]+$"},{"name":"topico","max_length":40,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"}]'::jsonb
    WHEN l.slug = 'prompt-eng-few-shot' THEN '[{"name":"nova_frase","max_length":80,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ,.?!]+$"}]'::jsonb
    WHEN l.slug = 'prompt-eng-chain-of-thought' THEN '[{"name":"problema","max_length":120,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ,.?!+\\-*/=()]+$"}]'::jsonb
    WHEN l.slug = 'prompt-eng-system-prompts' THEN '[{"name":"area","max_length":30,"allowed_chars":"^[A-Za-zÀ-ÿ0-9 ]+$"},{"name":"tom","max_length":20,"allowed_chars":"^[A-Za-zÀ-ÿ ]+$"}]'::jsonb
    WHEN l.slug = 'final-exam-project-capstone' THEN NULL
  END,
  l.age_band,
  1 -- All prompt templates have order_index = 1 for simplicity
FROM lesson_ids l;

-- Add the new CAPSTONE_BUILDER badge
INSERT INTO badges (id, code, name, description, unlock_rule, icon)
VALUES (
  gen_random_uuid(),
  'CAPSTONE_BUILDER',
  'Construtor Capstone',
  'Completou o Projeto Final do curso',
  'final_exam_completed',
  'crown-star'
) ON CONFLICT (code) DO NOTHING;

COMMIT;