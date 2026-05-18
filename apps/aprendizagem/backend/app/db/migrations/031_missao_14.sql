-- Migration 031: Insere conteudo da Stage 14 "Missao 14 - Jogos, apps e negocios"
--
-- Foco: criar coisas reais com IA - jogos (design/historia/arte/musica/codigo),
-- apps no-code (Lovable/Bubble/FlutterFlow/Glide), monetizacao (freemium/
-- assinatura/venda unica/servico), construindo marca (nome/tagline/visual/
-- voz), e do projeto ao negocio (5 elementos: produto/cliente/canal/receita/
-- operacao).
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=14, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 14
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's14-criando-jogos-ia',
  'Criando jogos com IA',
  'Creating games with AI',
  'Descobrir como usar IA em todas as partes da criação de um jogo',
  'Discover how to use AI in every part of game creation',
  '6-18', 14, 1,
  $$[
    {"type":"text","content":"Jogos são uma das formas mais divertidas de criar com IA. E hoje qualquer pessoa pode criar um jogo funcional mesmo sem saber programar. IA NO DESIGN DE JOGOS: MECÂNICAS — a IA ajuda a criar regras, sistemas de progressão e balanceamento. HISTÓRIA E PERSONAGENS — a IA escreve narrativa, diálogos, backstory e missões. ARTE — IAs de imagem como Midjourney criam sprites, backgrounds e ícones."},
    {"type":"text","content":"MÚSICA E SONS — Suno e Udio criam trilhas sonoras temáticas em minutos. CÓDIGO — ferramentas como Cursor e Claude Code escrevem o código. Para iniciantes, plataformas como GDevelop com IA permitem criar jogos 2D sem código. Com IA você pode iterar o design rapidamente até encontrar o que é divertido."},
    {"type":"text","content":"O segredo dos bons jogos: mecânicas simples, progressão clara, feedback imediato. Um jogo com 5 fases bem feitas é infinitamente melhor que um com 50 fases medíocres. Com IA você testa e melhora o design rápido até encontrar o que realmente funciona."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Games are one of the most fun ways to create with AI. And today anyone can create a functional game even without knowing how to program. AI IN GAME DESIGN: MECHANICS — AI helps create rules, progression systems and balancing. STORY AND CHARACTERS — AI writes narrative, dialogues, backstory and quests. ART — image AIs like Midjourney create sprites, backgrounds and icons."},
    {"type":"text","content":"MUSIC AND SOUNDS — Suno and Udio create thematic soundtracks in minutes. CODE — tools like Cursor and Claude Code write the code. For beginners, platforms like GDevelop with AI allow creating 2D games without code. With AI you can iterate the design quickly until you find what is fun."},
    {"type":"text","content":"The secret of good games: simple mechanics, clear progression, immediate feedback. A game with 5 well-made levels is infinitely better than one with 50 mediocre levels. With AI you test and improve the design fast until you find what really works."}
  ]$$::jsonb,
  'A criança descreve um jogo que gostaria de criar e a Atena ajuda a desenvolver as mecânicas principais o personagem central e as primeiras 3 fases.',
  'The child describes a game they would like to create and Atena helps develop the main mechanics the central character and the first 3 levels.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's14-criando-apps-ferramentas',
  'Criando apps e ferramentas úteis',
  'Creating useful apps and tools',
  'Aprender a criar apps funcionais com ferramentas no-code e IA',
  'Learn to create functional apps with no-code tools and AI',
  '6-18', 14, 2,
  $$[
    {"type":"text","content":"Apps não precisam ser complexos para serem úteis. Alguns dos apps mais usados resolvem um único problema muito bem. Categorias de apps que você pode criar: APP DE PRODUTIVIDADE — organizador de tarefas, tracker de hábitos, gerador de rotinas. APP EDUCACIONAL — flashcards interativos, quiz gerado por IA, tutor de matéria específica. APP CRIATIVO — gerador de histórias, criador de personagens, assistente de escrita."},
    {"type":"text","content":"APP DE COMUNIDADE — conecta pessoas com interesses em comum, facilita organização de grupos. APP DE UTILIDADE LOCAL — resolve um problema específico da sua cidade ou escola. Ferramentas no-code para criar apps: Lovable — descreve o app e ele constrói. Bubble — arrasta e solta para criar apps web completos. FlutterFlow — apps mobile sem código. Glide — transforma planilhas em apps."},
    {"type":"text","content":"A pergunta que deve guiar o design do app: qual é a única coisa que meu app faz melhor que qualquer outro? Um app que faz uma coisa perfeitamente é mais valioso do que um app que tenta fazer tudo e não faz nada bem."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Apps do not need to be complex to be useful. Some of the most used apps solve a single problem very well. Categories of apps you can create: PRODUCTIVITY APP — task organizer, habit tracker, routine generator. EDUCATIONAL APP — interactive flashcards, AI-generated quiz, subject-specific tutor. CREATIVE APP — story generator, character creator, writing assistant."},
    {"type":"text","content":"COMMUNITY APP — connects people with common interests, facilitates group organization. LOCAL UTILITY APP — solves a specific problem in your city or school. No-code tools to create apps: Lovable — describe the app and it builds it. Bubble — drag and drop to create complete web apps. FlutterFlow — mobile apps without code. Glide — turns spreadsheets into apps."},
    {"type":"text","content":"The question that should guide app design: what is the one thing my app does better than anything else? An app that does one thing perfectly is more valuable than an app that tries to do everything and does nothing well."}
  ]$$::jsonb,
  'A criança descreve um app que gostaria de criar e a Atena ajuda a definir a funcionalidade central o usuário ideal e como criar o MVP com no-code.',
  'The child describes an app they would like to create and Atena helps define the core feature the ideal user and how to create the MVP with no-code.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's14-monetizacao-ia',
  'Monetização — como ganhar dinheiro com criações de IA',
  'Monetization — how to earn money with AI creations',
  'Conhecer os modelos de monetização e como validar que pessoas pagariam',
  'Know the monetization models and how to validate that people would pay',
  '6-18', 14, 3,
  $$[
    {"type":"text","content":"Criar é ótimo. Criar e gerar renda é ainda melhor. Modelos de monetização: FREEMIUM — o básico é gratuito, funcionalidades avançadas são pagas. É o modelo do Spotify, Duolingo e Notion. Perfeito para apps que precisam de muitos usuários primeiro. ASSINATURA — pagamento recorrente mensal ou anual. Previsível para quem cria, conveniente para quem usa. Modelo do Netflix e maioria dos apps profissionais."},
    {"type":"text","content":"VENDA ÚNICA — o usuário paga uma vez e tem acesso para sempre. Funciona bem para jogos e templates. SERVIÇO COM IA — você usa IA para oferecer serviço que antes exigia muitas horas humanas: design de logo, criação de conteúdo, análise de dados. CONTEÚDO E EDUCAÇÃO — você aprende algo, usa IA para criar cursos e vídeos. VENDA DE ASSETS — templates de prompt, pacotes de imagens, músicas para uso comercial."},
    {"type":"text","content":"O mais importante: comece cobrando antes do que acha que deveria. A maioria dos criadores espera o produto estar perfeito para cobrar. Mas cobrar cedo valida que as pessoas realmente querem pagar — o teste mais importante de todos."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Creating is great. Creating and generating income is even better. Monetization models: FREEMIUM — the basics are free, advanced features are paid. This is the Spotify, Duolingo and Notion model. Perfect for apps that need many users first. SUBSCRIPTION — recurring monthly or annual payment. Predictable for creators, convenient for users. The Netflix model and most professional apps."},
    {"type":"text","content":"ONE-TIME SALE — the user pays once and has access forever. Works well for games and templates. AI SERVICE — you use AI to offer a service that previously required many human hours: logo design, content creation, data analysis. CONTENT AND EDUCATION — you learn something, use AI to create courses and videos. ASSET SALES — prompt templates, image packs, music for commercial use."},
    {"type":"text","content":"The most important thing: start charging earlier than you think you should. Most creators wait for the product to be perfect before charging. But charging early validates that people really want to pay — the most important test of all."}
  ]$$::jsonb,
  'A criança descreve uma ideia de produto ou serviço e a Atena ajuda a escolher o modelo de monetização mais adequado e criar uma estratégia de primeiros clientes.',
  'The child describes a product or service idea and Atena helps choose the most appropriate monetization model and create a first customers strategy.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's14-construindo-marca-ia',
  'Construindo uma marca com IA',
  'Building a brand with AI',
  'Aprender a criar os elementos de uma marca usando IA',
  'Learn to create brand elements using AI',
  '6-18', 14, 4,
  $$[
    {"type":"text","content":"Com IA construir os elementos de uma marca levou de semanas para horas. Os elementos de uma marca: NOME — memorável, fácil de pronunciar, disponível como domínio. A IA gera dezenas de opções com diferentes abordagens. TAGLINE — a frase de 5 a 10 palavras que resume o que você faz e para quem. IDENTIDADE VISUAL — logo, cores, fontes. IA de imagem cria logos e Claude sugere paletas baseadas na personalidade."},
    {"type":"text","content":"TOM DE VOZ — como a marca fala? Formal ou casual? Engraçado ou sério? Define como todos os textos devem ser escritos. HISTÓRIA DA MARCA — por que você criou? Qual problema te motivou? As melhores marcas têm uma história genuína. Como usar IA: descreva seu produto, usuário e valores. Peça opções de nome, taglines, paleta de cores e tom de voz. Itere até encontrar algo autêntico."},
    {"type":"text","content":"A regra de ouro da marca: seja consistente. Uma marca fraca executada consistentemente vence uma marca forte executada aleatoriamente. Consistência cria reconhecimento — e reconhecimento cria confiança."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"With AI building brand elements went from weeks to hours. Brand elements: NAME — memorable, easy to pronounce, available as a domain. AI generates dozens of options with different approaches. TAGLINE — the 5 to 10 word phrase that summarizes what you do and for whom. VISUAL IDENTITY — logo, colors, fonts. Image AI creates logos and Claude suggests palettes based on personality."},
    {"type":"text","content":"TONE OF VOICE — how does the brand speak? Formal or casual? Funny or serious? Defines how all texts should be written. BRAND STORY — why did you create it? What problem motivated you? The best brands have a genuine story. How to use AI: describe your product, user and values. Ask for name options, taglines, color palettes and tone of voice. Iterate until you find something authentic."},
    {"type":"text","content":"The golden rule of branding: be consistent. A weak brand executed consistently beats a strong brand executed randomly. Consistency creates recognition — and recognition creates trust."}
  ]$$::jsonb,
  'A criança escolhe um projeto e a Atena ajuda a criar os elementos básicos da marca — nome tagline tom de voz e paleta de cores sugerida.',
  'The child picks a project and Atena helps create the basic brand elements — name tagline tone of voice and suggested color palette.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's14-projeto-ao-negocio',
  'Do projeto ao negócio — os primeiros passos',
  'From project to business — the first steps',
  'Entender a diferença entre projeto e negócio e como dar os primeiros passos',
  'Understand the difference between project and business and how to take the first steps',
  '6-18', 14, 5,
  $$[
    {"type":"text","content":"Existe uma grande diferença entre projeto e negócio. Um projeto você faz porque gosta. Um negócio resolve um problema para pessoas que pagam para tê-lo resolvido. Os 5 elementos de um negócio funcionando: 1) PRODUTO — algo que resolve um problema real melhor que as alternativas. 2) CLIENTE — uma pessoa específica com esse problema disposta a pagar. 3) CANAL — como o cliente descobre e acessa o produto."},
    {"type":"text","content":"4) RECEITA — dinheiro entrando de forma sustentável e crescente. 5) OPERAÇÃO — como o produto é entregue, mantido e melhorado consistentemente. A IA pode ajudar em todos os 5, mas não substitui nenhum. A IA escreve a copy, mas você constrói o produto. A IA sugere canais, mas você executa. A IA calcula projeções, mas você faz as vendas."},
    {"type":"text","content":"Para começar hoje: 1) Defina seu primeiro cliente ideal — uma pessoa real, não um perfil. 2) Fale com 5 pessoas desse perfil antes de construir qualquer coisa. 3) Cobre por algo simples antes de ter o produto perfeito. 4) Use a IA para ir mais rápido em cada passo."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is a big difference between a project and a business. A project you do because you enjoy it. A business solves a problem for people who pay to have it solved. The 5 elements of a working business: 1) PRODUCT — something that solves a real problem better than alternatives. 2) CUSTOMER — a specific person with that problem willing to pay. 3) CHANNEL — how the customer discovers and accesses the product."},
    {"type":"text","content":"4) REVENUE — money coming in sustainably and growing. 5) OPERATION — how the product is delivered, maintained and improved consistently. AI can help with all 5, but does not replace any of them. AI writes the copy, but you build the product. AI suggests channels, but you execute. AI calculates projections, but you make the sales."},
    {"type":"text","content":"To start today: 1) Define your first ideal customer — a real person, not a profile. 2) Talk to 5 people of that profile before building anything. 3) Charge for something simple before having the perfect product. 4) Use AI to go faster at each step."}
  ]$$::jsonb,
  'A criança descreve uma ideia de negócio e a Atena ajuda a definir os 5 elementos — produto cliente canal receita e primeiros passos de operação.',
  'The child describes a business idea and Atena helps define the 5 elements — product customer channel revenue and first operation steps.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's14-teste-missao-14',
  'Teste — Missão 14',
  'Test — Mission 14',
  'Quiz para fechar a Missão 14',
  'Quiz to complete Mission 14',
  '6-18', 14, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 14! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 14! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s14-criando-jogos-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual IA seria mais adequada para criar a trilha sonora de um jogo?","options":["Claude ou ChatGPT","Suno ou Udio","GitHub Copilot","Adobe Firefly"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Which AI would be most suitable to create a game soundtrack?',
  $$["Claude or ChatGPT","Suno or Udio","GitHub Copilot","Adobe Firefly"]$$::jsonb
FROM lessons WHERE slug = 's14-criando-jogos-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que define um bom jogo?","options":["Muitas fases e muito conteúdo para manter o jogador ocupado","Mecânicas simples progressão clara e feedback imediato — qualidade acima de quantidade","Gráficos fotorrealistas criados com IA avançada","Modo multiplayer com suporte a centenas de jogadores"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What defines a good game?',
  $$["Many levels and lots of content to keep the player busy","Simple mechanics clear progression and immediate feedback — quality over quantity","Photorealistic graphics created with advanced AI","Multiplayer mode supporting hundreds of players"]$$::jsonb
FROM lessons WHERE slug = 's14-criando-jogos-ia';

-- s14-criando-apps-ferramentas
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual plataforma no-code permite criar um app descrevendo o que você quer em linguagem natural?","options":["Figma","Lovable","GitHub","Zapier"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Which no-code platform allows creating an app by describing what you want in natural language?',
  $$["Figma","Lovable","GitHub","Zapier"]$$::jsonb
FROM lessons WHERE slug = 's14-criando-apps-ferramentas';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual pergunta deve guiar o design de qualquer app?","options":["Qual é a tecnologia mais avançada que posso usar?","Quantas funcionalidades posso adicionar antes do lançamento?","Qual é a única coisa que meu app faz melhor que qualquer outro?","Qual app famoso posso imitar para garantir sucesso?"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What question should guide the design of any app?',
  $$["What is the most advanced technology I can use?","How many features can I add before launch?","What is the one thing my app does better than anything else?","Which famous app can I imitate to guarantee success?"]$$::jsonb
FROM lessons WHERE slug = 's14-criando-apps-ferramentas';

-- s14-monetizacao-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é o modelo Freemium?","options":["Quando o produto é completamente gratuito financiado por anúncios","Quando o básico é gratuito e funcionalidades avançadas são pagas","Quando o produto é pago mas oferece teste gratuito de 7 dias","Quando o preço muda dependendo do país do usuário"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the Freemium model?',
  $$["When the product is completely free funded by ads","When the basics are free and advanced features are paid","When the product is paid but offers a 7-day free trial","When the price changes depending on the users country"]$$::jsonb
FROM lessons WHERE slug = 's14-monetizacao-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que cobrar cedo é importante para validar uma ideia de negócio?","options":["Porque quanto mais cedo cobrar mais dinheiro você acumula","Porque pessoas pagando é o teste mais poderoso de que o produto resolve um problema real","Porque plataformas de pagamento exigem ativação antes do lançamento","Porque gratuito atrai usuários que não dão feedback útil"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is charging early important to validate a business idea?',
  $$["Because the earlier you charge the more money you accumulate","Because people paying is the most powerful test that the product solves a real problem","Because payment platforms require activation before launch","Because free attracts users who do not give useful feedback"]$$::jsonb
FROM lessons WHERE slug = 's14-monetizacao-ia';

-- s14-construindo-marca-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma tagline?","options":["O código técnico que identifica uma marca no sistema de domínios","A frase curta de 5 a 10 palavras que resume o que uma marca faz e para quem","O slogan legal registrado em cartório","O nome do arquivo de logo em alta resolução"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is a tagline?',
  $$["The technical code that identifies a brand in the domain system","The short 5 to 10 word phrase that summarizes what a brand does and for whom","The legal slogan registered with authorities","The name of the high-resolution logo file"]$$::jsonb
FROM lessons WHERE slug = 's14-construindo-marca-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que consistência é a regra de ouro de uma marca?","options":["Porque marcas consistentes pagam menos impostos","Porque uma marca aplicada consistentemente cria reconhecimento mesmo que não seja perfeita","Porque inconsistência viola termos de uso de plataformas de IA","Porque a IA só consegue trabalhar com marcas que têm guias de identidade definidos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is consistency the golden rule of a brand?',
  $$["Because consistent brands pay less tax","Because a brand applied consistently creates recognition even if it is not perfect","Because inconsistency violates AI platform terms of use","Because AI can only work with brands that have defined identity guides"]$$::jsonb
FROM lessons WHERE slug = 's14-construindo-marca-ia';

-- s14-projeto-ao-negocio
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença fundamental entre um projeto e um negócio?","options":["Projetos usam IA e negócios não","Um projeto você faz porque gosta; um negócio resolve um problema para pessoas que pagam para tê-lo resolvido de forma sustentável","Negócios precisam de registro legal e projetos não","Projetos são menores e negócios são maiores"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the fundamental difference between a project and a business?',
  $$["Projects use AI and businesses do not","A project you do because you enjoy it; a business solves a problem for people who pay to have it solved sustainably","Businesses need legal registration and projects do not","Projects are smaller and businesses are larger"]$$::jsonb
FROM lessons WHERE slug = 's14-projeto-ao-negocio';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que falar com 5 pessoas antes de construir qualquer coisa é recomendado?","options":["Por exigência de pesquisa de mercado para registro de empresa","Porque conversas reais revelam se o problema existe e se pessoas pagariam pela solução antes de você investir tempo construindo","Porque 5 é o número mínimo de clientes para uma empresa ser viável","Porque a IA precisa dessas entrevistas para gerar o produto correto"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is talking to 5 people before building anything recommended?',
  $$["Due to market research requirement for business registration","Because real conversations reveal if the problem exists and if people would pay for the solution before you invest time building","Because 5 is the minimum number of customers for a company to be viable","Because AI needs these interviews to generate the correct product"]$$::jsonb
FROM lessons WHERE slug = 's14-projeto-ao-negocio';

-- s14-teste-missao-14 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você quer criar um jogo mobile simples de aventura. Qual combinação de ferramentas seria mais eficiente?","options":["Usar apenas ChatGPT para tudo","Claude para história e mecânicas Midjourney para arte Suno para música e GDevelop ou Cursor para o código","Usar apenas GitHub Copilot","Midjourney para tudo incluindo o código do jogo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You want to create a simple mobile adventure game. Which combination of tools would be most efficient?',
  $$["Use only ChatGPT for everything","Claude for story and mechanics Midjourney for art Suno for music and GDevelop or Cursor for code","Use only GitHub Copilot","Midjourney for everything including the game code"]$$::jsonb
FROM lessons WHERE slug = 's14-teste-missao-14';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você criou um app de organização de estudos. Amigos adoram mas ninguém quer pagar. O que isso indica?","options":["O app está com bugs que precisam ser corrigidos antes de cobrar","Você precisa cobrar para descobrir se o valor percebido é real — gostar de graça não valida se pagariam","O modelo freemium não funciona para apps educacionais","Apps para jovens nunca geram receita direta"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You created a study organization app. Friends love it but nobody wants to pay. What does this indicate?',
  $$["The app has bugs that need to be fixed before charging","You need to charge to find out if the perceived value is real — liking it for free does not validate that they would pay","The freemium model does not work for educational apps","Apps for young people never generate direct revenue"]$$::jsonb
FROM lessons WHERE slug = 's14-teste-missao-14';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s14-criando-jogos-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria meu jogo', 'Quero criar um jogo de [gênero/tema]. Me ajuda a desenvolver: mecânica principal, personagem central, objetivo do jogo e as primeiras 3 fases.', '6-18', 1
FROM lessons WHERE slug = 's14-criando-jogos-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Balanceia meu jogo', 'Meu jogo tem [descreve mecânicas]. Como balancear a dificuldade para que seja desafiador mas não frustrante?', '6-18', 2
FROM lessons WHERE slug = 's14-criando-jogos-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'História do jogo', 'Me ajuda a criar uma história envolvente para um jogo de [gênero] com [personagem]. Inclui conflito, missão e final.', '6-18', 3
FROM lessons WHERE slug = 's14-criando-jogos-ia';

-- s14-criando-apps-ferramentas
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Design do meu app', 'Quero criar um app de [categoria]. Me ajuda a definir: a única funcionalidade central, o usuário ideal e o fluxo das 3 telas principais.', '6-18', 1
FROM lessons WHERE slug = 's14-criando-apps-ferramentas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'MVP do app', 'Meu app vai [função completa]. Me ajuda a definir o MVP — o mínimo que precisa funcionar para testar se a ideia vale.', '6-18', 2
FROM lessons WHERE slug = 's14-criando-apps-ferramentas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Ferramenta certa', 'Quero criar [tipo de app]. Qual ferramenta no-code seria melhor: Lovable, Bubble, FlutterFlow ou Glide? Por quê?', '6-18', 3
FROM lessons WHERE slug = 's14-criando-apps-ferramentas';

-- s14-monetizacao-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Modelo de negócio', 'Meu produto é [descreve]. Qual modelo de monetização faz mais sentido: freemium, assinatura, venda única ou serviço? Por quê?', '6-18', 1
FROM lessons WHERE slug = 's14-monetizacao-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Primeiros clientes', 'Estou lançando [produto]. Me ajuda a criar uma estratégia para conseguir os primeiros 10 clientes pagantes.', '6-18', 2
FROM lessons WHERE slug = 's14-monetizacao-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quanto cobrar?', 'Meu produto é [descreve] e resolve [problema]. Qual seria um preço justo e como eu poderia validar que as pessoas pagariam isso?', '6-18', 3
FROM lessons WHERE slug = 's14-monetizacao-ia';

-- s14-construindo-marca-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria minha marca', 'Meu projeto é [descreve] para [público]. Me ajuda a criar: 5 opções de nome, 3 taglines, tom de voz e paleta de cores sugerida.', '6-18', 1
FROM lessons WHERE slug = 's14-construindo-marca-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'História da marca', 'Criei [projeto] porque [motivação]. Me ajuda a transformar isso numa história de marca autêntica e convincente.', '6-18', 2
FROM lessons WHERE slug = 's14-construindo-marca-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Tom de voz', 'Minha marca é [descreve]. Me ajuda a definir o tom de voz com 5 exemplos de frases que mostram como ela fala.', '6-18', 3
FROM lessons WHERE slug = 's14-construindo-marca-ia';

-- s14-projeto-ao-negocio
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, '5 elementos do negócio', 'Minha ideia de negócio é [descreve]. Me ajuda a definir os 5 elementos: produto, cliente ideal, canal, modelo de receita e operação.', '6-18', 1
FROM lessons WHERE slug = 's14-projeto-ao-negocio';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Entrevista de validação', 'Quero validar minha ideia com potenciais clientes. Me ajuda a criar 5 perguntas para descobrir se pagariam pela solução.', '6-18', 2
FROM lessons WHERE slug = 's14-projeto-ao-negocio';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Primeiros passos', 'Tenho essa ideia de negócio: [descreve]. Quais são os 3 primeiros passos concretos que devo dar essa semana?', '6-18', 3
FROM lessons WHERE slug = 's14-projeto-ao-negocio';

COMMIT;
