-- ==========================================
-- Migration: migrations / V2_fluency_tracks_schemas / 1_create_fluency_tracks_tables.sql
-- Create Fluency Domain Schemas & Tables for Tracks, Stages, Stage Nodes, Node Activities, User Activity Progress
-- ==========================================

-- 1. Create Schema
CREATE SCHEMA IF NOT EXISTS fluency;

-- 2. Create Enums
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'fluency_track_type_enum' AND n.nspname = 'fluency') THEN
        CREATE TYPE fluency.fluency_track_type_enum AS ENUM ('UNFREEZE', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'activity_type_enum' AND n.nspname = 'fluency') THEN
        CREATE TYPE fluency.activity_type_enum AS ENUM (
            'lesson', 'express_image', 'express_video', 'forming_sentence',
            'echo_repeat', 'word_picture_match', 'tpr_command', 'listen_select',
            'fill_blank', 'sentence_correction', 'dictation', 'shadow_speaking',
            'roleplay', 'free_response', 'debate', 'rescue_phrase_drill',
            'interruption', 'listen_and_order', 'quiz'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'activity_status_enum' AND n.nspname = 'fluency') THEN
        CREATE TYPE fluency.activity_status_enum AS ENUM ('not_started', 'in_progress', 'completed');
    END IF;
END $$;

-- 3. Create Tables

CREATE TABLE IF NOT EXISTS fluency.tracks (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type fluency.fluency_track_type_enum NOT NULL DEFAULT 'UNFREEZE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fluency.stages (
    id UUID PRIMARY KEY,
    fluency_track_id UUID NOT NULL REFERENCES fluency.tracks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sequence INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fluency.stage_nodes (
    id UUID PRIMARY KEY,
    stage_id UUID NOT NULL REFERENCES fluency.stages(id) ON DELETE CASCADE,
    sequence INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fluency.node_activities (
    id UUID PRIMARY KEY,
    stage_node_id UUID NOT NULL REFERENCES fluency.stage_nodes(id) ON DELETE CASCADE,
    activity_type fluency.activity_type_enum NOT NULL,
    config JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fluency.user_activity_progress (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    node_activity_id UUID NOT NULL REFERENCES fluency.node_activities(id) ON DELETE CASCADE,
    status fluency.activity_status_enum NOT NULL DEFAULT 'not_started',
    score DOUBLE PRECISION DEFAULT 0.0,
    response_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_user_node_activity UNIQUE (user_id, node_activity_id)
);

CREATE INDEX IF NOT EXISTS idx_stages_track ON fluency.stages(fluency_track_id);
CREATE INDEX IF NOT EXISTS idx_stage_nodes_stage ON fluency.stage_nodes(stage_id);
CREATE INDEX IF NOT EXISTS idx_node_activities_node ON fluency.node_activities(stage_node_id);
CREATE INDEX IF NOT EXISTS idx_user_act_prog_user ON fluency.user_activity_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_act_prog_activity ON fluency.user_activity_progress(node_activity_id);
