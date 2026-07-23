"""llm usage tracking

Revision ID: 0002
Revises: 0001
Create Date: 2026-07-18

"""
from typing import Sequence, Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0002"
down_revision: Union[str, None] = "0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    call_type_enum = postgresql.ENUM(
        "stt", "turn", "tts", "analysis", name="call_type_enum", create_type=False
    )
    call_type_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "llm_usage_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "session_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("gd_sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("call_type", call_type_enum, nullable=False),
        sa.Column("model", sa.String(length=100), nullable=False),
        sa.Column("input_tokens", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("output_tokens", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("total_tokens", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("cost_usd", sa.Float(), nullable=False, server_default="0.0"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_llm_usage_logs_session_id", "llm_usage_logs", ["session_id"])

    op.add_column(
        "feedback_reports",
        sa.Column("total_tokens", sa.Integer(), nullable=False, server_default="0"),
    )
    op.add_column(
        "feedback_reports",
        sa.Column("total_cost_usd", sa.Float(), nullable=False, server_default="0.0"),
    )


def downgrade() -> None:
    op.drop_column("feedback_reports", "total_cost_usd")
    op.drop_column("feedback_reports", "total_tokens")
    op.drop_table("llm_usage_logs")
    postgresql.ENUM(name="call_type_enum").drop(op.get_bind(), checkfirst=True)
