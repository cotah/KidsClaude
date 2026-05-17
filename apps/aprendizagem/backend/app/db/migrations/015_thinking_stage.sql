-- Migration 015: novo Stage 2 "Thinking" entre Discovery e Exploration.
--
-- Renumera stages existentes: final exam (5) -> 6; regular 4->5, 3->4, 2->3.
-- Insere 6 licoes em stage=2 (5 conteudo + 1 stage test), 12 challenges.
-- Relaxa 2 CHECK constraints: lessons.stage agora 1..6, age_band aceita '6-18'.
--
-- ATOMICO: tudo dentro de BEGIN/COMMIT. Se algo falhar, rollback total.
-- IDEMPOTENTE via gate em run_migrations.sh (verifica se constraint ja
-- aceita stage <= 6).
--
-- title_en + description_en preenchidos junto. content_blocks_en e
-- question_en/options_en (dos challenges) ficam NULL nessa leva -
-- frontend ja faz fallback pro PT quando EN e' null (ver chat page +
-- lesson page locale fallback patterns). Backfill EN body pode vir em
-- migration 016 depois se necessario.

BEGIN;

-- 1) Relaxa CHECK do stage (1..5 -> 1..6)
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_stage_check;
ALTER TABLE lessons ADD CONSTRAINT lessons_stage_check
  CHECK (stage >= 1 AND stage <= 6);

-- 2) Adiciona '6-18' ao age_band aceito
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_age_band_check;
ALTER TABLE lessons ADD CONSTRAINT lessons_age_band_check
  CHECK (age_band = ANY (ARRAY['6-8','9-10','11-12','12+','6-18']));

-- 3) Renumera (bottom-up evita colisao com stage destino)
UPDATE lessons SET stage = 6 WHERE stage = 5;  -- final exam: 5 -> 6
UPDATE lessons SET stage = 5 WHERE stage = 4;
UPDATE lessons SET stage = 4 WHERE stage = 3;
UPDATE lessons SET stage = 3 WHERE stage = 2;

