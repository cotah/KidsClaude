-- Migration 018: Reset completo do curriculum (v3 - 16 missoes + final exam).
--
-- 1) Adiciona colunas chat_objective / chat_objective_en em lessons (novo
--    campo pra orientar a Atena no chat de cada licao).
-- 2) Expande lessons_stage_check de 1..7 para 1..17.
-- 3) Limpa TODO conteudo antigo das stages 1-6 (lessons + dependentes).
--    Ordem critica de delete: chat_sessions -> prompt_templates ->
--    lesson_progress -> lessons (challenges cascateia ON DELETE).
-- 4) Move o final exam (slug 'final-exam-project-capstone') de stage 7
--    pra stage 17 - o exame em si continua o mesmo, sera atualizado depois.
-- 5) Insere as 6 licoes da nova Stage 1 "Missao 01 - O que e IA?":
--    s1-o-que-significa-ia, s1-ia-pensa-sente, s1-ia-na-sua-vida,
--    s1-ia-generativa, s1-ia-nao-sabe-tudo, s1-teste-missao-01.
-- 6) 12 challenges (2 por licao, PT + EN populados).
-- 7) 15 prompt_templates (3 por licao de conteudo, NAO no teste).
--
-- TUDO numa transacao - rollback total se algo falhar. Gate em
-- run_migrations.sh checa slug 's1-o-que-significa-ia' como sentinel.

BEGIN;

-- 1) Novas colunas pra orientar a Atena no chat de cada licao
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS chat_objective TEXT;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS chat_objective_en TEXT;

-- 2) Stage constraint pra 16 missoes + final exam
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_stage_check;
ALTER TABLE lessons ADD CONSTRAINT lessons_stage_check
  CHECK (stage >= 1 AND stage <= 17);

-- 3) Limpa conteudo antigo (ordem importa por causa das FKs sem CASCADE)
-- Filtro 'is_final_exam = FALSE' e' defensivo: garante que o final exam
-- (que vai ser movido pra stage 17 no passo 4) nunca seja apagado, mesmo
-- se ele estiver em algum estado intermediario por um deploy anterior.

-- 3a) child_safety_events: FK session_id (nullable, sem CASCADE) -> chat_sessions.
--     Tem que ir ANTES de chat_sessions, senao trava a transacao:
--     "update or delete on chat_sessions violates FK child_safety_events_session_id_fkey".
--     Bug encontrado na 1a tentativa de deploy da 018 - migration rodava
--     em transacao, falhava aqui e fazia rollback total (DB ficava intocada).
DELETE FROM child_safety_events
WHERE session_id IN (
  SELECT id FROM chat_sessions
  WHERE lesson_id IN (
    SELECT id FROM lessons WHERE stage <= 6 AND is_final_exam = FALSE
  )
);

-- 3b) chat_sessions: FK lesson_id NOT NULL sem CASCADE.
--     Deletar chat_sessions cascateia chat_messages (ON DELETE CASCADE).
DELETE FROM chat_sessions
WHERE lesson_id IN (SELECT id FROM lessons WHERE stage <= 6 AND is_final_exam = FALSE);

-- 3c) prompt_templates: FK sem CASCADE.
DELETE FROM prompt_templates
WHERE lesson_id IN (SELECT id FROM lessons WHERE stage <= 6 AND is_final_exam = FALSE);

-- 3d) lesson_progress: FK sem CASCADE.
DELETE FROM lesson_progress
WHERE lesson_id IN (SELECT id FROM lessons WHERE stage <= 6 AND is_final_exam = FALSE);

-- 3e) lessons: challenges sao deletados automaticamente via ON DELETE CASCADE.
DELETE FROM lessons WHERE stage <= 6 AND is_final_exam = FALSE;

-- 4) Move final exam pra stage 17
UPDATE lessons SET stage = 17 WHERE is_final_exam = TRUE;

