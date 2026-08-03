import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Float, ForeignKey, Text, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.session import Session


class FeedbackReport(Base):
    __tablename__ = "feedback_reports"
    __table_args__ = {"schema": "analytics"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    session_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("conversation.sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    overall_score: Mapped[float] = mapped_column(Float, default=0.0)
    fluency_metrics: Mapped[dict] = mapped_column(JSONB, default=dict)
    vocabulary_metrics: Mapped[dict] = mapped_column(JSONB, default=dict)
    argument_metrics: Mapped[dict] = mapped_column(JSONB, default=dict)
    sub_scores: Mapped[dict] = mapped_column(JSONB, default=dict)
    highlight_reel: Mapped[dict] = mapped_column(JSONB, default=dict)
    recommendation: Mapped[str] = mapped_column(Text, default="")
    total_tokens: Mapped[int] = mapped_column(default=0)
    total_cost_usd: Mapped[float] = mapped_column(Float, default=0.0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    session: Mapped["Session"] = relationship(back_populates="report")
