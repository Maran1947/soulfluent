import enum
import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, String, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.feedback_report import FeedbackReport
    from app.models.gd_message import GDMessage
    from app.models.user import User


class SessionStatus(str, enum.Enum):
    active = "active"
    completed = "completed"
    abandoned = "abandoned"


class Difficulty(str, enum.Enum):
    beginner = "beginner"
    intermediate = "intermediate"
    advanced = "advanced"


class GDSession(Base):
    __tablename__ = "gd_sessions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    topic: Mapped[str] = mapped_column(String(500), nullable=False)
    category: Mapped[str] = mapped_column(String(100), nullable=False, default="general")
    difficulty: Mapped[Difficulty] = mapped_column(
        Enum(Difficulty, name="difficulty_enum"), default=Difficulty.intermediate
    )
    duration_minutes: Mapped[int] = mapped_column(Integer, default=10)
    personas: Mapped[list] = mapped_column(JSONB, default=list)  # list[str] persona keys
    status: Mapped[SessionStatus] = mapped_column(
        Enum(SessionStatus, name="session_status_enum"), default=SessionStatus.active
    )
    turn_index: Mapped[int] = mapped_column(Integer, default=0)
    last_speaker: Mapped[str] = mapped_column(String(50), default="")
    silent_turns: Mapped[dict] = mapped_column(JSONB, default=dict)  # persona -> silent count
    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    user: Mapped["User"] = relationship(back_populates="sessions")
    messages: Mapped[list["GDMessage"]] = relationship(
        back_populates="session", cascade="all, delete-orphan", order_by="GDMessage.turn_index"
    )
    report: Mapped["FeedbackReport | None"] = relationship(
        back_populates="session", cascade="all, delete-orphan", uselist=False
    )
