-- Migration 033: Insere conteudo da Stage 16 "Missao 16 - Como ser master em IA"
--
-- ULTIMA MISSAO DO CURRICULUM V3. Foco: o que separa master de usuario
-- comum (mentalidades de experimento/sistema/curador), tecnicas avancadas
-- (Chain of Thought, Few-Shot, Role Prompting avancado), kit de
-- ferramentas pessoal (biblioteca/fluxos/stack/criterios), aprendizado
-- continuo (estrategia de 3 niveis), e a jornada que comeca agora
-- (3 compromissos: usar todo dia, criar real, ensinar alguem).
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=16, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Apos esta migration o curriculum v3 fica completo: 16 missoes + final
-- exam = 97 licoes totais. Stages 1-16 todas com conteudo.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 16
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's16-usuario-vs-master',
  'O que separa um usuário comum de um master',
  'What separates a regular user from a master',
  'Entender as mentalidades e hábitos que definem um master em IA',
  'Understand the mindsets and habits that define an AI master',
  '6-18', 16, 1,
  $$[
    {"type":"text","content":"Existe uma diferença enorme entre saber sobre IA e ser master em IA. USUÁRIO COMUM: usa IA para tarefas simples, aceita a primeira resposta sem questionar, para de usar quando não funciona. MASTER EM IA: usa IA para tarefas que antes exigiam especialistas, itera sistematicamente até o resultado ser excelente, diagnostica e corrige quando não funciona, trata IA como parceiro criativo e intelectual."},
    {"type":"text","content":"A diferença não está na inteligência. Está na mentalidade e na prática. Master não é um título — é um hábito. Três mentalidades de master: MENTALIDADE DE EXPERIMENTO — todo prompt é uma hipótese. Se não funcionou você aprendeu algo. Ajusta e tenta de novo. MENTALIDADE DE SISTEMA — um bom sistema resolve sempre. Masters constroem sistemas não fazem pedidos únicos."},
    {"type":"text","content":"MENTALIDADE DE CURADOR — masters selecionam, refinam e melhoram continuamente. Não aceitam mediocridade porque sabem que melhor é possível. Estas três mentalidades juntas criam alguém que fica mais poderoso a cada semana de uso."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is an enormous difference between knowing about AI and being an AI master. REGULAR USER: uses AI for simple tasks, accepts the first response without questioning, stops using when it does not work. AI MASTER: uses AI for tasks that previously required specialists, iterates systematically until the result is excellent, diagnoses and corrects when it does not work, treats AI as a creative and intellectual partner."},
    {"type":"text","content":"The difference is not intelligence. It is mindset and practice. Master is not a title — it is a habit. Three master mindsets: EXPERIMENT MINDSET — every prompt is a hypothesis. If it did not work you learned something. Adjust and try again. SYSTEM MINDSET — a good system always works. Masters build systems not one-off requests."},
    {"type":"text","content":"CURATOR MINDSET — masters select, refine and continuously improve. They do not accept mediocrity because they know better is possible. These three mindsets together create someone who gets more powerful every week of use."}
  ]$$::jsonb,
  'A criança descreve como usa IA hoje e a Atena ajuda a identificar onde está no espectro usuário/master e quais hábitos desenvolver para avançar.',
  'The child describes how they use AI today and Atena helps identify where they are on the user/master spectrum and which habits to develop to advance.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's16-tecnicas-avancadas-prompt',
  'Técnicas avançadas de prompt',
  'Advanced prompt techniques',
  'Aprender Chain of Thought, Few-Shot e Role Prompting avançado',
  'Learn Chain of Thought, Few-Shot and advanced Role Prompting',
  '6-18', 16, 2,
  $$[
    {"type":"text","content":"CHAIN OF THOUGHT — em vez de pedir a resposta direto, peça para a IA pensar em voz alta. Antes de responder explica passo a passo como você está pensando sobre isso. Por que funciona: a IA produz respostas melhores quando mostra o trabalho assim como humanos raciocinam melhor quando verbalizam. FEW-SHOT PROMPTING — você dá exemplos do que quer antes de fazer o pedido. Aqui estão 3 exemplos de títulos que funcionam: [exemplos]. Agora cria 10 para este tema."},
    {"type":"text","content":"Por que funciona: exemplos concretos comunicam o padrão que você quer melhor que qualquer descrição abstrata. ROLE PROMPTING AVANÇADO — não apenas você é um professor mas você é um professor de física de 20 anos de experiência que especializa em fazer crianças entenderem conceitos complexos através de analogias do cotidiano. Nunca usa jargão sem explicar e sempre verifica se o aluno entendeu. Quanto mais específico o papel, mais consistente o comportamento."},
    {"type":"text","content":"OUTPUT FORMATTING — especifique exatamente o formato da saída. Responde em JSON com os campos: título, resumo de máximo 2 frases, e 3 tags. Masters controlam o output não apenas o input. A combinação dessas técnicas transforma prompts medianos em sistemas de produção profissional."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"CHAIN OF THOUGHT — instead of asking for the answer directly, ask AI to think out loud. Before answering, explain step by step how you are thinking about this. Why it works: AI produces better responses when it shows the work just as humans reason better when they verbalize their thinking. FEW-SHOT PROMPTING — you give examples of what you want before making the request. Here are 3 examples of titles that work: [examples]. Now create 10 for this topic."},
    {"type":"text","content":"Why it works: concrete examples communicate the pattern you want better than any abstract description. ADVANCED ROLE PROMPTING — not just you are a teacher but you are a physics teacher with 20 years of experience who specializes in making children understand complex concepts through everyday analogies. Never uses jargon without explaining and always checks if the student understood. The more specific the role the more consistent the behavior."},
    {"type":"text","content":"OUTPUT FORMATTING — specify exactly the output format. Respond in JSON with fields: title, summary of maximum 2 sentences, and 3 tags. Masters control the output not just the input. Combining these techniques transforms average prompts into professional production systems."}
  ]$$::jsonb,
  'A criança pega um pedido com resultado mediano e a Atena ajuda a reescrever usando Chain of Thought Few-Shot e Role Prompting avançado. Compara os resultados.',
  'The child takes a request with mediocre results and Atena helps rewrite it using Chain of Thought Few-Shot and advanced Role Prompting. Compares results.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's16-kit-ferramentas-pessoal',
  'Construindo seu kit de ferramentas pessoal',
  'Building your personal toolkit',
  'Aprender a construir e manter uma biblioteca pessoal de prompts e fluxos',
  'Learn to build and maintain a personal library of prompts and workflows',
  '6-18', 16, 3,
  $$[
    {"type":"text","content":"Masters não reinventam a roda toda vez. Eles constroem e mantêm um kit de ferramentas pessoal. O que vai no seu kit: BIBLIOTECA DE PROMPTS — uma coleção de prompts que funcionam bem para tarefas frequentes, guardados num documento, organizados por categoria, cada um testado e refinado. FLUXOS DE TRABALHO — sequências de passos com IA para tarefas complexas. Para pesquisar um assunto: primeiro peço mapa mental, depois aprofundo cada nó, depois verifico fontes."},
    {"type":"text","content":"TEMPLATES DE SISTEMAS — estruturas reutilizáveis. O system prompt que você usa para escrever, para analisar, para criar. Refinado com o tempo. STACK DE IAs — qual IA para cada tipo de tarefa. Quando usar Claude, ChatGPT, Gemini, IA de imagem. CRITÉRIOS DE QUALIDADE — o que significa bom o suficiente para cada tipo de output e quando parar de iterar."},
    {"type":"text","content":"O kit cresce com o tempo. Um prompt refinado 10 vezes vale muito mais que um novo prompt escrito na hora. Masters investem no kit porque ele multiplica a produtividade de tudo que fazem depois. Cada hora investida no kit retorna dezenas de horas economizadas."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Masters do not reinvent the wheel every time. They build and maintain a personal toolkit. What goes in your kit: PROMPT LIBRARY — a collection of prompts that work well for frequent tasks, saved in a document, organized by category, each tested and refined. WORKFLOWS — sequences of steps with AI for complex tasks. To research a subject: first ask for a mind map, then deepen each node, then verify sources."},
    {"type":"text","content":"SYSTEM TEMPLATES — reusable structures. The system prompt you use for writing, for analyzing, for creating. Refined over time. AI STACK — which AI for each type of task. When to use Claude, ChatGPT, Gemini, image AI. QUALITY CRITERIA — what good enough means for each type of output and when to stop iterating."},
    {"type":"text","content":"The kit grows over time. A prompt refined 10 times is worth much more than a new prompt written on the spot. Masters invest in the kit because it multiplies the productivity of everything they do afterward. Every hour invested in the kit returns dozens of hours saved."}
  ]$$::jsonb,
  'A criança identifica 3 tarefas frequentes com IA e a Atena ajuda a criar o prompt ideal para cada uma e organizar o começo da biblioteca pessoal.',
  'The child identifies 3 frequent AI tasks and Atena helps create the ideal prompt for each and organize the beginning of the personal library.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's16-aprendizado-continuo',
  'Aprendizado contínuo — como ficar atualizado',
  'Continuous learning — how to stay updated',
  'Aprender a estratégia de 3 níveis para acompanhar a evolução da IA',
  'Learn the 3-level strategy to follow AI evolution',
  '6-18', 16, 4,
  $$[
    {"type":"text","content":"IA está mudando mais rápido que qualquer outra tecnologia da história. Como um master se mantém atualizado sem virar escravo de notícias? A estratégia dos 3 níveis: NÍVEL 1 — MONITORAR (15 min por semana): acompanhar grandes lançamentos e mudanças. Não precisa ler tudo — só saber o que aconteceu de importante. Fontes: Twitter de pesquisadores de IA, newsletters como The Rundown AI, blogs da Anthropic e OpenAI."},
    {"type":"text","content":"NÍVEL 2 — EXPERIMENTAR (1 a 2 horas por semana): quando algo novo e relevante lançar você testa. Não lê sobre — usa. Cria um projeto pequeno. Compara com o que usava antes. A experiência direta ensina mais que qualquer artigo. NÍVEL 3 — APROFUNDAR (quando relevante): quando uma área se torna central para o que você faz você aprofunda. Lê artigos técnicos e faz cursos. Mas só quando é estratégico."},
    {"type":"text","content":"A armadilha do FOMO de IA: sentir que precisa aprender cada ferramenta nova que lança é uma armadilha. A maioria não sobrevive. Foque em fundamentos sólidos — que é o que este curso te deu — e adicione camadas específicas quando fizer sentido. Regra de ouro: você não precisa conhecer todas as IAs. Você precisa dominar as que usa e estar ciente das que importam."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI is changing faster than any other technology in history. How does a master stay updated without becoming a slave to news? The 3-level strategy: LEVEL 1 — MONITOR (15 min per week): follow major launches and changes. You do not need to read everything — just know what was important. Sources: AI researchers Twitter, newsletters like The Rundown AI, Anthropic and OpenAI blogs."},
    {"type":"text","content":"LEVEL 2 — EXPERIMENT (1 to 2 hours per week): when something new and relevant launches you test it. You do not read about it — you use it. Create a small project. Compare with what you used before. Direct experience teaches more than any article. LEVEL 3 — DEEPEN (when relevant): when an area becomes central to what you do you go deep. Read technical articles and take courses. But only when it is strategic."},
    {"type":"text","content":"The AI FOMO trap: feeling that you need to learn every new tool that launches is a trap. Most do not survive. Focus on solid fundamentals — which is what this course gave you — and add specific layers when it makes sense. Golden rule: you do not need to know all AIs. You need to master the ones you use and be aware of the ones that matter."}
  ]$$::jsonb,
  'A criança e a Atena criam um plano de aprendizado contínuo personalizado — quais fontes acompanhar quanto tempo dedicar e como decidir o que realmente vale aprender.',
  'The child and Atena create a personalized continuous learning plan — which sources to follow how much time to dedicate and how to decide what is really worth learning.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's16-sua-jornada-comeca-agora',
  'Sua jornada começa agora',
  'Your journey begins now',
  'Consolidar o aprendizado e definir os próximos passos concretos',
  'Consolidate learning and define the next concrete steps',
  '6-18', 16, 5,
  $$[
    {"type":"text","content":"Você completou as 16 missões. Mas o aprendizado real começa agora — na prática, nos projetos reais, nos erros que você vai cometer e resolver. O que você tem que a maioria das pessoas não tem: você entende o que IA faz por baixo. Você sabe como se comunicar com IA de forma eficaz. Você conhece os tipos de IA e quando usar cada um. Você sabe criar coisas reais. Você entende os riscos e como navegar com responsabilidade."},
    {"type":"text","content":"Os três compromissos de um master: 1) USE TODO DIA — não como entretenimento mas como ferramenta de trabalho, estudo e criação. Masters usam IA em tudo, não de vez em quando. 2) CRIE ALGO REAL — um projeto real com usuário real com feedback real ensina mais que mil horas de teoria. A diferença entre quem sabe e quem domina é simples: quem domina fez."},
    {"type":"text","content":"3) ENSINE ALGUÉM — a forma mais rápida de consolidar conhecimento é explicar para outra pessoa. Ensine um amigo, um familiar, alguém que não sabe nada sobre IA. Você vai descobrir o que realmente entendeu e o que ainda é superficial. A IA mais poderosa do mundo não vale nada nas mãos de alguém que não sabe usá-la. Você sabe. Agora use."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"You have completed all 16 missions. But real learning begins now — in practice, in real projects, in the mistakes you will make and solve. What you have that most people do not: you understand what AI does underneath. You know how to communicate with AI effectively. You know the types of AI and when to use each. You know how to create real things. You understand the risks and how to navigate responsibly."},
    {"type":"text","content":"The three commitments of a master: 1) USE IT EVERY DAY — not as entertainment but as a tool for work, study and creation. Masters use AI in everything, not occasionally. 2) CREATE SOMETHING REAL — a real project with a real user with real feedback teaches more than a thousand hours of theory. The difference between those who know and those who master is simple: those who master have done."},
    {"type":"text","content":"3) TEACH SOMEONE — the fastest way to consolidate knowledge is to explain it to another person. Teach a friend, a family member, someone who knows nothing about AI. You will discover what you truly understood and what is still superficial. The most powerful AI in the world is worth nothing in the hands of someone who does not know how to use it. You know. Now use it."}
  ]$$::jsonb,
  'A criança define seu próximo projeto real com IA — algo concreto para uma pessoa real que vai construir nos próximos 30 dias. A Atena ajuda a dar o primeiro passo hoje.',
  'The child defines their next real project with AI — something concrete for a real person to build in the next 30 days. Atena helps take the first step today.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's16-teste-missao-16',
  'Teste — Missão 16',
  'Test — Mission 16',
  'Quiz para fechar a Missão 16 e desbloquear o Projeto Final',
  'Quiz to complete Mission 16 and unlock the Final Project',
  '6-18', 16, 6,
  $$[
    {"type":"text","content":"Última missão, último teste! Responda as 2 perguntas e desbloqueie o Projeto Final — o desafio que vai colocar tudo que você aprendeu em prática."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Last mission, last test! Answer the 2 questions and unlock the Final Project — the challenge that will put everything you learned into practice."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s16-usuario-vs-master
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que diferencia um master em IA de um usuário comum?","options":["O master tem acesso a modelos mais avançados que o público geral","O master itera sistematicamente entende padrões e trata IA como parceiro criativo","O master sabe programar em Python e JavaScript","O master usa IA por mais horas por dia que o usuário comum"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What differentiates an AI master from a regular user?',
  $$["The master has access to more advanced models than the general public","The master iterates systematically understands patterns and treats AI as a creative partner","The master knows how to program in Python and JavaScript","The master uses AI for more hours per day than the regular user"]$$::jsonb
FROM lessons WHERE slug = 's16-usuario-vs-master';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa ter mentalidade de sistema em IA?","options":["Usar sempre o mesmo prompt para economizar tempo","Construir prompts e fluxos reutilizáveis que resolvem consistentemente em vez de fazer pedidos únicos","Aprender a programar sistemas complexos de IA","Usar múltiplas IAs ao mesmo tempo para comparar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does having a system mindset in AI mean?',
  $$["Always using the same prompt to save time","Building reusable prompts and workflows that consistently solve problems instead of making one-off requests","Learning to program complex AI systems","Using multiple AIs at the same time to compare"]$$::jsonb
FROM lessons WHERE slug = 's16-usuario-vs-master';

-- s16-tecnicas-avancadas-prompt
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é Chain of Thought prompting?","options":["Um prompt que pergunta várias coisas em sequência","Pedir para a IA explicar o raciocínio passo a passo antes de chegar à resposta final","Uma técnica para conectar múltiplos prompts em cadeia","Um prompt que começa com a resposta e pede para IA justificar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is Chain of Thought prompting?',
  $$["A prompt that asks multiple things in sequence","Asking AI to explain the reasoning step by step before reaching the final answer","A technique to connect multiple prompts in a chain","A prompt that starts with the answer and asks AI to justify"]$$::jsonb
FROM lessons WHERE slug = 's16-tecnicas-avancadas-prompt';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que Few-Shot Prompting funciona melhor que descrever o padrão abstratamente?","options":["Porque exemplos são mais curtos e economizam tokens","Porque exemplos concretos comunicam o padrão desejado com mais precisão do que qualquer descrição abstrata","Porque a IA foi treinada especificamente para seguir exemplos","Porque descrições abstratas confundem o modelo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does Few-Shot Prompting work better than describing the pattern abstractly?',
  $$["Because examples are shorter and save tokens","Because concrete examples communicate the desired pattern with more precision than any abstract description","Because AI was specifically trained to follow examples","Because abstract descriptions confuse the model"]$$::jsonb
FROM lessons WHERE slug = 's16-tecnicas-avancadas-prompt';

-- s16-kit-ferramentas-pessoal
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma biblioteca de prompts?","options":["Um site onde você encontra prompts criados por outras pessoas","Uma coleção pessoal de prompts testados e refinados organizados para reutilização em tarefas frequentes","Os prompts que a própria IA sugere durante a conversa","A documentação oficial de como criar prompts para cada modelo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is a prompt library?',
  $$["A site where you find prompts created by other people","A personal collection of tested and refined prompts organized for reuse in frequent tasks","The prompts AI itself suggests during the conversation","The official documentation on how to create prompts for each model"]$$::jsonb
FROM lessons WHERE slug = 's16-kit-ferramentas-pessoal';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que um prompt refinado 10 vezes vale mais que um novo prompt escrito na hora?","options":["Porque prompts mais antigos têm acesso a versões melhores do modelo","Porque cada refinamento incorpora aprendizado real sobre o que funciona criando um instrumento muito mais preciso","Porque prompts mais longos funcionam melhor que prompts curtos","Porque a IA memoriza prompts frequentemente usados"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is a prompt refined 10 times worth more than a new prompt written on the spot?',
  $$["Because older prompts have access to better versions of the model","Because each refinement incorporates real learning about what works creating a much more precise instrument","Because longer prompts work better than short prompts","Because AI memorizes frequently used prompts"]$$::jsonb
FROM lessons WHERE slug = 's16-kit-ferramentas-pessoal';

-- s16-aprendizado-continuo
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que experimentar uma nova ferramenta de IA é melhor do que só ler sobre ela?","options":["Porque economiza tempo — você não precisa ler artigos longos","Porque a experiência direta revela o que realmente funciona de um jeito que nenhum artigo consegue transmitir","Porque ler sobre IA é considerado menos eficiente por pesquisadores","Porque artigos sobre IA geralmente contêm informações erradas"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is experimenting with a new AI tool better than just reading about it?',
  $$["Because it saves time — you do not need to read long articles","Because direct experience reveals what really works in a way no article can convey","Because reading about AI is considered less efficient by researchers","Because articles about AI generally contain wrong information"]$$::jsonb
FROM lessons WHERE slug = 's16-aprendizado-continuo';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é a armadilha do FOMO de IA?","options":["Ter medo de que a IA vai tomar seu emprego","Sentir que precisa aprender cada nova ferramenta que lança desperdiçando energia em coisas que não sobrevivem","Compartilhar informações falsas sobre IA por medo de ficar desatualizado","Usar muitas IAs ao mesmo tempo e não dominar nenhuma completamente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the AI FOMO trap?',
  $$["Being afraid that AI will take your job","Feeling that you need to learn every new tool that launches wasting energy on things that do not survive","Sharing false information about AI for fear of being outdated","Using many AIs at the same time and not mastering any of them completely"]$$::jsonb
FROM lessons WHERE slug = 's16-aprendizado-continuo';

-- s16-sua-jornada-comeca-agora
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que criar um projeto real com usuário real ensina mais que teoria?","options":["Porque projetos reais aparecem em portfólios e ajudam a conseguir emprego","Porque o contato com feedback real erros inesperados e decisões de verdade cria aprendizado que nenhuma teoria consegue simular","Porque a IA funciona melhor quando usada em projetos com usuários","Porque teoria de IA está desatualizada e projetos práticos usam os modelos mais novos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does creating a real project with a real user teach more than theory?',
  $$["Because real projects appear in portfolios and help get jobs","Because contact with real feedback unexpected errors and real decisions creates learning that no theory can simulate","Because AI works better when used in projects with users","Because AI theory is outdated and practical projects use newer models"]$$::jsonb
FROM lessons WHERE slug = 's16-sua-jornada-comeca-agora';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que ensinar alguém é uma das melhores formas de consolidar conhecimento?","options":["Porque professores de IA ganham bem e é uma boa oportunidade de renda","Porque ao explicar para outros você descobre o que realmente entendeu e o que ainda é superficial","Porque a IA melhora seus prompts quando você usa ela para ensinar","Porque comunidades de aprendizado têm acesso a ferramentas premium"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is teaching someone one of the best ways to consolidate knowledge?',
  $$["Because AI teachers earn well and it is a good income opportunity","Because by explaining to others you discover what you truly understood and what is still superficial","Because AI improves your prompts when you use it to teach","Because learning communities have access to premium tools"]$$::jsonb
FROM lessons WHERE slug = 's16-sua-jornada-comeca-agora';

-- s16-teste-missao-16 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você quer criar um sistema para escrever e-mails profissionais de forma consistente. O que um master faria?","options":["Pediria para a IA memorizar as preferências automaticamente","Criaria um template de system prompt refinado e o salvaria na biblioteca pessoal para reutilizar em todos os e-mails","Usaria a IA de forma diferente para cada e-mail para aprender variações","Pagaria por uma IA especializada em e-mails corporativos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You want to create a system to write professional emails consistently. What would a master do?',
  $$["Ask AI to memorize preferences automatically","Create a refined system prompt template and save it in the personal library to reuse for all emails","Use AI differently for each email to learn variations","Pay for an AI specialized in corporate emails"]$$::jsonb
FROM lessons WHERE slug = 's16-teste-missao-16';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Uma nova IA lançou com muito hype. Como um master decide se vale aprender?","options":["Aprende imediatamente porque ficar desatualizado é o maior risco","Ignora completamente porque a maioria dos lançamentos não sobrevive","Testa durante 1 a 2 horas para ter experiência direta e decide se é relevante para o seu caminho específico","Espera 6 meses para ver se os outros continuam usando"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'A new AI launched with lots of hype. How does a master decide if it is worth learning?',
  $$["Learns immediately because being outdated is the biggest risk","Ignores completely because most launches do not survive","Tests for 1 to 2 hours to have direct experience and decides if it is relevant to their specific path","Waits 6 months to see if others continue using it"]$$::jsonb
FROM lessons WHERE slug = 's16-teste-missao-16';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s16-usuario-vs-master
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Avalia meu nível', 'Me faz 5 perguntas para avaliar meu nível atual como usuário de IA e me diz onde estou no espectro usuário/master.', '6-18', 1
FROM lessons WHERE slug = 's16-usuario-vs-master';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Próximos hábitos', 'Uso IA principalmente para [tarefas]. Quais 3 hábitos devo desenvolver para me tornar um usuário mais avançado?', '6-18', 2
FROM lessons WHERE slug = 's16-usuario-vs-master';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Diagnóstico de prompt', 'Esse prompt que uso frequentemente: [prompt]. O que um master mudaria nele para obter resultados melhores?', '6-18', 3
FROM lessons WHERE slug = 's16-usuario-vs-master';

-- s16-tecnicas-avancadas-prompt
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Aplica Chain of Thought', 'Preciso que você resolva [problema]. Antes de responder explica passo a passo como está pensando e quais são as opções que está considerando.', '6-18', 1
FROM lessons WHERE slug = 's16-tecnicas-avancadas-prompt';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Few-Shot na prática', 'Aqui estão 3 exemplos do resultado que quero: [exemplos]. Agora aplica o mesmo padrão para: [novo pedido].', '6-18', 2
FROM lessons WHERE slug = 's16-tecnicas-avancadas-prompt';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Role prompting avançado', 'Me ajuda a criar um role prompt detalhado para uma IA que vai me ajudar com [tarefa específica].', '6-18', 3
FROM lessons WHERE slug = 's16-tecnicas-avancadas-prompt';

-- s16-kit-ferramentas-pessoal
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria meu prompt master', 'Faço frequentemente essa tarefa com IA: [descreve]. Me ajuda a criar o prompt ideal para isso — testado com Chain of Thought e Role Prompting avançado.', '6-18', 1
FROM lessons WHERE slug = 's16-kit-ferramentas-pessoal';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu stack de IAs', 'Uso principalmente IA para [lista de tarefas]. Me ajuda a definir qual IA usar para cada tarefa e por quê.', '6-18', 2
FROM lessons WHERE slug = 's16-kit-ferramentas-pessoal';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Organiza minha biblioteca', 'Tenho esses prompts que uso com frequência: [lista]. Me ajuda a organizá-los em categorias e identificar qual deles precisa de mais refinamento.', '6-18', 3
FROM lessons WHERE slug = 's16-kit-ferramentas-pessoal';

-- s16-aprendizado-continuo
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu plano de atualização', 'Me ajuda a criar um plano de 15 minutos por semana para acompanhar as novidades de IA mais relevantes para [meus interesses].', '6-18', 1
FROM lessons WHERE slug = 's16-aprendizado-continuo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Vale a pena aprender?', 'Lançou [ferramenta de IA]. Vale a pena eu aprender? Me ajuda a decidir baseado no que já uso e nos meus objetivos.', '6-18', 2
FROM lessons WHERE slug = 's16-aprendizado-continuo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Fontes de qualidade', 'Quero me manter atualizado sobre IA sem perder muito tempo. Quais são as 3 melhores fontes para acompanhar?', '6-18', 3
FROM lessons WHERE slug = 's16-aprendizado-continuo';

-- s16-sua-jornada-comeca-agora
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu próximo projeto', 'Quero criar algo real com IA nos próximos 30 dias. Me ajuda a definir um projeto concreto para [pessoa específica] e os 3 primeiros passos para começar hoje.', '6-18', 1
FROM lessons WHERE slug = 's16-sua-jornada-comeca-agora';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como ensinar IA', 'Quero ensinar meu [familiar ou amigo] sobre IA. Ele tem [idade] e sabe [nível]. Me ajuda a criar um plano de 3 conversas para introduzir os conceitos mais importantes.', '6-18', 2
FROM lessons WHERE slug = 's16-sua-jornada-comeca-agora';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu compromisso de master', 'Quero me tornar master em IA. Me ajuda a criar um compromisso específico e realizável para os próximos 90 dias.', '6-18', 3
FROM lessons WHERE slug = 's16-sua-jornada-comeca-agora';

COMMIT;
