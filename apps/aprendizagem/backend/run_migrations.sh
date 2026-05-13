#!/bin/bash
set -e

echo "[migrate] checking database..."

# Gate na ULTIMA tabela criada pela 001 (child_safety_events). Se ela
# existir, sabemos que a 001 rodou ate o fim. Gatear na primeira tabela
# (parents) deixa passar runs parciais como "completas".
TABLE_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='child_safety_events');" | tr -d ' \n')

if [ "$TABLE_EXISTS" = "f" ]; then
    echo "[migrate] running 001_initial_schema.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/001_initial_schema.sql
    echo "[migrate] 001 done"
else
    echo "[migrate] 001 already applied, skipping"
fi

# Suprime stderr para o teste — se a tabela lessons nao existir, psql
# escreve erro em stderr e stdout fica vazio. Tratamos string vazia como
# "precisa rodar 002" (caso normal: rodada anterior nao chegou na 001 ou
# a tabela foi dropada). Sem este check, "" != "0" caia no else por engano
# e pulava 002 mesmo numa DB sem schema seed.
LESSONS_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM lessons;" 2>/dev/null | tr -d ' \n')

if [ -z "$LESSONS_COUNT" ] || [ "$LESSONS_COUNT" = "0" ]; then
    # Reset preventivo de qualquer transacao aberta. Cada psql -c abre uma
    # conexao nova, mas com poolers em transaction-mode pode haver estado
    # residual; este ROLLBACK e' inofensivo (no-op se nada estiver pendente).
    echo "[migrate] clearing any aborted transaction state before 002..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 002_seed_data.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/002_seed_data.sql
    echo "[migrate] 002 done"
else
    echo "[migrate] 002 already applied (lessons=$LESSONS_COUNT), skipping"
fi

# Gate 003: check if stage column exists on lessons table
STAGE_COLUMN_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='lessons' AND column_name='stage');" | tr -d ' \n')

if [ "$STAGE_COLUMN_EXISTS" = "f" ]; then
    echo "[migrate] running 003_curriculum_redesign.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/003_curriculum_redesign.sql
    echo "[migrate] 003 done"
else
    echo "[migrate] 003 already applied, skipping"
fi

# Gate 004: check if any lesson has is_final_exam=true (indicates new curriculum)
HAS_FINAL_EXAM=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM lessons WHERE is_final_exam = true);" 2>/dev/null | tr -d ' \n')

if [ -z "$HAS_FINAL_EXAM" ] || [ "$HAS_FINAL_EXAM" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 004..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 004_curriculum_seed.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/004_curriculum_seed.sql
    echo "[migrate] 004 done"
else
    echo "[migrate] 004 already applied (final exam exists), skipping"
fi

echo "[migrate] done. starting server..."
