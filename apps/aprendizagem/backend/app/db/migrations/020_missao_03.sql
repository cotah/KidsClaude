-- Migration 020: Insere conteudo da Stage 3 "Missao 03 - Como conversar com IA"
--
-- Foco: prompts - o que sao, os 5 elementos, ruins vs poderosos, contexto,
-- e iteracao. 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=3, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes - colunas chat_objective + constraint stage 1..17 ja'
-- foram criadas em 018. Sem ALTER, so' INSERTs.
--
-- Tudo numa transacao (BEGIN/COMMIT). Gate slug-only em run_migrations.sh.

BEGIN;

-- 1) Insere as 6 licoes da Stage 3
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's3-o-que-e-prompt',
  'O que é um prompt?',
  'What is a prompt?',
  'Descobrir o que é um prompt e por que ele muda tudo',
  'Discover what a prompt is and why it changes everything',
  '6-18', 3, 1,
  $$[
    {"type":"text","content":"Tudo que você escreve para uma IA se chama prompt. É a sua mensagem, o seu pedido, a sua instrução. É o jeito que você se comunica com a IA. Mas existe um segredo que a maioria das pessoas não sabe: a qualidade do prompt muda completamente a qualidade da resposta. A IA não é boa ou ruim — ela é tão boa quanto a instrução que recebe."},
    {"type":"text","content":"Pensa numa analogia simples: a IA é como um cozinheiro incrível. Se você chega e fala faz uma comida, ele faz qualquer coisa. Pode ser boa, pode ser ruim. Mas se você fala faz um risoto de cogumelos, cremoso, sem carne, para 4 pessoas, com parmesão por cima — ele faz exatamente o que você imaginou. O mesmo pedido, resultados completamente diferentes."},
    {"type":"text","content":"A diferença está no prompt. Isso é um dos conceitos mais importantes do curso: aprender a criar bons prompts é uma habilidade real, que as empresas mais importantes do mundo estão pagando muito bem para quem domina."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Everything you write to an AI is called a prompt. It is your message, your request, your instruction. It is the way you communicate with AI. But there is a secret most people do not know: the quality of the prompt completely changes the quality of the response. AI is not good or bad — it is as good as the instruction it receives."},
    {"type":"text","content":"Think of a simple analogy: AI is like an amazing chef. If you walk in and say make some food, they make anything. Could be good, could be bad. But if you say make a mushroom risotto, creamy, no meat, for 4 people, with parmesan on top — they make exactly what you imagined. The same request, completely different results."},
    {"type":"text","content":"The difference is in the prompt. This is one of the most important concepts in the course: learning to create good prompts is a real skill that the most important companies in the world are paying very well for those who master it."}
  ]$$::jsonb,
  'A criança manda um prompt simples e depois um prompt detalhado para o mesmo pedido. Compara os resultados e entende a diferença na prática.',
  'The child sends a simple prompt and then a detailed prompt for the same request. Compares results and understands the difference in practice.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-5-elementos-prompt',
  'A regra dos 5 elementos do prompt perfeito',
  'The 5 elements rule of the perfect prompt',
  'Aprender os 5 elementos que transformam qualquer prompt em poderoso',
  'Learn the 5 elements that transform any prompt into a powerful one',
  '6-18', 3, 2,
  $$[
    {"type":"text","content":"Existe uma fórmula que transforma qualquer prompt mediano em um prompt poderoso. São 5 elementos. Você não precisa usar todos sempre — mas quanto mais usar, melhor o resultado. MISSÃO: o que você quer que a IA faça? Seja específico. Não escreve uma história — escreve uma história de aventura com 3 parágrafos. PERSONAGEM: quem a IA deve ser? Você é um professor de história muda completamente o tom."},
    {"type":"text","content":"ESTILO: como você quer que a resposta seja? Engraçada? Séria? Simples? Técnica? Com emojis? DETALHES: quais informações específicas são importantes? Personagens, lugares, restrições, contexto. FORMATO: como entregar? Em tópicos? Em uma tabela? Um e-mail? Um poema?"},
    {"type":"text","content":"Exemplo fraco: Me fala sobre cachorros. Exemplo com os 5 elementos: Você é um veterinário bem-humorado. Me explica em 5 tópicos curtos e engraçados por que cachorros são os melhores animais de estimação para crianças. Use exemplos reais e linguagem simples. A diferença é gigantesca."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is a formula that transforms any average prompt into a powerful one. It has 5 elements. You do not need to use all of them every time — but the more you use, the better the result. MISSION: what do you want AI to do? Be specific. Not write a story — write an adventure story with 3 paragraphs. CHARACTER: who should AI be? You are a history teacher completely changes the tone."},
    {"type":"text","content":"STYLE: how do you want the response to be? Funny? Serious? Simple? Technical? With emojis? DETAILS: what specific information matters? Characters, places, restrictions, context. FORMAT: how to deliver? In bullet points? A table? An email? A poem?"},
    {"type":"text","content":"Weak example: Tell me about dogs. Example with 5 elements: You are a funny vet. Explain in 5 short funny bullet points why dogs are the best pets for children. Use real examples and simple language. The difference is massive."}
  ]$$::jsonb,
  'A criança escolhe um tema de interesse e cria um prompt usando os 5 elementos. A Atena avalia e mostra como cada elemento melhorou o resultado.',
  'The child chooses a topic of interest and creates a prompt using the 5 elements. Atena evaluates and shows how each element improved the result.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-prompts-ruins-vs-poderosos',
  'Prompts ruins vs prompts poderosos',
  'Weak prompts vs powerful prompts',
  'Aprender a identificar e transformar prompts ruins em poderosos',
  'Learn to identify and transform weak prompts into powerful ones',
  '6-18', 3, 3,
  $$[
    {"type":"text","content":"Vamos ser diretos: a maioria das pessoas usa prompts ruins. E depois acha que a IA é ruim. Mas o problema não é a IA — é o prompt. Prompts ruins têm características em comum: são vagos, sem contexto, sem especificação de formato, sem informação sobre quem está perguntando ou para que serve a resposta."},
    {"type":"text","content":"Compare: FRACO: Me ajuda com minha apresentação. PODEROSO: Sou estudante de 12 anos e preciso fazer uma apresentação de 5 slides sobre mudanças climáticas para minha turma do 7º ano. Cria um roteiro com: título chamativo, 3 fatos surpreendentes, 1 solução que jovens podem fazer, e uma pergunta para engajar a turma. Tom animado e linguagem simples."},
    {"type":"text","content":"A diferença é gigantesca. O prompt poderoso dá à IA tudo que ela precisa para criar algo realmente útil. O teste mental para saber se seu prompt é bom: se eu mandasse esse pedido para um humano, ele saberia exatamente o que fazer? Se a resposta for não, o prompt precisa melhorar."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Let us be direct: most people use weak prompts. And then think AI is bad. But the problem is not the AI — it is the prompt. Weak prompts share common characteristics: vague, no context, no format specification, no information about who is asking or what the response is for."},
    {"type":"text","content":"Compare: WEAK: Help me with my presentation. POWERFUL: I am a 12-year-old student and need to make a 5-slide presentation about climate change for my 7th grade class. Create an outline with: catchy title, 3 surprising facts, 1 solution young people can do, and a question to engage the class. Upbeat tone and simple language."},
    {"type":"text","content":"The difference is massive. The powerful prompt gives AI everything it needs to create something truly useful. The mental test to know if your prompt is good: if I sent this request to a human, would they know exactly what to do? If the answer is no, the prompt needs improvement."}
  ]$$::jsonb,
  'A criança pega um prompt ruim que já usou e transforma em poderoso com a ajuda da Atena. Compara os resultados das duas versões.',
  'The child takes a weak prompt they already used and transforms it into a powerful one with Atenas help. Compares results of both versions.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-contexto-e-tudo',
  'Contexto é tudo',
  'Context is everything',
  'Entender como o contexto transforma a qualidade das respostas',
  'Understand how context transforms response quality',
  '6-18', 3, 4,
  $$[
    {"type":"text","content":"Imagina chegar numa cidade que você nunca foi e perguntar para alguém na rua: Qual é o melhor lugar? A pessoa fica confusa. Melhor lugar para quê? Para comer? Dormir? Dançar? Fotografar? Sem contexto, impossível ajudar. Com a IA é igual. Contexto é a informação de fundo que ajuda a IA a entender sua situação real."},
    {"type":"text","content":"Sem contexto, a IA responde para uma pessoa genérica imaginária. Com contexto, ela responde especificamente para você. Os 4 elementos do bom contexto: 1) Quem você é — estudante de 10 anos, iniciante em culinária. 2) O que você já sabe — já entendo o básico ou nunca vi esse assunto. 3) Para que vai usar — apresentação escolar, post nas redes. 4) Suas restrições — sem palavras técnicas, máximo 3 parágrafos."},
    {"type":"text","content":"Adicionar contexto ao seu prompt é a mudança mais simples que gera o maior impacto no resultado. Não precisa escrever um romance — 2 ou 3 informações de contexto já transformam completamente a qualidade da resposta."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Imagine arriving in a city you have never been to and asking someone on the street: What is the best place? The person is confused. Best place for what? To eat? Sleep? Dance? Take photos? Without context, impossible to help. With AI it is the same. Context is the background information that helps AI understand your real situation."},
    {"type":"text","content":"Without context, AI responds to an imaginary generic person. With context, it responds specifically to you. The 4 elements of good context: 1) Who you are — 10-year-old student, cooking beginner. 2) What you already know — I already understand the basics or I have never seen this subject. 3) What you will use it for — school presentation, social media post. 4) Your restrictions — no technical words, maximum 3 paragraphs."},
    {"type":"text","content":"Adding context to your prompt is the simplest change that generates the biggest impact on the result. You do not need to write a novel — 2 or 3 pieces of context information already completely transform the quality of the response."}
  ]$$::jsonb,
  'A criança pega um assunto da escola e escreve dois prompts — um sem contexto e um com os 4 elementos. Vê a diferença na prática.',
  'The child picks a school subject and writes two prompts — one without context and one with the 4 elements. Sees the difference in practice.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-iterar-melhorar',
  'Iterar — melhorar até ficar perfeito',
  'Iterate — improve until perfect',
  'Aprender a melhorar respostas da IA sem começar do zero',
  'Learn to improve AI responses without starting over',
  '6-18', 3, 5,
  $$[
    {"type":"text","content":"Nenhum artista cria uma obra-prima na primeira tentativa. Nenhum escritor escreve um livro sem revisar. Criar com IA é igual — a primeira resposta raramente é a melhor. Iterar significa melhorar a resposta em cima do que a IA fez, sem começar do zero. É uma habilidade que separa usuários medianos de usuários avançados."},
    {"type":"text","content":"Três técnicas de iteração: REFINAR: tá bom mas quero mais curto, mais engraçado, em tom mais formal. FOCAR: da sua resposta, aprofunda mais a parte sobre X. Ignore o resto. REDIRECIONAR: não era exatamente isso. O que eu preciso é — explica de novo com mais detalhes."},
    {"type":"text","content":"A mentalidade certa é: a IA é um colaborador, não uma máquina de resposta única. Você e a IA trabalham juntos, cada rodada ficando mais próximo do resultado perfeito. A frase que resume tudo: A IA melhora quando você melhora. Quanto melhor você fica em criar prompts e iterar, melhores ficam os resultados."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"No artist creates a masterpiece on the first try. No writer finishes a book without revising. Creating with AI is the same — the first response is rarely the best. Iterating means improving the response on top of what AI did, without starting over. It is a skill that separates average users from advanced users."},
    {"type":"text","content":"Three iteration techniques: REFINE: it is good but I want it shorter, funnier, in a more formal tone. FOCUS: from your response, go deeper on the part about X. Ignore the rest. REDIRECT: that was not exactly it. What I really need is — explain again with more details."},
    {"type":"text","content":"The right mindset is: AI is a collaborator, not a one-answer machine. You and AI work together, each round getting closer to the perfect result. The phrase that sums it all up: AI improves when you improve. The better you get at creating prompts and iterating, the better the results become."}
  ]$$::jsonb,
  'A criança faz um pedido para a Atena e pratica as 3 técnicas de iteração em sequência — refinar, focar e redirecionar.',
  'The child makes a request to Atena and practices the 3 iteration techniques in sequence — refine, focus and redirect.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's3-teste-missao-03',
  'Teste — Missão 03',
  'Test — Mission 03',
  'Quiz para fechar a Missão 03',
  'Quiz to complete Mission 03',
  '6-18', 3, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 03! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 03! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s3-o-que-e-prompt
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é um prompt?","options":["O nome do botão de enviar mensagem","Tudo que você escreve para a IA — sua mensagem, pedido ou instrução","A resposta que a IA gera","Um tipo especial de computador para IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is a prompt?',
  $$["The name of the send message button","Everything you write to the AI — your message, request or instruction","The response the AI generates","A special type of computer for AI"]$$::jsonb
FROM lessons WHERE slug = 's3-o-que-e-prompt';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que dois prompts diferentes para a mesma tarefa podem dar resultados completamente diferentes?","options":["Porque a IA escolhe aleatoriamente qual resposta dar","Porque a IA só funciona bem de manhã","Porque a qualidade e o detalhe do prompt determinam a qualidade da resposta","Porque depende da velocidade da internet"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Why can two different prompts for the same task give completely different results?',
  $$["Because AI randomly picks which response to give","Because AI only works well in the morning","Because the quality and detail of the prompt determine the quality of the response","Because it depends on internet speed"]$$::jsonb
FROM lessons WHERE slug = 's3-o-que-e-prompt';

-- s3-5-elementos-prompt
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual dos 5 elementos define quem a IA deve ser?","options":["Missão","Estilo","Personagem","Formato"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which of the 5 elements defines who the AI should be?',
  $$["Mission","Style","Character","Format"]$$::jsonb
FROM lessons WHERE slug = 's3-5-elementos-prompt';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que especificar o FORMATO da resposta é importante?","options":["Porque a IA não consegue responder sem saber o formato","Porque o formato define como a informação será organizada e apresentada","Porque formatos diferentes custam tokens diferentes","Porque é obrigatório por regras da plataforma"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does specifying the FORMAT of the response matter?',
  $$["Because AI cannot respond without knowing the format","Because the format defines how information will be organized and presented","Because different formats cost different tokens","Because it is required by platform rules"]$$::jsonb
FROM lessons WHERE slug = 's3-5-elementos-prompt';

-- s3-prompts-ruins-vs-poderosos
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o principal problema dos prompts ruins?","options":["São muito longos e cansam a IA","São vagos e não dão informação suficiente para a IA ajudar bem","Usam palavras difíceis que a IA não entende","Precisam de conexão mais rápida para funcionar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the main problem with weak prompts?',
  $$["They are too long and tire the AI","They are vague and do not give enough information for the AI to help well","They use difficult words the AI does not understand","They need faster connection to work"]$$::jsonb
FROM lessons WHERE slug = 's3-prompts-ruins-vs-poderosos';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o teste mental para saber se um prompt é bom?","options":["Verificar se tem mais de 50 palavras","Verificar se usa todos os 5 elementos obrigatoriamente","Perguntar: se eu mandasse esse pedido para um humano, ele saberia exatamente o que fazer?","Verificar se está em inglês para melhores resultados"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the mental test to know if a prompt is good?',
  $$["Check if it has more than 50 words","Check if it uses all 5 elements mandatorily","Ask: if I sent this request to a human, would they know exactly what to do?","Check if it is in English for better results"]$$::jsonb
FROM lessons WHERE slug = 's3-prompts-ruins-vs-poderosos';

-- s3-contexto-e-tudo
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é contexto em um prompt?","options":["O título da conversa com a IA","A informação de fundo que ajuda a IA a entender sua situação real","O número de palavras que você usou","O idioma em que você está escrevendo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is context in a prompt?',
  $$["The title of the conversation with AI","The background information that helps AI understand your real situation","The number of words you used","The language you are writing in"]$$::jsonb
FROM lessons WHERE slug = 's3-contexto-e-tudo';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual desses prompts tem melhor contexto?","options":["Explica fotossíntese","FOTOSSÍNTESE AGORA","Sou estudante de 11 anos e preciso explicar fotossíntese para minha turma numa apresentação de 2 minutos. Usa linguagem simples e um exemplo com algo do dia a dia","Me ajuda com biologia"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which of these prompts has better context?',
  $$["Explain photosynthesis","PHOTOSYNTHESIS NOW","I am an 11-year-old student and need to explain photosynthesis to my class in a 2-minute presentation. Use simple language and an everyday-life example","Help me with biology"]$$::jsonb
FROM lessons WHERE slug = 's3-contexto-e-tudo';

-- s3-iterar-melhorar
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa iterar com a IA?","options":["Começar uma conversa nova toda vez que não gostou da resposta","Melhorar a resposta em cima do que a IA fez sem começar do zero","Repetir o mesmo prompt até a IA acertar","Traduzir o prompt para inglês para melhores resultados"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does iterating with AI mean?',
  $$["Starting a new conversation every time you do not like the response","Improving the response on top of what AI did without starting over","Repeating the same prompt until AI gets it right","Translating the prompt to English for better results"]$$::jsonb
FROM lessons WHERE slug = 's3-iterar-melhorar';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual frase resume melhor a relação entre usuário e IA?","options":["A IA sempre sabe mais que o usuário","O usuário deve aceitar a primeira resposta da IA","A IA melhora quando você melhora","Quanto mais simples o prompt, melhor a resposta"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which phrase best summarizes the relationship between user and AI?',
  $$["AI always knows more than the user","The user should accept the first AI response","AI improves when you improve","The simpler the prompt, the better the response"]$$::jsonb
FROM lessons WHERE slug = 's3-iterar-melhorar';

-- s3-teste-missao-03 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você quer pedir para a IA criar um personagem para um jogo. Qual prompt é mais poderoso?","options":["Cria um personagem","Personagem legal para jogo","Você é um designer de games. Cria um personagem guerreiro para um jogo de fantasia medieval com: nome épico, 3 habilidades especiais, fraqueza secreta e aparência marcante. Descreve em tópicos.","ME AJUDA COM MEU JOGO URGENTE"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'You want to ask the AI to create a character for a game. Which prompt is more powerful?',
  $$["Create a character","Cool character for game","You are a game designer. Create a warrior character for a medieval fantasy game with: epic name, 3 special abilities, secret weakness and striking appearance. Describe in bullet points.","HELP ME WITH MY GAME URGENT"]$$::jsonb
FROM lessons WHERE slug = 's3-teste-missao-03';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"A IA respondeu algo que foi na direção certa mas ficou muito longo e técnico demais. O que você faz?","options":["Apaga tudo e começa uma conversa nova do zero","Aceita a resposta assim mesmo porque a IA sempre sabe o que é melhor","Itera: pede para resumir e usar linguagem mais simples mantendo as ideias principais","Procura outra IA que responda melhor"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'The AI responded with something in the right direction but it got too long and technical. What do you do?',
  $$["Delete everything and start a new conversation from scratch","Accept the response as is because AI always knows what is best","Iterate: ask to summarize and use simpler language while keeping the main ideas","Find another AI that responds better"]$$::jsonb
FROM lessons WHERE slug = 's3-teste-missao-03';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.
--    Teste (s3-teste-missao-03) nao tem templates - e' quiz puro.

-- s3-o-que-e-prompt
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Prompt simples vs detalhado', 'Compara esses dois prompts e me mostra a diferença: 1) Escreve uma história. 2) Você é um escritor de aventura. Escreve uma história de 3 parágrafos sobre um garoto de 10 anos que descobre uma porta mágica em seu quarto. Tom animado, final surpreendente.', '6-18', 1
FROM lessons WHERE slug = 's3-o-que-e-prompt';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que é prompt?', 'Me explica o que é um prompt de IA usando uma analogia divertida', '6-18', 2
FROM lessons WHERE slug = 's3-o-que-e-prompt';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu primeiro prompt', 'Me ajuda a criar meu primeiro prompt sobre algo que eu gosto muito', '6-18', 3
FROM lessons WHERE slug = 's3-o-que-e-prompt';

-- s3-5-elementos-prompt
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa os 5 elementos', 'Vou criar um prompt usando os 5 elementos: MISSÃO(cria uma receita), PERSONAGEM(chef italiano), ESTILO(animado e engraçado), DETALHES(para crianças de 10 anos, sem ingredientes caros), FORMATO(lista de passos numerados). Vai!', '6-18', 1
FROM lessons WHERE slug = 's3-5-elementos-prompt';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Avalia meu prompt', 'Avalia esse prompt e me diz quais dos 5 elementos estou usando: [coloca seu prompt aqui]', '6-18', 2
FROM lessons WHERE slug = 's3-5-elementos-prompt';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Melhora meu prompt', 'Meu prompt é: [escreve aqui]. Me ajuda a adicionar os 5 elementos para ficar mais poderoso', '6-18', 3
FROM lessons WHERE slug = 's3-5-elementos-prompt';

-- s3-prompts-ruins-vs-poderosos
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Detective de prompts', 'Analisa esse prompt e me diz o que está errado: Faz uma coisa sobre animais', '6-18', 1
FROM lessons WHERE slug = 's3-prompts-ruins-vs-poderosos';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Transforma esse prompt', 'Transforma esse prompt ruim em poderoso: Me explica matemática', '6-18', 2
FROM lessons WHERE slug = 's3-prompts-ruins-vs-poderosos';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual é melhor?', 'Qual desses prompts vai gerar uma resposta melhor e por quê? A) Escreve algo B) Você é um escritor de aventura. Escreve uma história de 3 parágrafos para crianças de 8 anos sobre um dragão que tem medo de fogo. Final feliz.', '6-18', 3
FROM lessons WHERE slug = 's3-prompts-ruins-vs-poderosos';

-- s3-contexto-e-tudo
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Sem contexto vs com contexto', 'Me responde essas duas versões do mesmo pedido: 1) Explica programação. 2) Sou um iniciante de 11 anos que nunca programou. Explica o que é programação usando a analogia de um jogo que eu possa entender, em 3 parágrafos simples.', '6-18', 1
FROM lessons WHERE slug = 's3-contexto-e-tudo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Adiciona contexto', 'Meu prompt é: [escreve aqui]. Me ajuda a adicionar os 4 elementos de contexto para melhorar', '6-18', 2
FROM lessons WHERE slug = 's3-contexto-e-tudo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Contexto na prática', 'Por que o contexto muda tanto a resposta da IA? Me dá um exemplo prático', '6-18', 3
FROM lessons WHERE slug = 's3-contexto-e-tudo';

-- s3-iterar-melhorar
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Pratica refinar', 'Me escreve um parágrafo sobre cachorros. Depois vou pedir pra você melhorar.', '6-18', 1
FROM lessons WHERE slug = 's3-iterar-melhorar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Pratica focar', 'Me lista 5 curiosidades sobre o espaço. Depois vou pedir pra você aprofundar uma.', '6-18', 2
FROM lessons WHERE slug = 's3-iterar-melhorar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Pratica redirecionar', 'Me explica o que é fotossíntese. [Depois que responder, diga: Não era bem isso. O que eu precisava era de uma explicação usando a analogia de uma fábrica.]', '6-18', 3
FROM lessons WHERE slug = 's3-iterar-melhorar';

COMMIT;
