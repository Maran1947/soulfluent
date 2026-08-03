-- ==========================================
-- Migration: migrations / 1_create_schemas.sql
-- Create Core Domain Schemas (auth, conversation, analytics)
-- ==========================================

-- 1. Create Schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS conversation;
CREATE SCHEMA IF NOT EXISTS analytics;

-- 2. Create Enums in respective domain schemas
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'session_mode_enum' AND n.nspname = 'conversation') THEN
        CREATE TYPE conversation.session_mode_enum AS ENUM ('gd', 'debate', 'conversation', 'interview');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'difficulty_enum' AND n.nspname = 'conversation') THEN
        CREATE TYPE conversation.difficulty_enum AS ENUM ('beginner', 'intermediate', 'advanced');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'session_status_enum' AND n.nspname = 'conversation') THEN
        CREATE TYPE conversation.session_status_enum AS ENUM ('active', 'completed', 'abandoned');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'call_type_enum' AND n.nspname = 'analytics') THEN
        CREATE TYPE analytics.call_type_enum AS ENUM ('stt', 'turn', 'tts', 'analysis');
    END IF;
END $$;

-- 3. Create Tables
CREATE TABLE IF NOT EXISTS auth.users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS conversation.sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    mode conversation.session_mode_enum NOT NULL DEFAULT 'gd',
    topic VARCHAR(500) NOT NULL,
    category VARCHAR(100) NOT NULL DEFAULT 'general',
    difficulty conversation.difficulty_enum NOT NULL DEFAULT 'intermediate',
    duration_minutes INTEGER DEFAULT 10,
    personas JSONB DEFAULT '[]'::jsonb,
    config JSONB DEFAULT '{}'::jsonb,
    status conversation.session_status_enum NOT NULL DEFAULT 'active',
    turn_index INTEGER DEFAULT 0,
    last_speaker VARCHAR(50) DEFAULT '',
    silent_turns JSONB DEFAULT '{}'::jsonb,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS conversation.messages (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES conversation.sessions(id) ON DELETE CASCADE,
    turn_index INTEGER NOT NULL,
    speaker VARCHAR(50) NOT NULL,
    speaker_role VARCHAR(50) NOT NULL DEFAULT 'peer',
    text TEXT NOT NULL,
    audio_duration_seconds DOUBLE PRECISION DEFAULT 0.0,
    audio_key VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS analytics.feedback_reports (
    id UUID PRIMARY KEY,
    session_id UUID UNIQUE NOT NULL REFERENCES conversation.sessions(id) ON DELETE CASCADE,
    overall_score DOUBLE PRECISION DEFAULT 0.0,
    fluency_metrics JSONB DEFAULT '{}'::jsonb,
    vocabulary_metrics JSONB DEFAULT '{}'::jsonb,
    argument_metrics JSONB DEFAULT '{}'::jsonb,
    sub_scores JSONB DEFAULT '{}'::jsonb,
    highlight_reel JSONB DEFAULT '{}'::jsonb,
    recommendation TEXT DEFAULT '',
    total_tokens INTEGER DEFAULT 0,
    total_cost_usd DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS analytics.llm_usage_logs (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES conversation.sessions(id) ON DELETE CASCADE,
    call_type analytics.call_type_enum NOT NULL,
    model VARCHAR(100) NOT NULL,
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    cost_usd DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
