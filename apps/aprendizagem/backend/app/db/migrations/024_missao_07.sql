-- Migration 024: Insere conteudo da Stage 7 "Missao 07 - IA para estudos"
--
-- Foco: estudar com IA - professor particular 24h, perguntas profundas vs
-- rasas, organizacao de estudos (cronograma/flashcards/mapas mentais),
-- aprender idiomas via conversacao, e a linha entre usar IA pra aprender
-- vs colar ("se a IA fizer tudo por voce, quem deixa de aprender e' voce").
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=7, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 7
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's7-ia-professor-particular',
  'IA como professor particular',
  'AI as a private tutor',
  'Descobrir como usar IA para aprender de verdade, não só obter respostas',
  'Discover how to use AI to truly learn, not just get answers',
  '6-18', 7, 1,
  $$[
    {"type":"text","content":"Imagina ter um professor particular disponível 24 horas por dia que nunca fica impaciente, explica quantas vezes for necessário e adapta a explicação para o seu nível. Esse professor existe — é a IA. A diferença entre usar IA de forma passiva e ativa no aprendizado é enorme. Passivo é perguntar o que é fotossíntese e copiar a resposta. Ativo é usar a IA para realmente entender."},
    {"type":"text","content":"O segredo é sempre dizer seu nível e contexto: Tenho 10 anos e estou aprendendo isso pela primeira vez gera uma resposta completamente diferente de Explica fotossíntese. A IA adapta vocabulário, exemplos e profundidade quando você dá esse contexto. Isso é usar IA de forma inteligente."},
    {"type":"text","content":"Outra técnica poderosa: pedir para a IA explicar de múltiplas formas. Explica usando uma analogia com algo do cotidiano. Agora explica como se eu fosse um cientista. Explica em 3 tópicos simples. Cada ângulo diferente solidifica o entendimento e ajuda você a realmente aprender, não só memorizar."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Imagine having a private tutor available 24 hours a day that never gets impatient, explains as many times as needed and adapts the explanation to your level. That tutor exists — it is AI. The difference between using AI passively and actively in learning is enormous. Passive is asking what photosynthesis is and copying the answer. Active is using AI to truly understand."},
    {"type":"text","content":"The secret is always telling your level and context: I am 10 years old and learning this for the first time generates a completely different response than just Explain photosynthesis. AI adapts vocabulary, examples and depth when you give that context. That is using AI intelligently."},
    {"type":"text","content":"Another powerful technique: ask AI to explain in multiple ways. Explain using an analogy from everyday life. Now explain as if I were a scientist. Explain in 3 simple points. Each different angle solidifies understanding and helps you truly learn, not just memorize."}
  ]$$::jsonb,
  'A criança escolhe um assunto difícil e a Atena explica de 3 formas diferentes. Objetivo: ver como múltiplas perspectivas solidificam o entendimento.',
  'The child picks a difficult subject and Atena explains it 3 different ways. Goal: see how multiple perspectives solidify understanding.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's7-perguntas-aprendizado-real',
  'Como fazer perguntas que geram aprendizado real',
  'How to ask questions that generate real learning',
  'Aprender a diferença entre perguntas rasas e perguntas profundas',
  'Learn the difference between shallow and deep questions',
  '6-18', 7, 2,
  $$[
    {"type":"text","content":"A qualidade da sua aprendizagem com IA depende diretamente da qualidade das suas perguntas. Perguntas rasas geram aprendizado raso. Perguntas profundas geram aprendizado profundo. Perguntas rasas: O que é X? Me fala sobre Y. Explica Z."},
    {"type":"text","content":"Perguntas que geram aprendizado real: Por que X funciona dessa forma e não de outra? Qual é a conexão entre X e Y? Me dá um exemplo de como X aparece no meu dia a dia. Se X não existisse, o que seria diferente no mundo? Quais são as exceções onde X não funciona? Como X evoluiu ao longo do tempo?"},
    {"type":"text","content":"A diferença entre decorar e aprender é essa: decorar é guardar a resposta. Aprender é entender o porquê, ver as conexões e conseguir aplicar em situações novas. A IA é uma ferramenta de aprendizado extraordinária quando você usa ela para explorar, não apenas para obter respostas prontas."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"The quality of your learning with AI depends directly on the quality of your questions. Shallow questions generate shallow learning. Deep questions generate deep learning. Shallow questions: What is X? Tell me about Y. Explain Z."},
    {"type":"text","content":"Questions that generate real learning: Why does X work this way and not another? What is the connection between X and Y? Give me an example of how X appears in my daily life. If X did not exist what would be different in the world? What are the exceptions where X does not work? How has X evolved over time?"},
    {"type":"text","content":"The difference between memorizing and truly learning is this: memorizing is storing the answer. Learning is understanding the why, seeing the connections and being able to apply in new situations. AI is an extraordinary learning tool when you use it to explore, not just to get ready answers."}
  ]$$::jsonb,
  'A criança transforma perguntas rasas em perguntas profundas com ajuda da Atena. Compara as respostas e vê a diferença no aprendizado.',
  'The child transforms shallow questions into deep questions with Atenas help. Compares responses and sees the difference in learning.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's7-organizar-estudos',
  'IA para organizar estudos e criar rotinas',
  'AI to organize studies and create routines',
  'Aprender a usar IA para criar sistemas personalizados de estudo',
  'Learn to use AI to create personalized study systems',
  '6-18', 7, 3,
  $$[
    {"type":"text","content":"Uma das formas mais práticas de usar IA é para organização de estudos. A IA consegue criar sistemas personalizados que se adaptam ao seu estilo, tempo disponível e objetivos. O que a IA pode criar: CRONOGRAMA DE ESTUDOS — com base nas suas matérias e provas, a IA monta um plano semanal realista. MAPAS MENTAIS — a IA organiza conceitos em forma de mapa mostrando conexões entre ideias."},
    {"type":"text","content":"RESUMOS PERSONALIZADOS — em vez de copiar o resumo do livro, você pede para a IA criar um resumo focado no que você ainda não domina. FLASHCARDS — perguntas e respostas para revisão ativa, comprovadamente a técnica mais eficaz para memorização. PLANO DE REVISÃO — baseado na ciência da memória, a IA cria um calendário de revisão espaçada para você lembrar mais com menos esforço."},
    {"type":"text","content":"O mais importante: a IA organiza, mas você executa. Um cronograma perfeito que não é seguido não vale nada. Use a IA para criar o sistema — depois você é responsável por mantê-lo. A disciplina ainda é humana."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"One of the most practical ways to use AI is for study organization. AI can create personalized systems that adapt to your style, available time and goals. What AI can create: STUDY SCHEDULE — based on your subjects and exams, AI builds a realistic weekly plan. MIND MAPS — AI organizes concepts in map form showing connections between ideas."},
    {"type":"text","content":"PERSONALIZED SUMMARIES — instead of copying the book summary, you ask AI to create a summary focused on what you have not mastered yet. FLASHCARDS — questions and answers for active review, proven to be the most effective technique for memorization. REVISION PLAN — based on memory science, AI creates a spaced repetition calendar for you to remember more with less effort."},
    {"type":"text","content":"The most important thing: AI organizes, but you execute. A perfect schedule that is not followed is worth nothing. Use AI to create the system — then you are responsible for maintaining it. Discipline is still human."}
  ]$$::jsonb,
  'A criança descreve suas matérias e tempo disponível. A Atena cria um cronograma e flashcards para uma matéria específica.',
  'The child describes their subjects and available time. Atena creates a schedule and flashcards for a specific subject.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's7-ia-aprender-idiomas',
  'IA para aprender idiomas',
  'AI to learn languages',
  'Descobrir como usar IA como parceiro de conversa para aprender idiomas',
  'Discover how to use AI as a conversation partner to learn languages',
  '6-18', 7, 4,
  $$[
    {"type":"text","content":"Aprender um novo idioma é uma das habilidades mais valiosas que existe. E a IA transformou completamente como isso é possível. Antes você precisava de um professor caro ou de viver em outro país. Hoje você tem um parceiro de conversa fluente em qualquer idioma disponível 24 horas por dia, de graça."},
    {"type":"text","content":"Como usar IA para aprender idiomas: CONVERSAÇÃO — a IA conversa com você no idioma que está aprendendo, corrige gentilmente e explica os erros. VOCABULÁRIO EM CONTEXTO — você aprende palavras novas dentro de frases e histórias reais, não em listas. CORREÇÃO DE TEXTO — você escreve um parágrafo e a IA corrige e explica de forma natural. IMERSÃO TEMÁTICA — aprende vocabulário sobre temas que te interessam."},
    {"type":"text","content":"O segredo: consistência. 15 minutos por dia com a IA vale mais do que 2 horas uma vez por semana. A memória consolida melhor com prática regular e distribuída. Começar com temas que você já ama — games, música, esporte — torna o processo muito mais natural e divertido."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Learning a new language is one of the most valuable skills there is. And AI has completely transformed how that is possible. Before you needed an expensive teacher or to live in another country. Today you have a fluent conversation partner in any language available 24 hours a day, for free."},
    {"type":"text","content":"How to use AI to learn languages: CONVERSATION — AI talks with you in the language you are learning, gently corrects and explains errors. VOCABULARY IN CONTEXT — you learn new words in real sentences and stories, not lists. TEXT CORRECTION — you write a paragraph and AI corrects and explains naturally. THEMATIC IMMERSION — learn vocabulary about topics you love."},
    {"type":"text","content":"The secret: consistency. 15 minutes a day with AI is worth more than 2 hours once a week. Memory consolidates better with regular distributed practice. Starting with topics you already love — games, music, sports — makes the process much more natural and fun."}
  ]$$::jsonb,
  'A criança escolhe um idioma e a Atena começa uma conversa simples nesse idioma corrigindo erros e explicando o porquê.',
  'The child picks a language and Atena starts a simple conversation in that language correcting errors and explaining why.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's7-ia-cola-linha-nao-cruzar',
  'IA e cola — a linha que não deve ser cruzada',
  'AI and cheating — the line that must not be crossed',
  'Entender a diferença ética e prática entre usar IA para aprender e para colar',
  'Understand the ethical and practical difference between using AI to learn and to cheat',
  '6-18', 7, 5,
  $$[
    {"type":"text","content":"Esta é uma das lições mais importantes para sua vida escolar: a diferença entre usar IA para aprender e usar IA para colar. USAR IA PARA APRENDER: você pesquisa o tema, forma suas ideias, escreve um rascunho. Usa a IA para verificar informações, melhorar a estrutura e corrigir erros. O pensamento é seu. A IA é uma ferramenta de melhoria."},
    {"type":"text","content":"USAR IA PARA COLAR: você pede para a IA escrever a tarefa. Copia e entrega como se fosse seu. Você não aprendeu nada. O professor avaliou o trabalho da IA, não o seu. E o mais importante: você perdeu a oportunidade de desenvolver uma habilidade que vai importar na sua vida."},
    {"type":"text","content":"A diferença não é só ética — é prática. Escrever, raciocinar, argumentar, criar — essas habilidades se desenvolvem com prática. Se a IA pratica por você, você não desenvolve. A frase que define tudo: se a IA fizer tudo por você, quem deixa de aprender é você."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"This is one of the most important lessons for your school life: the difference between using AI to learn and using AI to cheat. USING AI TO LEARN: you research the topic, form your ideas, write a draft. You use AI to verify information, improve structure and correct errors. The thinking is yours. AI is an improvement tool."},
    {"type":"text","content":"USING AI TO CHEAT: you ask AI to write the assignment. You copy and submit as if it were yours. You learned nothing. The teacher evaluated AI work, not yours. And most importantly: you missed the opportunity to develop a skill that will matter in your life."},
    {"type":"text","content":"The difference is not just ethical — it is practical. Writing, reasoning, arguing, creating — these skills develop with practice. If AI practices for you, you do not develop. The phrase that defines it all: if AI does everything for you, the one who stops learning is you."}
  ]$$::jsonb,
  'A criança descreve uma tarefa escolar e a Atena ajuda a criar um plano de uso ético — o que a IA pode ajudar e o que a criança deve fazer sozinha.',
  'The child describes a school task and Atena helps create an ethical use plan — what AI can help with and what the child should do alone.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's7-teste-missao-07',
  'Teste — Missão 07',
  'Test — Mission 07',
  'Quiz para fechar a Missão 07',
  'Quiz to complete Mission 07',
  '6-18', 7, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 07! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 07! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s7-ia-professor-particular
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença entre usar IA de forma passiva e ativa no aprendizado?","options":["Passivo usa mais internet ativo usa menos","Passivo copia respostas ativo usa a IA para realmente entender através de perguntas e exploração","Passivo é mais rápido ativo é mais lento","Não há diferença real entre os dois modos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the difference between using AI passively and actively in learning?',
  $$["Passive uses more internet active uses less","Passive copies answers active uses AI to truly understand through questions and exploration","Passive is faster active is slower","There is no real difference between the two modes"]$$::jsonb
FROM lessons WHERE slug = 's7-ia-professor-particular';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que dizer seu nível e contexto melhora as explicações da IA?","options":["Porque a IA cobra menos tokens quando sabe o nível","Porque a IA adapta vocabulário exemplos e profundidade especificamente para você","Porque é obrigatório por regras de uso","Porque a IA não funciona sem essa informação"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does telling your level and context improve AI explanations?',
  $$["Because AI charges fewer tokens when it knows your level","Because AI adapts vocabulary examples and depth specifically for you","Because it is required by usage rules","Because AI does not work without that information"]$$::jsonb
FROM lessons WHERE slug = 's7-ia-professor-particular';

-- s7-perguntas-aprendizado-real
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual pergunta gera um aprendizado mais profundo sobre um assunto?","options":["O que é gravidade?","Me fala sobre gravidade","Por que a gravidade funciona assim e não de outra forma? O que mudaria se ela fosse duas vezes mais forte?","Gravidade resumo rápido"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which question generates deeper learning about a subject?',
  $$["What is gravity?","Tell me about gravity","Why does gravity work this way and not another? What would change if it were twice as strong?","Gravity quick summary"]$$::jsonb
FROM lessons WHERE slug = 's7-perguntas-aprendizado-real';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença entre decorar e aprender de verdade?","options":["Decorar é mais rápido e mais eficiente para provas","Decorar é guardar a resposta; aprender é entender o porquê e conseguir aplicar em situações novas","Aprender leva mais tempo e não vale a pena para matérias fáceis","Não há diferença — ambos levam ao mesmo resultado"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the difference between memorizing and truly learning?',
  $$["Memorizing is faster and more efficient for tests","Memorizing is storing the answer; learning is understanding the why and being able to apply in new situations","Learning takes more time and is not worth it for easy subjects","There is no difference — both lead to the same result"]$$::jsonb
FROM lessons WHERE slug = 's7-perguntas-aprendizado-real';

-- s7-organizar-estudos
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que são flashcards e por que são eficazes?","options":["Cartões digitais coloridos usados em apresentações escolares","Perguntas e respostas para revisão ativa — comprovadamente a técnica mais eficaz para memorização","Um aplicativo de IA para criar resumos automáticos","Cartões de pontuação usados em jogos educativos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What are flashcards and why are they effective?',
  $$["Colored digital cards used in school presentations","Questions and answers for active review — proven to be the most effective technique for memorization","An AI app to create automatic summaries","Score cards used in educational games"]$$::jsonb
FROM lessons WHERE slug = 's7-organizar-estudos';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que o cronograma criado pela IA não resolve tudo sozinho?","options":["Porque a IA não sabe criar cronogramas realmente eficazes","Porque a IA organiza mas você é o responsável por executar o plano","Porque cronogramas de IA são muito rígidos para a vida real","Porque IA não tem acesso ao calendário escolar oficial"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does the schedule created by AI not solve everything on its own?',
  $$["Because AI does not know how to create truly effective schedules","Because AI organizes but you are responsible for executing the plan","Because AI schedules are too rigid for real life","Because AI does not have access to the official school calendar"]$$::jsonb
FROM lessons WHERE slug = 's7-organizar-estudos';

-- s7-ia-aprender-idiomas
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual vantagem a IA oferece para aprender idiomas?","options":["Tradução automática instantânea sem precisar aprender nada","Um parceiro de conversa fluente disponível 24h por dia de graça em qualquer idioma","Certificados oficiais de proficiência reconhecidos internacionalmente","Pronúncia perfeita através de reconhecimento de voz avançado"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What advantage does AI offer for learning languages?',
  $$["Instant automatic translation without needing to learn anything","A fluent conversation partner available 24h a day for free in any language","Official internationally recognized proficiency certificates","Perfect pronunciation through advanced voice recognition"]$$::jsonb
FROM lessons WHERE slug = 's7-ia-aprender-idiomas';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que aprender vocabulário em contexto é melhor do que decorar listas de palavras?","options":["Porque listas de palavras são difíceis de encontrar na internet","Porque palavras aprendidas em frases e histórias reais são lembradas com muito mais facilidade","Porque a IA não consegue criar listas de vocabulário eficazes","Porque listas de palavras são proibidas em muitos currículos escolares"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is learning vocabulary in context better than memorizing lists of words?',
  $$["Because word lists are hard to find on the internet","Because words learned in real sentences and stories are remembered much more easily","Because AI cannot create effective vocabulary lists","Because word lists are forbidden in many school curricula"]$$::jsonb
FROM lessons WHERE slug = 's7-ia-aprender-idiomas';

-- s7-ia-cola-linha-nao-cruzar
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o uso correto de IA numa tarefa escolar de escrita?","options":["Pedir para a IA escrever tudo e copiar o resultado","Usar a IA para verificar informações melhorar estrutura e corrigir erros depois de você ter escrito o rascunho","Usar a IA para traduzir a tarefa para inglês e depois de volta para português","Perguntar para a IA qual nota a tarefa vai tirar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the correct use of AI in a school writing task?',
  $$["Ask AI to write everything and copy the result","Use AI to verify information improve structure and correct errors after you have written the draft","Use AI to translate the task to English and back to Portuguese","Ask AI what grade the task will get"]$$::jsonb
FROM lessons WHERE slug = 's7-ia-cola-linha-nao-cruzar';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que usar IA para colar é prejudicial mesmo que o professor não descubra?","options":["Porque a IA comete erros que o professor sempre detecta","Porque você perde a oportunidade de desenvolver habilidades que vão importar na sua vida","Porque a IA cobra por esse tipo de uso avançado","Porque os termos de uso da IA proíbem uso escolar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is using AI to cheat harmful even if the teacher does not find out?',
  $$["Because AI makes mistakes the teacher always detects","Because you miss the opportunity to develop skills that will matter in your life","Because AI charges for this kind of advanced use","Because AI terms of use forbid school use"]$$::jsonb
FROM lessons WHERE slug = 's7-ia-cola-linha-nao-cruzar';

-- s7-teste-missao-07 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você está estudando para uma prova de história e pediu para a IA criar um resumo. O que você faz depois?","options":["Copia o resumo e decora sem ler com atenção","Usa o resumo como ponto de partida faz perguntas profundas sobre o que não entendeu e cria seus próprios flashcards","Entrega o resumo como sua anotação de aula","Pede para a IA criar mais 10 resumos de assuntos diferentes"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You are studying for a history test and asked AI to create a summary. What do you do next?',
  $$["Copy the summary and memorize without reading carefully","Use the summary as a starting point ask deep questions about what you did not understand and create your own flashcards","Submit the summary as your class notes","Ask AI to create 10 more summaries on different subjects"]$$::jsonb
FROM lessons WHERE slug = 's7-teste-missao-07';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual desses usos de IA é mais adequado para aprender de verdade?","options":["Pedir para a IA resolver todos os exercícios de matemática","Pedir para a IA escrever sua redação completa","Pedir para a IA explicar um conceito de 3 formas diferentes até você realmente entender","Pedir para a IA fazer sua pesquisa escolar do início ao fim"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which of these AI uses is most suitable for truly learning?',
  $$["Asking AI to solve all math exercises","Asking AI to write your complete essay","Asking AI to explain a concept in 3 different ways until you truly understand","Asking AI to do your school research from start to finish"]$$::jsonb
FROM lessons WHERE slug = 's7-teste-missao-07';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s7-ia-professor-particular
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Explica de 3 formas', 'Explica [assunto] de 3 formas diferentes: 1) usando uma analogia do cotidiano 2) em 3 tópicos simples 3) como se eu fosse um especialista', '6-18', 1
FROM lessons WHERE slug = 's7-ia-professor-particular';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Adapta para meu nível', 'Tenho [idade] anos e estou aprendendo [assunto] pela primeira vez. Explica de um jeito que eu consiga entender.', '6-18', 2
FROM lessons WHERE slug = 's7-ia-professor-particular';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa meu entendimento', 'Acabei de aprender sobre [assunto]. Me faz 3 perguntas para ver se entendi de verdade.', '6-18', 3
FROM lessons WHERE slug = 's7-ia-professor-particular';

