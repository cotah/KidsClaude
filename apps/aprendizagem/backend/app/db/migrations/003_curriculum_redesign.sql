-- Migration 003: Curriculum Redesign Schema Changes
-- Adds stage progression, final exam support, new age bands, and claude model selection
-- Idempotent: safe to re-run

BEGIN;

-- Extend children age constraint from 6-12 to 6-16 (support "12+" age band)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.check_constraints
              WHERE constraint_name = 'children_age_check'
              AND constraint_schema = 'public') THEN
        ALTER TABLE children DROP CONSTRAINT children_age_check;
    END IF;
END
$$;
ALTER TABLE children ADD CONSTRAINT children_age_check CHECK (age BETWEEN 6 AND 16);

-- Update lessons table: add stage progression and model selection columns
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS stage INTEGER NOT NULL DEFAULT 1
    CHECK (stage BETWEEN 1 AND 5);

ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS is_final_exam BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS claude_model TEXT NOT NULL
    DEFAULT 'claude-haiku-4-5-20251001';

-- Drop old age_band constraints e migra valores legados ANTES de adicionar
-- as novas constraints. Sem este UPDATE, qualquer linha pre-existente com
-- age_band='9-12' (do seed antigo 002) viola a nova constraint e a
-- migracao 003 inteira aborta com:
--   ERROR: check constraint lessons_age_band_check violated by some row
-- Mapeamos 9-12 -> 9-10 como aproximacao razoavel; as linhas serao
-- apagadas em seguida pelo 004 (seed novo) entao o mapeamento exato
-- nao importa, so' precisa passar o CHECK.

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.check_constraints
              WHERE constraint_name = 'lessons_age_band_check'
              AND constraint_schema = 'public') THEN
        ALTER TABLE lessons DROP CONSTRAINT lessons_age_band_check;
    END IF;
END
$$;
UPDATE lessons SET age_band = '9-10' WHERE age_band = '9-12';
ALTER TABLE lessons
  ADD CONSTRAINT lessons_age_band_check
  CHECK (age_band IN ('6-8','9-10','11-12','12+'));

-- Same for prompt_templates
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.check_constraints
              WHERE constraint_name = 'prompt_templates_age_band_check'
              AND constraint_schema = 'public') THEN
        ALTER TABLE prompt_templates DROP CONSTRAINT prompt_templates_age_band_check;
    END IF;
END
$$;
UPDATE prompt_templates SET age_band = '9-10' WHERE age_band = '9-12';
ALTER TABLE prompt_templates
  ADD CONSTRAINT prompt_templates_age_band_check
  CHECK (age_band IN ('6-8','9-10','11-12','12+'));

-- Index for stage-based lesson queries (performance optimization)
CREATE INDEX IF NOT EXISTS idx_lessons_stage_active
  ON lessons (stage, is_active, order_index);

-- Ensure only one final exam exists (unique constraint)
CREATE UNIQUE INDEX IF NOT EXISTS uq_lessons_final_exam
  ON lessons (is_final_exam) WHERE is_final_exam = TRUE;

-- Add is_exam flag to chat_sessions for final exam sessions
ALTER TABLE chat_sessions
  ADD COLUMN IF NOT EXISTS is_exam BOOLEAN NOT NULL DEFAULT FALSE;

-- Add is_active flag to chat_sessions (for exam session state management)
ALTER TABLE chat_sessions
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

COMMIT;