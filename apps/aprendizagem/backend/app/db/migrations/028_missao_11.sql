-- Migration 028: Insere conteudo da Stage 11 "Missao 11 - APIs, MCP e conexoes"
--
-- Foco: como sistemas conversam - APIs (analogia restaurante), APIs de IA
-- (endpoint/key/model/messages/tokens), MCP (Model Context Protocol da
-- Anthropic), webhooks e automacoes (Zapier/Make/n8n), e ciclo completo
-- de construcao de um produto com IA.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=11, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 11
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's11-o-que-e-api',
  'O que é uma API?',
  'What is an API?',
  'Entender o que são APIs e como conectam o mundo digital',
  'Understand what APIs are and how they connect the digital world',
  '6-18', 11, 1,
  $$[
    {"type":"text","content":"API significa Application Programming Interface — Interface de Programação de Aplicativos. É uma forma padronizada de dois sistemas de software conversarem entre si. A melhor analogia: pensa num restaurante. Você é o cliente. A cozinha é o sistema. O garçom é a API — ele recebe seu pedido, leva para a cozinha, e traz o resultado de volta. Você não precisa entrar na cozinha nem saber como a comida é feita."},
    {"type":"text","content":"Exemplos reais de APIs no seu dia a dia: quando um app mostra o clima ele usa a API de um serviço meteorológico. Quando você faz login com Google o site usa a API do Google. Quando você paga com cartão num app ele usa a API de um processador de pagamento. Quando você manda mensagem pelo WhatsApp passa pela API da Meta."},
    {"type":"text","content":"APIs são a cola invisível que conecta toda a internet. Sem APIs, cada sistema seria uma ilha isolada. Com APIs, sistemas diferentes podem trabalhar juntos de forma padronizada e eficiente."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"API stands for Application Programming Interface. It is a standardized way for two software systems to talk to each other. The best analogy: think of a restaurant. You are the customer. The kitchen is the system. The waiter is the API — they receive your order, take it to the kitchen, and bring the result back to you. You do not need to enter the kitchen or know how the food is made."},
    {"type":"text","content":"Real examples of APIs in your daily life: when an app shows the weather it uses a weather service API. When you log in with Google the site uses Googles API. When you pay with a card in an app it uses a payment processor API. When you send a message on WhatsApp it goes through Metas API."},
    {"type":"text","content":"APIs are the invisible glue that connects the entire internet. Without APIs, every system would be an isolated island. With APIs, different systems can work together in a standardized and efficient way."}
  ]$$::jsonb,
  'A criança pensa em 3 apps que usa todo dia e a Atena explica quais APIs estão sendo usadas por baixo. Objetivo: tornar APIs concretas e presentes no cotidiano.',
  'The child thinks of 3 apps they use every day and Atena explains which APIs are probably being used underneath. Goal: make APIs concrete and present in daily life.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's11-api-ia-funciona',
  'Como a API da IA funciona',
  'How the AI API works',
  'Entender como desenvolvedores usam APIs de IA para criar produtos',
  'Understand how developers use AI APIs to create products',
  '6-18', 11, 2,
  $$[
    {"type":"text","content":"Quando você usa o Claude, o ChatGPT ou qualquer outra IA num site ou app, você está usando uma API de IA. Funciona assim: você manda uma mensagem (chamada de request — requisição). A API recebe, manda para o modelo de IA, que processa e gera uma resposta. A API devolve essa resposta para o seu app. Tudo em frações de segundo."},
    {"type":"text","content":"Por que isso é poderoso? Porque qualquer desenvolvedor do mundo pode usar a inteligência de uma IA avançada nos próprios produtos sem precisar criar uma IA do zero. Os componentes de uma chamada de API de IA: ENDPOINT — o endereço para onde você manda a mensagem. API KEY — sua senha de acesso, nunca compartilhe. MODEL — qual versão da IA você quer usar. MESSAGES — a conversa e o histórico. MAX TOKENS — o limite de tamanho da resposta."},
    {"type":"text","content":"Exemplos reais: o assistente do Duolingo usa API de IA. Ferramentas de atendimento ao cliente usam API de IA. Corretores de texto em apps usam API de IA. Este curso que você está fazendo usa a API do Claude para a Atena conversar com você."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"When you use Claude, ChatGPT or any other AI on a site or app, you are using an AI API. It works like this: you send a message (called a request). The API receives it, sends it to the AI model, which processes it and generates a response. The API returns that response to your app. All in fractions of a second."},
    {"type":"text","content":"Why is this powerful? Because any developer in the world can use the intelligence of an advanced AI in their own products without needing to create an AI from scratch. The components of an AI API call: ENDPOINT — the address where you send the message. API KEY — your access password, never share it. MODEL — which version of AI you want to use. MESSAGES — the conversation and history. MAX TOKENS — the response size limit."},
    {"type":"text","content":"Real examples: the Duolingo assistant uses an AI API. Customer service tools use AI APIs. Text correctors in apps use AI APIs. This course you are taking uses the Claude API for Atena to talk with you."}
  ]$$::jsonb,
  'A criança imagina um app que gostaria de criar e a Atena explica como uma API de IA seria usada nesse app.',
  'The child imagines an app they would like to create and Atena explains how an AI API would be used in that app.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's11-o-que-e-mcp',
  'O que é MCP — Model Context Protocol',
  'What is MCP — Model Context Protocol',
  'Entender o que é MCP e como permite que IAs acessem ferramentas externas',
  'Understand what MCP is and how it allows AIs to access external tools',
  '6-18', 11, 3,
  $$[
    {"type":"text","content":"MCP significa Model Context Protocol — Protocolo de Contexto de Modelo. É um padrão criado pela Anthropic que permite que IAs se conectem a ferramentas e serviços externos de forma padronizada. APIs permitem que sistemas conversem. MCP permite que IAs acessem e usem ferramentas do mundo real durante uma conversa. É a diferença entre uma IA que só responde e uma IA que age."},
    {"type":"text","content":"Exemplos do que MCP permite: IA que acessa seus arquivos do Google Drive e lê documentos. IA que verifica seu e-mail e responde mensagens. IA que consulta um banco de dados em tempo real. IA que usa ferramentas de código para executar programas. IA que faz pesquisas na web dentro da conversa."},
    {"type":"text","content":"Antes do MCP cada empresa criava sua própria forma de conectar IA com ferramentas — um sistema caótico. Com MCP existe um padrão universal. Um servidor MCP criado uma vez pode funcionar com qualquer IA compatível. Este curso usa MCP — a Atena tem acesso a contexto sobre suas lições e progresso por causa do MCP."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"MCP stands for Model Context Protocol. It is a standard created by Anthropic that allows AIs to connect to external tools and services in a standardized way. APIs allow systems to talk. MCP specifically allows AIs to access and use real-world tools during a conversation. It is the difference between an AI that only responds and an AI that acts."},
    {"type":"text","content":"Examples of what MCP enables: AI that accesses your Google Drive files and reads documents. AI that checks your email and replies to messages. AI that queries a database in real time. AI that uses code tools to execute programs. AI that does web searches within the conversation."},
    {"type":"text","content":"Before MCP each company created its own way to connect AI with tools — a chaotic system. With MCP there is a universal standard. An MCP server created once can work with any compatible AI. This course uses MCP — Atena has access to context about your lessons and progress because of MCP."}
  ]$$::jsonb,
  'A criança pensa em ferramentas que a Atena poderia acessar para ser ainda mais útil. A Atena explica como MCP tornaria isso possível.',
  'The child thinks of tools Atena could access to be even more helpful. Atena explains how MCP would make that possible.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's11-webhooks-automacoes',
  'Webhooks, automações e IAs que agem sozinhas',
  'Webhooks, automations and AIs that act on their own',
  'Entender webhooks e como criar automações com IA',
  'Understand webhooks and how to create AI automations',
  '6-18', 11, 4,
  $$[
    {"type":"text","content":"Webhook é como uma API ao contrário. Em vez de você perguntar para um sistema tem novidades toda hora, o sistema te avisa automaticamente quando algo acontece. Quando alguém fizer uma compra, avise meu sistema. Quando chegar um e-mail, execute essa ação. O sistema empurra a informação para você em vez de você puxar."},
    {"type":"text","content":"Automações com IA combinam tudo: um cliente manda mensagem no Instagram, webhook captura a mensagem, IA processa e gera uma resposta personalizada, API envia a resposta de volta. Tudo em segundos sem humano envolvido. Ferramentas como Zapier, Make e n8n permitem criar essas automações sem programar — você conecta peças como se fosse LEGO."},
    {"type":"text","content":"O poder: sistemas que trabalham 24 horas por dia, respondem instantaneamente e escalam para milhares de pessoas. O limite importante: automações sem supervisão humana podem cometer erros que se multiplicam em escala. Por isso sistemas críticos sempre precisam de revisão humana."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Webhook is like an API in reverse. Instead of you asking a system any updates every hour, the system automatically notifies you when something happens. When someone makes a purchase, notify my system. When an email arrives, execute this action. The system pushes information to you instead of you pulling it."},
    {"type":"text","content":"AI automations combine everything: a customer sends a message on Instagram, webhook captures the message, AI processes and generates a personalized response, API sends the response back. All in seconds without a human involved. Tools like Zapier, Make and n8n allow creating these automations without programming — you connect pieces like LEGO."},
    {"type":"text","content":"The power: systems that work 24 hours a day, respond instantly and scale to thousands of people. The important limit: automations without human supervision can make errors that multiply at scale. That is why critical systems always need human review."}
  ]$$::jsonb,
  'A criança descreve uma tarefa repetitiva da família e a Atena explica como uma automação com IA poderia fazer isso.',
  'The child describes a repetitive family task and Atena explains how an AI automation could handle it.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's11-construindo-com-ia',
  'Construindo com IA — do zero ao produto',
  'Building with AI — from zero to product',
  'Entender o ciclo completo de construção de um produto com IA',
  'Understand the complete cycle of building a product with AI',
  '6-18', 11, 5,
  $$[
    {"type":"text","content":"Com tudo que você aprendeu — prompts, APIs, MCP, automações — você entende como produtos reais com IA são construídos. O ciclo: 1) IDEIA — qual problema você está resolvendo? Para quem? O que a IA vai fazer? 2) ESCOLHA DO MODELO — Claude para texto e raciocínio, DALL-E para imagens, Whisper para transcrição de áudio. 3) INTEGRAÇÃO VIA API — você conecta seu produto à IA, manda o contexto certo e recebe a resposta."},
    {"type":"text","content":"4) FERRAMENTAS EXTRAS VIA MCP — se precisar que a IA acesse dados externos como banco de dados, e-mails ou arquivos, você usa MCP. 5) AUTOMAÇÕES — para coisas que precisam acontecer automaticamente você usa webhooks e automações. 6) FEEDBACK E MELHORIA — você observa onde a IA erra, ajusta os prompts e melhora o sistema continuamente."},
    {"type":"text","content":"Você não precisa ser programador para entender esse ciclo. Ferramentas como Lovable, Bubble e Glide permitem criar produtos com IA sem código. E entender o ciclo — mesmo sem programar — é o que permite você ter boas ideias, colaborar com desenvolvedores e transformar visão em produto real."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"With everything you learned — prompts, APIs, MCP, automations — you understand how real AI products are built. The cycle: 1) IDEA — what problem are you solving? For whom? What will AI do? 2) MODEL CHOICE — Claude for text and reasoning, DALL-E for images, Whisper for audio transcription. 3) API INTEGRATION — you connect your product to AI, send the right context and receive the response."},
    {"type":"text","content":"4) EXTRA TOOLS VIA MCP — if you need AI to access external data like databases, emails or files, you use MCP. 5) AUTOMATIONS — for things that need to happen automatically you use webhooks and automations. 6) FEEDBACK AND IMPROVEMENT — you observe where AI makes mistakes, adjust prompts and improve the system continuously."},
    {"type":"text","content":"You do not need to be a programmer to understand this cycle. Tools like Lovable, Bubble and Glide allow creating AI products without code. And understanding the cycle — even without programming — is what allows you to have good ideas, collaborate with developers and turn vision into a real product."}
  ]$$::jsonb,
  'A criança descreve um produto simples que gostaria de criar com IA e a Atena explica o ciclo completo — ideia, modelo, API, MCP e automação.',
  'The child describes a simple product they would like to create with AI and Atena explains the full cycle — idea, model, API, MCP and automation.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's11-teste-missao-11',
  'Teste — Missão 11',
  'Test — Mission 11',
  'Quiz para fechar a Missão 11',
  'Quiz to complete Mission 11',
  '6-18', 11, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 11! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 11! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s11-o-que-e-api
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma API?","options":["Um tipo de vírus de computador que conecta sistemas","Uma forma padronizada de dois sistemas de software conversarem entre si","Um aplicativo que gerencia senhas e logins","Um tipo de banco de dados para armazenar informações"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is an API?',
  $$["A type of computer virus that connects systems","A standardized way for two software systems to talk to each other","An app that manages passwords and logins","A type of database to store information"]$$::jsonb
FROM lessons WHERE slug = 's11-o-que-e-api';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Na analogia do restaurante o que o garçom representa?","options":["O cliente que faz o pedido","A cozinha que prepara a comida","A API que recebe o pedido comunica com o sistema e traz o resultado","O menu com as opções disponíveis"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'In the restaurant analogy what does the waiter represent?',
  $$["The customer who orders","The kitchen that prepares the food","The API that receives the order communicates with the system and brings the result","The menu with available options"]$$::jsonb
FROM lessons WHERE slug = 's11-o-que-e-api';

-- s11-api-ia-funciona
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que as APIs de IA são tão valiosas para desenvolvedores?","options":["São gratuitas para sempre para qualquer uso","Permitem usar inteligência de IA avançada em qualquer produto sem precisar criar uma IA do zero","Garantem que o produto vai funcionar mais rápido","Eliminam a necessidade de programação completamente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why are AI APIs so valuable for developers?',
  $$["They are forever free for any use","They allow using advanced AI intelligence in any product without needing to create AI from scratch","They guarantee the product will work faster","They eliminate the need for programming completely"]$$::jsonb
FROM lessons WHERE slug = 's11-api-ia-funciona';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma API Key?","options":["O botão de enviar mensagem em aplicativos de chat","O endereço do servidor onde a IA está hospedada","A senha de acesso que identifica quem está usando a API e nunca deve ser compartilhada","O nome do modelo de IA que será usado"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is an API Key?',
  $$["The send message button in chat apps","The server address where the AI is hosted","The access password that identifies who is using the API and should never be shared","The name of the AI model to be used"]$$::jsonb
FROM lessons WHERE slug = 's11-api-ia-funciona';

-- s11-o-que-e-mcp
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a principal diferença entre API e MCP?","options":["MCP é mais barato que APIs tradicionais","APIs permitem que sistemas conversem; MCP permite que IAs acessem e usem ferramentas externas de forma padronizada durante conversas","MCP é uma versão mais antiga de API","APIs são para texto; MCP é para imagens"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the main difference between API and MCP?',
  $$["MCP is cheaper than traditional APIs","APIs allow systems to talk; MCP allows AIs to access and use external tools in a standardized way during conversations","MCP is an older version of API","APIs are for text; MCP is for images"]$$::jsonb
FROM lessons WHERE slug = 's11-o-que-e-mcp';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a padronização do MCP é importante?","options":["Porque reduz o custo de processamento das IAs","Porque cria um padrão universal — um servidor MCP criado uma vez funciona com qualquer IA compatível","Porque obriga todas as empresas a usar o mesmo modelo de IA","Porque elimina a necessidade de APIs completamente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is MCP standardization important?',
  $$["Because it reduces AI processing cost","Because it creates a universal standard — an MCP server created once works with any compatible AI","Because it forces all companies to use the same AI model","Because it eliminates the need for APIs completely"]$$::jsonb
FROM lessons WHERE slug = 's11-o-que-e-mcp';

-- s11-webhooks-automacoes
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é um webhook?","options":["Um tipo especial de API para aplicativos web","Um sistema que avisa automaticamente quando algo acontece em vez de você precisar perguntar constantemente","Uma ferramenta de segurança para proteger APIs","Um protocolo para conectar IAs a bancos de dados"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is a webhook?',
  $$["A special type of API for web applications","A system that automatically notifies when something happens instead of you needing to constantly ask","A security tool to protect APIs","A protocol to connect AIs to databases"]$$::jsonb
FROM lessons WHERE slug = 's11-webhooks-automacoes';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o limite importante das automações com IA sem supervisão humana?","options":["São muito lentas para tarefas simples","Custam mais caro que contratar humanos","Podem cometer erros que se multiplicam em escala sem que ninguém perceba","Só funcionam durante o horário comercial"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the important limit of AI automations without human supervision?',
  $$["They are too slow for simple tasks","They cost more than hiring humans","They can make errors that multiply at scale without anyone noticing","They only work during business hours"]$$::jsonb
FROM lessons WHERE slug = 's11-webhooks-automacoes';

-- s11-construindo-com-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o primeiro passo essencial antes de começar a construir um produto com IA?","options":["Escolher qual linguagem de programação usar","Comprar créditos de API suficientes","Definir qual problema está sendo resolvido e para quem","Decidir qual empresa de IA tem a API mais barata"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the essential first step before starting to build an AI product?',
  $$["Choose which programming language to use","Buy enough API credits","Define what problem is being solved and for whom","Decide which AI company has the cheapest API"]$$::jsonb
FROM lessons WHERE slug = 's11-construindo-com-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que entender o ciclo de construção com IA é valioso mesmo para quem não programa?","options":["Porque permite copiar produtos de outras empresas mais facilmente","Porque permite ter boas ideias colaborar com desenvolvedores e usar ferramentas no-code para criar produtos reais","Porque substitui a necessidade de aprender programação completamente","Porque é obrigatório por lei para usar APIs comercialmente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is understanding the AI build cycle valuable even for non-programmers?',
  $$["Because it allows copying other companies products more easily","Because it allows having good ideas collaborating with developers and using no-code tools to create real products","Because it replaces the need to learn programming completely","Because it is legally required to use APIs commercially"]$$::jsonb
FROM lessons WHERE slug = 's11-construindo-com-ia';

-- s11-teste-missao-11 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Um app de estudos tem assistente de IA que responde dúvidas acessa seu histórico e manda lembretes automáticos. Quais tecnologias estão por baixo?","options":["Só uma API de IA para o chat","API de IA para o chat MCP para acessar o histórico e webhooks para os lembretes automáticos","Apenas webhooks para tudo","MCP sozinho resolve tudo sem precisar de API"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'A study app has an AI assistant that answers questions accesses your history and sends automatic reminders. Which technologies are underneath?',
  $$["Only an AI API for the chat","AI API for the chat MCP to access history and webhooks for automatic reminders","Only webhooks for everything","MCP alone solves everything without needing API"]$$::jsonb
FROM lessons WHERE slug = 's11-teste-missao-11';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você quer criar um bot que responde automaticamente mensagens de clientes usando IA. Qual seria a sequência correta?","options":["Contratar um programador caro para criar uma IA do zero","Webhook captura a mensagem, API de IA processa e gera resposta, API envia resposta de volta","Criar uma lista de respostas prontas e copiar manualmente","Usar apenas MCP sem precisar de webhook ou API"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You want to create a bot that automatically responds to customer messages using AI. What would be the correct sequence?',
  $$["Hire an expensive programmer to create AI from scratch","Webhook captures the message, AI API processes and generates response, API sends response back","Create a list of ready responses and copy manually","Use only MCP without needing webhook or API"]$$::jsonb
FROM lessons WHERE slug = 's11-teste-missao-11';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s11-o-que-e-api
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'APIs nos meus apps', 'Me explica quais APIs provavelmente estão sendo usadas por baixo do [app]. Como cada uma funciona?', '6-18', 1
FROM lessons WHERE slug = 's11-o-que-e-api';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como APIs funcionam?', 'Me explica como uma API funciona usando uma analogia diferente do restaurante.', '6-18', 2
FROM lessons WHERE slug = 's11-o-que-e-api';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'APIs no dia a dia', 'Me dá 5 exemplos surpreendentes de APIs que as pessoas usam sem saber no cotidiano.', '6-18', 3
FROM lessons WHERE slug = 's11-o-que-e-api';

-- s11-api-ia-funciona
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu app com IA', 'Quero criar um app que [descreve]. Como a API de IA seria usada? Me explica o fluxo completo.', '6-18', 1
FROM lessons WHERE slug = 's11-api-ia-funciona';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quanto custa usar API de IA?', 'Como funciona a cobrança das APIs de IA? Como os desenvolvedores calculam o custo?', '6-18', 2
FROM lessons WHERE slug = 's11-api-ia-funciona';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'API do Claude', 'Me explica como a API do Claude funciona. Quais são as opções de modelos e para que serve cada um?', '6-18', 3
FROM lessons WHERE slug = 's11-api-ia-funciona';

-- s11-o-que-e-mcp
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'MCP na prática', 'Se você pudesse acessar qualquer ferramenta via MCP o que você faria com ela para me ajudar melhor?', '6-18', 1
FROM lessons WHERE slug = 's11-o-que-e-mcp';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'API vs MCP', 'Me explica a diferença entre API e MCP com um exemplo prático de como cada um seria usado num produto real.', '6-18', 2
FROM lessons WHERE slug = 's11-o-que-e-mcp';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria um servidor MCP', 'Se eu quisesse criar um servidor MCP para conectar você ao meu sistema de [descreve], como funcionaria conceitualmente?', '6-18', 3
FROM lessons WHERE slug = 's11-o-que-e-mcp';

-- s11-webhooks-automacoes
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Automatiza isso', 'Tenho essa tarefa repetitiva: [descreve]. Como uma automação com webhook e IA poderia fazer isso automaticamente?', '6-18', 1
FROM lessons WHERE slug = 's11-webhooks-automacoes';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Webhook vs API', 'Me explica a diferença entre webhook e API com um exemplo prático de quando usar cada um.', '6-18', 2
FROM lessons WHERE slug = 's11-webhooks-automacoes';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria minha automação', 'Quero criar uma automação que [descreve objetivo]. Me explica quais ferramentas usar e como conectar tudo.', '6-18', 3
FROM lessons WHERE slug = 's11-webhooks-automacoes';

-- s11-construindo-com-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Ciclo do meu produto', 'Quero criar [descreve produto com IA]. Me explica o ciclo completo: ideia, modelo, API, MCP e automações que eu precisaria.', '6-18', 1
FROM lessons WHERE slug = 's11-construindo-com-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'No-code com IA', 'Quero criar um produto com IA sem programar. Quais ferramentas no-code eu poderia usar e como cada uma funciona?', '6-18', 2
FROM lessons WHERE slug = 's11-construindo-com-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Da ideia ao produto', 'Tenho essa ideia: [descreve]. O que seria o MVP — produto mínimo viável — e como eu poderia construir usando IA?', '6-18', 3
FROM lessons WHERE slug = 's11-construindo-com-ia';

COMMIT;
