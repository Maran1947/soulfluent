import uuid
from datetime import datetime
from typing import TYPE_CHECKING, Any

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class UserPreference(Base):
    __tablename__ = "user_preferences"
    __table_args__ = {"schema": "auth"}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("auth.users.id", ondelete="CASCADE"),
        unique=True,
        index=True,
        nullable=False,
    )
    app_language: Mapped[str] = mapped_column(String(20), default="English", nullable=False)
    cefr_level: Mapped[str] = mapped_column(String(5), default="B1", nullable=False)
    primary_goals: Mapped[list[Any]] = mapped_column(JSONB, default=list, nullable=False)
    daily_goal_minutes: Mapped[int] = mapped_column(Integer, default=10, nullable=False)
    extra_preferences: Mapped[dict[str, Any]] = mapped_column(JSONB, default=dict, nullable=False)
    is_onboarded: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="preferences", lazy="joined")
