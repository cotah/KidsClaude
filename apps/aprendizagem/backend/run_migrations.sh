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

# Gate 005: novo curriculo (16 licoes nas stages 1-4). Detectamos via slug
# canonico 's1-o-que-e-ia' que so' aparece nesse seed; se ele existe, 005
# ja foi aplicado e podemos pular.
HAS_NEW_CURRICULUM=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM lessons WHERE slug = 's1-o-que-e-ia');" 2>/dev/null | tr -d ' \n')

if [ -z "$HAS_NEW_CURRICULUM" ] || [ "$HAS_NEW_CURRICULUM" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 005..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 005_new_curriculum.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/005_new_curriculum.sql
    echo "[migrate] 005 done"
else
    echo "[migrate] 005 already applied (new curriculum slug present), skipping"
fi

# Gate 006: coluna username na tabela children (login direto da crianca).
# Detectamos via information_schema.columns. Se username existe, ja' rodou.
USERNAME_COL_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='children' AND column_name='username');" 2>/dev/null | tr -d ' \n')

if [ -z "$USERNAME_COL_EXISTS" ] || [ "$USERNAME_COL_EXISTS" = "f" ]; then
    echo "[migrate] running 006_add_child_username.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/006_add_child_username.sql
    echo "[migrate] 006 done"
else
    echo "[migrate] 006 already applied (username column present), skipping"
fi

# Gate 007: 2 templates extras por licao (16 -> 48 templates totais).
# Detectamos via label canonica que so' aparece no seed da 007.
HAS_EXTRA_TEMPLATES=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM prompt_templates WHERE label = 'Curiosidade legal sobre IA');" 2>/dev/null | tr -d ' \n')

if [ -z "$HAS_EXTRA_TEMPLATES" ] || [ "$HAS_EXTRA_TEMPLATES" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 007..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 007_more_prompt_templates.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/007_more_prompt_templates.sql
    echo "[migrate] 007 done"
else
    echo "[migrate] 007 already applied (extra templates present), skipping"
fi

# Gate 008: limpa child_badges legados (do periodo do bug update_streak).
# Sentinel: coluna children.badges_cleaned_at. Se nao existe, 008 nunca
# rodou. Apos rodar, a coluna existe e nao tocamos mais.
BADGES_CLEANED_COL_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='children' AND column_name='badges_cleaned_at');" 2>/dev/null | tr -d ' \n')

if [ -z "$BADGES_CLEANED_COL_EXISTS" ] || [ "$BADGES_CLEANED_COL_EXISTS" = "f" ]; then
    echo "[migrate] running 008_cleanup_child_badges.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/008_cleanup_child_badges.sql
    echo "[migrate] 008 done"
else
    echo "[migrate] 008 already applied (badges_cleaned_at column present), skipping"
fi

# Gate 009: content_blocks adaptados por idade nas 16 licoes regulares.
# Sentinel: frase exclusiva da nova versao da s1-o-que-e-ia ("brinquedo
# que parecia pensar sozinho"). Se ela existe no JSONB de qualquer linha
# de lessons, 009 ja' rodou.
HAS_ADAPTED_CONTENT=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM lessons WHERE slug = 's1-o-que-e-ia' AND content_blocks::text LIKE '%brinquedo que parecia pensar sozinho%');" 2>/dev/null | tr -d ' \n')

if [ -z "$HAS_ADAPTED_CONTENT" ] || [ "$HAS_ADAPTED_CONTENT" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 009..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 009_adapted_content.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/009_adapted_content.sql
    echo "[migrate] 009 done"
else
    echo "[migrate] 009 already applied (adapted content present), skipping"
fi

# Gate 010: versao em ingles dos titulos, content_blocks e challenges.
# Sentinel: existencia da coluna lessons.title_en. Migration adiciona
# 4 colunas (lessons.title_en, lessons.content_blocks_en, challenges.
# question_en, challenges.options_en) e popula 16 licoes + 32 challenges
# em uma transacao (ROLLBACK total se algo falhar - re-execucao limpa).
TITLE_EN_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='lessons' AND column_name='title_en');" 2>/dev/null | tr -d ' \n')

if [ -z "$TITLE_EN_EXISTS" ] || [ "$TITLE_EN_EXISTS" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 010..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 010_english_content.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/010_english_content.sql
    echo "[migrate] 010 done"
else
    echo "[migrate] 010 already applied (title_en column present), skipping"
fi

# Gate 011: traducao EN dos badges. Sentinel: existencia de badges.name_en.
BADGE_NAME_EN_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='badges' AND column_name='name_en');" 2>/dev/null | tr -d ' \n')