-- s7-perguntas-aprendizado-real
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Transforma minha pergunta', 'Minha pergunta sobre [assunto] é: [pergunta rasa]. Me ajuda a transformá-la numa pergunta mais profunda.', '6-18', 1
FROM lessons WHERE slug = 's7-perguntas-aprendizado-real';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Conexões entre assuntos', 'Qual é a conexão entre [assunto 1] e [assunto 2]? Como eles se relacionam?', '6-18', 2
FROM lessons WHERE slug = 's7-perguntas-aprendizado-real';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'E se não existisse?', 'Se [conceito] não existisse no mundo, o que seria diferente? Quais seriam as consequências?', '6-18', 3
FROM lessons WHERE slug = 's7-perguntas-aprendizado-real';

-- s7-organizar-estudos
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria meu cronograma', 'Tenho as matérias [lista] e posso estudar [horas] por dia. Cria um cronograma semanal de estudos realista para mim.', '6-18', 1
FROM lessons WHERE slug = 's7-organizar-estudos';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Flashcards de [assunto]', 'Cria 10 flashcards de perguntas e respostas sobre [assunto] para eu revisar antes da prova.', '6-18', 2
FROM lessons WHERE slug = 's7-organizar-estudos';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Mapa mental', 'Cria um mapa mental em texto sobre [assunto] mostrando os conceitos principais e as conexões entre eles.', '6-18', 3
FROM lessons WHERE slug = 's7-organizar-estudos';

