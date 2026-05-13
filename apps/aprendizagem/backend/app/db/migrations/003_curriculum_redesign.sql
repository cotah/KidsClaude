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

-- Drop old age_band constraints and add new 4-stage constraints
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.check_constraints
              WHERE constraint_name = 'lessons_age_band_check'
              AND constraint_schema = 'public') THEN
        ALTER TABLE lessons DROP CONSTRAINT lessons_age_band_check;
    END IF;
END
$$;
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