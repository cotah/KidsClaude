-- Migration 014: relaxa constraint de idade em children para <= 18.
--
-- Estado anterior: a 003 ja' tinha bumpado o constraint para 6-16
-- (suportar a chegada do age band "12+"), e pydantic estava em le=16.
-- Mas o tier "Engenharia" dos novos system prompts (Atena adaptativa)
-- cobre 13-18 conceitualmente, entao subimos o teto pra 18.
--
-- O DROP busca por definicao (LIKE '%age%<=%') em vez de nome literal
-- pra ser robusto a renames acidentais entre clones do schema. O
-- constraint atual e' 'children_age_check' nas instancias conhecidas.
--
-- Sem perda de dados: faixa nova (6-18) e' superset da atual (6-16).

BEGIN;

DO $$
DECLARE
  cons_name TEXT;
BEGIN
  SELECT conname INTO cons_name
  FROM pg_constraint
  WHERE conrelid = 'children'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%age%<=%'
  LIMIT 1;

  IF cons_name IS NOT NULL THEN
    EXECUTE 'ALTER TABLE children DROP CONSTRAINT ' || quote_ident(cons_name);
  END IF;
END $$;

ALTER TABLE children
  ADD CONSTRAINT children_age_check CHECK (age >= 6 AND age <= 18);

COMMIT;
