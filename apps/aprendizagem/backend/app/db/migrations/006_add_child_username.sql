-- 006_add_child_username.sql
-- Adiciona campo username unico na tabela children para permitir
-- login direto da crianca (sem precisar do device do pai). Uso:
-- POST /v1/auth/child/login-direct { username, pin }.
--
-- Idempotente: usa IF NOT EXISTS pra coluna e indice. Pode rodar varias
-- vezes sem efeito colateral.

ALTER TABLE children ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;
CREATE INDEX IF NOT EXISTS idx_children_username ON children(username);
