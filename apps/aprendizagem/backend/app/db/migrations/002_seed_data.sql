-- Migration 002 (corrigida) - dados seed: 12 lições, 12 badges, 12 desafios, 12 prompt templates
--
-- Correção principal:
--   O INSERT em `challenges` falhava com "column 'question' is of type jsonb but
--   expression is of type text" porque o CASE retorna tipo TEXT e o Postgres nao
--   converte implicitamente para JSONB em INSERT...SELECT. Solucao: cast (...)::jsonb
--   no resultado de cada CASE.
--
-- Idempotencia:
--   A 002 original nao tinha BEGIN, entao cada statement comitava sozinho. A primeira
--   tentativa ja inseriu badges e lessons antes de falhar em challenges. Esta versao
--   usa BEGIN/COMMIT + ON CONFLICT DO NOTHING para ser segura de re-rodar quantas
--   vezes precisar.

BEGIN;

-- =========================================================
-- 1) Badges (12 conquistas do MVP - spec secao 11.4)
-- =========================================================
INSERT INTO badges (code, name, description, icon, unlock_rule) VALUES
('FIRST_STEPS', 'Primeiros Passos', 'Completou sua primeira lição', 'first-steps', '{"type": "lesson_completed", "count": 1}'),
('QUICK_LEARNER', 'Aprendiz Rápido', 'Completou 5 lições', 'quick-learner', '{"type": "lesson_completed", "count": 5}'),
('LESSON_MASTER', 'Mestre das Lições', 'Completou todas as lições da sua trilha', 'lesson-master', '{"type": "track_completed"}'),
('PROMPT_PRO', 'Mestre dos Prompts', 'Usou 20 prompts guiados', 'prompt-pro', '{"type": "messages_sent", "count": 20}'),
('STREAK_3', 'Trio Vencedor', 'Streak de 3 dias', 'streak-3', '{"type": "streak_days", "count": 3}'),
('STREAK_7', 'Semana Brilhante', 'Streak de 7 dias', 'streak-7', '{"type": "streak_days", "count": 7}'),
('STREAK_30', 'Mês de Ouro', 'Streak de 30 dias', 'streak-30', '{"type": "streak_days", "count": 30}'),
('CHALLENGE_ACE', 'Ás dos Desafios', 'Acertou 10 desafios na primeira tentativa', 'challenge-ace', '{"type": "first_attempt_challenges", "count": 10}'),
('CURIOUS_MIND', 'Mente Curiosa', 'Explorou 3 trilhas diferentes', 'curious-mind', '{"type": "different_tracks", "count": 3}'),
('STORYTELLER', 'Contador de Histórias', 'Criou 5 histórias completas no chat', 'storyteller', '{"type": "story_sessions", "count": 5}'),
('LEVEL_5', 'Nível 5', 'Alcançou o nível 5', 'level-5', '{"type": "level_reached", "level": 5}'),
('LEVEL_10', 'Lendário', 'Alcançou o nível 10', 'level-10', '{"type": "level_reached", "level": 10}')
ON CONFLICT (code) DO NOTHING;

-- =========================================================
-- 2) Licoes faixa 6-8 anos (6 licoes)
-- =========================================================
INSERT INTO lessons (slug, title, description, age_band, order_index, content_blocks, xp_reward) VALUES
('ola-atena-6-8', 'Olá, Atena!', 'Conheça sua nova amiga robô que adora conversar', '6-8', 1,
'[
    {"type": "text", "content": "Oi! Eu sou a Atena, sua nova amiga robô! 🤖"},
    {"type": "image", "src": "atena-hello.png", "alt": "Atena cumprimentando"},
    {"type": "text", "content": "Adoro conversar e ajudar você a aprender coisas novas. Vamos nos divertir juntos!"}
]', 50),

('primeira-conversa-6-8', 'Primeira Conversa', 'Aprenda a falar com a Atena de um jeito especial', '6-8', 2,
'[
    {"type": "text", "content": "Para conversar comigo, você toca nos botões mágicos! ✨"},
    {"type": "image", "src": "magic-buttons.png", "alt": "Botões coloridos"},
    {"type": "text", "content": "Cada botão tem uma pergunta diferente. Toque em um e veja a mágica!"}
]', 50),

