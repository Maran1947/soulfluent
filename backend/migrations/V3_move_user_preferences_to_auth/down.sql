-- Down migration for moving user_preferences back to public schema
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'user_preferences') THEN
        ALTER TABLE auth.user_preferences SET SCHEMA public;
    END IF;
END $$;
