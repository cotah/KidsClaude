-- 007_more_prompt_templates.sql
-- Adiciona 2 templates extras por licao (16 licoes x 2 = 32 inserts) pra
-- que cada licao tenha 3 sugestoes clicaveis no chat (1 ja seedada na 005
-- + 2 aqui = 3 botoes por licao). Mantem age_band casando com a licao.
--
-- Idempotente via gate no run_migrations.sh (label canonica unica:
-- 'Curiosidade legal sobre IA'). Se ela ja existe, 007 ja rodou.
--
-- Order_index = 2 e 3 pra ficarem abaixo do template original (order_index=1).

BEGIN;

INSERT INTO prompt_templates (lesson_id, label, template, slots, age_band, order_index) VALUES

-- ============================================================
-- STAGE 1 (age 6-8) - simples e divertido
-- ============================================================

((SELECT id FROM lessons WHERE slug = 's1-o-que-e-ia'),
 'Curiosidade legal sobre IA',
 'Me conta uma coisa surpreendente sobre IA que poucas crianças sabem!',
 NULL, '6-8', 2),
((SELECT id FROM lessons WHERE slug = 's1-o-que-e-ia'),
 'IA pode errar?',
 'Me dá 3 exemplos de coisas que a IA ainda erra muito ou nao consegue fazer bem.',
 NULL, '6-8', 3),

((SELECT id FROM lessons WHERE slug = 's1-quem-e-claude'),
 'O que você ADORA fazer?',
 'Me conta 3 coisas que você adora fazer e 2 que você nao consegue fazer bem!',
 NULL, '6-8', 2),
((SELECT id FROM lessons WHERE slug = 's1-quem-e-claude'),
 'Como você aprendeu?',
 'Como você foi ensinado a falar comigo? Me explica como se eu tivesse 7 anos.',
 NULL, '6-8', 3),

((SELECT id FROM lessons WHERE slug = 's1-como-conversar-claude'),
 '3 prompts super bons',
 'Me mostra 3 exemplos de prompts MUITO bons pra fazer perguntas legais pra uma IA.',
 NULL, '6-8', 2),
((SELECT id FROM lessons WHERE slug = 's1-como-conversar-claude'),
 'Vamos brincar de adivinhação',
 'Vamos brincar! Pense em um animal e me dá 3 dicas pra eu adivinhar qual e.',
 NULL, '6-8', 3),

((SELECT id FROM lessons WHERE slug = 's1-claude-conta-historias'),
 'História com meu nome',
 'Crie uma aventura curta onde o herói principal sou eu (você inventa o nome). Me surpreenda!',
 NULL, '6-8', 2),
((SELECT id FROM lessons WHERE slug = 's1-claude-conta-historias'),
 'História de fantasma boba',
 'Conte uma história de fantasma boba e engraçada com final que faz rir, nao com medo!',
 NULL, '6-8', 3),

-- ============================================================
-- STAGE 2 (age 9-10) - APIs e dados
-- ============================================================

((SELECT id FROM lessons WHERE slug = 's2-o-que-e-api'),
 'API explicada com pizzaria',
 'Explica o que e uma API usando uma pizzaria como analogia: o cliente, o garçom e o cozinheiro.',
 NULL, '9-10', 2),
((SELECT id FROM lessons WHERE slug = 's2-o-que-e-api'),
 'APIs do meu dia',
 'Me mostra 5 sites/apps que eu uso e que provavelmente usam APIs por trás. Explica brevemente.',
 NULL, '9-10', 3),

((SELECT id FROM lessons WHERE slug = 's2-json-lingua-apis'),
 'JSON do herói inventado',
 'Crie o JSON de um herói inventado por você. Inclua nome, poderes, idade e fraquezas.',
 NULL, '9-10', 2),
((SELECT id FROM lessons WHERE slug = 's2-json-lingua-apis'),
 'JSON vs XML lado a lado',
 'Mostra a mesma informaçao (sobre um cachorro) em JSON e em XML, lado a lado, e diz qual e mais facil de ler.',
 NULL, '9-10', 3),

((SELECT id FROM lessons WHERE slug = 's2-apis-gratuitas'),
 'APIs gratuitas pra crianças',
 'Me sugira 5 APIs gratuitas e seguras que crianças podem explorar (Pokémon, espaço, animais, etc).',
 NULL, '9-10', 2),
((SELECT id FROM lessons WHERE slug = 's2-apis-gratuitas'),
 'Como testar uma API?',
 'Me explica passo a passo como eu testaria uma API gratuita usando so o navegador, sem instalar nada.',
 NULL, '9-10', 3),

((SELECT id FROM lessons WHERE slug = 's2-claude-apis-superpoder'),
 'Time perfeito de Pokémon',
 'Monte um time perfeito de 6 Pokémon equilibrado pra iniciantes, explicando os pontos fortes de cada um.',
 NULL, '9-10', 2),
((SELECT id FROM lessons WHERE slug = 's2-claude-apis-superpoder'),
 'Quiz de Pokémon',
 'Crie um quiz divertido com 5 perguntas sobre Pokémon, com 4 alternativas cada. As respostas vao no final.',
 NULL, '9-10', 3),