('contando-historias-6-8', 'Contando Histórias', 'Descubra como a Atena conta histórias incríveis', '6-8', 3,
'[
    {"type": "text", "content": "Eu sei milhares de histórias! De dragões, princesas, aventuras..."},
    {"type": "image", "src": "storytelling.png", "alt": "Livro mágico aberto"},
    {"type": "text", "content": "Quando você pede uma história, eu invento uma só pra você!"}
]', 60),

('aprendendo-brincando-6-8', 'Aprendendo Brincando', 'Veja como aprender pode ser divertido', '6-8', 4,
'[
    {"type": "text", "content": "Comigo você aprende sem perceber! É só brincar! 🎮"},
    {"type": "image", "src": "learning-fun.png", "alt": "Crianças brincando com robô"},
    {"type": "text", "content": "Posso te ajudar com lição de casa, explicar coisas difíceis de um jeito fácil..."}
]', 50),

('sendo-educado-6-8', 'Sendo Educado', 'Aprenda as palavras mágicas para uma conversa legal', '6-8', 5,
'[
    {"type": "text", "content": "As palavras mágicas funcionam comigo também! ✨"},
    {"type": "image", "src": "magic-words.png", "alt": "Por favor, obrigado, com licença"},
    {"type": "text", "content": "''Por favor'', ''obrigado'', ''com licença''... Elas tornam nossa conversa mais gostosa!"}
]', 50),

('seguranca-primeiro-6-8', 'Segurança Primeiro', 'Regras importantes para ficar sempre seguro', '6-8', 6,
'[
    {"type": "text", "content": "Existem segredos que só você e seus pais podem saber! 🔒"},
    {"type": "image", "src": "safety-first.png", "alt": "Escudo protetor"},
    {"type": "text", "content": "Nunca conte seu nome completo, endereço ou telefone para mim. Eu não preciso saber!"}
]', 60)
ON CONFLICT (slug) DO NOTHING;

-- =========================================================
-- 3) Licoes faixa 9-12 anos (6 licoes)
-- =========================================================
INSERT INTO lessons (slug, title, description, age_band, order_index, content_blocks, xp_reward) VALUES
('como-ia-funciona-9-12', 'Como a IA Funciona', 'Descubra os segredos por trás da inteligência artificial', '9-12', 1,
'[
    {"type": "text", "content": "Inteligência artificial não é mágica - é matemática muito avançada! 🧮"},
    {"type": "image", "src": "ai-brain.png", "alt": "Cérebro digital"},
    {"type": "text", "content": "Eu fui treinada lendo milhões de textos e aprendendo padrões. É como você aprender a ler, mas muito mais rápido!"}
]', 70),

('prompts-inteligentes-9-12', 'Prompts Inteligentes', 'Aprenda a fazer perguntas que geram respostas incríveis', '9-12', 2,
'[
    {"type": "text", "content": "A arte de conversar com IA se chama ''prompt engineering''! 🎯"},
    {"type": "image", "src": "prompt-engineering.png", "alt": "Engrenagens do pensamento"},
    {"type": "text", "content": "Quanto mais específico e claro você for, melhor eu entendo o que você quer!"}
]', 80),

('criatividade-com-ia-9-12', 'Criatividade com IA', 'Use a IA como parceira criativa nos seus projetos', '9-12', 3,
'[
    {"type": "text", "content": "Juntos podemos criar histórias, poemas, ideias para projetos... 🎨"},
    {"type": "image", "src": "creativity.png", "alt": "Paleta de cores e ideias"},
    {"type": "text", "content": "Eu não substituo sua criatividade - eu amplifico ela! Você tem as ideias, eu ajudo a desenvolvê-las."}
]', 80),

('pesquisa-responsavel-9-12', 'Pesquisa Responsável', 'Aprenda a verificar informações e usar IA com sabedoria', '9-12', 4,
'[
    {"type": "text", "content": "Nem tudo que eu digo está 100% certo. Sempre verifique informações importantes! ⚠️"},
    {"type": "image", "src": "fact-check.png", "alt": "Lupa investigativa"},
    {"type": "text", "content": "Sou ótima para brainstorming e explicações, mas para trabalhos escolares, confirme tudo em fontes confiáveis!"}
]', 90),

('colaboracao-humano-ia-9-12', 'Colaboração Humano-IA', 'Entenda como trabalhar em equipe com inteligência artificial', '9-12', 5,
'[
    {"type": "text", "content": "O futuro é sobre humanos e IA trabalhando juntos! 🤝"},
    {"type": "image", "src": "collaboration.png", "alt": "Aperto de mãos humano-robô"},
    {"type": "text", "content": "Você traz intuição, emoção e experiência humana. Eu trago processamento rápido e acesso a informações."}
]', 80),

