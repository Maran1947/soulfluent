"""Migration: Update fluency_track_type_enum to UNFREEZE and SCRATCH only

Revision ID: 0006
Revises: 0005
Create Date: 2026-08-16

"""
from typing import Sequence, Union
from alembic import op

revision: str = "0006"
down_revision: Union[str, None] = "0005"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("""
        DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'fluency_track_type_enum' AND n.nspname = 'fluency') THEN
                ALTER TYPE fluency.fluency_track_type_enum ADD VALUE IF NOT EXISTS 'SCRATCH';
            END IF;
        END $$;
    """)


def downgrade() -> None:
    pass
