import enum
import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, DateTime, Enum, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class SignupSource(str, enum.Enum):
    EMAIL = "EMAIL"
    GOOGLE = "GOOGLE"


class AccountStatus(str, enum.Enum):
    NOT_VERIFIED = "NOT_VERIFIED"
    VERIFIED = "VERIFIED"
    SUSPENDED = "SUSPENDED"
    DELETED = "DELETED"


class Account(Base):
    __tablename__ = "accounts"
    __table_args__ = {"schema": "auth"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    hashed_password: Mapped[str | None] = mapped_column(String(255), nullable=True)
    signup_source: Mapped[SignupSource] = mapped_column(
        Enum(SignupSource, name="signup_source_enum", schema="auth"),
        default=SignupSource.EMAIL,
        nullable=False,
    )
    status: Mapped[AccountStatus] = mapped_column(
        Enum(AccountStatus, name="account_status_enum", schema="auth"),
        default=AccountStatus.VERIFIED,
        nullable=False,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped["User"] = relationship(
        back_populates="account", uselist=False, cascade="all, delete-orphan"
    )