('etica-e-ia-9-12', 'Ética e IA', 'Reflexões importantes sobre tecnologia e responsabilidade', '9-12', 6,
'[
    {"type": "text", "content": "Com grandes poderes vêm grandes responsabilidades! 🦸‍♂️"},
    {"type": "image", "src": "ethics.png", "alt": "Balança da justiça"},
    {"type": "text", "content": "IA deve ser usada para ajudar, não para enganar. Sempre seja honesto sobre quando usa minha ajuda!"}
]', 100)
ON CONFLICT (slug) DO NOTHING;

-- =========================================================
-- 4) Desafios (1 multiple_choice por licao = 12 total)
--    FIX: cast (...)::jsonb no resultado de cada CASE para evitar
--    erro 42804 "column is of type jsonb but expression is of type text".
--    Sem ON CONFLICT: nao ha chave natural unica em challenges; em
--    re-run, primeiro deletamos as linhas antigas dessa migracao.
-- =========================================================
-- Limpeza preventiva: remove desafios das 12 licoes seed caso re-rodada.
DELETE FROM challenges
WHERE lesson_id IN (SELECT id FROM lessons WHERE slug IN (
    'ola-atena-6-8','primeira-conversa-6-8','contando-historias-6-8',
    'aprendendo-brincando-6-8','sendo-educado-6-8','seguranca-primeiro-6-8',
    'como-ia-funciona-9-12','prompts-inteligentes-9-12','criatividade-com-ia-9-12',
    'pesquisa-responsavel-9-12','colaboracao-humano-ia-9-12','etica-e-ia-9-12'
));

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward)
SELECT
    l.id,
    'multiple_choice',
    (CASE l.slug
        WHEN 'ola-atena-6-8' THEN '{"question": "Como a Atena se apresentou?", "options": ["Como uma amiga robô", "Como uma professora", "Como um jogo", "Como um livro"]}'
        WHEN 'primeira-conversa-6-8' THEN '{"question": "Como você conversa com a Atena?", "options": ["Tocando nos botões", "Gritando", "Escrevendo cartas", "Cantando"]}'
        WHEN 'contando-historias-6-8' THEN '{"question": "Quantas histórias a Atena sabe?", "options": ["Milhares", "Dez", "Três", "Nenhuma"]}'
        WHEN 'aprendendo-brincando-6-8' THEN '{"question": "Como você aprende com a Atena?", "options": ["Brincando", "Estudando muito", "Dormindo", "Assistindo TV"]}'
        WHEN 'sendo-educado-6-8' THEN '{"question": "Qual é uma palavra mágica?", "options": ["Por favor", "Abracadabra", "Presto", "Alakazam"]}'
        WHEN 'seguranca-primeiro-6-8' THEN '{"question": "O que você não deve contar para a Atena?", "options": ["Seu endereço", "Que gosta de brincar", "Sua cor favorita", "Que tem um pet"]}'
        WHEN 'como-ia-funciona-9-12' THEN '{"question": "IA é baseada em:", "options": ["Matemática avançada", "Mágica real", "Poderes especiais", "Sorte"]}'
        WHEN 'prompts-inteligentes-9-12' THEN '{"question": "Prompt engineering é:", "options": ["A arte de fazer boas perguntas", "Programar robôs", "Consertar computadores", "Criar jogos"]}'
        WHEN 'criatividade-com-ia-9-12' THEN '{"question": "A IA com criatividade:", "options": ["Amplifica suas ideias", "Substitui sua mente", "Faz tudo sozinha", "Não ajuda em nada"]}'
        WHEN 'pesquisa-responsavel-9-12' THEN '{"question": "Informações da IA devem sempre ser:", "options": ["Verificadas", "Aceitas sem questionar", "Ignoradas", "Decoradas"]}'
        WHEN 'colaboracao-humano-ia-9-12' THEN '{"question": "Humanos e IA trabalham melhor:", "options": ["Em equipe", "Separados", "Competindo", "Um substituindo o outro"]}'
        WHEN 'etica-e-ia-9-12' THEN '{"question": "Ao usar IA, você deve ser:", "options": ["Honesto sobre sua ajuda", "Secreto", "Competitivo", "Independente"]}'
    END)::jsonb,
    (CASE l.slug
        WHEN 'ola-atena-6-8' THEN '{"answer": 0}'
        WHEN 'primeira-conversa-6-8' THEN '{"answer": 0}'
        WHEN 'contando-historias-6-8' THEN '{"answer": 0}'
        WHEN 'aprendendo-brincando-6-8' THEN '{"answer": 0}'
        WHEN 'sendo-educado-6-8' THEN '{"answer": 0}'
        WHEN 'seguranca-primeiro-6-8' THEN '{"answer": 0}'
        WHEN 'como-ia-funciona-9-12' THEN '{"answer": 0}'
        WHEN 'prompts-inteligentes-9-12' THEN '{"answer": 0}'
        WHEN 'criatividade-com-ia-9-12' THEN '{"answer": 0}'
        WHEN 'pesquisa-responsavel-9-12' THEN '{"answer": 0}'
        WHEN 'colaboracao-humano-ia-9-12' THEN '{"answer": 0}'
        WHEN 'etica-e-ia-9-12' THEN '{"answer": 0}'
    END)::jsonb,
    20