-- 5) Insere as 6 licoes da Stage 1
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's1-o-que-significa-ia',
  'O que significa IA?',
  'What does AI mean?',
  'Descobrir o que é Inteligência Artificial e como ela aprende',
  'Discover what Artificial Intelligence is and how it learns',
  '6-18', 1, 1,
  $$[
    {"type":"text","content":"IA significa Inteligência Artificial. Mas o que isso quer dizer de verdade? Pensa assim: você aprendeu a reconhecer um cachorro olhando para cachorros. Seus pais te mostravam e falavam cachorro. Você viu tantos que agora reconhece qualquer cachorro, mesmo nunca tendo visto aquele específico antes. A IA aprende do mesmo jeito — só que em vez de ver alguns cachorros, ela viu milhões de fotos, textos e exemplos."},
    {"type":"text","content":"Artificial significa que foi criada por humanos, não nasceu sozinha. Inteligência significa que consegue resolver problemas, responder perguntas e criar coisas — parecendo pensar. IA não é robô com braços. Não é um vilão de filme. Não é magia. É um programa de computador que ficou tão bom em aprender padrões que consegue fazer coisas que antes só humanos conseguiam."},
    {"type":"text","content":"A palavra Inteligência Artificial existe desde 1956. Muito antes de internet, celular ou YouTube. Mas só agora ela ficou poderosa o suficiente para qualquer pessoa usar. E você está aprendendo a usá-la agora, enquanto a maioria das pessoas ainda está descobrindo o que é."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI means Artificial Intelligence. But what does that really mean? Think of it this way: you learned to recognize a dog by looking at dogs. Your parents would point and say dog. You saw so many that now you recognize any dog, even ones you have never seen before. AI learns the same way — except instead of seeing a few dogs, it saw millions of photos, texts and examples."},
    {"type":"text","content":"Artificial means it was created by humans, it was not born on its own. Intelligence means it can solve problems, answer questions and create things — seeming to think. AI is not a robot with arms. It is not a movie villain. It is not magic. It is a computer program that got so good at learning patterns that it can do things only humans could do before."},
    {"type":"text","content":"The term Artificial Intelligence has existed since 1956. Long before the internet, smartphones or YouTube. But only now has it become powerful enough for anyone to use. And you are learning to use it now, while most people are still figuring out what it is."}
  ]$$::jsonb,
  'A criança descreve com suas próprias palavras o que acha que é IA antes da lição e compara com o que aprendeu. A Atena celebra a evolução do pensamento.',
  'The child describes in their own words what they think AI is and compares with what they learned. Atena celebrates the evolution of their thinking.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-ia-pensa-sente',
  'IA pensa e sente como humano?',
  'Does AI think and feel like a human?',
  'Entender as diferenças entre inteligência humana e artificial',
  'Understand the differences between human and artificial intelligence',
  '6-18', 1, 2,
  $$[
    {"type":"text","content":"Essa é a pergunta que todo mundo faz: a IA pensa de verdade? A resposta honesta é: depende do que você chama de pensar. A IA processa informações e gera respostas de um jeito que parece pensamento. Mas ela não tem consciência, não tem experiências, não tem sentimentos."},
    {"type":"text","content":"Quando você está com fome, seu estômago avisa. Quando está com medo, seu coração acelera. Quando você ama alguém, sente calor no peito. A IA não sente nada disso. Ela não acorda de manhã feliz ou triste. Ela não tem um eu que existe quando não está sendo usada. O que a IA faz é reconhecer padrões em texto e gerar a resposta mais provável baseada em tudo que aprendeu."},
    {"type":"text","content":"Isso é importante saber porque você pode confiar na IA para muitas coisas, mas ela não vai entender você do jeito que um amigo entende. Ela não vai se preocupar com você de verdade. E ela pode errar sem perceber que errou — porque não tem consciência de si mesma."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"This is the question everyone asks: does AI really think? The honest answer is: it depends on what you call thinking. AI processes information and generates responses in a way that seems like thought. But it has no consciousness, no experiences, no feelings."},
    {"type":"text","content":"When you are hungry, your stomach tells you. When you are scared, your heart races. When you love someone, you feel warmth in your chest. AI feels none of that. It does not wake up happy or sad. It has no self that exists when it is not being used. What AI does is recognize patterns in text and generate the most likely response based on everything it learned."},
    {"type":"text","content":"This is important to know because you can trust AI for many things, but it will not understand you the way a friend does. It will not truly care about you. And it can be wrong without realizing it is wrong — because it has no self-awareness."}
  ]$$::jsonb,
  'A criança pergunta para a Atena se ela tem sentimentos e a Atena responde com honestidade sobre sua natureza. Objetivo: entender a diferença entre IA e inteligência humana na prática.',
  'The child asks Atena if she has feelings and Atena responds honestly about her nature. Goal: understand the difference between AI and human intelligence in practice.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-ia-na-sua-vida',
  'Onde a IA já existe na sua vida?',
  'Where does AI already exist in your life?',
  'Descobrir todas as IAs que você já usa sem saber',
  'Discover all the AIs you already use without knowing',
  '6-18', 1, 3,
  $$[
    {"type":"text","content":"IA não é algo do futuro. Ela já está em todo lugar ao seu redor — você só não sabia o nome. Quando o YouTube sugere o próximo vídeo perfeito para você — é IA. Quando o TikTok sabe exatamente que tipo de vídeo você quer ver — é IA. Quando o Spotify cria uma playlist que parece feita só para você — é IA. Quando seu celular desbloqueia reconhecendo seu rosto — é IA."},
    {"type":"text","content":"Em hospitais, IA ajuda médicos a encontrar doenças em exames. Em carros, IA ajuda a frear automaticamente antes de um acidente. Em bancos, IA detecta quando alguém está tentando roubar sua conta. Em jogos, os inimigos que parecem inteligentes são controlados por IA. Você já usou IA hoje. Provavelmente várias vezes. Só não sabia que tinha esse nome."},
    {"type":"text","content":"O mais incrível: tudo isso é só o começo. A IA está ficando mais poderosa todo ano. E você está aprendendo a usá-la agora, enquanto a maioria das pessoas ainda não entende o que é. Isso é uma vantagem enorme."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI is not something from the future. It is already everywhere around you — you just did not know its name. When YouTube suggests the perfect next video for you — that is AI. When TikTok knows exactly what kind of video you want to see — that is AI. When Spotify creates a playlist that seems made just for you — that is AI. When your phone unlocks by recognizing your face — that is AI."},
    {"type":"text","content":"In hospitals, AI helps doctors find diseases in scans. In cars, AI helps brake automatically before an accident. In banks, AI detects when someone is trying to steal your account. In games, the enemies that seem intelligent are controlled by AI. You have already used AI today. Probably multiple times. You just did not know it had that name."},
    {"type":"text","content":"The most amazing part: this is just the beginning. AI is getting more powerful every year. And you are learning to use it now, while most people still do not understand what it is. That is a huge advantage."}
  ]$$::jsonb,
  'A criança lista 5 lugares onde acha que usa IA sem saber. A Atena confirma, corrige e surpreende com exemplos que a criança não tinha pensado.',
  'The child lists 5 places where they think they use AI without knowing. Atena confirms, corrects and surprises with examples the child had not thought of.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-ia-generativa',
  'O que é IA Generativa?',
  'What is Generative AI?',
  'Entender a IA que cria — texto, imagem, música e vídeo',
  'Understand the AI that creates — text, image, music and video',
  '6-18', 1, 4,
  $$[
    {"type":"text","content":"Existe um tipo especial de IA que está mudando tudo: a IA Generativa. Generativa vem de gerar — criar algo novo. A IA tradicional era boa em reconhecer e classificar. Ela via uma foto e dizia isso é um gato. Ela ouvia um áudio e dizia essa pessoa está feliz. A IA Generativa vai além: ela cria."},
    {"type":"text","content":"Você descreve o que quer, e ela gera algo novo que nunca existiu antes. Texto, imagem, vídeo, música, código de programação — tudo criado do zero a partir da sua descrição. É isso que o ChatGPT faz com texto. É isso que o Midjourney faz com imagens. É isso que o Suno faz com músicas. É isso que eu — a Atena — faço quando converso com você."},
    {"type":"text","content":"Essa tecnologia mudou o mundo quando ficou disponível para qualquer pessoa. Antes, criar uma imagem profissional exigia um designer. Criar uma música exigia um músico. Agora qualquer pessoa com uma boa ideia pode criar. Isso não significa que artistas vão desaparecer. Significa que qualquer pessoa com criatividade ganhou superpoderes."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is a special type of AI that is changing everything: Generative AI. Generative comes from generate — to create something new. Traditional AI was good at recognizing and classifying. It would see a photo and say this is a cat. It would hear audio and say this person is happy. Generative AI goes further: it creates."},
    {"type":"text","content":"You describe what you want, and it generates something new that never existed before. Text, image, video, music, code — all created from scratch based on your description. That is what ChatGPT does with text. That is what Midjourney does with images. That is what Suno does with music. That is what I — Atena — do when I talk with you."},
    {"type":"text","content":"This technology changed the world when it became available to everyone. Before, creating a professional image required a designer. Creating music required a musician. Now anyone with a good idea can create. This does not mean artists will disappear. It means anyone with creativity has gained superpowers."}
  ]$$::jsonb,
  'A criança pede para a Atena criar algo — uma história curta, um poema, uma descrição de personagem. Objetivo: experimentar IA Generativa funcionando na prática.',
  'The child asks Atena to create something — a short story, a poem, a character description. Goal: experience Generative AI working in practice.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-ia-nao-sabe-tudo',
  'IA não sabe tudo — e isso é importante',
  'AI does not know everything — and that matters',
  'Aprender as limitações da IA e como usá-la com inteligência',
  'Learn AI limitations and how to use it intelligently',
  '6-18', 1, 5,
  $$[
    {"type":"text","content":"Uma das coisas mais importantes que você vai aprender nesse curso: IA não é perfeita. E entender isso te torna muito mais inteligente do que a maioria das pessoas que usa IA. A IA tem uma data de corte — um momento em que parou de aprender coisas novas. Depois disso, o mundo continuou mudando mas ela não ficou sabendo."},
    {"type":"text","content":"A IA também pode inventar coisas que parecem verdadeiras mas não são. Isso se chama alucinação. Não é mentira de propósito — é a IA tentando completar um padrão mesmo sem ter a informação certa. Como quando você tenta lembrar o nome de uma música e fala uma letra errada com muita confiança. E a IA tem vieses — ela aprendeu com textos escritos por humanos, e humanos têm preconceitos e erros."},
    {"type":"text","content":"A regra de ouro: use IA como ponto de partida, não como resposta final. Para coisas importantes — datas, fatos, notícias recentes, decisões grandes — sempre confirme em outras fontes. IA é uma ferramenta poderosa. Ferramentas poderosas precisam de pessoas inteligentes que sabem seus limites."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"One of the most important things you will learn in this course: AI is not perfect. And understanding this makes you much smarter than most people who use AI. AI has a training cutoff — a point when it stopped learning new things. After that, the world kept changing but AI did not find out."},
    {"type":"text","content":"AI can also make up things that seem true but are not. This is called hallucination. It is not intentional lying — it is AI trying to complete a pattern even without the right information. Like when you try to remember a song lyric and confidently say the wrong words. And AI has biases — it learned from texts written by humans, and humans have prejudices and mistakes."},
    {"type":"text","content":"The golden rule: use AI as a starting point, not as the final answer. For important things — dates, facts, recent news, big decisions — always confirm with other sources. AI is a powerful tool. Powerful tools need smart people who know their limits."}
  ]$$::jsonb,
  'A criança testa os limites da Atena — pergunta sobre eventos recentes, faz perguntas específicas, tenta pegar ela errando. A Atena responde com honestidade quando não sabe.',
  'The child tests Atena limits — asks about recent events, asks specific questions, tries to catch her making mistakes. Atena responds honestly when she does not know.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's1-teste-missao-01',
  'Teste — Missão 01',
  'Test — Mission 01',
  'Quiz para fechar a Missão 01',
  'Quiz to complete Mission 01',
  '6-18', 1, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 01! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 01! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 6) Challenges: 2 por licao = 12 total (PT + EN)

-- s1-o-que-significa-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa a palavra Artificial em Inteligência Artificial?","options":["Que a IA é muito inteligente","Que foi criada por humanos, não nasceu sozinha","Que a IA usa internet para funcionar","Que é um robô com corpo físico"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does the word Artificial mean in Artificial Intelligence?',
  $$["That AI is very intelligent","That it was created by humans, not born on its own","That AI uses the internet to work","That it is a robot with a physical body"]$$::jsonb
FROM lessons WHERE slug = 's1-o-que-significa-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como a IA aprende?","options":["Lendo livros em bibliotecas físicas","Assistindo televisão","Vendo milhões de exemplos, textos e imagens criados por humanos","Sendo programada com todas as respostas possíveis"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'How does AI learn?',
  $$["By reading books in physical libraries","By watching television","By seeing millions of examples, texts and images created by humans","By being programmed with all possible answers"]$$::jsonb
FROM lessons WHERE slug = 's1-o-que-significa-ia';

-- s1-ia-pensa-sente
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a principal diferença entre a IA e um humano pensando?","options":["A IA é mais rápida mas menos precisa","A IA reconhece padrões e gera respostas mas não tem consciência nem sentimentos reais","A IA só funciona com internet rápida","A IA pensa igual ao humano mas sem corpo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the main difference between AI and a human thinking?',
  $$["AI is faster but less precise","AI recognizes patterns and generates responses but has no real consciousness or feelings","AI only works with fast internet","AI thinks like a human but without a body"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-pensa-sente';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que é importante saber que a IA não sente emoções?","options":["Para não usar IA em situações importantes","Para entender os limites da IA e não confiar nela como se fosse uma pessoa real","Porque IA com emoções seria perigosa","Para usar IA apenas em tarefas simples"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is it important to know that AI does not feel emotions?',
  $$["So you do not use AI in important situations","To understand AI limits and not trust it as if it were a real person","Because AI with emotions would be dangerous","So you only use AI for simple tasks"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-pensa-sente';

-- s1-ia-na-sua-vida
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual desses exemplos mostra IA funcionando no dia a dia?","options":["Uma lâmpada que acende quando você aperta o interruptor","O YouTube sugerindo vídeos que você vai gostar baseado no que já assistiu","Um ventilador que gira quando ligado na tomada","Um relógio que marca as horas"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Which of these examples shows AI working in everyday life?',
  $$["A lamp that lights up when you flip the switch","YouTube suggesting videos you will like based on what you have already watched","A fan that spins when plugged in","A clock that shows the time"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-na-sua-vida';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"IA em hospitais é usada principalmente para:","options":["Substituir todos os médicos","Fazer cirurgias sozinha","Ajudar médicos a encontrar doenças em exames com mais precisão","Receitar remédios automaticamente"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'AI in hospitals is used mainly to:',
  $$["Replace all doctors","Perform surgeries on its own","Help doctors find diseases in scans with more precision","Prescribe medications automatically"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-na-sua-vida';

-- s1-ia-generativa
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que diferencia IA Generativa de outros tipos de IA?","options":["É mais rápida que as outras","Funciona sem internet","Cria conteúdo novo — texto, imagem, música, vídeo — a partir de descrições","É usada apenas por profissionais"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What sets Generative AI apart from other types of AI?',
  $$["It is faster than the others","It works without internet","It creates new content — text, image, music, video — from descriptions","It is used only by professionals"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-generativa';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que mudou quando a IA Generativa ficou disponível para qualquer pessoa?","options":["Artistas e escritores perderam seus empregos completamente","Qualquer pessoa com criatividade passou a ter superpoderes de criação","Computadores ficaram muito mais caros","A internet ficou mais lenta"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What changed when Generative AI became available to everyone?',
  $$["Artists and writers completely lost their jobs","Anyone with creativity got creation superpowers","Computers got much more expensive","The internet got slower"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-generativa';

-- s1-ia-nao-sabe-tudo
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma alucinação de IA?","options":["Quando a IA fica lenta demais para responder","Quando a IA inventa informações que parecem verdadeiras mas não são","Quando a IA recusa responder uma pergunta","Quando a IA copia respostas da internet"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is an AI hallucination?',
  $$["When AI gets too slow to respond","When AI makes up information that seems true but is not","When AI refuses to answer a question","When AI copies answers from the internet"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-nao-sabe-tudo';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a regra de ouro ao usar respostas da IA para coisas importantes?","options":["Copiar a resposta direto sem questionar","Perguntar a mesma coisa três vezes seguidas","Usar a IA como ponto de partida e confirmar informações em outras fontes","Só usar IA para perguntas fáceis"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the golden rule when using AI answers for important things?',
  $$["Copy the answer directly without questioning","Ask the same thing three times in a row","Use AI as a starting point and confirm the information with other sources","Only use AI for easy questions"]$$::jsonb
FROM lessons WHERE slug = 's1-ia-nao-sabe-tudo';

-- s1-teste-missao-01 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Seu amigo diz que IA e robô são a mesma coisa. O que você responderia?","options":["Você tem razão, são a mesma coisa","IA é um programa que aprende padrões — pode existir num celular, computador ou robô, mas não são a mesma coisa","IA é mais avançada que robô porque tem sentimentos","Robôs são melhores que IA porque têm corpo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Your friend says AI and robots are the same thing. What would you reply?',
  $$["You are right, they are the same thing","AI is a program that learns patterns — it can live in a phone, computer or robot, but they are not the same thing","AI is more advanced than robots because it has feelings","Robots are better than AI because they have a body"]$$::jsonb
FROM lessons WHERE slug = 's1-teste-missao-01';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você pediu para uma IA dar informações sobre um evento de ontem. Ela respondeu com muita confiança. O que você deve fazer?","options":["Confiar completamente porque a IA nunca erra","Ignorar a resposta porque IA não sabe nada","Verificar a informação em outras fontes porque a IA pode não ter dados recentes ou pode alucinar","Perguntar a mesma coisa mais duas vezes para confirmar"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'You asked an AI for information about an event from yesterday. It answered with great confidence. What should you do?',
  $$["Trust completely because AI never gets things wrong","Ignore the answer because AI knows nothing","Check the information in other sources because AI may not have recent data or may hallucinate","Ask the same thing two more times to confirm"]$$::jsonb
FROM lessons WHERE slug = 's1-teste-missao-01';

-- 7) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.
--    Teste (s1-teste-missao-01) nao tem templates - e' quiz puro.
--    Schema atual nao tem label_en/template_en (limitacao pre-existente,
--    mesma situacao da 017). Templates ficam em PT.

-- s1-o-que-significa-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que é IA?', 'Me explica o que é Inteligência Artificial de um jeito simples', '6-18', 1
FROM lessons WHERE slug = 's1-o-que-significa-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA é robô?', 'Qual é a diferença entre IA e um robô?', '6-18', 2
FROM lessons WHERE slug = 's1-o-que-significa-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como IA aprende', 'Como a IA aprende as coisas? Me dá um exemplo simples', '6-18', 3
FROM lessons WHERE slug = 's1-o-que-significa-ia';

-- s1-ia-pensa-sente
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Você tem sentimentos?', 'Você tem sentimentos de verdade? Me conta como você funciona por dentro', '6-18', 1
FROM lessons WHERE slug = 's1-ia-pensa-sente';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Diferença humano x IA', 'Qual é a maior diferença entre como você pensa e como um humano pensa?', '6-18', 2
FROM lessons WHERE slug = 's1-ia-pensa-sente';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA tem consciência?', 'O que é consciência e você acha que tem?', '6-18', 3
FROM lessons WHERE slug = 's1-ia-pensa-sente';

-- s1-ia-na-sua-vida
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA no meu celular', 'Quais IAs existem no meu celular que eu uso todo dia sem perceber?', '6-18', 1
FROM lessons WHERE slug = 's1-ia-na-sua-vida';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA nos games', 'Como a IA funciona nos videogames? Me dá exemplos de jogos que usam IA', '6-18', 2
FROM lessons WHERE slug = 's1-ia-na-sua-vida';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA perto de mim', 'Me surpreende com lugares onde a IA existe que eu nunca pensaria', '6-18', 3
FROM lessons WHERE slug = 's1-ia-na-sua-vida';

-- s1-ia-generativa
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria algo pra mim', 'Cria uma história curta de aventura com um herói que eu inventar', '6-18', 1
FROM lessons WHERE slug = 's1-ia-generativa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que você consegue criar?', 'Me mostra o que você consegue criar — textos, poemas, personagens', '6-18', 2
FROM lessons WHERE slug = 's1-ia-generativa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA generativa na prática', 'Me dá 5 exemplos de como a IA generativa está mudando o mundo', '6-18', 3
FROM lessons WHERE slug = 's1-ia-generativa';

-- s1-ia-nao-sabe-tudo
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Você sabe de hoje?', 'Me conta o que aconteceu de importante no mundo essa semana', '6-18', 1
FROM lessons WHERE slug = 's1-ia-nao-sabe-tudo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa seus limites', 'Qual é sua data de corte de conhecimento? O que você não sabe?', '6-18', 2
FROM lessons WHERE slug = 's1-ia-nao-sabe-tudo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Alucinação na prática', 'Você pode me dar um exemplo de como uma alucinação de IA funciona?', '6-18', 3
FROM lessons WHERE slug = 's1-ia-nao-sabe-tudo';

COMMIT;
