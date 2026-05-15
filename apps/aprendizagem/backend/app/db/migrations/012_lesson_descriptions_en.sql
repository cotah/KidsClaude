-- 012_lesson_descriptions_en.sql
-- Adiciona description_en a lessons e popula com a versao EN do
-- subtitulo curto exibido no card da lista de licoes da stage.
--
-- Migration 010 ja' adicionou title_en e content_blocks_en. Faltava
-- o description_en (subtitulo de 1 linha) - sem ele, a lista
-- /play/stage/N mostra titulo EN mas descricao PT.
--
-- Idempotente: ALTER usa IF NOT EXISTS; UPDATEs deterministicos.
-- Gate em run_migrations.sh detecta lessons.description_en.
-- BEGIN/COMMIT pra rollback total se algo falhar.

BEGIN;

ALTER TABLE lessons ADD COLUMN IF NOT EXISTS description_en TEXT;

-- Stage 1 (6-8)
UPDATE lessons SET description_en = 'Discover what AI really is'                 WHERE slug = 's1-o-que-e-ia';
UPDATE lessons SET description_en = 'Meet your new AI friend'                    WHERE slug = 's1-quem-e-claude';
UPDATE lessons SET description_en = 'Learn the magic of prompts'                 WHERE slug = 's1-como-conversar-claude';
UPDATE lessons SET description_en = 'Create amazing stories together'            WHERE slug = 's1-claude-conta-historias';

-- Stage 2 (9-10)
UPDATE lessons SET description_en = 'How apps talk to each other'                WHERE slug = 's2-o-que-e-api';
UPDATE lessons SET description_en = 'Understand the data format APIs use'        WHERE slug = 's2-json-lingua-apis';
UPDATE lessons SET description_en = 'Real APIs you can try right now'            WHERE slug = 's2-apis-gratuitas';
UPDATE lessons SET description_en = 'Combine real data with AI creativity'       WHERE slug = 's2-claude-apis-superpoder';

-- Stage 3 (11-12)
UPDATE lessons SET description_en = 'Learn what powers every app'                WHERE slug = 's3-o-que-e-codigo';
UPDATE lessons SET description_en = 'Get a full-stack dev anytime'               WHERE slug = 's3-claude-escreve-codigo';
UPDATE lessons SET description_en = '6 ingredients for pro-quality sites'        WHERE slug = 's3-receita-site-perfeito';
UPDATE lessons SET description_en = 'Build apps with real data via fetch'        WHERE slug = 's3-site-api-app-real';

-- Stage 4 (12+)
UPDATE lessons SET description_en = 'The skill that pays $175k/year'             WHERE slug = 's4-prompt-engineering';
UPDATE lessons SET description_en = 'Why prompt quality matters most'            WHERE slug = 's4-prompts-poderosos-vs-fracos';
UPDATE lessons SET description_en = 'Behind every great AI product'              WHERE slug = 's4-system-prompts';
UPDATE lessons SET description_en = 'The new AI Engineer skillset'               WHERE slug = 's4-claude-code-mcp';

-- Final exam
UPDATE lessons SET description_en = 'Plan your dream app in 5 steps'             WHERE is_final_exam = true;

COMMIT;
