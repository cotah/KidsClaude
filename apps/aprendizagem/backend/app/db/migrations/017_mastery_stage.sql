-- Migration 017: nova Stage 6 "Mastery" — Claude Code, MCP, Cowork, AI Engineer.
--
-- Renumera: final exam de stage=6 -> stage=7. Insere 6 licoes em stage=6
-- (5 conteudo + 1 stage test) + 12 challenges + 18 prompt_templates.
-- Atomico via BEGIN/COMMIT. Gate em run_migrations.sh com sentinel
-- "lessons_stage_check ja aceita stage <= 7".
--
-- prompt_templates_age_band_check ja foi relaxado pra aceitar '6-18'
-- na 016 - nao precisa ALTER de novo.

BEGIN;

-- 1) Relaxa CHECK do stage: 1..6 -> 1..7 - DEFENSIVO.
-- Mesmo pattern da 015: so' aplica se nenhuma linha viola a nova constraint.
-- Protege contra DB em estado v3 (rows com stage > 7) caso o v3 fence em
-- run_migrations.sh tenha falhado e essa migration tente rodar de novo.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM lessons WHERE stage > 7) THEN
    ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_stage_check;
    ALTER TABLE lessons ADD CONSTRAINT lessons_stage_check
      CHECK (stage >= 1 AND stage <= 7);
  END IF;
END $$;

-- 2) Move final exam: stage 6 -> 7 (libera 6 pra Mastery)
UPDATE lessons SET stage = 7 WHERE stage = 6 AND is_final_exam = TRUE;

-- 3) Insere 6 novas licoes em stage=6 (5 conteudo + 1 stage test)
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en, xp_reward, is_active,
   is_final_exam, claude_model)
