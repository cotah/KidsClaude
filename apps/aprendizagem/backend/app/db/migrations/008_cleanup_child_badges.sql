-- 008_cleanup_child_badges.sql
-- Limpa child_badges concedidas automaticamente durante o periodo em que
-- POST /lessons/{id}/complete falhava com 500 (update_streak quebrava com
-- AttributeError em timezone.timedelta). Nesse periodo, award_xp +
-- _check_and_award_badges JA' tinham rodado e inserido badges no DB,
-- mas o endpoint retornava 500 e a crianca nunca via a celebracao.
-- Resultado: navbar mostrava 2 badges sem que a crianca soubesse de onde.
--
-- Idempotencia: usamos uma coluna marker children.badges_cleaned_at.
-- Run 1: coluna nao existe -> migration cria, deleta tudo, marca todos.
-- Run 2: coluna existe (gate no run_migrations.sh skip) -> sem efeito.
-- Crianca nova criada apos: badges_cleaned_at=NULL por default; nao roda
-- nada porque o gate no shell ja' passou. Os badges legitimos dela
-- ficam intactos.

BEGIN;

ALTER TABLE children
  ADD COLUMN IF NOT EXISTS badges_cleaned_at TIMESTAMPTZ;

-- Wipe geral. Apos isso, badges so' aparecem via /complete funcional.
DELETE FROM child_badges;

-- Marca todas as criancas existentes como ja' limpas (idempotencia).
UPDATE children
SET badges_cleaned_at = NOW()
WHERE badges_cleaned_at IS NULL;

COMMIT;
