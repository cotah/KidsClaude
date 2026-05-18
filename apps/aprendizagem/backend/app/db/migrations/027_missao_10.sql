-- Migration 027: Insere conteudo da Stage 10 "Missao 10 - O futuro da IA"
--
-- Foco: para onde a IA esta indo - multimodal/agentic/cientifica/fisica,
-- AGI e o debate sobre quando, profissoes que vao explodir, geopolitica
-- da IA (EUA/China/Europa/Brasil), e plano de acao concreto pra crianca
-- comecar agora.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=10, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 10
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's10-futuro-ia-fronteiras',
  'Para onde a IA está indo — as próximas fronteiras',
  'Where AI is going — the next frontiers',
  'Descobrir as principais direções da IA nos próximos anos',
  'Discover the main directions of AI in the coming years',
  '6-18', 10, 1,
  $$[
    {"type":"text","content":"A IA de hoje já é impressionante. Mas o que vem nos próximos anos vai ser ainda mais transformador. IA MULTIMODAL: as IAs já conseguem trabalhar com texto, imagem, áudio e vídeo ao mesmo tempo. A próxima geração vai integrar tudo isso de forma ainda mais natural — você mostra uma foto, fala algo, e a IA entende o contexto completo. IA AGENTE: em vez de responder perguntas, a IA vai agir."},
    {"type":"text","content":"Você diz organiza minha semana e ela acessa seu calendário, e-mail e tarefas, pensa no que é prioritário e toma ações. IA CIENTÍFICA: AlphaFold da Google resolveu um problema de biologia que levou 50 anos para humanos resolverem — em dias. IA está acelerando pesquisas em medicina, física e clima a uma velocidade sem precedentes."},
    {"type":"text","content":"IA FÍSICA: a combinação de IA com robótica vai trazer assistentes físicos que entendem linguagem natural e agem no mundo real. Você está aprendendo sobre IA no momento mais importante da história dessa tecnologia. Quem entende agora tem uma vantagem enorme."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Todays AI is already impressive. But what comes in the next few years will be even more transformative. MULTIMODAL AI: AIs can already work with text, image, audio and video simultaneously. The next generation will integrate all of this even more naturally — you show a photo, say something, and AI understands the full context. AGENTIC AI: instead of answering questions, AI will act."},
    {"type":"text","content":"You say organize my week and it accesses your calendar, email and tasks, thinks about priorities and takes actions. SCIENTIFIC AI: Googles AlphaFold solved a biology problem that took 50 years for humans to solve — in days. AI is accelerating research in medicine, physics and climate at unprecedented speed."},
    {"type":"text","content":"PHYSICAL AI: the combination of AI with robotics will bring physical assistants that understand natural language and act in the real world. You are learning about AI at the most important moment in the history of this technology. Those who understand now have a huge advantage."}
  ]$$::jsonb,
  'A criança escolhe uma área que ama e a Atena explica como a IA vai transformar essa área nos próximos 10 anos.',
  'The child picks an area they love and Atena explains how AI will transform that area in the next 10 years.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's10-agi-ia-que-pensa',
  'AGI — a IA que pensa como humano',
  'AGI — the AI that thinks like a human',
  'Entender o que é AGI e por que é o conceito mais debatido em IA',
  'Understand what AGI is and why it is the most debated concept in AI',
  '6-18', 10, 2,
  $$[
    {"type":"text","content":"AGI significa Artificial General Intelligence — Inteligência Artificial Geral. É uma IA que consegue aprender e executar qualquer tarefa intelectual que um humano consegue. Não especializada em uma coisa só — capaz de qualquer coisa. As IAs de hoje são narrow AI — inteligência estreita. O ChatGPT é incrível em texto mas não dirige um carro. O AlphaFold resolve proteínas mas não escreve poesia."},
    {"type":"text","content":"AGI seria diferente: uma IA que pode aprender qualquer coisa, se adaptar a situações novas como humanos fazem, e transferir conhecimento de uma área para outra. Quando vai acontecer? Opiniões variam muito. Alguns especialistas acham que em poucos anos. Outros dizem décadas. Alguns dizem que nunca vai acontecer da forma que imaginamos."},
    {"type":"text","content":"O que todo mundo concorda: quando AGI existir, será o evento mais transformador da história humana. Precisará de uma quantidade enorme de cuidado, regulação e responsabilidade. É por isso que empresas como a Anthropic existem — para garantir que IA seja desenvolvida de forma segura e benéfica."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AGI stands for Artificial General Intelligence. It is an AI that can learn and perform any intellectual task a human can. Not specialized in one thing — capable of anything. Todays AIs are narrow AI — specialized intelligence. ChatGPT is incredible at text but cannot drive a car. AlphaFold solves proteins but does not write poetry."},
    {"type":"text","content":"AGI would be different: an AI that can learn anything, adapt to new situations like humans do, and transfer knowledge from one area to another. When will it happen? Opinions vary widely. Some experts think in a few years. Others say decades. Some say it will never happen the way we imagine."},
    {"type":"text","content":"What everyone agrees on: when AGI exists, it will be the most transformative event in human history. It will require an enormous amount of care, regulation and responsibility. That is why companies like Anthropic exist — to ensure AI is developed safely and beneficially."}
  ]$$::jsonb,
  'A criança e a Atena debatem o que seria diferente no mundo se AGI existisse. Objetivo: pensamento especulativo e crítico sobre tecnologia.',
  'The child and Atena debate what would be different in the world if AGI existed. Goal: speculative and critical thinking about technology.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's10-profissoes-explodem-ia',
  'As profissões que vão explodir com IA',
  'The professions that will explode with AI',
  'Conhecer as carreiras de maior demanda no futuro com IA',
  'Know the careers in highest demand in the AI future',
  '6-18', 10, 3,
  $$[
    {"type":"text","content":"Existe uma enorme escassez de pessoas que sabem trabalhar com IA — e essa escassez vai crescer. Engenheiro de Prompt: especialista em criar instruções eficazes para IAs. Empresas pagam salários altíssimos para quem sabe extrair o máximo de modelos de linguagem. Treinador de IA: ensina a IA a melhorar, identifica erros e cria dados de treinamento de qualidade. É como ser professor de uma IA."},
    {"type":"text","content":"Especialista em Ética de IA: garante que sistemas de IA sejam justos, seguros e transparentes. Uma das profissões mais importantes do futuro. Engenheiro de IA e MLOps: constrói, treina e coloca em produção modelos de IA — altíssima demanda. Designer de Experiência com IA: cria interfaces que fazem a IA ser útil para pessoas comuns. Curador de Dados: garante que os dados de treinamento sejam de qualidade e éticos."},
    {"type":"text","content":"E a mais importante de todas: qualquer profissional que use IA melhor que seus colegas. Médico que usa IA para diagnóstico. Advogado que usa IA para pesquisa. Professor que usa IA para personalizar aulas. A IA não vai substituir profissionais — vai amplificar os que a usarem melhor."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is an enormous shortage of people who know how to work with AI — and that shortage will grow. Prompt Engineer: specialist in creating effective instructions for AIs. Companies pay very high salaries to those who can extract the most from language models. AI Trainer: teaches AI to improve, identifies errors and creates quality training data. It is like being a teacher for an AI."},
    {"type":"text","content":"AI Ethics Specialist: ensures AI systems are fair, safe and transparent. One of the most important professions of the future. AI Engineer and MLOps: builds, trains and deploys AI models — extremely high demand. AI Experience Designer: creates interfaces that make AI useful for everyday people. Data Curator: ensures training data is quality and ethical."},
    {"type":"text","content":"And the most important of all: any professional who uses AI better than their colleagues. Doctor who uses AI for diagnosis. Lawyer who uses AI for research. Teacher who uses AI to personalize lessons. AI will not replace professionals — it will amplify those who use it best."}
  ]$$::jsonb,
  'A criança descreve o que gosta de fazer e a Atena cria um caminho de carreira mostrando como IA vai potencializar essa área.',
  'The child describes what they like to do and Atena creates a career path showing how AI will enhance that area.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's10-paises-competindo-ia',
  'Como países e empresas estão competindo por IA',
  'How countries and companies are competing for AI',
  'Entender a geopolítica da IA e por que isso importa',
  'Understand the geopolitics of AI and why it matters',
  '6-18', 10, 4,
  $$[
    {"type":"text","content":"IA não é só tecnologia — é geopolítica, economia e poder. Os países e empresas que dominarem IA vão dominar o século XXI. Estados Unidos: liderou a criação dos modelos mais avançados. OpenAI, Anthropic, Google DeepMind, Meta AI — as maiores empresas de IA são americanas. China: segundo maior player, com acesso a dados de 1,4 bilhão de pessoas e investimento massivo em IA militar e manufatura."},
    {"type":"text","content":"Europa: foca mais em regulação e ética. O AI Act europeu é a primeira lei abrangente sobre IA do mundo. Brasil e outros países emergentes podem se beneficiar enormemente das IAs criadas por outros — mas correm o risco de depender de tecnologia estrangeira e ter suas informações processadas por servidores de outros países."},
    {"type":"text","content":"Por que isso importa para você? Quem controla a IA controla os dados, a narrativa e o poder econômico. Jovens que entendem IA hoje vão ter vantagem enorme para posicionar seus países nessa competição. Entender o jogo é o primeiro passo para participar dele."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI is not just technology — it is geopolitics, economics and power. The countries and companies that master AI will dominate the 21st century. United States: led the creation of the most advanced models. OpenAI, Anthropic, Google DeepMind, Meta AI — the biggest AI companies are American. China: second biggest player, with access to data from 1.4 billion people and massive investment in military AI and manufacturing."},
    {"type":"text","content":"Europe: focuses more on regulation and ethics. The European AI Act is the worlds first comprehensive AI law. Brazil and other emerging countries can benefit enormously from AIs created by others — but risk depending on foreign technology and having their information processed by servers in other countries."},
    {"type":"text","content":"Why does this matter to you? Those who control AI control data, narrative and economic power. Young people who understand AI today will have a huge advantage in positioning their countries in this competition. Understanding the game is the first step to participating in it."}
  ]$$::jsonb,
  'A criança e a Atena discutem o que o Brasil poderia fazer para se tornar um player relevante em IA. Objetivo: conectar tecnologia a identidade nacional.',
  'The child and Atena discuss what Brazil could do to become a relevant AI player. Goal: connect technology to national identity.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's10-o-que-fazer-agora',
  'O que você pode fazer agora para estar pronto',
  'What you can do now to be ready',
  'Criar um plano de ação concreto para continuar aprendendo com IA',
  'Create a concrete action plan to keep learning with AI',
  '6-18', 10, 5,
  $$[
    {"type":"text","content":"A pergunta mais importante de todo o curso: o que você faz com tudo isso? A resposta não é espere crescer para começar. É comece agora. Cinco coisas que você pode fazer hoje: 1) USE IA TODO DIA PARA APRENDER — não para fazer sua lição por você, mas para entender mais fundo, explorar mais longe e conectar o que aprende com o mundo real."},
    {"type":"text","content":"2) CRIE ALGO COM IA — uma história, um personagem, uma imagem, um projeto. Colocar a mão na massa é a melhor forma de aprender. 3) DESENVOLVA PENSAMENTO CRÍTICO — questione, verifique, não acredite em tudo que IA fala. 4) CULTIVE HABILIDADES HUMANAS — comunicação, empatia, criatividade, trabalho em equipe. São essas habilidades que vão te diferenciar."},
    {"type":"text","content":"5) FIQUE CURIOSO — a IA está evoluindo rapidamente. Quem acompanha e experimenta continuamente vai sempre ter vantagem. A geração que está aprendendo sobre IA agora vai ser responsável por decidir como essa tecnologia vai ser usada. Essa é uma responsabilidade enorme. E uma oportunidade incrível."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"The most important question of the entire course: what do you do with all of this? The answer is not wait until you grow up to start. It is start now. Five things you can do today: 1) USE AI EVERY DAY TO LEARN — not to do your homework for you, but to understand more deeply, explore further and connect what you learn with the real world."},
    {"type":"text","content":"2) CREATE SOMETHING WITH AI — a story, a character, an image, a project. Getting hands-on is the best way to learn. 3) DEVELOP CRITICAL THINKING — question, verify, do not believe everything AI says. 4) CULTIVATE HUMAN SKILLS — communication, empathy, creativity, teamwork. These are the skills that will set you apart."},
    {"type":"text","content":"5) STAY CURIOUS — AI is evolving rapidly. Those who follow along and experiment continuously will always have an advantage. The generation learning about AI now will be responsible for deciding how this technology is used. That is an enormous responsibility. And an incredible opportunity."}
  ]$$::jsonb,
  'A criança cria seu plano pessoal de 3 ações concretas para os próximos 30 dias. A Atena ajuda a tornar o plano específico e realizável.',
  'The child creates their personal plan of 3 concrete actions for the next 30 days. Atena helps make the plan specific and achievable.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's10-teste-missao-10',
  'Teste — Missão 10',
  'Test — Mission 10',
  'Quiz para fechar a Missão 10',
  'Quiz to complete Mission 10',
  '6-18', 10, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 10! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 10! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s10-futuro-ia-fronteiras
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma IA agente?","options":["Uma IA que age como personagem em jogos de RPG","Uma IA que não só responde perguntas mas toma ações por conta própria para completar tarefas","Um agente humano que usa IA como ferramenta de trabalho","Uma IA que representa uma empresa em negociações"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is an agentic AI?',
  $$["An AI that acts as a character in RPG games","An AI that not only answers questions but takes actions on its own to complete tasks","A human agent who uses AI as a work tool","An AI that represents a company in negotiations"]$$::jsonb
FROM lessons WHERE slug = 's10-futuro-ia-fronteiras';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que o AlphaFold demonstrou sobre o potencial da IA científica?","options":["Que IA pode substituir completamente cientistas humanos","Que IA pode acelerar pesquisas científicas resolvendo em dias problemas que levaram décadas para humanos","Que IA só funciona bem em problemas de biologia","Que IA científica só está disponível para grandes universidades"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What did AlphaFold demonstrate about the potential of scientific AI?',
  $$["That AI can completely replace human scientists","That AI can accelerate scientific research solving in days problems that took decades for humans","That AI only works well on biology problems","That scientific AI is only available to large universities"]$$::jsonb
FROM lessons WHERE slug = 's10-futuro-ia-fronteiras';

-- s10-agi-ia-que-pensa
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença entre a IA de hoje e AGI?","options":["AGI é mais rápida que a IA atual","A IA de hoje é especializada em domínios específicos; AGI poderia aprender e executar qualquer tarefa intelectual como um humano","AGI tem mais parâmetros que a IA atual","A IA de hoje usa mais energia que AGI"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the difference between todays AI and AGI?',
  $$["AGI is faster than current AI","Todays AI is specialized in specific domains; AGI could learn and perform any intellectual task like a human","AGI has more parameters than current AI","Todays AI uses more energy than AGI"]$$::jsonb
FROM lessons WHERE slug = 's10-agi-ia-que-pensa';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que especialistas discordam tanto sobre quando AGI vai existir?","options":["Porque é um assunto secreto que governos controlam","Porque AGI envolve desafios técnicos e filosóficos profundos que ninguém sabe exatamente como e quando serão resolvidos","Porque cada empresa de IA tem uma definição diferente de AGI","Porque governos proibiram pesquisas oficiais sobre AGI"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why do experts disagree so much about when AGI will exist?',
  $$["Because it is a secret subject that governments control","Because AGI involves deep technical and philosophical challenges that nobody knows exactly how and when will be solved","Because each AI company has a different definition of AGI","Because governments banned official research on AGI"]$$::jsonb
FROM lessons WHERE slug = 's10-agi-ia-que-pensa';

-- s10-profissoes-explodem-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que faz um Engenheiro de Prompt?","options":["Programa as instruções de segurança de sistemas de IA","Cria instruções eficazes para extrair o máximo de modelos de linguagem de IA","Constrói os servidores onde as IAs funcionam","Verifica se os prompts dos usuários são seguros"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does a Prompt Engineer do?',
  $$["Programs security instructions for AI systems","Creates effective instructions to extract the most from AI language models","Builds the servers where AIs run","Verifies if user prompts are safe"]$$::jsonb
FROM lessons WHERE slug = 's10-profissoes-explodem-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a profissão mais importante para qualquer área no futuro com IA?","options":["Engenheiro de IA que sabe programar modelos do zero","Especialista em ética que regula o uso de IA","Qualquer profissional que usa IA melhor que seus colegas na sua própria área","Curador de dados que treina os modelos"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the most important profession for any area in the AI future?',
  $$["AI engineer who knows how to program models from scratch","Ethics specialist who regulates AI use","Any professional who uses AI better than their colleagues in their own area","Data curator who trains the models"]$$::jsonb
FROM lessons WHERE slug = 's10-profissoes-explodem-ia';

-- s10-paises-competindo-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a China tem uma vantagem significativa na corrida pela IA?","options":["Porque tem os programadores mais talentosos do mundo","Porque tem acesso a uma quantidade enorme de dados de sua população de 1,4 bilhão de pessoas","Porque inventou a tecnologia de redes neurais","Porque gasta mais dinheiro em pesquisa de IA que os EUA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does China have a significant advantage in the AI race?',
  $$["Because it has the most talented programmers in the world","Because it has access to a huge amount of data from its 1.4 billion population","Because it invented neural network technology","Because it spends more money on AI research than the US"]$$::jsonb
FROM lessons WHERE slug = 's10-paises-competindo-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que países que não desenvolvem sua própria IA ficam em desvantagem?","options":["Porque não podem usar IAs de outros países","Porque dependem de tecnologia estrangeira pagam royalties e têm menos influência sobre as regras de desenvolvimento","Porque a IA só funciona no idioma do país que a criou","Porque leis internacionais proíbem exportar tecnologia de IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why are countries that do not develop their own AI at a disadvantage?',
  $$["Because they cannot use AIs from other countries","Because they depend on foreign technology pay royalties and have less influence over development rules","Because AI only works in the language of the country that created it","Because international laws prohibit exporting AI technology"]$$::jsonb
FROM lessons WHERE slug = 's10-paises-competindo-ia';

-- s10-o-que-fazer-agora
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual das ações é mais importante para se preparar para o futuro com IA?","options":["Esperar crescer e fazer faculdade de computação","Decorar os nomes de todas as IAs existentes","Começar agora — usar IA para aprender criar coisas pensar criticamente e cultivar habilidades humanas","Escolher uma IA favorita e usar só ela para tudo"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which action is most important to prepare for the AI future?',
  $$["Wait to grow up and study computer science","Memorize the names of all existing AIs","Start now — use AI to learn create things think critically and cultivate human skills","Pick a favorite AI and use only it for everything"]$$::jsonb
FROM lessons WHERE slug = 's10-o-que-fazer-agora';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que cultivar habilidades humanas como empatia e criatividade é importante no futuro com IA?","options":["Porque IA nunca vai conseguir processar informações tão rápido quanto humanos","Porque são as habilidades que diferenciam humanos quando IA assume tarefas repetitivas","Porque empresas de IA exigem essas habilidades para contratação","Porque habilidades humanas tornam a IA mais eficiente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is cultivating human skills like empathy and creativity important in the AI future?',
  $$["Because AI will never process information as fast as humans","Because they are the skills that differentiate humans when AI takes over repetitive tasks","Because AI companies require these skills for hiring","Because human skills make AI more efficient"]$$::jsonb
FROM lessons WHERE slug = 's10-o-que-fazer-agora';

-- s10-teste-missao-10 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença mais importante entre a IA de hoje e AGI?","options":["AGI usa muito mais energia para funcionar","A IA de hoje é especializada em domínios específicos; AGI poderia aprender e executar qualquer tarefa intelectual como um humano","AGI é apenas uma versão mais rápida da IA atual","A IA de hoje só funciona em inglês; AGI funcionaria em todos os idiomas"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the most important difference between todays AI and AGI?',
  $$["AGI uses much more energy to function","Todays AI is specialized in specific domains; AGI could learn and perform any intellectual task like a human","AGI is just a faster version of current AI","Todays AI only works in English; AGI would work in all languages"]$$::jsonb
FROM lessons WHERE slug = 's10-teste-missao-10';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que é vantajoso aprender sobre IA agora mesmo sendo jovem?","options":["Porque IA vai ser proibida para adultos no futuro","Porque existe uma enorme escassez de pessoas que sabem trabalhar com IA e quem começa agora terá anos de vantagem","Porque IA só funciona bem quando aprendida antes dos 18 anos","Porque jovens têm acesso a versões melhores de IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is it advantageous to learn about AI now even being young?',
  $$["Because AI will be forbidden for adults in the future","Because there is a huge shortage of people who know how to work with AI and those who start now will have years of advantage","Because AI only works well when learned before age 18","Because young people have access to better versions of AI"]$$::jsonb
FROM lessons WHERE slug = 's10-teste-missao-10';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s10-futuro-ia-fronteiras
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA na minha área favorita', 'Como a IA vai transformar a área de [área] nos próximos 10 anos? Me conta o que já está acontecendo e o que vem aí.', '6-18', 1
FROM lessons WHERE slug = 's10-futuro-ia-fronteiras';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA agente na prática', 'Me dá 3 exemplos concretos de tarefas que uma IA agente poderia fazer por mim no dia a dia.', '6-18', 2
FROM lessons WHERE slug = 's10-futuro-ia-fronteiras';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Próximas fronteiras', 'Qual você acha que será o avanço mais surpreendente da IA nos próximos 5 anos? Por quê?', '6-18', 3
FROM lessons WHERE slug = 's10-futuro-ia-fronteiras';

-- s10-agi-ia-que-pensa
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Se AGI existisse', 'Se AGI existisse hoje, como seria diferente o mundo? Me dá exemplos concretos em 3 áreas diferentes.', '6-18', 1
FROM lessons WHERE slug = 's10-agi-ia-que-pensa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'AGI é possível?', 'Por que alguns especialistas acham que AGI é impossível? Quais são os maiores obstáculos técnicos?', '6-18', 2
FROM lessons WHERE slug = 's10-agi-ia-que-pensa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Narrow AI vs AGI', 'Me dá 5 exemplos de tarefas que mostram a diferença entre a IA estreita de hoje e o que AGI poderia fazer.', '6-18', 3
FROM lessons WHERE slug = 's10-agi-ia-que-pensa';

-- s10-profissoes-explodem-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Carreira com IA', 'Gosto de [área]. Como posso combinar esse interesse com IA para ter uma carreira interessante no futuro?', '6-18', 1
FROM lessons WHERE slug = 's10-profissoes-explodem-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Profissões do futuro', 'Me lista as 5 profissões relacionadas a IA com maior demanda e melhores salários nos próximos 10 anos.', '6-18', 2
FROM lessons WHERE slug = 's10-profissoes-explodem-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como começar?', 'Quero trabalhar com IA no futuro. O que posso fazer agora com [idade] anos para me preparar?', '6-18', 3
FROM lessons WHERE slug = 's10-profissoes-explodem-ia';

-- s10-paises-competindo-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Brasil e IA', 'Quais são as vantagens e desvantagens do Brasil na corrida global pela IA? O que poderíamos fazer para ser mais relevantes?', '6-18', 1
FROM lessons WHERE slug = 's10-paises-competindo-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Regulação de IA', 'O que é o AI Act europeu? Por que regular IA é importante e quais são os riscos de regular demais ou de menos?', '6-18', 2
FROM lessons WHERE slug = 's10-paises-competindo-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Corrida pela IA', 'Me explica a competição entre EUA e China em IA como se fosse uma partida de xadrez. Quem está ganhando e por quê?', '6-18', 3
FROM lessons WHERE slug = 's10-paises-competindo-ia';

-- s10-o-que-fazer-agora
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu plano de 30 dias', 'Quero usar mais IA para aprender. Me ajuda a criar um plano de 30 dias com 3 ações concretas e realizáveis.', '6-18', 1
FROM lessons WHERE slug = 's10-o-que-fazer-agora';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Habilidades para desenvolver', 'Tenho [idade] anos. Quais habilidades humanas devo focar em desenvolver agora pensando no futuro com IA?', '6-18', 2
FROM lessons WHERE slug = 's10-o-que-fazer-agora';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Por onde começar?', 'Quero me tornar um expert em usar IA. Me dá um roteiro de aprendizado dos próximos 6 meses.', '6-18', 3
FROM lessons WHERE slug = 's10-o-que-fazer-agora';

COMMIT;
