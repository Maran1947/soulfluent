"""initial schema

Revision ID: 0001
Revises:
Create Date: 2026-07-18

"""
from typing import Sequence, Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("hashed_password", sa.String(length=255), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    difficulty_enum = postgresql.ENUM(
        "beginner", "intermediate", "advanced", name="difficulty_enum", create_type=False
    )
    session_status_enum = postgresql.ENUM(
        "active", "completed", "abandoned", name="session_status_enum", create_type=False
    )
    difficulty_enum.create(op.get_bind(), checkfirst=True)
    session_status_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "gd_sessions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("topic", sa.String(length=500), nullable=False),
        sa.Column("category", sa.String(length=100), nullable=False, server_default="general"),
        sa.Column(
            "difficulty",
            difficulty_enum,
            nullable=False,
            server_default="intermediate",
        ),
        sa.Column("duration_minutes", sa.Integer(), nullable=False, server_default="10"),
        sa.Column("personas", postgresql.JSONB(), nullable=False, server_default="[]"),
        sa.Column(
            "status",
            session_status_enum,
            nullable=False,
            server_default="active",
        ),
        sa.Column("turn_index", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_speaker", sa.String(length=50), nullable=False, server_default=""),
        sa.Column("silent_turns", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("started_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
    )

    op.create_table(
        "gd_messages",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "session_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("gd_sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("turn_index", sa.Integer(), nullable=False),
        sa.Column("speaker", sa.String(length=50), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column(
            "audio_duration_seconds", sa.Float(), nullable=False, server_default="0.0"
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    op.create_table(
        "feedback_reports",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "session_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("gd_sessions.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        ),
        sa.Column("overall_score", sa.Float(), nullable=False, server_default="0.0"),
        sa.Column("fluency_metrics", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("vocabulary_metrics", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("argument_metrics", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("sub_scores", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("highlight_reel", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("recommendation", sa.Text(), nullable=False, server_default=""),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("feedback_reports")
    op.drop_table("gd_messages")
    op.drop_table("gd_sessions")
    op.drop_table("users")
    postgresql.ENUM(name="session_status_enum").drop(op.get_bind(), checkfirst=True)
    postgresql.ENUM(name="difficulty_enum").drop(op.get_bind(), checkfirst=True)
