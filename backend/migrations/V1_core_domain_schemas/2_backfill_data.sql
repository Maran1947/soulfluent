-- ==========================================
-- Migration: migrations / 2_backfill_data.sql
-- Safely Backfill Data from Legacy Public Tables to Domain Schemas
-- Then cleanup / drop old legacy public tables
-- ==========================================

DO $$
BEGIN
    -- 1. Backfill users (public.users -> auth.users)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
        INSERT INTO auth.users (id, email, hashed_password, name, created_at)
        SELECT id, email, hashed_password, name, created_at
        FROM public.users
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- 2. Backfill sessions (public.gd_sessions -> conversation.sessions)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'gd_sessions') THEN
        INSERT INTO conversation.sessions (
            id, user_id, mode, topic, category, difficulty, duration_minutes,
            personas, config, status, turn_index, last_speaker, silent_turns, started_at, ended_at
        )
        SELECT 
            id, user_id, 'gd'::conversation.session_mode_enum, topic, category,
            difficulty::text::conversation.difficulty_enum, duration_minutes,
            personas, '{}'::jsonb, status::text::conversation.session_status_enum,
            turn_index, last_speaker, silent_turns, started_at, ended_at
        FROM public.gd_sessions
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- 3. Backfill messages (public.gd_messages -> conversation.messages)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'gd_messages') THEN
        INSERT INTO conversation.messages (
            id, session_id, turn_index, speaker, speaker_role, text, audio_duration_seconds, audio_key, created_at
        )
        SELECT 
            id, session_id, turn_index, speaker, 'peer', text, audio_duration_seconds, audio_key, created_at
        FROM public.gd_messages
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- 4. Backfill feedback_reports (public.feedback_reports -> analytics.feedback_reports)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'feedback_reports') THEN
        INSERT INTO analytics.feedback_reports (
            id, session_id, overall_score, fluency_metrics, vocabulary_metrics, argument_metrics,
            sub_scores, highlight_reel, recommendation, total_tokens, total_cost_usd, created_at
        )
        SELECT 
            id, session_id, overall_score, fluency_metrics, vocabulary_metrics, argument_metrics,
            sub_scores, highlight_reel, recommendation, total_tokens, total_cost_usd, created_at
        FROM public.feedback_reports
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- 5. Backfill llm_usage_logs (public.llm_usage_logs -> analytics.llm_usage_logs)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'llm_usage_logs') THEN
        INSERT INTO analytics.llm_usage_logs (
            id, session_id, call_type, model, input_tokens, output_tokens, total_tokens, cost_usd, created_at
        )
        SELECT 
            id, session_id, call_type::text::analytics.call_type_enum, model, input_tokens, output_tokens, total_tokens, cost_usd, created_at
        FROM public.llm_usage_logs
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- Drop legacy public schema tables and types after backfilling
DROP TABLE IF EXISTS public.gd_messages CASCADE;
DROP TABLE IF EXISTS public.feedback_reports CASCADE;
DROP TABLE IF EXISTS public.llm_usage_logs CASCADE;
DROP TABLE IF EXISTS public.gd_sessions CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

DROP TYPE IF EXISTS public.difficulty_enum CASCADE;
DROP TYPE IF EXISTS public.session_status_enum CASCADE;
DROP TYPE IF EXISTS public.call_type_enum CASCADE;
