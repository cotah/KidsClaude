-- 013_force_lesson_translations.sql
-- Re-aplica UPDATEs de title_en (010) e description_en (012). As colunas
-- ja' existem mas em producao todos os valores estao NULL - migrations
-- 010/012 rodaram a parte ALTER mas as UPDATEs nao bateram (causa ainda
-- nao identificada; suspeita: psql sem ON_ERROR_STOP em version antiga
-- engoliu erro silencioso, COMMIT mesmo assim).
--
-- Gate em run_migrations.sh: detecta title_en NULL na slug canonica
-- 's1-o-que-e-ia'. Quando NULL -> roda. Apos sucesso, NULL vira
-- 'What is Artificial Intelligence?' -> gate fica false -> nao re-roda.
--
-- BEGIN/COMMIT garante atomicidade. Sem ALTER (colunas ja' existem).

BEGIN;

-- ============================================================
-- title_en (16 licoes regulares)
-- ============================================================
UPDATE lessons SET title_en = 'What is Artificial Intelligence?'   WHERE slug = 's1-o-que-e-ia';
UPDATE lessons SET title_en = 'Who is Claude?'                     WHERE slug = 's1-quem-e-claude';
UPDATE lessons SET title_en = 'How to Talk to Claude'              WHERE slug = 's1-como-conversar-claude';
UPDATE lessons SET title_en = 'Claude Tells Stories!'              WHERE slug = 's1-claude-conta-historias';
UPDATE lessons SET title_en = 'What is an API?'                    WHERE slug = 's2-o-que-e-api';
UPDATE lessons SET title_en = 'JSON — The Language of APIs'        WHERE slug = 's2-json-lingua-apis';
UPDATE lessons SET title_en = 'Free APIs to Explore!'              WHERE slug = 's2-apis-gratuitas';
UPDATE lessons SET title_en = 'Claude + APIs = Superpower!'        WHERE slug = 's2-claude-apis-superpoder';
UPDATE lessons SET title_en = 'What is Code?'                      WHERE slug = 's3-o-que-e-codigo';
UPDATE lessons SET title_en = 'Claude Writes Code for You!'        WHERE slug = 's3-claude-escreve-codigo';
UPDATE lessons SET title_en = 'The Perfect Website Recipe'         WHERE slug = 's3-receita-site-perfeito';
UPDATE lessons SET title_en = 'Website + API = A Real App!'        WHERE slug = 's3-site-api-app-real';
UPDATE lessons SET title_en = 'What is Prompt Engineering?'        WHERE slug = 's4-prompt-engineering';
UPDATE lessons SET title_en = 'Powerful vs. Weak Prompts'          WHERE slug = 's4-prompts-poderosos-vs-fracos';
UPDATE lessons SET title_en = 'System Prompts — Building AI Agents' WHERE slug = 's4-system-prompts';
UPDATE lessons SET title_en = 'Claude Code and MCP — The Future of AI' WHERE slug = 's4-claude-code-mcp';

-- ============================================================
-- description_en (16 + final exam)
-- ============================================================
UPDATE lessons SET description_en = 'Discover what AI really is'           WHERE slug = 's1-o-que-e-ia';
UPDATE lessons SET description_en = 'Meet your new AI friend'              WHERE slug = 's1-quem-e-claude';
UPDATE lessons SET description_en = 'Learn the magic of prompts'           WHERE slug = 's1-como-conversar-claude';
UPDATE lessons SET description_en = 'Create amazing stories together'      WHERE slug = 's1-claude-conta-historias';
UPDATE lessons SET description_en = 'How apps talk to each other'          WHERE slug = 's2-o-que-e-api';
UPDATE lessons SET description_en = 'Understand the data format APIs use'  WHERE slug = 's2-json-lingua-apis';
UPDATE lessons SET description_en = 'Real APIs you can try right now'      WHERE slug = 's2-apis-gratuitas';
UPDATE lessons SET description_en = 'Combine real data with AI creativity' WHERE slug = 's2-claude-apis-superpoder';
UPDATE lessons SET description_en = 'Learn what powers every app'          WHERE slug = 's3-o-que-e-codigo';
UPDATE lessons SET description_en = 'Get a full-stack dev anytime'         WHERE slug = 's3-claude-escreve-codigo';
UPDATE lessons SET description_en = '6 ingredients for pro-quality sites'  WHERE slug = 's3-receita-site-perfeito';
UPDATE lessons SET description_en = 'Build apps with real data via fetch' WHERE slug = 's3-site-api-app-real';
UPDATE lessons SET description_en = 'The skill that pays $175k/year'       WHERE slug = 's4-prompt-engineering';
UPDATE lessons SET description_en = 'Why prompt quality matters most'      WHERE slug = 's4-prompts-poderosos-vs-fracos';
UPDATE lessons SET description_en = 'Behind every great AI product'        WHERE slug = 's4-system-prompts';
UPDATE lessons SET description_en = 'The new AI Engineer skillset'         WHERE slug = 's4-claude-code-mcp';
UPDATE lessons SET description_en = 'Plan your dream app in 5 steps'       WHERE is_final_exam = true;

COMMIT;
