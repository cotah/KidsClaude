-- Migration 016: backfill EN content_blocks + add prompt_templates pras 6
-- licoes de Stage 2 "Thinking" inseridas na 015. Tudo em uma transacao.
--
-- Gate em run_migrations.sh checa existencia de prompt_template pra
-- 's2-ia-pode-errar' (1a licao de Stage 2). Se nao existe, roda. Se ja,
-- skip - idempotente.
--
-- prompt_templates segue padrao das stages existentes: 3 por licao, sem
-- slots (nenhum template no DB hoje usa slots; PromptSlotEditor no
-- frontend e' codigo planejado mas inativo). label_en/template_en nao
-- existem no schema atual - templates sao PT only, frontend mostra
-- mesma string em ambos os locales (issue conhecido pra outra leva).

BEGIN;

-- 1) Backfill content_blocks_en pras 6 licoes de Stage 2
UPDATE lessons SET content_blocks_en = $$[
  {"type":"text","content":"You know when you study hard for a test but still get a question wrong? AI makes mistakes too — and understanding that is the secret to using AI smartly! AI learns by reading billions of texts written by humans. But humans also make mistakes, write wrong things, or have different opinions. AI absorbed all of that together — the good and the bad."},
  {"type":"text","content":"When AI invents an answer that looks true but isn't, we call that a hallucination. It's not lying on purpose — it's like when you try to remember a movie title and say something similar but wrong. The brain tried to help but missed. Real examples: ask AI to cite a book it hasn't read — it might invent a title that sounds real. Or ask about a recent news story — it might mix up info from different dates."},
  {"type":"text","content":"The golden rule: AI is a starting point, not the final answer. Whenever something matters — a date, a number, a news story — double-check it in another source. To practice: ask Atena to cite a famous book on any topic, then search to see if the book really exists."}
]$$::jsonb WHERE slug = 's2-ia-pode-errar';

UPDATE lessons SET content_blocks_en = $$[
  {"type":"text","content":"Imagine you studied a ton, read millions of books, and then walked into a room with no internet, no phone, no newspapers. You know everything you learned before entering — but you don't know anything that happened after. That's exactly how AI works. It has a training cutoff — a moment when it stopped learning new things."},
  {"type":"text","content":"That means if you ask about yesterday's game score, the latest song from your favorite artist, or what happened in the news this week — AI probably won't know. And if it tries to answer, it might invent something wrong."},
  {"type":"text","content":"But not everything changes fast. Math, history, science, grammar, how to code — those things change slowly. For that kind of question, AI is very reliable. Pro tip: stable facts -> trust. Recent events -> always verify on news sites. To practice: ask Atena something recent and watch how it honestly admits it doesn't know."}
]$$::jsonb WHERE slug = 's2-data-de-corte';

UPDATE lessons SET content_blocks_en = $$[
  {"type":"text","content":"You don't use the same app for everything, right? TikTok for videos, Spotify for music, WhatsApp for chatting. AI works the same way — each one was built with a different focus."},
  {"type":"text","content":"Claude is excellent at reasoning over long texts, writing carefully, explaining complex things, programming, analyzing documents — it's like a very patient teacher who reads everything attentively. ChatGPT is strong in general conversation, generating images with DALL-E, using plugins — it's a Swiss Army knife. Gemini shines in Google integration (Gmail, Docs, Drive), recent searches, and tasks in the Google ecosystem."},
  {"type":"text","content":"It's not that one is better — each has a place where it works best. A real engineer tests different tools and picks the right one for each job. Pro rule: Claude for thinking and creating; Gemini for searching/organizing in Google; ChatGPT when you need an image or plugins. To practice: describe a task to Atena and ask which AI to use."}
]$$::jsonb WHERE slug = 's2-cada-ia-superpoder';

UPDATE lessons SET content_blocks_en = $$[
  {"type":"text","content":"Imagine arriving in a new city and asking: What's the best place? The person gets confused — best place for what? Eating? Sleeping? Hanging out? Without context, helping well is impossible. With AI, it's the same."},
  {"type":"text","content":"Compare: Without context: 'Explain photosynthesis.' With context: 'I'm a 10-year-old student and need to explain photosynthesis to my class in a 2-minute presentation. Use simple language and an everyday example.' The second one generates a MUCH more useful answer — because AI knows who it's talking to and what you need."},
  {"type":"text","content":"The 4 elements of good context: (1) who you are, (2) what you want to do, (3) how you want the answer, (4) who it's for. To practice: pick a school topic, write two prompts (one with no context, one with all 4 elements), compare Atena's answers."}
]$$::jsonb WHERE slug = 's2-contexto-certo';

