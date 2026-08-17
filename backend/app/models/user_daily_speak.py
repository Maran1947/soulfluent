import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.daily_speak_topic import DailySpeakTopic
    from app.models.session import Session
    from app.models.user import User


class UserDailySpeak(Base):
    __tablename__ = "user_daily_speaks"
    __table_args__ = (
        UniqueConstraint("user_id", "completed_at_date", name="uq_user_daily_speak_date"),
        {"schema": "daily_speak"},
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("auth.users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    topic_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("daily_speak.topics.id", ondelete="SET NULL"), nullable=True
    )
    session_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("conversation.sessions.id", ondelete="SET NULL"), nullable=True
    )
    completed_at_date: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

    user: Mapped["User"] = relationship()
    topic: Mapped["DailySpeakTopic | None"] = relationship()
    session: Mapped["Session | None"] = relationship()
