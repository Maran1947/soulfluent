"""Migration: Rename schema fluency_tracks to fluency and table fluency_tracks to tracks

Revision ID: 0005
Revises: 0004
Create Date: 2026-08-16

"""
from typing import Sequence, Union
from alembic import op

revision: str = "0005"
down_revision: Union[str, None] = "0004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("""
        DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'fluency_tracks') AND NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'fluency') THEN
                ALTER SCHEMA fluency_tracks RENAME TO fluency;
            ELSIF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'fluency_tracks') AND EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'fluency') THEN
                IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'fluency_tracks' AND table_name = 'fluency_tracks') AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'fluency' AND table_name = 'tracks') THEN
                    ALTER TABLE fluency_tracks.fluency_tracks SET SCHEMA fluency;
                END IF;
                DROP SCHEMA IF EXISTS fluency_tracks CASCADE;
            ELSE
                CREATE SCHEMA IF NOT EXISTS fluency;
            END IF;
        END $$;
    """)

    op.execute("""
        DO $$ BEGIN
            IF EXISTS (
                SELECT 1 FROM information_schema.tables 
                WHERE table_schema = 'fluency' AND table_name = 'fluency_tracks'
            ) AND NOT EXISTS (
                SELECT 1 FROM information_schema.tables 
                WHERE table_schema = 'fluency' AND table_name = 'tracks'
            ) THEN
                ALTER TABLE fluency.fluency_tracks RENAME TO tracks;
            END IF;
        END $$;
    """)


def downgrade() -> None:
    op.execute("""
        DO $$ BEGIN
            IF EXISTS (
                SELECT 1 FROM information_schema.tables 
                WHERE table_schema = 'fluency' AND table_name = 'tracks'
            ) THEN
                ALTER TABLE fluency.tracks RENAME TO fluency_tracks;
            END IF;
        END $$;
    """)
    op.execute("""
        DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'fluency') THEN
                ALTER SCHEMA fluency RENAME TO fluency_tracks;
            END IF;
        END $$;
    """)
