-- ==========================================
-- Migration: migrations / down.sql
-- Rollback core domain schemas and tables
-- ==========================================

DROP TABLE IF EXISTS analytics.llm_usage_logs CASCADE;
DROP TABLE IF EXISTS analytics.feedback_reports CASCADE;
DROP TABLE IF EXISTS conversation.messages CASCADE;
DROP TABLE IF EXISTS conversation.sessions CASCADE;
DROP TABLE IF EXISTS auth.users CASCADE;

DROP TYPE IF EXISTS analytics.call_type_enum CASCADE;
DROP TYPE IF EXISTS conversation.session_status_enum CASCADE;
DROP TYPE IF EXISTS conversation.difficulty_enum CASCADE;
DROP TYPE IF EXISTS conversation.session_mode_enum CASCADE;

DROP SCHEMA IF EXISTS analytics CASCADE;
DROP SCHEMA IF EXISTS conversation CASCADE;
DROP SCHEMA IF EXISTS auth CASCADE;
