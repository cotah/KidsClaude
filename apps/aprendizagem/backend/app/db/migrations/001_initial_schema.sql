-- Migração inicial: cria todas as tabelas do sistema aprendizagem
-- Baseada na spec seção 6, com RLS habilitado

-- Extension para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela parents (sincronizada com auth.users do Supabase)
CREATE TABLE parents (
    id UUID PRIMARY KEY, -- será igual a auth.users.id
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para parents: só pode acessar próprios dados
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "parents_self_access" ON parents FOR ALL USING (id = auth.uid());

-- Trigger para updated_at automático
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_parents_updated_at
    BEFORE UPDATE ON parents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Tabela children
CREATE TABLE children (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    name TEXT NOT NULL CHECK (LENGTH(name) >= 1 AND LENGTH(name) <= 30),
    age INTEGER NOT NULL CHECK (age >= 6 AND age <= 12),
    avatar_id TEXT NOT NULL,
    pin_hash TEXT, -- bcrypt hash do PIN de 4 dígitos, nullable
    daily_limit_minutes INTEGER NOT NULL DEFAULT 30 CHECK (daily_limit_minutes >= 5 AND daily_limit_minutes <= 180),
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 0,
    last_active_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_children_parent ON children(parent_id);

-- RLS para children: parent vê apenas próprios filhos
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
CREATE POLICY "children_parent_access" ON children FOR ALL USING (parent_id = auth.uid());

CREATE TRIGGER trigger_children_updated_at
    BEFORE UPDATE ON children
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Tabela lessons
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    age_band TEXT NOT NULL CHECK (age_band IN ('6-8', '9-12')),
    order_index INTEGER NOT NULL,
    content_blocks JSONB NOT NULL, -- array de blocos: text/image/video/animation
    prerequisites UUID[] DEFAULT '{}', -- array de lesson IDs
    xp_reward INTEGER NOT NULL DEFAULT 50,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lessons_age_active ON lessons(age_band, is_active, order_index);

-- RLS para lessons: leitura pública (autenticado), escrita só service role
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lessons_read_authenticated" ON lessons FOR SELECT USING (auth.role() = 'authenticated');

CREATE TRIGGER trigger_lessons_updated_at
    BEFORE UPDATE ON lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Tabela lesson_progress
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id),
    status TEXT NOT NULL CHECK (status IN ('not_started', 'in_progress', 'completed')),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    xp_earned INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, lesson_id)
);

CREATE INDEX idx_progress_child ON lesson_progress(child_id);

-- RLS para lesson_progress: parent vê progresso dos próprios filhos
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "progress_parent_access" ON lesson_progress FOR ALL
USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
);

CREATE TRIGGER trigger_lesson_progress_updated_at
    BEFORE UPDATE ON lesson_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Tabela challenges
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    kind TEXT NOT NULL CHECK (kind IN ('multiple_choice', 'fill_prompt')),
    question JSONB NOT NULL, -- estrutura dependente do kind
    correct_answer JSONB NOT NULL,
    xp_reward INTEGER DEFAULT 20
);

-- RLS para challenges: leitura pública
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "challenges_read_authenticated" ON challenges FOR SELECT USING (auth.role() = 'authenticated');

-- Tabela challenge_attempts
CREATE TABLE challenge_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenges(id),
    answer JSONB NOT NULL,
    is_correct BOOLEAN NOT NULL,
    xp_earned INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_attempts_child_chal ON challenge_attempts(child_id, challenge_id);

-- RLS para challenge_attempts
ALTER TABLE challenge_attempts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "attempts_parent_access" ON challenge_attempts FOR ALL
USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
);

-- Tabela prompt_templates
CREATE TABLE prompt_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID NOT NULL REFERENCES lessons(id),
    label TEXT NOT NULL, -- texto do botão
    template TEXT NOT NULL, -- com placeholders {{slot_name}}
    slots JSONB, -- array de {name, max_length, allowed_chars}
    age_band TEXT NOT NULL CHECK (age_band IN ('6-8', '9-12')),
    order_index INTEGER DEFAULT 0
);

-- RLS para prompt_templates: leitura pública
ALTER TABLE prompt_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "prompt_templates_read_authenticated" ON prompt_templates FOR SELECT USING (auth.role() = 'authenticated');

-- Tabela chat_sessions
CREATE TABLE chat_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    safety_status TEXT DEFAULT 'green' CHECK (safety_status IN ('green', 'yellow', 'red')),
    summary TEXT, -- gerado por Claude
    message_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sessions_child ON chat_sessions(child_id, started_at DESC);

-- RLS para chat_sessions
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sessions_parent_access" ON chat_sessions FOR ALL
USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
);

-- Tabela chat_messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('child', 'assistant', 'system')),
    template_id UUID REFERENCES prompt_templates(id), -- nullable
    content TEXT NOT NULL,
    moderation_status TEXT DEFAULT 'passed' CHECK (moderation_status IN ('passed', 'blocked')),
    moderation_reason TEXT,
    token_count INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_session ON chat_messages(session_id, created_at);

-- RLS para chat_messages
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "messages_parent_access" ON chat_messages FOR ALL
USING (
    session_id IN (
        SELECT id FROM chat_sessions
        WHERE child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
    )
);

-- Tabela badges
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL, -- id do catálogo de ícones
    unlock_rule JSONB NOT NULL
);

-- RLS para badges: leitura pública
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "badges_read_authenticated" ON badges FOR SELECT USING (auth.role() = 'authenticated');

-- Tabela child_badges
CREATE TABLE child_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id),
    awarded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, badge_id)
);

-- RLS para child_badges
ALTER TABLE child_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "child_badges_parent_access" ON child_badges FOR ALL
USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
);

-- Tabela daily_usage
CREATE TABLE daily_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    usage_date DATE NOT NULL,
    minutes_used INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, usage_date)
);

CREATE INDEX idx_usage_child_date ON daily_usage(child_id, usage_date DESC);

-- RLS para daily_usage
ALTER TABLE daily_usage ENABLE ROW LEVEL SECURITY;
CREATE POLICY "daily_usage_parent_access" ON daily_usage FOR ALL
USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
);

CREATE TRIGGER trigger_daily_usage_updated_at
    BEFORE UPDATE ON daily_usage
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Tabela child_safety_events
CREATE TABLE child_safety_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    session_id UUID REFERENCES chat_sessions(id), -- nullable
    kind TEXT NOT NULL CHECK (kind IN ('input_blocked', 'output_blocked', 'session_terminated')),
    details JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_safety_child_date ON child_safety_events(child_id, created_at DESC);

-- RLS para child_safety_events
ALTER TABLE child_safety_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "safety_events_parent_access" ON child_safety_events FOR ALL
USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
);

COMMIT;