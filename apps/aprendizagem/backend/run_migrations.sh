#!/bin/bash
set -e

echo "[migrate] checking database..."

TABLE_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='parents');" | tr -d ' \n')

if [ "$TABLE_EXISTS" = "f" ]; then
    echo "[migrate] running 001_initial_schema.sql..."
    psql "$DATABASE_URL" -f app/db/migrations/001_initial_schema.sql
    echo "[migrate] 001 done"
else
    echo "[migrate] 001 already applied, skipping"
fi

LESSONS_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM lessons;" | tr -d ' \n')

if [ "$LESSONS_COUNT" = "0" ]; then
    echo "[migrate] running 002_seed_data.sql..."
    psql "$DATABASE_URL" -f app/db/migrations/002_seed_data.sql
    echo "[migrate] 002 done"
else
    echo "[migrate] 002 already applied, skipping"
fi

echo "[migrate] done. starting server..."
