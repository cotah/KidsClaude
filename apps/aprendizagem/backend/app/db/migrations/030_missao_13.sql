-- Migration 030: Insere conteudo da Stage 13 "Missao 13 - Criar projetos reais"
--
-- Foco: metodo de criar projetos com IA - 5 etapas (problema/usuario/MVP/
-- ferramentas/iterar), prototipagem rapida (texto/wireframe/mockup/funcional),
-- ciclo de feedback e iteracao, documentacao e apresentacao (problema/
-- solucao/demo/impacto), e projetos com impacto real na vida das pessoas.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=13, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 13
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's13-da-ideia-ao-projeto',
  'Da ideia ao projeto — o método certo',
  'From idea to project — the right method',
  'Aprender o método de 5 etapas para transformar qualquer ideia em projeto real',
  'Learn the 5-step method to transform any idea into a real project',
  '6-18', 13, 1,
  $$[
    {"type":"text","content":"A maioria das pessoas que quer criar algo com IA trava no começo por falta de método. O método que transforma ideia em projeto real tem 5 etapas. ETAPA 1 — DEFINIR O PROBLEMA COM CLAREZA: não quero criar um app, mas quero criar um app que ajuda estudantes de 12-16 anos a revisar matemática de forma gamificada em 5 minutos por dia. ETAPA 2 — IDENTIFICAR O USUÁRIO: quem vai usar? Que problema essa pessoa tem hoje?"},
    {"type":"text","content":"ETAPA 3 — DEFINIR O MVP: MVP significa Minimum Viable Product — Produto Mínimo Viável. É a versão mais simples que ainda resolve o problema. Não tente fazer tudo de uma vez. ETAPA 4 — ESCOLHER AS FERRAMENTAS: qual IA vai usar? Qual plataforma? No-code, low-code ou programação? ETAPA 5 — CONSTRUIR, TESTAR, MELHORAR: construa a versão mais simples. Mostre para alguém. Pegue feedback. Melhore. Repita."},
    {"type":"text","content":"A IA não substitui esse método — ela acelera cada etapa dele. Com IA você define problemas mais rápido, prototipa em horas em vez de semanas, e analisa feedback em minutos. Mas o método continua sendo humano."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Most people who want to create something with AI get stuck at the beginning for lack of method. The method that transforms an idea into a real project has 5 steps. STEP 1 — DEFINE THE PROBLEM CLEARLY: not I want to create an app, but I want to create an app that helps 12-16 year old students review math in a gamified way in 5 minutes per day. STEP 2 — IDENTIFY THE USER: who will use it? What problem does this person have today?"},
    {"type":"text","content":"STEP 3 — DEFINE THE MVP: MVP stands for Minimum Viable Product. It is the simplest version that still solves the problem. Do not try to do everything at once. STEP 4 — CHOOSE THE TOOLS: which AI will you use? Which platform? No-code, low-code or programming? STEP 5 — BUILD, TEST, IMPROVE: build the simplest version. Show it to someone. Get feedback. Improve. Repeat."},
    {"type":"text","content":"AI does not replace this method — it accelerates each step of it. With AI you define problems faster, prototype in hours instead of weeks, and analyze feedback in minutes. But the method remains human."}
  ]$$::jsonb,
  'A criança tem uma ideia de projeto e a Atena guia pelas 5 etapas do método ajudando a refinar até ter um plano claro e realizável.',
  'The child has a project idea and Atena guides through the 5 steps of the method helping refine until there is a clear and achievable plan.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's13-prototipagem-rapida',
  'Prototipagem rápida com IA',
  'Rapid prototyping with AI',
  'Aprender a criar protótipos rápidos para testar ideias antes de construir',
  'Learn to create rapid prototypes to test ideas before building',
  '6-18', 13, 2,
  $$[
    {"type":"text","content":"Com IA a velocidade de prototipagem aumentou dramaticamente. O que levava semanas agora leva horas. Tipos de protótipo: PROTÓTIPO DE TEXTO — você descreve o produto em palavras. A IA escreve a copy, os textos das telas, os fluxos. Você entende se a ideia faz sentido sem escrever uma linha de código. WIREFRAME — um esboço das telas sem design. Ferramentas como Figma com plugins de IA criam wireframes a partir de descrições."},
    {"type":"text","content":"MOCKUP VISUAL — uma versão com design mas sem funcionalidade. Mostra como vai ficar visualmente. PROTÓTIPO FUNCIONAL — uma versão que realmente funciona, mas simples. Com ferramentas como Lovable você cria isso sem programar. O princípio do protótipo: melhor descobrir que a ideia não funciona em 2 horas do que depois de 2 meses de trabalho."},
    {"type":"text","content":"O objetivo do protótipo não é ser perfeito — é ser rápido o suficiente para aprender. Mostre para 5 pessoas do seu público-alvo. As reações delas vão ensinar mais do que qualquer quantidade de planejamento."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"With AI the speed of prototyping has increased dramatically. What took weeks now takes hours. Types of prototype: TEXT PROTOTYPE — you describe the product in words. AI writes the copy, screen texts, flows. You understand if the idea makes sense without writing a line of code. WIREFRAME — a sketch of the screens without design. Tools like Figma with AI plugins create wireframes from descriptions."},
    {"type":"text","content":"VISUAL MOCKUP — a version with design but without functionality. Shows how it will look visually. FUNCTIONAL PROTOTYPE — a version that actually works, but simple. With tools like Lovable you create this without programming. The prototype principle: better to discover the idea does not work in 2 hours than after 2 months of work."},
    {"type":"text","content":"The goal of the prototype is not to be perfect — it is to be fast enough to learn. Show it to 5 people from your target audience. Their reactions will teach more than any amount of planning."}
  ]$$::jsonb,
  'A criança escolhe um projeto e a Atena ajuda a criar um protótipo de texto completo — telas fluxos e copy — em uma única conversa.',
  'The child picks a project and Atena helps create a complete text prototype — screens flows and copy — in a single conversation.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's13-feedback-iteracao',
  'Feedback, iteração e como melhorar',
  'Feedback, iteration and how to improve',
  'Aprender o ciclo de feedback e como usar IA para melhorar projetos rapidamente',
  'Learn the feedback cycle and how to use AI to improve projects quickly',
  '6-18', 13, 3,
  $$[
    {"type":"text","content":"O maior erro de quem cria pela primeira vez é ter medo de mostrar o trabalho antes de estar perfeito. O problema: perfeito nunca chega. O ciclo de feedback: 1) construa a versão mais simples possível. 2) Mostre para pessoas reais do seu público. 3) Observe como elas usam sem explicar — deixe descobrirem sozinhas. 4) Anote o que confunde, encanta ou frustra. 5) Melhore a parte mais problemática. 6) Repita."},
    {"type":"text","content":"Como usar IA no ciclo de feedback: a IA pode analisar feedback qualitativo — você coleta comentários e pede para a IA identificar padrões. Aqui estão 20 respostas de usuários. Quais são os 3 problemas mais comuns? A IA pode sugerir soluções: meu usuário não entendeu como começar, quais são 5 formas de tornar o onboarding mais claro?"},
    {"type":"text","content":"A IA pode escrever variações: escreve 3 versões diferentes para esse texto de boas-vindas e eu vou testar qual funciona melhor. O princípio central: você não sabe o que funciona — você testa o que funciona. A IA acelera os testes."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"The biggest mistake of first-time creators is being afraid to show work before it is perfect. The problem: perfect never arrives. The feedback cycle: 1) build the simplest version possible. 2) Show it to real people from your audience. 3) Watch how they use it without explaining — let them discover on their own. 4) Note what confuses, delights or frustrates. 5) Improve the most problematic part. 6) Repeat."},
    {"type":"text","content":"How to use AI in the feedback cycle: AI can analyze qualitative feedback — you collect comments and ask AI to identify patterns. Here are 20 user responses. What are the 3 most common problems? AI can suggest solutions: my user did not understand how to start, what are 5 ways to make onboarding clearer?"},
    {"type":"text","content":"AI can write variations: write 3 different versions of this welcome text and I will test which works best. The central principle: you do not know what works — you test what works. AI accelerates the tests."}
  ]$$::jsonb,
  'A criança descreve feedback negativo que recebeu e a Atena ajuda a transformar cada crítica em uma melhoria concreta.',
  'The child describes negative feedback they received and Atena helps transform each criticism into a concrete improvement.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's13-documentacao-apresentacao',
  'Documentação e apresentação do projeto',
  'Documentation and project presentation',
  'Aprender a comunicar projetos de forma clara e convincente',
  'Learn to communicate projects clearly and convincingly',
  '6-18', 13, 4,
  $$[
    {"type":"text","content":"Um projeto incrível que ninguém entende não vai a lugar nenhum. Os 4 elementos da apresentação de projeto: 1) O PROBLEMA — que dor você está resolvendo? Por que importa? Quem sofre com isso hoje? 2) A SOLUÇÃO — o que você criou? Como funciona? O que torna especial? 3) A DEMONSTRAÇÃO — mostrar é mais poderoso que explicar. Uma demo de 2 minutos vale mais que 10 minutos de slides. 4) O IMPACTO — o que muda para quem usa?"},
    {"type":"text","content":"Como usar IA para comunicar melhor: a IA pode ajudar a escrever o pitch — você descreve o projeto e pede: escreve um pitch de 2 parágrafos para um professor de 40 anos que não tem experiência com IA. A IA pode ajudar a criar o README — a documentação técnica. A IA pode criar slides — roteiro, estrutura e textos."},
    {"type":"text","content":"A regra de ouro da apresentação: fale sobre o usuário, não sobre você. Não eu criei um app incrível com IA. Mas estudantes de matemática passavam 30 minutos frustrantes tentando revisar e meu app transformou isso em 5 minutos divertidos."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"An incredible project that nobody understands goes nowhere. The 4 elements of project presentation: 1) THE PROBLEM — what pain are you solving? Why does it matter? Who suffers from it today? 2) THE SOLUTION — what did you create? How does it work? What makes it special? 3) THE DEMONSTRATION — showing is more powerful than explaining. A 2-minute demo is worth more than 10 minutes of slides. 4) THE IMPACT — what changes for those who use it?"},
    {"type":"text","content":"How to use AI to communicate better: AI can help write the pitch — you describe the project and ask: write a 2-paragraph pitch for a 40-year-old teacher with no AI experience. AI can help create the README — the technical documentation. AI can create slides — script, structure and texts."},
    {"type":"text","content":"The golden rule of presentation: talk about the user, not about yourself. Not I created an amazing app with AI. But math students spent 30 frustrating minutes trying to review and my app transformed that into 5 fun minutes."}
  ]$$::jsonb,
  'A criança descreve um projeto e a Atena ajuda a montar o pitch completo — problema solução demo e impacto — em linguagem clara e convincente.',
  'The child describes a project and Atena helps build the complete pitch — problem solution demo and impact — in clear and convincing language.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's13-projetos-impacto-real',
  'Projetos que fazem diferença — impacto real',
  'Projects that make a difference — real impact',
  'Aprender a encontrar ideias de projeto com impacto real na vida das pessoas',
  'Learn to find project ideas with real impact on peoples lives',
  '6-18', 13, 5,
  $$[
    {"type":"text","content":"Os melhores projetos não são os mais tecnicamente complexos. São os que resolvem um problema real para pessoas reais. Você não precisa ser adulto para criar algo com impacto. Com IA as barreiras nunca foram tão baixas. Como encontrar ideias com impacto: OBSERVE SUA PRÓPRIA VIDA — qual é o maior problema que você enfrenta na escola, em casa, no esporte, no hobby? Se você tem esse problema, provavelmente outras pessoas têm."},
    {"type":"text","content":"OBSERVE SUA COMUNIDADE — qual problema você vê ao redor? Na sua rua, escola, no grupo que você frequenta? PERGUNTE PARA QUEM VOCÊ QUER AJUDAR — a melhor pesquisa de produto é uma conversa de 20 minutos com uma pessoa do seu público. Qual é a parte mais difícil de X para você? COMECE PEQUENO, PENSE GRANDE — um projeto que ajuda 10 pessoas muito bem é melhor que um que ajuda 1000 pessoas mal."},
    {"type":"text","content":"A pergunta que deve guiar todo projeto: a vida de alguém vai ser melhor por causa disso? Se a resposta for sim, você tem uma ideia que vale a pena construir. Com IA como ferramenta, sua geração tem o poder de criar soluções que gerações anteriores levavam décadas para desenvolver."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"The best projects are not the most technically complex. They are the ones that solve a real problem for real people. You do not need to be an adult to create something with impact. With AI the barriers have never been lower. How to find impactful ideas: OBSERVE YOUR OWN LIFE — what is the biggest problem you face at school, at home, in sports, in a hobby? If you have that problem, others probably do too."},
    {"type":"text","content":"OBSERVE YOUR COMMUNITY — what problem do you see around you? In your street, school, the group you frequent? ASK THOSE YOU WANT TO HELP — the best product research is a 20-minute conversation with someone from your audience. What is the hardest part of X for you? START SMALL, THINK BIG — a project that helps 10 people very well is better than one that helps 1000 people poorly."},
    {"type":"text","content":"The question that should guide every project: will someones life be better because of this? If the answer is yes, you have an idea worth building. With AI as a tool, your generation has the power to create solutions that previous generations took decades to develop."}
  ]$$::jsonb,
  'A criança identifica um problema real na própria vida ou comunidade e a Atena ajuda a transformar esse problema em uma ideia de projeto concreto com IA.',
  'The child identifies a real problem in their own life or community and Atena helps transform that problem into a concrete project idea with AI.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's13-teste-missao-13',
  'Teste — Missão 13',
  'Test — Mission 13',
  'Quiz para fechar a Missão 13',
  'Quiz to complete Mission 13',
  '6-18', 13, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 13! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 13! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s13-da-ideia-ao-projeto
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é MVP — Minimum Viable Product?","options":["O produto mais caro e completo possível","A versão mais simples que ainda resolve o problema permitindo testar e aprender rápido","Um produto criado apenas por máquinas sem intervenção humana","O produto mais popular de uma categoria"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is MVP — Minimum Viable Product?',
  $$["The most expensive and complete product possible","The simplest version that still solves the problem allowing fast testing and learning","A product created only by machines without human intervention","The most popular product in a category"]$$::jsonb
FROM lessons WHERE slug = 's13-da-ideia-ao-projeto';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que definir o usuário claramente é importante antes de começar a criar?","options":["Porque plataformas de no-code exigem essa informação","Porque entender quem vai usar e qual problema tem é o que define todas as decisões de design do produto","Porque a IA não funciona sem saber o usuário alvo","Por exigência de privacidade de dados"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is clearly defining the user important before starting to create?',
  $$["Because no-code platforms require this information","Because understanding who will use it and what problem they have is what defines all product design decisions","Because AI does not work without knowing the target user","Due to data privacy requirements"]$$::jsonb
FROM lessons WHERE slug = 's13-da-ideia-ao-projeto';

-- s13-prototipagem-rapida
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o principal objetivo de um protótipo?","options":["Criar a versão final do produto o mais rápido possível","Descobrir se a ideia funciona de forma rápida e barata antes de investir muito tempo e recursos","Impressionar investidores com design profissional","Treinar a IA que vai ser usada no produto"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the main objective of a prototype?',
  $$["Create the final product version as fast as possible","Discover if the idea works fast and cheaply before investing a lot of time and resources","Impress investors with professional design","Train the AI that will be used in the product"]$$::jsonb
FROM lessons WHERE slug = 's13-prototipagem-rapida';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que mostrar o protótipo para pessoas do público-alvo é essencial?","options":["Por exigência legal antes de lançar qualquer produto","Porque as reações reais de quem vai usar ensinam mais do que qualquer planejamento","Porque a IA precisa de feedback humano para melhorar","Para cumprir requisitos de acessibilidade"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is showing the prototype to target audience people essential?',
  $$["Legal requirement before launching any product","Because real reactions from those who will use it teach more than any planning","Because AI needs human feedback to improve","To meet accessibility requirements"]$$::jsonb
FROM lessons WHERE slug = 's13-prototipagem-rapida';

-- s13-feedback-iteracao
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que observar como as pessoas usam o protótipo sem explicar é mais valioso?","options":["Porque economiza tempo na sessão de feedback","Porque revela problemas reais de usabilidade que só aparecem quando a pessoa descobre sozinha sem guia","Porque a IA não consegue processar feedback com explicações","Por regras de privacidade nas sessões de teste"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is observing how people use the prototype without explaining more valuable?',
  $$["Because it saves time in the feedback session","Because it reveals real usability problems that only appear when the person discovers it alone without guidance","Because AI cannot process feedback with explanations","Due to privacy rules in test sessions"]$$::jsonb
FROM lessons WHERE slug = 's13-feedback-iteracao';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como a IA pode ajudar a analisar feedback de usuários?","options":["Substituindo completamente as entrevistas com usuários","Identificando padrões em múltiplos comentários e sugerindo soluções para os problemas mais comuns","Gerando avaliações automáticas positivas para o produto","Prevendo com precisão como os usuários vão reagir antes do teste"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'How can AI help analyze user feedback?',
  $$["By completely replacing user interviews","By identifying patterns in multiple comments and suggesting solutions to the most common problems","By generating automatic positive reviews for the product","By precisely predicting how users will react before testing"]$$::jsonb
FROM lessons WHERE slug = 's13-feedback-iteracao';

-- s13-documentacao-apresentacao
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que uma demonstração de 2 minutos vale mais que 10 minutos de slides?","options":["Porque slides são tecnologia antiga e IA não consegue criá-los","Porque mostrar o produto funcionando cria compreensão e convicção que nenhuma explicação consegue","Porque apresentações longas cansam a IA que processa o feedback","Por regras de tempo em competições de projetos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is a 2-minute demonstration worth more than 10 minutes of slides?',
  $$["Because slides are old technology and AI cannot create them","Because showing the product working creates understanding and conviction that no explanation can","Because long presentations tire the AI processing the feedback","Due to time rules in project competitions"]$$::jsonb
FROM lessons WHERE slug = 's13-documentacao-apresentacao';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a regra de ouro da apresentação de projeto?","options":["Sempre mencionar quantas horas você trabalhou no projeto","Falar sobre o usuário e o impacto na vida dele não sobre você e a tecnologia que usou","Listar todas as ferramentas de IA que você usou","Começar com a parte técnica mais complexa para impressionar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the golden rule of project presentation?',
  $$["Always mention how many hours you worked on the project","Talk about the user and the impact on their life not about you and the technology you used","List all the AI tools you used","Start with the most complex technical part to impress"]$$::jsonb
FROM lessons WHERE slug = 's13-documentacao-apresentacao';

-- s13-projetos-impacto-real
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que observar sua própria vida é uma boa fonte de ideias de projeto?","options":["Porque projetos pessoais são mais fáceis de apresentar","Porque se você tem um problema provavelmente outras pessoas têm também tornando a solução relevante","Porque a IA funciona melhor com problemas que você conhece pessoalmente","Por exigência de autenticidade nas competições de projetos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is observing your own life a good source of project ideas?',
  $$["Because personal projects are easier to present","Because if you have a problem others probably have it too making the solution relevant","Because AI works better with problems you know personally","Due to authenticity requirements in project competitions"]$$::jsonb
FROM lessons WHERE slug = 's13-projetos-impacto-real';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que um projeto que ajuda 10 pessoas muito bem é melhor que um que ajuda 1000 mal?","options":["Porque projetos pequenos são mais fáceis de apresentar para professores","Porque impacto real e profundo em poucas pessoas cria aprendizado genuíno e base para escalar depois","Porque a IA não consegue escalar para 1000 usuários","Por restrições de licença de uso das ferramentas de IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is a project that helps 10 people very well better than one that helps 1000 poorly?',
  $$["Because small projects are easier to present to teachers","Because deep real impact on few people creates genuine learning and foundation to scale later","Because AI cannot scale to 1000 users","Due to license restrictions on AI tools"]$$::jsonb
FROM lessons WHERE slug = 's13-projetos-impacto-real';

-- s13-teste-missao-13 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você tem uma ideia de app mas não sabe por onde começar. Qual é o primeiro passo correto?","options":["Abrir o Lovable e começar a construir imediatamente","Definir o problema com clareza — quem tem esse problema qual é exatamente e por que as soluções atuais não funcionam","Pesquisar qual IA tem a API mais barata","Criar o design visual completo antes de qualquer outra coisa"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You have an app idea but do not know where to start. What is the correct first step?',
  $$["Open Lovable and start building immediately","Define the problem clearly — who has this problem what exactly it is and why current solutions do not work","Research which AI has the cheapest API","Create the complete visual design before anything else"]$$::jsonb
FROM lessons WHERE slug = 's13-teste-missao-13';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você mostrou seu protótipo para 5 pessoas e todas ficaram confusas sobre como começar. O que você faz?","options":["Adiciona uma explicação longa na tela inicial descrevendo todas as funcionalidades","Conclui que o projeto é ruim e começa uma ideia diferente","Usa o feedback para melhorar especificamente o onboarding — a primeira experiência do usuário","Pede para a IA reescrever todo o projeto do zero"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'You showed your prototype to 5 people and all got confused about how to start. What do you do?',
  $$["Add a long explanation on the home screen describing all features","Conclude the project is bad and start a different idea","Use the feedback to specifically improve the onboarding — the first user experience","Ask AI to rewrite the entire project from scratch"]$$::jsonb
FROM lessons WHERE slug = 's13-teste-missao-13';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s13-da-ideia-ao-projeto
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Refina minha ideia', 'Tenho essa ideia de projeto: [descreve]. Me ajuda a passar pelas 5 etapas do método — problema, usuário, MVP, ferramentas e plano.', '6-18', 1
FROM lessons WHERE slug = 's13-da-ideia-ao-projeto';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quem é meu usuário?', 'Meu projeto é [descreve]. Me ajuda a definir claramente quem é o usuário, qual problema tem e o que já tentou.', '6-18', 2
FROM lessons WHERE slug = 's13-da-ideia-ao-projeto';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual é meu MVP?', 'Quero criar [projeto completo]. Me ajuda a definir o MVP — a versão mais simples que ainda resolveria o problema principal.', '6-18', 3
FROM lessons WHERE slug = 's13-da-ideia-ao-projeto';

-- s13-prototipagem-rapida
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Protótipo de texto', 'Quero criar [produto]. Me ajuda a criar um protótipo de texto com as 3 telas principais, o fluxo do usuário e os textos de cada tela.', '6-18', 1
FROM lessons WHERE slug = 's13-prototipagem-rapida';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Estrutura do MVP', 'Meu MVP é [descreve]. Quais são as funcionalidades mínimas indispensáveis e quais posso deixar para depois?', '6-18', 2
FROM lessons WHERE slug = 's13-prototipagem-rapida';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como testar rápido', 'Tenho esse protótipo: [descreve]. Como posso testá-lo com 5 pessoas de forma rápida e aprender o máximo possível?', '6-18', 3
FROM lessons WHERE slug = 's13-prototipagem-rapida';

-- s13-feedback-iteracao
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Analisa meu feedback', 'Recebi esses comentários dos usuários: [lista]. Quais são os 3 problemas mais comuns e o que devo melhorar primeiro?', '6-18', 1
FROM lessons WHERE slug = 's13-feedback-iteracao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Transforma crítica em melhoria', 'Meu usuário disse: [feedback negativo]. Quais são 3 formas de melhorar isso no projeto?', '6-18', 2
FROM lessons WHERE slug = 's13-feedback-iteracao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa variações', 'Preciso de 3 versões diferentes de [texto ou feature] para testar qual funciona melhor com meus usuários.', '6-18', 3
FROM lessons WHERE slug = 's13-feedback-iteracao';

-- s13-documentacao-apresentacao
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Escreve meu pitch', 'Meu projeto é [descreve]. Escreve um pitch de 2 parágrafos para [público específico] focando no problema e no impacto.', '6-18', 1
FROM lessons WHERE slug = 's13-documentacao-apresentacao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Estrutura de apresentação', 'Tenho [X minutos] para apresentar meu projeto [descreve]. Me ajuda a criar a estrutura ideal para esse tempo.', '6-18', 2
FROM lessons WHERE slug = 's13-documentacao-apresentacao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'README do projeto', 'Me ajuda a criar um README claro para o meu projeto [descreve] explicando o que é, como funciona e como usar.', '6-18', 3
FROM lessons WHERE slug = 's13-documentacao-apresentacao';

-- s13-projetos-impacto-real
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Encontra minha ideia', 'Me ajuda a encontrar um problema real na minha vida que eu poderia resolver com IA. Me faz 3 perguntas para descobrir.', '6-18', 1
FROM lessons WHERE slug = 's13-projetos-impacto-real';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Problema vira projeto', 'Percebi esse problema: [descreve]. Me ajuda a transformar isso numa ideia de projeto concreto e realizável.', '6-18', 2
FROM lessons WHERE slug = 's13-projetos-impacto-real';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Entrevista de usuário', 'Quero entrevistar [perfil de pessoa] sobre o problema [descreve]. Me ajuda a criar 5 perguntas para descobrir o máximo possível.', '6-18', 3
FROM lessons WHERE slug = 's13-projetos-impacto-real';

COMMIT;
