-- Move user_preferences table from public to auth schema and drop legacy curriculum schema
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_preferences') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'user_preferences') THEN
            ALTER TABLE public.user_preferences SET SCHEMA auth;
        ELSE
            DROP TABLE public.user_preferences CASCADE;
        END IF;
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS auth.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    app_language VARCHAR(20) NOT NULL DEFAULT 'English',
    cefr_level VARCHAR(5) NOT NULL DEFAULT 'B1',
    primary_goals JSONB NOT NULL DEFAULT '[]'::jsonb,
    daily_goal_minutes INTEGER NOT NULL DEFAULT 10,
    extra_preferences JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_onboarded BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP SCHEMA IF EXISTS curriculum CASCADE;