-- 4) Insere 6 novas licoes em stage=2 (5 conteudo + 1 stage test)
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's2-ia-pode-errar',
  'A IA pode errar?',
  'Can AI make mistakes?',
  'Entender alucinações e por que verificar respostas é essencial',
  'Understanding hallucinations and why verifying answers is essential',
  '6-18', 2, 1,
  $$[
    {"type":"text","content":"Sabe quando você estuda muito para uma prova mas ainda erra uma questão? A IA também erra — e entender isso é o segredo para usar a IA de forma inteligente! A IA aprende lendo bilhões de textos escritos por humanos. Mas humanos também cometem erros, escrevem coisas erradas, ou têm opiniões diferentes. A IA absorveu tudo isso junto — o bom e o ruim."},
    {"type":"text","content":"Quando a IA inventa uma resposta que parece verdadeira mas não é, chamamos isso de alucinação. Não é mentira de propósito — é como quando você tenta lembrar o nome de um filme e fala um nome parecido mas errado. O cérebro tentou ajudar mas errou. Exemplos reais: pedir para a IA citar um livro que ela não leu — ela pode inventar um título que parece real. Ou perguntar sobre uma notícia recente — ela pode misturar informações de datas diferentes."},
    {"type":"text","content":"A regra de ouro: a IA é um ponto de partida, não a resposta final. Sempre que algo for importante — uma data, um número, uma notícia — confirme em outra fonte. Pra praticar: peça à Atena pra citar um livro famoso sobre um tema qualquer, depois pesquise se o livro realmente existe."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-data-de-corte',
  'Por que a IA não sabe o que aconteceu ontem?',
  'Why doesn''t AI know what happened yesterday?',
  'Entender o conceito de data de corte e quando a IA é confiável',
  'Understanding the concept of training cutoff and when AI is reliable',
  '6-18', 2, 2,
  $$[
    {"type":"text","content":"Imagina que você estudou muito, leu milhões de livros, e aí entrou numa sala sem internet, sem celular, sem jornal. Você sabe tudo que aprendeu antes de entrar — mas não sabe nada do que aconteceu depois. É exatamente assim que a IA funciona. Ela tem uma data de corte — um momento em que parou de aprender coisas novas."},
    {"type":"text","content":"Isso significa que se você perguntar sobre o resultado de um jogo de ontem, a última música lançada pelo seu artista favorito, ou o que aconteceu nas notícias essa semana — a IA provavelmente não vai saber. E se tentar responder, pode inventar algo errado."},
    {"type":"text","content":"Mas nem tudo muda rápido. Matemática, história, ciência, gramática, como programar — essas coisas mudam devagar. Para esse tipo de pergunta, a IA é muito confiável. Dica profissional: fatos estáveis -> confie. Eventos recentes -> sempre verifique em sites de notícias. Pra praticar: pergunte à Atena algo recente e veja como ela responde com honestidade que não sabe."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-cada-ia-superpoder',
  'Cada IA tem um superpoder diferente',
  'Each AI has a different superpower',
  'Aprender as diferenças entre Claude, ChatGPT e Gemini',
  'Learning the differences between Claude, ChatGPT and Gemini',
  '6-18', 2, 3,
  $$[
    {"type":"text","content":"Você não usa o mesmo aplicativo para tudo, né? TikTok para vídeos, Spotify para música, WhatsApp para conversar. Com IA é igual — cada uma foi feita com um foco diferente."},
    {"type":"text","content":"Claude é excelente em raciocinar em textos longos, escrever com cuidado, explicar coisas complexas, programar, analisar documentos — é como um professor muito paciente que lê tudo com atenção. ChatGPT é forte em conversas gerais, gerar imagens com DALL-E, usar plugins — é um canivete suíço. Gemini brilha em integração com Google (Gmail, Docs, Drive), pesquisas recentes, e tarefas no ecossistema Google."},
    {"type":"text","content":"Não é que um seja melhor — cada um tem um lugar onde funciona melhor. Um engenheiro de verdade testa ferramentas diferentes e escolhe a certa pra cada trabalho. Regra do profissional: Claude pra pensar e criar; Gemini pra pesquisar/organizar no Google; ChatGPT quando precisar de imagem ou plugins. Pra praticar: descreva uma tarefa pra Atena e peça sugestão de qual IA usar."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-contexto-certo',
  'Como dar contexto certo para a IA',
  'How to give AI the right context',
  'Os 4 elementos do bom contexto e como eles mudam tudo',
  'The 4 elements of good context and how they change everything',
  '6-18', 2, 4,
  $$[
    {"type":"text","content":"Imagina que você chega numa cidade nova e pergunta: Qual é o melhor lugar? A pessoa fica confusa — melhor lugar pra quê? Comer? Dormir? Passear? Sem contexto, é impossível ajudar bem. Com a IA é igual."},
    {"type":"text","content":"Compare: Sem contexto: 'Me explica fotossíntese.' Com contexto: 'Sou estudante de 10 anos e preciso explicar fotossíntese para minha turma numa apresentação de 2 minutos. Usa linguagem simples e um exemplo com algo do dia a dia.' A segunda gera uma resposta MUITO mais útil — porque a IA sabe pra quem está falando e o que você precisa."},
    {"type":"text","content":"Os 4 elementos do bom contexto: (1) quem você é, (2) o que você quer fazer, (3) como quer a resposta, (4) pra quem é. Pra praticar: pegue um assunto da escola, escreva dois prompts (um sem contexto e um com os 4 elementos), compare as respostas da Atena."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-iterar-melhorar',
  'Iterar — melhorar até ficar perfeito',
  'Iterate — improve until it''s perfect',
  'Como melhorar respostas da IA sem começar do zero',
  'How to improve AI responses without starting over',
  '6-18', 2, 5,
  $$[
    {"type":"text","content":"Nenhum artista pinta um quadro perfeito na primeira pincelada. Nenhum jogador de futebol marca gol em todo chute. Criar com IA também é assim — a primeira resposta raramente é a melhor."},
    {"type":"text","content":"Iterar significa pegar o que a IA fez e melhorar em cima, sem começar do zero. É como editar um texto — você não joga fora e reescreve tudo, você ajusta o que precisa. Três técnicas: REFINAR (tá bom mas quero mais curto), FOCAR (da parte 2, desenvolve mais o segundo ponto), REDIRECIONAR (não era isso, o que eu preciso é...)."},
    {"type":"text","content":"A diferença entre iniciante e avançado em IA NÃO é a pergunta inicial — é o que faz depois da primeira resposta. Iniciante aceita qualquer coisa. Avançado itera até ficar certo. Pra praticar: peça algo pra Atena, depois use as 3 técnicas (refinar, focar, redirecionar) em sequência."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-test-thinking',
  'Teste do Stage 2 — Thinking',
  'Stage 2 Test — Thinking',
  'Quiz rápido pra fechar a etapa Thinking',
  'Quick quiz to close the Thinking stage',
  '6-18', 2, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu nesta etapa! Responda as 2 perguntas a seguir e siga adiante pra Stage 3."}
  ]$$::jsonb,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 5) Insere 12 challenges (2 por licao, multiple_choice, 10 XP cada).
-- Associa via slug pra nao depender do uuid auto-gerado das licoes acima.
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma alucinação de IA?","options":["Quando a IA vê imagens que não existem","Quando a IA inventa uma resposta que parece verdadeira mas está errada","Quando a IA fica lenta para responder","Quando a IA recusa uma pergunta"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's2-ia-pode-errar';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a regra de ouro ao usar respostas da IA?","options":["Sempre copiar e colar sem ler","Nunca usar IA para nada importante","Usar a IA como ponto de partida e confirmar informações importantes em outra fonte","Perguntar a mesma coisa três vezes para ter certeza"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-ia-pode-errar';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA não consegue responder sobre eventos muito recentes?","options":["Porque ela não tem acesso à internet","Porque ela tem uma data de corte — parou de aprender em determinado momento","Porque as notícias são protegidas por direitos autorais","Porque ela só fala sobre ciência e matemática"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's2-data-de-corte';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Para qual tipo de pergunta a IA é mais confiável?","options":["Quem ganhou o jogo de futebol ontem","Qual o último álbum lançado pelo seu cantor favorito","Como funciona a fotossíntese","Qual é o preço do tênis mais novo"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-data-de-corte';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Por que existem diferentes IAs no mercado?","options":["Porque as empresas não conseguem fazer uma IA só que funcione bem","Porque cada IA foi desenvolvida com focos diferentes e tem pontos fortes distintos","Porque a lei exige que haja competição no mercado de IA","Porque cada IA fala um idioma diferente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's2-cada-ia-superpoder';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Para qual tarefa o Claude é especialmente recomendado?","options":["Gerar imagens e ilustrações","Gerenciar arquivos no Google Drive","Raciocinar sobre textos longos, escrever com cuidado e programar","Jogar videogames online"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-cada-ia-superpoder';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"O que significa dar contexto para a IA?","options":["Escrever o prompt em letras maiúsculas","Repetir a pergunta três vezes seguidas","Informar quem você é, o que quer, como quer a resposta e para quem é","Usar palavras técnicas e difíceis"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-contexto-certo';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual desses prompts tem melhor contexto?","options":["Explica história do Brasil","Faz um resumo","Sou estudante de 12 anos e preciso de um resumo de 5 pontos sobre a Independência do Brasil para uma prova amanhã, linguagem simples","HISTÓRIA DO BRASIL AGORA"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-contexto-certo';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"O que significa iterar ao usar IA?","options":["Começar uma conversa nova cada vez que não gostou da resposta","Melhorar a resposta em cima do que a IA fez, sem começar do zero","Repetir a mesma pergunta até a IA acertar","Pedir para a IA refazer tudo completamente"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's2-iterar-melhorar';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença entre um usuário iniciante e avançado de IA?","options":["O avançado usa palavras mais difíceis no prompt","O iniciante usa mais IA por dia","O avançado itera e melhora a resposta; o iniciante aceita qualquer coisa","O avançado tem uma assinatura paga"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-iterar-melhorar';

-- Stage test challenges (2 perguntas integrativas)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Você pediu para uma IA citar três livros sobre dinossauros para sua pesquisa escolar. Como você deve usar essa resposta?","options":["Copiar os títulos direto para a pesquisa sem verificar","Verificar se os livros realmente existem antes de usar, porque a IA pode alucinar títulos","Pedir para a IA repetir a lista mais três vezes para confirmar","Só usar livros que a IA citar em inglês"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10
FROM lessons WHERE slug = 's2-test-thinking';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT id, 'multiple_choice',
  $${"question":"Você quer criar uma apresentação sobre um tema da escola. Qual é o melhor prompt?","options":["Cria apresentação","APRESENTAÇÃO SOBRE ANIMAIS","Sou estudante de 11 anos e preciso de uma apresentação de 5 slides sobre animais em extinção para minha turma. Linguagem simples, 1 fato curioso por slide, tom animado","Faz algo sobre animais que a professora vai gostar"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10
FROM lessons WHERE slug = 's2-test-thinking';

COMMIT;
