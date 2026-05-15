-- 011_badges_english.sql
-- Adiciona name_en e description_en a badges, populando com a versao EN
-- dos 12 badges da migration 002. Frontend escolhe baseado no locale.
--
-- Idempotente: ALTER usa IF NOT EXISTS; UPDATEs sao deterministicos
-- (mesma entrada = mesma saida). Gate em run_migrations.sh detecta a
-- coluna name_en pra pular re-execucao.
-- BEGIN/COMMIT garante rollback total se algum UPDATE falhar.

BEGIN;

ALTER TABLE badges ADD COLUMN IF NOT EXISTS name_en TEXT;
ALTER TABLE badges ADD COLUMN IF NOT EXISTS description_en TEXT;

UPDATE badges SET name_en = 'First Steps',         description_en = 'Completed your first lesson'                       WHERE code = 'FIRST_STEPS';
UPDATE badges SET name_en = 'Quick Learner',       description_en = 'Completed 5 lessons'                                WHERE code = 'QUICK_LEARNER';
UPDATE badges SET name_en = 'Lesson Master',       description_en = 'Completed all lessons in your track'                WHERE code = 'LESSON_MASTER';
UPDATE badges SET name_en = 'Prompt Pro',          description_en = 'Used 20 guided prompts'                             WHERE code = 'PROMPT_PRO';
UPDATE badges SET name_en = 'Three in a Row',      description_en = '3-day streak'                                       WHERE code = 'STREAK_3';
UPDATE badges SET name_en = 'Bright Week',         description_en = '7-day streak'                                       WHERE code = 'STREAK_7';
UPDATE badges SET name_en = 'Gold Month',          description_en = '30-day streak'                                      WHERE code = 'STREAK_30';
UPDATE badges SET name_en = 'Challenge Ace',       description_en = 'Got 10 challenges right on the first try'           WHERE code = 'CHALLENGE_ACE';
UPDATE badges SET name_en = 'Curious Mind',        description_en = 'Explored 3 different tracks'                        WHERE code = 'CURIOUS_MIND';
UPDATE badges SET name_en = 'Storyteller',         description_en = 'Created 5 complete stories in chat'                 WHERE code = 'STORYTELLER';
UPDATE badges SET name_en = 'Level 5',             description_en = 'Reached level 5'                                    WHERE code = 'LEVEL_5';
UPDATE badges SET name_en = 'Legendary',           description_en = 'Reached level 10'                                   WHERE code = 'LEVEL_10';

-- Badges que aparecem em migration 002 alem dos 12 acima (POLITE_TALKER,
-- SAFETY_FIRST, EARLY_BIRD, LEVEL_3): traducao defensiva caso existam.
UPDATE badges SET name_en = 'Polite Talker',       description_en = 'Used magic words in 5 conversations'                WHERE code = 'POLITE_TALKER';
UPDATE badges SET name_en = 'Safety First',        description_en = 'Completed the safety lesson'                        WHERE code = 'SAFETY_FIRST';
UPDATE badges SET name_en = 'Early Bird',          description_en = 'Learned before 9am'                                 WHERE code = 'EARLY_BIRD';
UPDATE badges SET name_en = 'Capstone Builder',    description_en = 'Completed the final project'                        WHERE code = 'CAPSTONE_BUILDER';

COMMIT;