-- ============================================================
-- STAGE 3 (age 11-12) - codigo e sites
-- ============================================================

((SELECT id FROM lessons WHERE slug = 's3-o-que-e-codigo'),
 'CSS na prática',
 'Mostra um exemplo simples de CSS que muda a cor e o tamanho do texto. Explica linha por linha.',
 NULL, '11-12', 2),
((SELECT id FROM lessons WHERE slug = 's3-o-que-e-codigo'),
 'JavaScript pra iniciante',
 'Mostra um JavaScript SUPER simples que faz aparecer um alerta quando clico num botao. Explica.',
 NULL, '11-12', 3),

((SELECT id FROM lessons WHERE slug = 's3-claude-escreve-codigo'),
 'Site sobre meu hobby',
 'Crie um site simples sobre algum hobby (você sugere). HTML+CSS, com cabeçalho e 2 seções.',
 NULL, '11-12', 2),
((SELECT id FROM lessons WHERE slug = 's3-claude-escreve-codigo'),
 'Portfolio escolar',
 'Crie uma pagina HTML+CSS de portfolio escolar com 3 projetos ficticios e fotos placeholder.',
 NULL, '11-12', 3),

((SELECT id FROM lessons WHERE slug = 's3-receita-site-perfeito'),
 'Site de receitas fáceis',
 'Use a receita: TEMA receitas faceis, PUBLICO crianças, SECOES intro+lista+contato, CORES laranja/branco, EXTRAS fotos placeholder, DISPOSITIVOS responsivo.',
 NULL, '11-12', 2),
((SELECT id FROM lessons WHERE slug = 's3-receita-site-perfeito'),
 'Site de jogos retro',
 'Use a receita: TEMA games anos 90, PUBLICO nostalgicos, SECOES top 10+galeria+download, CORES preto e neon, EXTRAS animaçao 8-bit, DISPOSITIVOS responsivo.',
 NULL, '11-12', 3),

((SELECT id FROM lessons WHERE slug = 's3-site-api-app-real'),
 'Fatos sobre o espaço',
 'Crie um site simples HTML+JS que busca fatos da NASA APOD (Astronomy Picture of the Day). Explica como integrar.',
 NULL, '11-12', 2),
((SELECT id FROM lessons WHERE slug = 's3-site-api-app-real'),
 'App de previsao do tempo',
 'Crie um app HTML+JS que mostra a previsao do tempo de uma cidade usando uma API gratuita de clima. Comente o codigo.',
 NULL, '11-12', 3),

-- ============================================================
-- STAGE 4 (age 12+) - prompt engineering avançado
-- ============================================================

((SELECT id FROM lessons WHERE slug = 's4-prompt-engineering'),
 '5 pilares pra estudar matemática',
 'Crie um prompt poderoso usando os 5 pilares (Persona, Contexto, Objetivo, Formato, Exemplos) pra pedir ajuda pra estudar matematica.',
 NULL, '12+', 2),
((SELECT id FROM lessons WHERE slug = 's4-prompt-engineering'),
 'Prompt pra simular entrevista',
 'Crie um prompt usando os 5 pilares pra simular uma entrevista de emprego. A IA fara a parte do entrevistador.',
 NULL, '12+', 3),

((SELECT id FROM lessons WHERE slug = 's4-prompts-poderosos-vs-fracos'),
 'Plano de estudos: 3 versoes',
 'Mostre 3 prompts (fraco, medio, poderoso) pra pedir um plano de estudos. Explica a diferença.',
 NULL, '12+', 2),
((SELECT id FROM lessons WHERE slug = 's4-prompts-poderosos-vs-fracos'),
 'Historia de aventura: 3 versoes',
 'Quero pedir uma historia de aventura. Mostre como fazer isso de 3 formas: prompt fraco, medio e poderoso.',
 NULL, '12+', 3),

((SELECT id FROM lessons WHERE slug = 's4-system-prompts'),
 'System Prompt pra tutor',
 'Crie um System Prompt completo pra um tutor virtual de matematica, paciente e que usa exemplos do dia a dia.',
 NULL, '12+', 2),
((SELECT id FROM lessons WHERE slug = 's4-system-prompts'),
 'System Prompt pra chef',
 'Crie um System Prompt pra um chef virtual que ajuda crianças a cozinharem de forma segura e divertida.',
 NULL, '12+', 3),

((SELECT id FROM lessons WHERE slug = 's4-claude-code-mcp'),
 'Bot de Discord com Claude Code',
 'Como eu usaria Claude Code pra criar um bot de Discord que responde perguntas? Que comandos eu daria?',
 NULL, '12+', 2),
((SELECT id FROM lessons WHERE slug = 's4-claude-code-mcp'),
 'MCP pro meu calendário',
 'Explica como o MCP poderia me dar superpoderes pra integrar Claude Code com meu calendario do Google.',
 NULL, '12+', 3);

COMMIT;