FROM lessons l
WHERE l.slug IN (
    'ola-atena-6-8','primeira-conversa-6-8','contando-historias-6-8',
    'aprendendo-brincando-6-8','sendo-educado-6-8','seguranca-primeiro-6-8',
    'como-ia-funciona-9-12','prompts-inteligentes-9-12','criatividade-com-ia-9-12',
    'pesquisa-responsavel-9-12','colaboracao-humano-ia-9-12','etica-e-ia-9-12'
);

-- =========================================================
-- 5) Prompt templates - faixa 6-8 (botoes fechados, sem slots)
-- =========================================================
-- Limpeza preventiva: remove templates 6-8 das 12 licoes seed caso re-rodada.
DELETE FROM prompt_templates
WHERE age_band = '6-8'
  AND lesson_id IN (SELECT id FROM lessons WHERE slug IN (
    'ola-atena-6-8','primeira-conversa-6-8','contando-historias-6-8',
    'aprendendo-brincando-6-8','sendo-educado-6-8','seguranca-primeiro-6-8'
));

INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT
    l.id,
    CASE
        WHEN l.slug = 'ola-atena-6-8' THEN 'Conte sobre você!'
        WHEN l.slug = 'primeira-conversa-6-8' THEN 'Como você funciona?'
        WHEN l.slug = 'contando-historias-6-8' THEN 'Conte uma história de aventura!'
        WHEN l.slug = 'aprendendo-brincando-6-8' THEN 'Me ajuda com matemática?'
        WHEN l.slug = 'sendo-educado-6-8' THEN 'Por favor, me ensine algo legal!'
        WHEN l.slug = 'seguranca-primeiro-6-8' THEN 'Por que é importante ser seguro?'
    END,
    CASE
        WHEN l.slug = 'ola-atena-6-8' THEN 'Me conte mais sobre você, Atena! O que você mais gosta de fazer?'
        WHEN l.slug = 'primeira-conversa-6-8' THEN 'Como você consegue entender o que eu falo e responder tão rápido?'
        WHEN l.slug = 'contando-historias-6-8' THEN 'Por favor, conte uma história de aventura com um herói corajoso!'
        WHEN l.slug = 'aprendendo-brincando-6-8' THEN 'Pode me ajudar a aprender matemática de um jeito divertido?'
        WHEN l.slug = 'sendo-educado-6-8' THEN 'Por favor, me ensine algo interessante e legal!'
        WHEN l.slug = 'seguranca-primeiro-6-8' THEN 'Por que é tão importante manter alguns segredos seguros?'
    END,
    '6-8',
    0
FROM lessons l
WHERE l.age_band = '6-8'
  AND l.slug IN (
    'ola-atena-6-8','primeira-conversa-6-8','contando-historias-6-8',
    'aprendendo-brincando-6-8','sendo-educado-6-8','seguranca-primeiro-6-8'
);

-- =========================================================
-- 6) Prompt templates - faixa 9-12 (com slots editaveis em JSONB)
--    FIX preventivo: cast (...)::jsonb tambem aqui na coluna `slots`,
--    embora a 002 original ja inserisse texto que era coercido. Mantemos
--    o cast explicito por seguranca.
-- =========================================================
DELETE FROM prompt_templates
WHERE age_band = '9-12'
  AND lesson_id IN (SELECT id FROM lessons WHERE slug IN (
    'como-ia-funciona-9-12','prompts-inteligentes-9-12','criatividade-com-ia-9-12',
    'pesquisa-responsavel-9-12','colaboracao-humano-ia-9-12','etica-e-ia-9-12'
));

