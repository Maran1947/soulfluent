import uuid
from datetime import date, datetime
from sqlalchemy import Date, DateTime, Integer, String, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class DailySpeakTopic(Base):
    __tablename__ = "topics"
    __table_args__ = {"schema": "daily_speak"}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    topic: Mapped[str] = mapped_column(String(500), nullable=False)
    subtitle: Mapped[str] = mapped_column(String(500), nullable=False, default="")
    category: Mapped[str] = mapped_column(String(100), default="General")
    scheduled_date: Mapped[date | None] = mapped_column(Date, nullable=True, index=True)
    duration_seconds: Mapped[int] = mapped_column(Integer, default=60)
    talking_points: Mapped[list] = mapped_column(JSONB, default=list)  # list[str]
    starter_phrases: Mapped[list] = mapped_column(JSONB, default=list)  # list[str]
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