-- s7-ia-aprender-idiomas
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Conversa em inglês', 'Quero praticar inglês. Vamos conversar sobre [tema] em inglês? Corrija meus erros e explica por quê.', '6-18', 1
FROM lessons WHERE slug = 's7-ia-aprender-idiomas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Vocabulário em contexto', 'Quero aprender palavras em [idioma] sobre o tema [tema]. Me ensina 5 palavras novas dentro de frases reais.', '6-18', 2
FROM lessons WHERE slug = 's7-ia-aprender-idiomas';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Corrige meu texto', 'Escrevi esse texto em [idioma]: [texto]. Corrige os erros e explica o que estava errado.', '6-18', 3
FROM lessons WHERE slug = 's7-ia-aprender-idiomas';

-- s7-ia-cola-linha-nao-cruzar
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Ajuda ética na tarefa', 'Tenho que fazer [tarefa]. Me ajuda a planejar o que devo pesquisar e pensar eu mesmo, e onde você pode me ajudar sem fazer por mim.', '6-18', 1
FROM lessons WHERE slug = 's7-ia-cola-linha-nao-cruzar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Melhora meu texto', 'Escrevi esse rascunho: [texto]. Me ajuda a melhorar a estrutura e clareza sem mudar minhas ideias principais.', '6-18', 2
FROM lessons WHERE slug = 's7-ia-cola-linha-nao-cruzar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Verificar informações', 'Escrevi que [afirmação] na minha redação. Isso está correto? Tem algo que devo corrigir ou adicionar?', '6-18', 3
FROM lessons WHERE slug = 's7-ia-cola-linha-nao-cruzar';

COMMIT;
