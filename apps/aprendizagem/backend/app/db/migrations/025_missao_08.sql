-- Migration 025: Insere conteudo da Stage 8 "Missao 08 - IA para resolver problemas"
--
-- Foco: usar IA pra resolver problemas reais - organizar a vida (habitos/
-- metas/rotina), resolver problemas como parceira de raciocinio (5 passos),
-- criar negocios e ideias (democratizacao), ajudar pessoas e problemas
-- sociais, IA como superpoder humano que amplifica o que voce ja' e'.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=8, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 8
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's8-ia-organizar-vida',
  'IA para organizar sua vida',
  'AI to organize your life',
  'Aprender a usar IA para criar sistemas de organização pessoal',
  'Learn to use AI to create personal organization systems',
  '6-18', 8, 1,
  $$[
    {"type":"text","content":"A IA pode ajudar a organizar sua vida inteira de um jeito que antes só era possível com um assistente pessoal. A maioria das pessoas vive em modo reativo — fazendo o que aparece, não o que planejou. Com IA você pode criar sistemas simples que mudam isso. LISTA DE PRIORIDADES: você descreve tudo que precisa fazer e a IA ajuda a ordenar por importância e urgência."},
    {"type":"text","content":"SISTEMA DE HÁBITOS: você fala quais hábitos quer criar e a IA monta um plano progressivo e realista. Não corra 10km amanhã — mas caminhe 10 minutos por 2 semanas, depois 20 minutos. PLANO DE METAS: você tem um sonho grande e a IA ajuda a quebrar em passos pequenos e concretos. ROTINA PERSONALIZADA: a IA cria uma rotina baseada nos seus objetivos e tempo disponível."},
    {"type":"text","content":"A IA não vai fazer as coisas por você. Mas vai ajudar você a pensar mais claro e agir com mais direção. O sistema é da IA. A execução é sua."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI can help organize your entire life in a way that before was only possible with a personal assistant. Most people live in reactive mode — doing what comes up, not what they planned. With AI you can create simple systems that change this. PRIORITY LIST: you describe everything you need to do and AI helps order by importance and urgency."},
    {"type":"text","content":"HABIT SYSTEM: you say which habits you want to create and AI builds a progressive and realistic plan. Not run 10km tomorrow — but walk 10 minutes for 2 weeks, then 20 minutes. GOAL PLAN: you have a big dream and AI helps break it into small concrete steps. PERSONALIZED ROUTINE: AI creates a routine based on your goals and available time."},
    {"type":"text","content":"AI will not do things for you. But it will help you think more clearly and act with more direction. The system is from AI. The execution is yours."}
  ]$$::jsonb,
  'A criança descreve 3 objetivos pessoais e a Atena ajuda a criar um plano com passos concretos e uma rotina simples para começar.',
  'The child describes 3 personal goals and Atena helps create a plan with concrete steps and a simple routine to start.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's8-ia-resolver-problemas',
  'IA para resolver problemas do mundo real',
  'AI to solve real world problems',
  'Aprender a usar IA como parceira de raciocínio para resolver problemas',
  'Learn to use AI as a reasoning partner to solve problems',
  '6-18', 8, 2,
  $$[
    {"type":"text","content":"Uma das habilidades mais valiosas é saber resolver problemas. E a IA pode ser uma parceira extraordinária nesse processo. Mas existe uma forma certa e uma errada. FORMA ERRADA: você tem um problema, pede para a IA resolver, copia a solução. FORMA CERTA: você usa a IA como parceira de raciocínio, analisa as opções juntos, você decide a melhor solução para o seu contexto."},
    {"type":"text","content":"A diferença é fundamental. A IA não conhece todos os detalhes do seu problema. Ela não sabe suas restrições, seus valores, seu contexto. Pode gerar soluções que parecem boas em geral mas não funcionam para você. O processo ideal: 1) descreva o problema com todos os detalhes 2) peça múltiplas soluções 3) pergunte os prós e contras de cada uma 4) filtre pelas suas restrições reais 5) escolha e refine."},
    {"type":"text","content":"Você é o decisor. A IA é a geradora de opções. Essa distinção é fundamental para usar IA de forma inteligente e responsável."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"One of the most valuable skills is knowing how to solve problems. And AI can be an extraordinary partner in this process. But there is a right and a wrong way. WRONG WAY: you have a problem, ask AI to solve it, copy the solution. RIGHT WAY: you use AI as a reasoning partner, analyze options together, you decide the best solution for your context."},
    {"type":"text","content":"The difference is fundamental. AI does not know all the details of your problem. It does not know your restrictions, values, context. It can generate solutions that seem good in general but do not work for you. The ideal process: 1) describe the problem with all details 2) ask for multiple solutions 3) ask pros and cons of each 4) filter by your real restrictions 5) choose and refine."},
    {"type":"text","content":"You are the decision maker. AI is the options generator. This distinction is fundamental to using AI intelligently and responsibly."}
  ]$$::jsonb,
  'A criança descreve um problema real e a Atena guia o processo dos 5 passos — listando soluções, analisando prós e contras e ajudando a decidir.',
  'The child describes a real problem and Atena guides the 5-step process — listing solutions, analyzing pros and cons and helping decide.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's8-ia-criar-negocios-ideias',
  'IA para criar negócios e ideias',
  'AI to create businesses and ideas',
  'Descobrir como usar IA para transformar ideias em projetos reais',
  'Discover how to use AI to transform ideas into real projects',
  '6-18', 8, 3,
  $$[
    {"type":"text","content":"Uma das coisas mais empolgantes sobre IA é que ela democratizou a criação. Hoje uma criança com uma boa ideia e acesso à IA pode criar coisas que antes exigiam uma equipe inteira. O que você pode criar: CANAL OU MARCA DIGITAL — logo, nome, identidade visual, estratégia de conteúdo, roteiros. PEQUENO NEGÓCIO — nome, pitch de vendas, estratégia de preço e primeiras mensagens para clientes."},
    {"type":"text","content":"APP OU SITE SIMPLES — com ferramentas como Lovable, você descreve o que quer e a IA constrói. PROJETO ESCOLAR DE IMPACTO — IA ajuda a pesquisar, estruturar, criar apresentação e simular cenários. CAMPANHA PARA UMA CAUSA — mensagens, argumentos, material visual e estratégia para espalhar uma ideia."},
    {"type":"text","content":"A IA não vai ter a ideia por você. Mas vai amplificar qualquer ideia boa que você tiver de um jeito incrível. A ideia ainda precisa ser humana — a execução pode ser turbinada pela IA."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"One of the most exciting things about AI is that it democratized creation. Today a child with a good idea and access to AI can create things that before required an entire team. What you can create: DIGITAL CHANNEL OR BRAND — logo, name, visual identity, content strategy, scripts. SMALL BUSINESS — name, sales pitch, pricing strategy and first messages for clients."},
    {"type":"text","content":"SIMPLE APP OR WEBSITE — with tools like Lovable, you describe what you want and AI builds it. HIGH IMPACT SCHOOL PROJECT — AI helps research, structure, create presentation and simulate scenarios. CAMPAIGN FOR A CAUSE — messages, arguments, visual material and strategy to spread an idea."},
    {"type":"text","content":"AI will not have the idea for you. But it will amplify any good idea you have in an incredible way. The idea still needs to be human — the execution can be turbocharged by AI."}
  ]$$::jsonb,
  'A criança descreve uma ideia de negócio ou projeto. A Atena ajuda a desenvolver nome, missão e primeiros passos concretos.',
  'The child describes a business idea or project. Atena helps develop name, mission and first concrete steps.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's8-ia-ajudar-pessoas',
  'IA para ajudar pessoas e resolver problemas sociais',
  'AI to help people and solve social problems',
  'Descobrir como IA está sendo usada para resolver os maiores desafios da humanidade',
  'Discover how AI is being used to solve humanity greatest challenges',
  '6-18', 8, 4,
  $$[
    {"type":"text","content":"A IA mais poderosa não é aquela que faz mais coisas para você. É aquela que você usa para fazer coisas para os outros. IA já está sendo usada para resolver alguns dos maiores problemas da humanidade. SAÚDE: IA detecta câncer em exames antes que médicos consigam ver, ajuda a desenvolver remédios em meses em vez de anos, traduz informações médicas para pessoas que não falam o idioma local."},
    {"type":"text","content":"EDUCAÇÃO: IA personaliza o aprendizado para crianças com necessidades especiais e leva educação de qualidade para regiões sem professores suficientes. ACESSIBILIDADE: IA converte texto em voz para pessoas cegas, traduz linguagem de sinais em tempo real e ajuda pessoas com dificuldades de comunicação. MEIO AMBIENTE: IA monitora desmatamento por satélite e prevê desastres naturais com mais precisão."},
    {"type":"text","content":"Você tem uma ideia de como usar IA para ajudar alguém ou resolver um problema real? Isso é o tipo de pensamento que vai definir a próxima geração de criadores. A tecnologia mais poderosa é aquela colocada a serviço das pessoas."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"The most powerful AI is not the one that does the most things for you. It is the one you use to do things for others. AI is already being used to solve some of humanity greatest challenges. HEALTH: AI detects cancer in scans before doctors can see it, helps develop medicines in months instead of years, translates medical information for people who do not speak the local language."},
    {"type":"text","content":"EDUCATION: AI personalizes learning for children with special needs and brings quality education to regions without enough teachers. ACCESSIBILITY: AI converts text to voice for blind people, translates sign language in real time and helps people with communication difficulties. ENVIRONMENT: AI monitors deforestation by satellite and predicts natural disasters more accurately."},
    {"type":"text","content":"Do you have an idea of how to use AI to help someone or solve a real problem? That is the type of thinking that will define the next generation of creators. The most powerful technology is the one placed at the service of people."}
  ]$$::jsonb,
  'A criança escolhe um problema social que a preocupa e a Atena ajuda a imaginar como IA poderia ser usada para ajudar.',
  'The child picks a social problem they care about and Atena helps imagine how AI could be used to help.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's8-ia-superpoder-humano',
  'IA como superpoder humano',
  'AI as a human superpower',
  'Entender como a IA amplifica o que você já é',
  'Understand how AI amplifies what you already are',
  '6-18', 8, 5,
  $$[
    {"type":"text","content":"A IA não é uma ameaça. Não é um substituto. Não é magia. É uma extensão das capacidades humanas — como óculos para quem não enxerga bem, como calculadora para números rápidos, como telescópio para ver além do alcance dos olhos. O que muda com IA: antes criar um logo precisava contratar designer. Com IA você mesmo cria versões para testar."},
    {"type":"text","content":"Antes pesquisar um assunto complexo levava horas na biblioteca. Com IA você tem resumo em minutos. Antes aprender idioma levava anos de curso caro. Com IA você pratica todo dia de graça. Antes resolver problema difícil precisava de especialistas. Com IA você tem parceiro de raciocínio sempre disponível."},
    {"type":"text","content":"A IA amplifica o que você já é. Se você é curioso fica mais curioso. Se você é criativo fica mais criativo. Se você quer ajudar pessoas tem mais ferramentas para isso. O superpoder não é a IA. O superpoder é você usando a IA."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI is not a threat. It is not a substitute. It is not magic. It is an extension of human capabilities — like glasses for someone who cannot see well, like a calculator for quick numbers, like a telescope to see beyond the reach of the eyes. What changes with AI: before creating a logo required hiring a designer. With AI you create versions to test yourself."},
    {"type":"text","content":"Before researching a complex topic took hours in the library. With AI you have a summary in minutes. Before learning a language took years of expensive courses. With AI you practice every day for free. Before solving a difficult problem required specialists. With AI you have a reasoning partner always available."},
    {"type":"text","content":"AI amplifies what you already are. If you are curious you become more curious. If you are creative you become more creative. If you want to help people you have more tools to do so. The superpower is not AI. The superpower is you using AI."}
  ]$$::jsonb,
  'A criança descreve uma qualidade ou habilidade que tem e a Atena mostra como a IA poderia amplificá-la de formas concretas.',
  'The child describes a quality or skill they have and Atena shows how AI could amplify it in concrete ways.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's8-teste-missao-08',
  'Teste — Missão 08',
  'Test — Mission 08',
  'Quiz para fechar a Missão 08',
  'Quiz to complete Mission 08',
  '6-18', 8, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 08! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 08! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s8-ia-organizar-vida
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa viver em modo reativo?","options":["Reagir rápido a emergências com ajuda da IA","Fazer o que aparece em vez do que você planejou sem direção clara","Usar IA para reagir a problemas em tempo real","Ter uma rotina muito rígida que não aceita mudanças"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does it mean to live in reactive mode?',
  $$["Reacting quickly to emergencies with AI help","Doing what comes up instead of what you planned without clear direction","Using AI to react to problems in real time","Having a very rigid routine that does not accept changes"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-organizar-vida';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como a IA ajuda a criar um sistema de hábitos eficaz?","options":["Monitora seu celular para verificar se você está seguindo os hábitos","Cria um plano progressivo e realista que começa pequeno e cresce gradualmente","Substitui a força de vontade automaticamente","Envia alertas automáticos a cada hora"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'How does AI help create an effective habit system?',
  $$["Monitors your phone to verify you are following the habits","Creates a progressive and realistic plan that starts small and grows gradually","Automatically replaces willpower","Sends automatic alerts every hour"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-organizar-vida';

-- s8-ia-resolver-problemas
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a forma correta de usar IA para resolver problemas?","options":["Pedir para a IA resolver e copiar a solução diretamente","Usar a IA como parceira de raciocínio analisar opções juntos e você decidir a melhor solução","Perguntar para várias IAs diferentes e usar a resposta mais comum","Usar IA apenas para problemas simples e resolver os difíceis sozinho"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the correct way to use AI to solve problems?',
  $$["Ask AI to solve and copy the solution directly","Use AI as a reasoning partner analyze options together and you decide the best solution","Ask several different AIs and use the most common answer","Use AI only for simple problems and solve hard ones alone"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-resolver-problemas';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA pode gerar soluções que não funcionam para você especificamente?","options":["Porque a IA não é inteligente o suficiente para problemas complexos","Porque ela não conhece todos os detalhes do seu contexto restrições e valores","Porque a IA sempre gera soluções muito simples","Porque a IA só resolve problemas em inglês"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why can AI generate solutions that do not work for you specifically?',
  $$["Because AI is not intelligent enough for complex problems","Because it does not know all the details of your context restrictions and values","Because AI always generates very simple solutions","Because AI only solves problems in English"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-resolver-problemas';

-- s8-ia-criar-negocios-ideias
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa dizer que a IA democratizou a criação?","options":["Que a IA vota em eleições para decidir quais criações são melhores","Que a IA tornou possível para qualquer pessoa criar coisas que antes exigiam equipes e recursos enormes","Que a IA criou um governo digital para regular criações","Que toda criação feita com IA é gratuita e pública"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does it mean to say AI democratized creation?',
  $$["That AI votes in elections to decide which creations are best","That AI made it possible for anyone to create things that before required huge teams and resources","That AI created a digital government to regulate creations","That all creations made with AI are free and public"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-criar-negocios-ideias';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Para criar um pequeno negócio com ajuda de IA o que a IA pode ajudar?","options":["Fazer as vendas automaticamente por você","Ter a ideia do negócio no lugar de você","Criar nome pitch de vendas estratégia de preço e primeiras mensagens para clientes","Garantir que o negócio vai ter sucesso"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'To create a small business with AI help what can AI help with?',
  $$["Make sales automatically for you","Have the business idea instead of you","Create name sales pitch pricing strategy and first messages for clients","Guarantee the business will succeed"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-criar-negocios-ideias';

-- s8-ia-ajudar-pessoas
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é um exemplo real de como IA está ajudando na área da saúde?","options":["IA substitui completamente os médicos em consultas","IA detecta câncer em exames antes que médicos consigam ver e ajuda a desenvolver remédios mais rápido","IA cura doenças diretamente sem necessidade de remédios","IA garante que todos os hospitais tenham equipamentos modernos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is a real example of how AI is helping in healthcare?',
  $$["AI completely replaces doctors in consultations","AI detects cancer in scans before doctors can see it and helps develop medicines faster","AI cures diseases directly without need for medicines","AI ensures all hospitals have modern equipment"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-ajudar-pessoas';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que torna a IA especialmente poderosa para resolver problemas sociais?","options":["É gratuita para todos os países em desenvolvimento","Pode ser aplicada em escala ajudando milhares ou milhões de pessoas ao mesmo tempo com o mesmo sistema","É mais inteligente que qualquer ser humano em qualquer área","Não precisa de internet para funcionar em regiões remotas"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What makes AI especially powerful to solve social problems?',
  $$["It is free for all developing countries","It can be applied at scale helping thousands or millions of people at the same time with the same system","It is smarter than any human in any area","It does not need internet to work in remote regions"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-ajudar-pessoas';

-- s8-ia-superpoder-humano
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"A afirmação IA é um superpoder humano significa que:","options":["Humanos se tornam invencíveis quando usam IA","IA amplifica as capacidades humanas existentes como ferramentas amplificam o que os humanos já conseguem fazer","Apenas super-heróis têm acesso às melhores IAs","IA dá poderes sobrenaturais que humanos não teriam de outra forma"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'The statement AI is a human superpower means that:',
  $$["Humans become invincible when they use AI","AI amplifies existing human capabilities the way tools amplify what humans can already do","Only superheroes have access to the best AIs","AI gives supernatural powers humans would not have otherwise"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-superpoder-humano';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA amplifica tanto as qualidades positivas quanto precisaria ser usada com responsabilidade?","options":["Porque a IA cobra mais quando usada para coisas ruins","Porque amplificar capacidades sem responsabilidade pode amplificar também erros preconceitos e danos","Porque a IA não consegue amplificar características negativas","Porque a lei exige uso responsável de IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does AI need to be used responsibly since it amplifies both positive qualities?',
  $$["Because AI charges more when used for bad things","Because amplifying capabilities without responsibility can also amplify errors prejudices and harms","Because AI cannot amplify negative characteristics","Because the law requires responsible AI use"]$$::jsonb
FROM lessons WHERE slug = 's8-ia-superpoder-humano';

-- s8-teste-missao-08 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você quer usar IA para resolver um problema na escola. Qual é o processo correto?","options":["Pedir para a IA resolver e entregar a solução pronta","Descrever o problema com todos os detalhes pedir múltiplas soluções analisar prós e contras e decidir qual funciona para o contexto específico","Pesquisar o que outras escolas fazem e copiar a solução","Pedir para a IA escrever uma carta de reclamação"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You want to use AI to solve a school problem. What is the correct process?',
  $$["Ask AI to solve and deliver the ready solution","Describe the problem with all details ask for multiple solutions analyze pros and cons and decide which works for the specific context","Research what other schools do and copy the solution","Ask AI to write a complaint letter"]$$::jsonb
FROM lessons WHERE slug = 's8-teste-missao-08';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual afirmação sobre IA e superpoderes humanos é mais precisa?","options":["IA substitui as habilidades humanas tornando-as desnecessárias","IA dá superpoderes iguais para todas as pessoas independente de suas qualidades","IA amplifica o que você já é — sua criatividade curiosidade e capacidade de ajudar ficam maiores","Apenas adultos com formação técnica conseguem usar IA como superpoder"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which statement about AI and human superpowers is more accurate?',
  $$["AI replaces human skills making them unnecessary","AI gives equal superpowers to all people regardless of their qualities","AI amplifies what you already are — your creativity curiosity and capacity to help become greater","Only adults with technical training can use AI as a superpower"]$$::jsonb
FROM lessons WHERE slug = 's8-teste-missao-08';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s8-ia-organizar-vida
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Organiza minha semana', 'Tenho esses objetivos essa semana: [lista]. Me ajuda a criar um plano de prioridades para os próximos 7 dias.', '6-18', 1
FROM lessons WHERE slug = 's8-ia-organizar-vida';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria meu sistema de hábitos', 'Quero criar os hábitos de [lista]. Me monta um plano progressivo e realista começando pequeno.', '6-18', 2
FROM lessons WHERE slug = 's8-ia-organizar-vida';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Minha rotina matinal', 'Acordo às [hora] e preciso sair às [hora]. Me ajuda a criar uma rotina matinal que inclua [objetivos].', '6-18', 3
FROM lessons WHERE slug = 's8-ia-organizar-vida';

-- s8-ia-resolver-problemas
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Resolve comigo', 'Tenho esse problema: [descreve]. Me ajuda a pensar em múltiplas soluções e analisar os prós e contras de cada uma.', '6-18', 1
FROM lessons WHERE slug = 's8-ia-resolver-problemas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quais são minhas opções?', 'Estou nessa situação: [descreve]. Quais são as diferentes abordagens que eu poderia tomar? Me lista pelo menos 4 opções.', '6-18', 2
FROM lessons WHERE slug = 's8-ia-resolver-problemas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Analisa essa decisão', 'Estou pensando em [decisão]. Me ajuda a analisar os pontos positivos e negativos antes de decidir.', '6-18', 3
FROM lessons WHERE slug = 's8-ia-resolver-problemas';

-- s8-ia-criar-negocios-ideias
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Desenvolve minha ideia', 'Tenho essa ideia: [descreve]. Me ajuda a criar: nome, missão em 1 frase, público-alvo e 3 primeiros passos concretos.', '6-18', 1
FROM lessons WHERE slug = 's8-ia-criar-negocios-ideias';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Nome para meu projeto', 'Estou criando [descreve projeto]. Me dá 5 opções de nome criativo e memorável com uma explicação para cada um.', '6-18', 2
FROM lessons WHERE slug = 's8-ia-criar-negocios-ideias';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Pitch da minha ideia', 'Minha ideia é [descreve]. Me ajuda a criar um pitch de 30 segundos para explicar para alguém de forma convincente.', '6-18', 3
FROM lessons WHERE slug = 's8-ia-criar-negocios-ideias';

-- s8-ia-ajudar-pessoas
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA para minha causa', 'Me preocupo com [problema social]. Como a IA poderia ser usada para ajudar a resolver isso? Me dá ideias concretas.', '6-18', 1
FROM lessons WHERE slug = 's8-ia-ajudar-pessoas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA na saúde', 'Me conta exemplos reais de como a IA está sendo usada para salvar vidas na área da saúde.', '6-18', 2
FROM lessons WHERE slug = 's8-ia-ajudar-pessoas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Projeto de impacto', 'Quero criar um projeto usando IA para ajudar [grupo de pessoas]. Me ajuda a desenvolver a ideia inicial.', '6-18', 3
FROM lessons WHERE slug = 's8-ia-ajudar-pessoas';

-- s8-ia-superpoder-humano
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Amplifica minha habilidade', 'Sou bom em [habilidade]. Como a IA poderia amplificar isso e me ajudar a ir ainda mais longe?', '6-18', 1
FROM lessons WHERE slug = 's8-ia-superpoder-humano';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu superpoder com IA', 'Me dá 3 exemplos concretos de como eu poderia usar IA para potencializar [interesse ou objetivo].', '6-18', 2
FROM lessons WHERE slug = 's8-ia-superpoder-humano';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA como ferramenta', 'Quero usar IA como ferramenta e não como substituto. Me ajuda a pensar em como fazer isso na prática.', '6-18', 3
FROM lessons WHERE slug = 's8-ia-superpoder-humano';

COMMIT;
