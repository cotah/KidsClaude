#!/usr/bin/env bash
# Bootstrap de migrations - roda os SQLs em ordem, com gate de idempotencia.
#
# Quando rodar:
#   Chamado no startCommand do Railway antes do uvicorn. Em ambiente local,
#   tambem da pra rodar manual: DATABASE_URL=... ./run_migrations.sh
#
# Idempotencia:
#   - 001 (schema): so roda se a tabela `parents` ainda nao existir. A 001
#     tem CREATE TABLE sem IF NOT EXISTS, entao a segunda passada estouraria.
#   - 002 (seed): so roda se a tabela `lessons` estiver vazia. Usar lessons
#     como gate evita falha quando a tabela challenges nao existe ainda (por
#     exemplo, schema parcial de um deploy anterior). lessons tambem e'
#     criada na 001 e populada na 002, entao funciona como sentinela.

set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "[migrate] ERRO: DATABASE_URL nao esta definida." >&2
  exit 1
fi

# Diretorio onde os SQLs ficam dentro do container (copiado via Dockerfile).
MIGRATIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/app/db/migrations"

# --- 001_initial_schema.sql ---------------------------------------------
PARENTS_EXISTS=$(psql "$DATABASE_URL" -tAc \
  "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='parents');")

if [[ "$PARENTS_EXISTS" == "f" ]]; then
  echo "[migrate] aplicando 001_initial_schema.sql"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$MIGRATIONS_DIR/001_initial_schema.sql"
else
  echo "[migrate] schema ja existe, pulando 001"
fi

# --- 002_seed_data.sql --------------------------------------------------
LESSONS_COUNT=$(psql "$DATABASE_URL" -tAc "SELECT COUNT(*) FROM lessons;")

if [[ "$LESSONS_COUNT" == "0" ]]; then
  echo "[migrate] aplicando 002_seed_data.sql"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$MIGRATIONS_DIR/002_seed_data.sql"
else
  echo "[migrate] seed ja aplicada (${LESSONS_COUNT} licoes), pulando 002"
fi

echo "[migrate] OK"
