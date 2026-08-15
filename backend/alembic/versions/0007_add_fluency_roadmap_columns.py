"""Migration: Add roadmap metadata columns to fluency tables

Revision ID: 0007
Revises: 0006
Create Date: 2026-08-16

"""
from typing import Sequence, Union
from alembic import op

revision: str = "0007"
down_revision: Union[str, None] = "0006"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. fluency.tracks
    op.execute("ALTER TABLE fluency.tracks ADD COLUMN IF NOT EXISTS slug VARCHAR(100) DEFAULT 'track';")
    op.execute("ALTER TABLE fluency.tracks ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';")
    op.execute("ALTER TABLE fluency.tracks ADD COLUMN IF NOT EXISTS cefr_min VARCHAR(10) DEFAULT 'A1';")
    op.execute("ALTER TABLE fluency.tracks ADD COLUMN IF NOT EXISTS cefr_max VARCHAR(10) DEFAULT 'C2';")
    op.execute("ALTER TABLE fluency.tracks ADD COLUMN IF NOT EXISTS sequence INT DEFAULT 1;")

    # 2. fluency.stages
    op.execute("ALTER TABLE fluency.stages ADD COLUMN IF NOT EXISTS slug VARCHAR(100) DEFAULT 'stage';")
    op.execute("ALTER TABLE fluency.stages ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';")
    op.execute("ALTER TABLE fluency.stages ADD COLUMN IF NOT EXISTS cefr_min VARCHAR(10) DEFAULT 'A1';")
    op.execute("ALTER TABLE fluency.stages ADD COLUMN IF NOT EXISTS cefr_max VARCHAR(10) DEFAULT 'C2';")
    op.execute("ALTER TABLE fluency.stages ADD COLUMN IF NOT EXISTS primary_goals JSONB DEFAULT '[]'::jsonb;")

    # 3. fluency.stage_nodes
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS name VARCHAR(150) DEFAULT '';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS slug VARCHAR(150) DEFAULT 'node';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS cefr_min VARCHAR(10) DEFAULT 'A1';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS cefr_max VARCHAR(10) DEFAULT 'C2';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS learning_goal TEXT DEFAULT '';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS primary_skill VARCHAR(100) DEFAULT '';")
    op.execute("ALTER TABLE fluency.stage_nodes ADD COLUMN IF NOT EXISTS estimated_minutes INT DEFAULT 10;")

    # 4. fluency.node_activities
    op.execute("ALTER TABLE fluency.node_activities ADD COLUMN IF NOT EXISTS sequence INT DEFAULT 1;")
    op.execute("ALTER TABLE fluency.node_activities ADD COLUMN IF NOT EXISTS title VARCHAR(150) DEFAULT '';")
    op.execute("ALTER TABLE fluency.node_activities ADD COLUMN IF NOT EXISTS is_required BOOLEAN DEFAULT TRUE;")

    # 5. fluency.user_activity_progress
    op.execute("ALTER TABLE fluency.user_activity_progress ADD COLUMN IF NOT EXISTS attempt_count INT DEFAULT 1;")
    op.execute("ALTER TABLE fluency.user_activity_progress ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ;")
    op.execute("ALTER TABLE fluency.user_activity_progress ADD COLUMN IF NOT EXISTS last_attempted_at TIMESTAMPTZ;")


def downgrade() -> None:
    pass