UPDATE lessons SET content_blocks_en = $$[
  {"type":"text","content":"No artist paints a perfect picture on the first brushstroke. No soccer player scores on every shot. Creating with AI is the same — the first response is rarely the best."},
  {"type":"text","content":"Iterating means taking what AI made and improving on top of it, without starting over. It's like editing a text — you don't throw it away and rewrite, you adjust what needs adjusting. Three techniques: REFINE ('it's good but make it shorter'), FOCUS ('from part 2, expand the second point'), REDIRECT ('that's not what I needed, what I actually need is...')."},
  {"type":"text","content":"The difference between an AI beginner and pro is NOT the first question — it's what you do after the first response. A beginner accepts anything. A pro iterates until it's right. To practice: ask Atena for something, then use the 3 techniques (refine, focus, redirect) in sequence."}
]$$::jsonb WHERE slug = 's2-iterar-melhorar';

UPDATE lessons SET content_blocks_en = $$[
  {"type":"text","content":"Time to test what you learned in this stage! Answer the 2 questions below and move on to Stage 3."}
]$$::jsonb WHERE slug = 's2-test-thinking';


-- 2) Insere prompt_templates (3 por licao, age_band='6-18', sem slots)

-- s2-ia-pode-errar
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cita 3 livros sobre um tema',
  'Cita 3 livros famosos sobre dinossauros. Quero verificar se realmente existem!',
  '6-18', 1 FROM lessons WHERE slug = 's2-ia-pode-errar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Conta uma notícia recente',
  'Me conta o que aconteceu nas notícias do mundo essa semana.',
  '6-18', 2 FROM lessons WHERE slug = 's2-ia-pode-errar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cita uma frase famosa',
  'Cita uma frase famosa do Albert Einstein. Quero pesquisar se ele realmente disse isso.',
  '6-18', 3 FROM lessons WHERE slug = 's2-ia-pode-errar';

-- s2-data-de-corte
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Sabe sobre evento recente?',
  'Quem ganhou o último jogo do meu time favorito? Se você não souber, me fala honestamente!',
  '6-18', 1 FROM lessons WHERE slug = 's2-data-de-corte';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'App mudou ano passado',
  'Qual foi a última grande atualização no TikTok? Se sua informação for antiga, me avisa.',
  '6-18', 2 FROM lessons WHERE slug = 's2-data-de-corte';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Pergunta de matemática',
  'Me explica como calcular a área de um círculo. Isso não muda com o tempo, então você deve saber bem!',
  '6-18', 3 FROM lessons WHERE slug = 's2-data-de-corte';

-- s2-cada-ia-superpoder
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual IA usar?',
  'Eu quero criar uma história longa com personagens detalhados. Qual IA você recomenda — Claude, ChatGPT ou Gemini? Por quê?',
  '6-18', 1 FROM lessons WHERE slug = 's2-cada-ia-superpoder';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'No que você é melhor?',
  'Em que tipo de tarefa você (Claude) se sai melhor que outras IAs? Me dá 3 exemplos.',
  '6-18', 2 FROM lessons WHERE slug = 's2-cada-ia-superpoder';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Compara as 3 IAs',
  'Faz uma comparação curta entre Claude, ChatGPT e Gemini em 3 critérios: textos longos, geração de imagens, integração com Google.',
  '6-18', 3 FROM lessons WHERE slug = 's2-cada-ia-superpoder';

-- s2-contexto-certo
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Prompt sem contexto',
  'Me explica fotossíntese.',
  '6-18', 1 FROM lessons WHERE slug = 's2-contexto-certo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Prompt com contexto',
  'Sou estudante de 10 anos e preciso explicar fotossíntese para minha turma numa apresentação de 2 minutos. Linguagem simples, exemplo com algo do dia a dia.',
  '6-18', 2 FROM lessons WHERE slug = 's2-contexto-certo';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Trabalho da escola',
  'Sou aluno de 12 anos e preciso de um resumo da Independência do Brasil para uma prova amanhã. 5 pontos principais, linguagem clara.',
  '6-18', 3 FROM lessons WHERE slug = 's2-contexto-certo';

-- s2-iterar-melhorar
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Refinar resposta',
  'Tá bom, mas quero mais curto. Pode resumir em 3 frases?',
  '6-18', 1 FROM lessons WHERE slug = 's2-iterar-melhorar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Focar num ponto',
  'Da resposta anterior, desenvolve mais o segundo ponto com um exemplo prático.',
  '6-18', 2 FROM lessons WHERE slug = 's2-iterar-melhorar';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Redirecionar',
  'Não era isso que eu queria. O que eu realmente preciso é entender com exemplos práticos pra criança aprender.',
  '6-18', 3 FROM lessons WHERE slug = 's2-iterar-melhorar';

-- s2-test-thinking
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Revisar a etapa',
  'Me faz um resumo dos 5 conceitos principais que aprendemos nessa etapa: alucinações, data de corte, diferentes IAs, contexto e iteração.',
  '6-18', 1 FROM lessons WHERE slug = 's2-test-thinking';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Praticar mais',
  'Me dá 3 perguntas práticas pra eu testar o que aprendi sobre IA. Sem dar a resposta!',
  '6-18', 2 FROM lessons WHERE slug = 's2-test-thinking';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Dica pro próximo stage',
  'Me dá uma dica curta do que vou aprender em Exploration (próximo stage). Curiosidade pra continuar!',
  '6-18', 3 FROM lessons WHERE slug = 's2-test-thinking';

COMMIT;