VALUES
(
  's6-claude-code',
  'Claude Code — IA que age no seu computador',
  'Claude Code — AI that acts on your computer',
  'Descobrir o Claude Code e como ele constrói projetos completos',
  'Discover Claude Code and how it builds complete projects',
  '6-18', 6, 1,
  $$[
    {"type":"text","content":"Até agora você aprendeu a conversar com a IA pelo chat. Mas existe uma versão do Claude que faz muito mais do que conversar — ela age. O Claude Code é uma versão do Claude que roda direto no seu computador, lê seus arquivos, escreve código, instala programas e constrói projetos inteiros sozinho."},
    {"type":"text","content":"Imagina ter um desenvolvedor sênior trabalhando no seu computador 24 horas por dia. Você fala o que quer construir, e ele lê os arquivos, entende o projeto, escreve o código, testa, corrige os erros e entrega funcionando. É exatamente isso que o Claude Code faz. Desenvolvedores que usam Claude Code reportam ser 3 a 5 vezes mais produtivos."},
    {"type":"text","content":"Para usar o Claude Code você precisa de um computador, um terminal, e uma conta na Anthropic. Não precisa saber programar do zero — mas quanto mais você entender de tecnologia, mais poderoso fica. E adivinha? Você já está aprendendo exatamente isso nesse curso. Pra praticar: descreva um projeto simples e peça pra Atena explicar como o Claude Code te ajudaria a construir cada parte."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Until now you learned to talk to AI through chat. But there is a version of Claude that does much more than talk — it acts. Claude Code is a version of Claude that runs directly on your computer, reads your files, writes code, installs programs and builds entire projects on its own."},
    {"type":"text","content":"Imagine having a senior developer working on your computer 24 hours a day. You say what you want to build, and it reads the files, understands the project, writes the code, tests it, fixes errors and delivers it working. That is exactly what Claude Code does. Developers using Claude Code report being 3 to 5 times more productive."},
    {"type":"text","content":"To use Claude Code you need a computer, a terminal, and an Anthropic account. You do not need to know how to program from scratch — but the more you understand technology, the more powerful it becomes. And guess what? You are already learning exactly that in this course. To practice: describe a simple project and ask Atena to explain how Claude Code would help you build each part."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-mcp',
  'MCP — Conectando a IA ao mundo real',
  'MCP — Connecting AI to the real world',
  'Entender o Model Context Protocol e como ele liga a IA a qualquer ferramenta',
  'Understand the Model Context Protocol and how it connects AI to any tool',
  '6-18', 6, 2,
  $$[
    {"type":"text","content":"Você já aprendeu que a IA sozinha é poderosa. Mas e se ela pudesse se conectar a qualquer ferramenta que você já usa? É exatamente isso que o MCP — Model Context Protocol — faz. MCP é um padrão criado pela Anthropic em 2024 que funciona como uma tomada universal."},
    {"type":"text","content":"Assim como uma tomada elétrica serve para qualquer aparelho, o MCP serve para conectar a IA a qualquer serviço: Google Drive, GitHub, Slack, Notion, banco de dados, calendário, e-mail — qualquer coisa. Na prática: imagina pedir para a Claude olha meu Google Drive e me resume os documentos do projeto X. Com MCP conectado, funciona em segundos."},
    {"type":"text","content":"Hoje já existem centenas de MCPs prontos para usar — para Spotify, Figma, Jira, Vercel, Supabase, e muito mais. Quem sabe usar MCP tem um superpoder que a maioria dos profissionais ainda não descobriu. Pra praticar: escolha 3 ferramentas que você usa no dia a dia e peça pra Atena explicar como o MCP poderia conectar a IA a cada uma."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"You already learned that AI alone is powerful. But what if it could connect to any tool you already use? That is exactly what MCP — Model Context Protocol — does. MCP is a standard created by Anthropic in 2024 that works like a universal plug."},
    {"type":"text","content":"Just like an electrical outlet works for any appliance, MCP connects AI to any service: Google Drive, GitHub, Slack, Notion, databases, calendar, email — anything. In practice: imagine asking Claude to look at your Google Drive and summarize the documents from project X. With MCP connected, it works in seconds."},
    {"type":"text","content":"Today there are hundreds of ready-to-use MCPs — for Spotify, Figma, Jira, Vercel, Supabase, and much more. Whoever knows how to use MCP has a superpower that most professionals have not discovered yet. To practice: pick 3 tools you use daily and ask Atena to explain how MCP could connect AI to each one."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-claude-cowork',
  'Claude Cowork — IA para tarefas do mundo real',
  'Claude Cowork — AI for real world tasks',
  'Descobrir o Claude Cowork e como ele executa tarefas no desktop',
  'Discover Claude Cowork and how it executes tasks on the desktop',
  '6-18', 6, 3,
  $$[
    {"type":"text","content":"Claude Code é para desenvolvedores no terminal. Mas e para quem não programa? A Anthropic criou o Claude Cowork — uma versão do Claude que opera no seu desktop e executa tarefas reais no seu computador, mesmo sem você saber programar."},
    {"type":"text","content":"Com o Claude Cowork você pode dizer: organiza os arquivos da minha pasta Downloads por tipo, pesquisa os 5 melhores restaurantes italianos em Dublin e cria uma planilha, lê esses 10 PDFs e me diz quais falam sobre inteligência artificial. E ele faz — clicando, abrindo arquivos, navegando no computador — como um assistente pessoal digital."},
    {"type":"text","content":"É a diferença entre uma IA que conversa e uma IA que trabalha. O Cowork não só te diz como fazer — ele faz por você. Pesquisadores, jornalistas, advogados, professores, contadores — qualquer profissional pode usar o Cowork para automatizar horas de trabalho repetitivo. Pra praticar: descreva uma tarefa chata e repetitiva que você ou alguém da família faz, e peça pra Atena explicar como o Cowork poderia automatizar."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Claude Code is for developers in the terminal. But what about people who do not program? Anthropic created Claude Cowork — a version of Claude that operates on your desktop and executes real tasks on your computer, even without programming knowledge."},
    {"type":"text","content":"With Claude Cowork you can say: organize the files in my Downloads folder by type, research the 5 best Italian restaurants in Dublin and create a spreadsheet, read these 10 PDFs and tell me which ones talk about artificial intelligence. And it does it — clicking, opening files, navigating the computer — like a digital personal assistant."},
    {"type":"text","content":"It is the difference between an AI that talks and an AI that works. Cowork does not just tell you how to do something — it does it for you. Researchers, journalists, lawyers, teachers, accountants — any professional can use Cowork to automate hours of repetitive work. To practice: describe a boring repetitive task you or a family member does, and ask Atena how Cowork could automate it."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-ai-engineer',
  'Você como AI Engineer',
  'You as an AI Engineer',
  'Entender a profissão de AI Engineer e como o curso te preparou',
  'Understand the AI Engineer profession and how the course prepared you',
  '6-18', 6, 4,
  $$[
    {"type":"text","content":"Existe uma profissão nova que não existia há 5 anos e que está entre as mais bem pagas do mundo de tecnologia: o AI Engineer. Não é o cientista que cria a IA — é o profissional que sabe usar, conectar e orquestrar sistemas de IA para construir produtos reais."},
    {"type":"text","content":"Um AI Engineer sabe: escrever prompts profissionais, criar system prompts para agentes, conectar IAs a ferramentas via MCP, usar Claude Code para construir projetos, e decidir qual IA usar para cada problema. Você aprendeu tudo isso nesse curso. Nos Estados Unidos, AI Engineers ganham entre 150 e 300 mil dólares por ano."},
    {"type":"text","content":"Mas o mais importante não é a carreira. É a mentalidade. Você aprendeu a pensar como alguém que usa ferramentas inteligentes para resolver problemas reais. Isso vai ser útil em qualquer área que você escolher — medicina, arte, esporte, negócios, ciência. A IA vai estar em todo lugar. Quem sabe usá-la bem tem vantagem em qualquer caminho. Pra praticar: escolha uma área que você gosta e peça pra Atena mostrar como a IA já está sendo usada nessa área."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is a new profession that did not exist 5 years ago and is among the highest paid in the technology world: the AI Engineer. It is not the scientist who creates AI — it is the professional who knows how to use, connect and orchestrate AI systems to build real products."},
    {"type":"text","content":"An AI Engineer knows how to: write professional prompts, create system prompts for agents, connect AIs to tools via MCP, use Claude Code to build projects, and decide which AI to use for each problem. You learned all of this in this course. In the United States, AI Engineers earn between 150 and 300 thousand dollars per year."},
    {"type":"text","content":"But the most important thing is not the career. It is the mindset. You learned to think like someone who uses intelligent tools to solve real problems. This will be useful in any area you choose — medicine, art, sports, business, science. AI will be everywhere. Whoever knows how to use it well has an advantage in any path. To practice: pick an area you like and ask Atena to show how AI is already being used in that area."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-construindo-futuro',
  'Construindo seu futuro com IA',
  'Building your future with AI',
  'Consolidar tudo que foi aprendido e criar intenção de prática',
  'Consolidate everything learned and create intention to practice',
  '6-18', 6, 5,
  $$[
    {"type":"text","content":"Você chegou até aqui. Isso já te coloca num grupo muito pequeno de pessoas no mundo que entende de verdade como a IA funciona, onde ela erra, como usá-la bem e como conectá-la ao mundo real."},
    {"type":"text","content":"Pensa no que você aprendeu: o que é IA e como ela pensa. Como verificar respostas e não confiar cegamente. Qual IA usar para cada situação. Como dar contexto certo e iterar até ficar perfeito. Como usar APIs e dados reais. Como fazer a IA escrever código e criar sites. Como fazer prompts profissionais e system prompts. O que é Claude Code, MCP e Cowork."},
    {"type":"text","content":"Esse conhecimento não vai envelhecer rápido — porque você não aprendeu a apertar botões. Você aprendeu a pensar com IA. O próximo passo é praticar. Toda vez que você tiver um problema, pergunta: como a IA poderia me ajudar aqui? Use Claude. Experimente. Erre. Itere. Melhore. Você está pronto. Pra praticar: conte pra Atena qual foi a lição mais importante do curso e como pretende usar o que aprendeu — ela vai te desafiar a usar IA em 3 situações nos próximos 7 dias."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"You made it here. That already puts you in a very small group of people in the world who truly understand how AI works, where it makes mistakes, how to use it well and how to connect it to the real world."},
    {"type":"text","content":"Think about what you learned: what AI is and how it thinks. How to verify answers and not trust blindly. Which AI to use for each situation. How to give the right context and iterate until perfect. How to use APIs and real data. How to make AI write code and create websites. How to write professional prompts and system prompts. What Claude Code, MCP and Cowork are."},
    {"type":"text","content":"This knowledge will not age quickly — because you did not learn to push buttons. You learned to think with AI. The next step is to practice. Every time you have a problem, ask: how could AI help me here? Use Claude. Experiment. Make mistakes. Iterate. Improve. You are ready. To practice: tell Atena which lesson was most important and how you plan to use what you learned — she will challenge you to use AI in 3 situations in the next 7 days."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-test-mastery',
  'Teste do Stage 6 — Mastery',
  'Stage 6 Test — Mastery',
  'Quiz final para fechar a etapa Mastery',
  'Final quiz to close the Mastery stage',
  '6-18', 6, 6,
  $$[
    {"type":"text","content":"Chegou a hora do teste final do Stage 6! Responda as 2 perguntas e desbloqueie o Projeto Final."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time for the Stage 6 final test! Answer the 2 questions and unlock the Final Project."}
  ]$$::jsonb,
  100, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 4) Insere 12 challenges (2 por licao, multiple_choice, 10 XP cada)

-- s6-claude-code
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"O que diferencia o Claude Code do Claude normal no chat?","options":["O Claude Code só funciona em inglês","O Claude Code age no computador — lê arquivos, escreve código e constrói projetos completos","O Claude Code é mais lento que o chat","O Claude Code só serve para matemática"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-claude-code';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Por que desenvolvedores que usam Claude Code são mais produtivos?","options":["Porque o Claude Code não comete erros nunca","Porque podem descrever o que querem e a IA constrói, enquanto eles focam nas decisões","Porque o Claude Code é gratuito para sempre","Porque o Claude Code substitui completamente o desenvolvedor"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-claude-code';

-- s6-mcp
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"O que é o MCP — Model Context Protocol?","options":["Um novo modelo de IA mais avançado que o Claude Sonnet","Um padrão que permite conectar a IA a ferramentas externas como GitHub, Notion e Google Drive","Uma linguagem de programação criada pela Anthropic","Um protocolo de segurança para criptografar conversas"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-mcp';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a vantagem do MCP em relação a conectar ferramentas manualmente?","options":["O MCP é gratuito enquanto as conexões manuais são pagas","O MCP usa um padrão universal — sempre o mesmo jeito para qualquer ferramenta","O MCP só funciona com ferramentas da Anthropic","O MCP elimina a necessidade de internet"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-mcp';

-- s6-claude-cowork
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a principal diferença entre o Claude Cowork e o Claude no chat?","options":["O Cowork é mais inteligente que o chat","O Cowork executa tarefas reais no computador — clica, abre arquivos e navega — em vez de só conversar","O Cowork só funciona em inglês","O Cowork precisa de internet mais rápida"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-claude-cowork';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Para qual tipo de profissional o Claude Cowork é especialmente útil?","options":["Apenas para programadores e desenvolvedores","Apenas para estudantes de tecnologia","Para qualquer profissional que faz tarefas repetitivas — pesquisadores, advogados, professores, contadores","Apenas para quem tem computador Mac"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's6-claude-cowork';

-- s6-ai-engineer
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"O que faz um AI Engineer?","options":["Cria novos modelos de IA do zero em laboratório","Usa, conecta e orquestra sistemas de IA para construir produtos reais","Conserta computadores que têm problemas com IA","Ensina IA para outras IAs"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-ai-engineer';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Por que aprender a usar IA bem é útil em qualquer carreira?","options":["Porque todas as carreiras vão ser substituídas por IA em breve","Porque a IA vai estar presente em todas as áreas e quem sabe usá-la bem tem vantagem em qualquer caminho","Porque a IA paga um salário direto para quem a usa","Porque só quem usa IA vai conseguir emprego no futuro"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-ai-engineer';

-- s6-construindo-futuro
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença entre aprender a apertar botões de IA e aprender a pensar com IA?","options":["Não há diferença — as duas formas ensinam a mesma coisa","Apertar botões é mais rápido; pensar com IA é mais lento","Aprender a pensar com IA é mais duradouro — você entende os princípios e se adapta a qualquer ferramenta nova","Apertar botões é para profissionais; pensar com IA é para estudantes"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's6-construindo-futuro';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual deve ser o próximo passo depois de terminar esse curso?","options":["Esperar a IA melhorar mais antes de usar de verdade","Praticar — usar IA em problemas reais do dia a dia, experimentar, errar e iterar","Fazer um curso de programação antes de continuar","Ensinar outras IAs a usar o que você aprendeu"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-construindo-futuro';

-- s6-test-mastery (stage test)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Você quer automatizar uma tarefa chata de organizar arquivos no computador sem precisar programar. Qual ferramenta da Anthropic é mais indicada?","options":["Claude no chat normal","Claude Code no terminal","Claude Cowork no desktop","Claude API com Python"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's6-test-mastery';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Seu amigo diz que toda IA é igual e não importa qual usar. O que você responderia?","options":["Você tem razão, tanto faz qual usar","Cada IA tem pontos fortes diferentes — Claude para raciocínio longo, Gemini para Google, ChatGPT para imagens. Escolher a certa faz diferença","A melhor IA é sempre a mais cara","Só o Claude presta, as outras são ruins"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's6-test-mastery';

-- 5) Insere 18 prompt_templates (3 por licao, age_band='6-18', sem slots)

-- s6-claude-code
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Me explica o Claude Code',
  'O que é o Claude Code e como ele é diferente do Claude no chat?',
  '6-18', 1 FROM lessons WHERE slug = 's6-claude-code';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como usaria no meu projeto',
  'Tenho uma ideia de um app de organizar tarefas da escola. Como o Claude Code me ajudaria a construir isso?',
  '6-18', 2 FROM lessons WHERE slug = 's6-claude-code';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quero ser mais produtivo',
  'Como o Claude Code pode me ajudar a fazer mais coisas em menos tempo?',
  '6-18', 3 FROM lessons WHERE slug = 's6-claude-code';

-- s6-mcp
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que é MCP?',
  'Me explica o que é MCP de um jeito simples com um exemplo do dia a dia.',
  '6-18', 1 FROM lessons WHERE slug = 's6-mcp';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'MCP na prática',
  'Como o MCP conectaria a IA ao Spotify? Me dá um exemplo prático.',
  '6-18', 2 FROM lessons WHERE slug = 's6-mcp';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quantos MCPs existem',
  'Quais são os MCPs mais populares e para que cada um serve?',
  '6-18', 3 FROM lessons WHERE slug = 's6-mcp';

-- s6-claude-cowork
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que é Cowork?',
  'Me explica o Claude Cowork de um jeito simples. O que ele consegue fazer que o chat normal não faz?',
  '6-18', 1 FROM lessons WHERE slug = 's6-claude-cowork';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Tarefa que ele faria',
  'Tenho essa tarefa chata: organizar fotos de viagem em pastas por ano. O Claude Cowork conseguiria fazer isso? Como?',
  '6-18', 2 FROM lessons WHERE slug = 's6-claude-cowork';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cowork vs Claude Code',
  'Qual é a diferença entre o Claude Cowork e o Claude Code? Quando uso cada um?',
  '6-18', 3 FROM lessons WHERE slug = 's6-claude-cowork';

-- s6-ai-engineer
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que é AI Engineer?',
  'Me explica o que é um AI Engineer e o que essa profissão faz no dia a dia.',
  '6-18', 1 FROM lessons WHERE slug = 's6-ai-engineer';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA na minha área',
  'Gosto muito de medicina. Como a IA já está sendo usada nessa área?',
  '6-18', 2 FROM lessons WHERE slug = 's6-ai-engineer';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quanto ganha um AI Engineer',
  'Como é a carreira de AI Engineer? Quanto ganha e o que precisa saber?',
  '6-18', 3 FROM lessons WHERE slug = 's6-ai-engineer';

-- s6-construindo-futuro
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que aprendi',
  'Me ajuda a resumir tudo que aprendi nesse curso em 5 pontos principais.',
  '6-18', 1 FROM lessons WHERE slug = 's6-construindo-futuro';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu próximo passo',
  'Quero praticar IA nos próximos 7 dias. Me dá um desafio diferente para cada dia.',
  '6-18', 2 FROM lessons WHERE slug = 's6-construindo-futuro';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Minha área favorita',
  'Gosto de música. Me dá 3 ideias de como posso usar IA nessa área essa semana.',
  '6-18', 3 FROM lessons WHERE slug = 's6-construindo-futuro';

-- s6-test-mastery (3 templates de revisao, espelhando o padrao do teste de Stage 2)
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Revisar a etapa',
  'Me faz um resumo dos 5 conceitos principais que aprendemos nessa etapa: Claude Code, MCP, Cowork, AI Engineer e mentalidade de futuro.',
  '6-18', 1 FROM lessons WHERE slug = 's6-test-mastery';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Praticar mais',
  'Me dá 3 perguntas práticas pra eu testar o que aprendi sobre IA avançada. Sem dar a resposta!',
  '6-18', 2 FROM lessons WHERE slug = 's6-test-mastery';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Pronto pro Projeto Final',
  'Me dá uma motivação curta para encarar o Projeto Final do curso. O que eu vou criar lá?',
  '6-18', 3 FROM lessons WHERE slug = 's6-test-mastery';

COMMIT;