INSERT INTO prompt_templates (lesson_id, label, template, slots, age_band, order_index)
SELECT
    l.id,
    CASE
        WHEN l.slug = 'como-ia-funciona-9-12' THEN 'Explique {{conceito}} de IA'
        WHEN l.slug = 'prompts-inteligentes-9-12' THEN 'Como melhorar prompts sobre {{tema}}?'
        WHEN l.slug = 'criatividade-com-ia-9-12' THEN 'Crie uma {{tipo_obra}} sobre {{assunto}}'
        WHEN l.slug = 'pesquisa-responsavel-9-12' THEN 'Fatos sobre {{topico}} para verificar'
        WHEN l.slug = 'colaboracao-humano-ia-9-12' THEN 'Como IA ajuda em {{area}}?'
        WHEN l.slug = 'etica-e-ia-9-12' THEN 'Dilema ético: IA em {{situacao}}'
    END,
    CASE
        WHEN l.slug = 'como-ia-funciona-9-12' THEN 'Me explique o conceito de {{conceito}} em inteligência artificial de forma clara'
        WHEN l.slug = 'prompts-inteligentes-9-12' THEN 'Como posso melhorar meus prompts quando pergunto sobre {{tema}}?'
        WHEN l.slug = 'criatividade-com-ia-9-12' THEN 'Vamos criar uma {{tipo_obra}} interessante sobre {{assunto}} juntos!'
        WHEN l.slug = 'pesquisa-responsavel-9-12' THEN 'Me dê alguns fatos sobre {{topico}} que eu deveria verificar em outras fontes'
        WHEN l.slug = 'colaboracao-humano-ia-9-12' THEN 'Como a IA pode ajudar profissionais da área de {{area}}?'
        WHEN l.slug = 'etica-e-ia-9-12' THEN 'Qual sua opinião sobre o uso ético de IA na situação: {{situacao}}?'
    END,
    (CASE l.slug
        WHEN 'como-ia-funciona-9-12' THEN '[{"name": "conceito", "max_length": 30, "allowed_chars": "^[A-Za-zÀ-ÿ0-9 ]+$"}]'
        WHEN 'prompts-inteligentes-9-12' THEN '[{"name": "tema", "max_length": 30, "allowed_chars": "^[A-Za-zÀ-ÿ0-9 ]+$"}]'
        WHEN 'criatividade-com-ia-9-12' THEN '[{"name": "tipo_obra", "max_length": 20, "allowed_chars": "^[A-Za-zÀ-ÿ ]+$"}, {"name": "assunto", "max_length": 30, "allowed_chars": "^[A-Za-zÀ-ÿ0-9 ]+$"}]'
        WHEN 'pesquisa-responsavel-9-12' THEN '[{"name": "topico", "max_length": 30, "allowed_chars": "^[A-Za-zÀ-ÿ0-9 ]+$"}]'
        WHEN 'colaboracao-humano-ia-9-12' THEN '[{"name": "area", "max_length": 30, "allowed_chars": "^[A-Za-zÀ-ÿ0-9 ]+$"}]'
        WHEN 'etica-e-ia-9-12' THEN '[{"name": "situacao", "max_length": 50, "allowed_chars": "^[A-Za-zÀ-ÿ0-9 .,!?]+$"}]'
    END)::jsonb,
    '9-12',
    0
FROM lessons l
WHERE l.age_band = '9-12'
  AND l.slug IN (
    'como-ia-funciona-9-12','prompts-inteligentes-9-12','criatividade-com-ia-9-12',
    'pesquisa-responsavel-9-12','colaboracao-humano-ia-9-12','etica-e-ia-9-12'
);

COMMIT;

-- =========================================================
-- Verificacao final - rode estas queries depois do COMMIT
-- para confirmar que tudo foi inserido:
--
--   SELECT COUNT(*) FROM badges;          -- esperado: 12
--   SELECT COUNT(*) FROM lessons;         -- esperado: 12
--   SELECT COUNT(*) FROM challenges;      -- esperado: 12
--   SELECT COUNT(*) FROM prompt_templates;-- esperado: 12 (6 da faixa 6-8 + 6 da 9-12)
-- =========================================================