if [ -z "$BADGE_NAME_EN_EXISTS" ] || [ "$BADGE_NAME_EN_EXISTS" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 011..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 011_badges_english.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/011_badges_english.sql
    echo "[migrate] 011 done"
else
    echo "[migrate] 011 already applied (badges.name_en column present), skipping"
fi

# Gate 012: lessons.description_en (subtitulo curto da lista de licoes
# da stage). Migration 010 ja' tinha title_en + content_blocks_en;
# 012 fecha a lacuna do subtitulo. Sentinel: existencia da coluna.
DESC_EN_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='lessons' AND column_name='description_en');" 2>/dev/null | tr -d ' \n')

if [ -z "$DESC_EN_EXISTS" ] || [ "$DESC_EN_EXISTS" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 012..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 012_lesson_descriptions_en.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/012_lesson_descriptions_en.sql
    echo "[migrate] 012 done"
else
    echo "[migrate] 012 already applied (lessons.description_en present), skipping"
fi

# Gate 013: re-aplica UPDATEs de title_en/description_en porque em
# producao a coluna existe mas todos os valores estao NULL (010/012
# rodaram ALTER mas as UPDATEs nao bateram - causa nao identificada).
# Sentinel: title_en IS NULL na slug canonica. Quando NULL -> roda;
# apos sucesso, NULL vira string -> gate fica false.
TITLE_EN_NULL=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM lessons WHERE slug = 's1-o-que-e-ia' AND title_en IS NULL);" 2>/dev/null | tr -d ' \n')

if [ "$TITLE_EN_NULL" = "t" ]; then
    echo "[migrate] clearing any aborted transaction state before 013..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 013_force_lesson_translations.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/013_force_lesson_translations.sql
    echo "[migrate] 013 done"
else
    echo "[migrate] 013 already applied (title_en populated), skipping"
fi

# Gate 014: relaxa idade max de 12 para 18. Sentinel: procura check
# constraint na tabela children que mencione "18" em sua definicao.
# Se ja existir -> 014 aplicada; senao -> rodar.
AGE_18_APPLIED=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'children'::regclass AND contype = 'c' AND pg_get_constraintdef(oid) LIKE '%age%18%');" 2>/dev/null | tr -d ' \n')

if [ "$AGE_18_APPLIED" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 014..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 014_age_limit_to_18.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/014_age_limit_to_18.sql
    echo "[migrate] 014 done"
else
    echo "[migrate] 014 already applied (age constraint allows 18), skipping"
fi

# Gate 015: novo Stage 2 "Thinking" + renumera demais (final exam vai pra 6).
# Sentinel ANTIGO checava lessons_stage_check LIKE '%<= 6%', mas 017 mexeu
# nessa constraint pra <= 7 - o gate parou de bater e 015 tentava rodar
# de novo. Sentinel NOVO: existencia do slug 's2-ia-pode-errar', que 015
# cria e nada mais altera. Se existe, 015 ja rodou - skip.
THINKING_STAGE_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM lessons WHERE slug = 's2-ia-pode-errar');" 2>/dev/null | tr -d ' \n')

if [ "$THINKING_STAGE_EXISTS" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 015..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 015_thinking_stage.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/015_thinking_stage.sql
    echo "[migrate] 015 done"
else
    echo "[migrate] 015 already applied (thinking stage present), skipping"
fi

# Gate 016: backfill EN content_blocks + adicionar prompt_templates pras
# 6 licoes de Stage 2. Sentinel: existe prompt_template pra
# 's2-ia-pode-errar' (1a licao). Se nao, roda. Se ja' existe, skip.
TEMPLATES_016_APPLIED=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM prompt_templates pt JOIN lessons l ON pt.lesson_id = l.id WHERE l.slug = 's2-ia-pode-errar');" 2>/dev/null | tr -d ' \n')

if [ "$TEMPLATES_016_APPLIED" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 016..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 016_thinking_en_and_templates.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/016_thinking_en_and_templates.sql
    echo "[migrate] 016 done"
else
    echo "[migrate] 016 already applied (templates for s2-ia-pode-errar present), skipping"
fi

# Gate 017: nova Stage 6 "Mastery" + final exam movido pra stage 7.
# Sentinel: lessons_stage_check ja aceita stage <= 7.
STAGE_7_ALLOWED=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='lessons'::regclass AND conname='lessons_stage_check' AND pg_get_constraintdef(oid) LIKE '%<= 7%');" 2>/dev/null | tr -d ' \n')

if [ "$STAGE_7_ALLOWED" = "f" ]; then
    echo "[migrate] clearing any aborted transaction state before 017..."
    psql "$DATABASE_URL" -c 'ROLLBACK' 2>/dev/null || true

    echo "[migrate] running 017_mastery_stage.sql..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f app/db/migrations/017_mastery_stage.sql
    echo "[migrate] 017 done"
else
    echo "[migrate] 017 already applied (stage<=7 constraint present), skipping"
fi

echo "[migrate] done. starting server..."
