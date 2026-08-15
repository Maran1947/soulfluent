import enum
import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    pass


class FluencyTrackType(str, enum.Enum):
    UNFREEZE = "UNFREEZE"
    SCRATCH = "SCRATCH"


class ActivityType(str, enum.Enum):
    lesson = "lesson"
    express_image = "express_image"
    express_video = "express_video"
    forming_sentence = "forming_sentence"
    echo_repeat = "echo_repeat"
    word_picture_match = "word_picture_match"
    tpr_command = "tpr_command"
    listen_select = "listen_select"
    fill_blank = "fill_blank"
    sentence_correction = "sentence_correction"
    dictation = "dictation"
    shadow_speaking = "shadow_speaking"
    roleplay = "roleplay"
    free_response = "free_response"
    debate = "debate"
    rescue_phrase_drill = "rescue_phrase_drill"
    interruption = "interruption"
    listen_and_order = "listen_and_order"
    quiz = "quiz"


class ActivityStatus(str, enum.Enum):
    not_started = "not_started"
    in_progress = "in_progress"
    completed = "completed"


class FluencyTrack(Base):
    __tablename__ = "tracks"
    __table_args__ = {"schema": "fluency"}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[FluencyTrackType] = mapped_column(
        Enum(FluencyTrackType, name="fluency_track_type_enum", schema="fluency"),
        nullable=False,
        default=FluencyTrackType.UNFREEZE,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    stages: Mapped[list["Stage"]] = relationship(
        back_populates="fluency_track", cascade="all, delete-orphan", order_by="Stage.sequence"
    )


class Stage(Base):
    __tablename__ = "stages"
    __table_args__ = {"schema": "fluency"}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    fluency_track_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("fluency.tracks.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    sequence: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    fluency_track: Mapped["FluencyTrack"] = relationship(back_populates="stages")
    nodes: Mapped[list["StageNode"]] = relationship(
        back_populates="stage", cascade="all, delete-orphan", order_by="StageNode.sequence"
    )


class StageNode(Base):
    __tablename__ = "stage_nodes"
    __table_args__ = {"schema": "fluency"}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stage_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("fluency.stages.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    sequence: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    stage: Mapped["Stage"] = relationship(back_populates="nodes")
    activities: Mapped[list["NodeActivity"]] = relationship(
        back_populates="stage_node", cascade="all, delete-orphan"
    )


class NodeActivity(Base):
    __tablename__ = "node_activities"
    __table_args__ = {"schema": "fluency"}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stage_node_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("fluency.stage_nodes.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    activity_type: Mapped[ActivityType] = mapped_column(
        Enum(ActivityType, name="activity_type_enum", schema="fluency"),
        nullable=False,
    )
    config: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    stage_node: Mapped["StageNode"] = relationship(back_populates="activities")
    user_progresses: Mapped[list["UserActivityProgress"]] = relationship(
        back_populates="node_activity", cascade="all, delete-orphan"
    )


class UserActivityProgress(Base):
    __tablename__ = "user_activity_progress"
    __table_args__ = (
        UniqueConstraint("user_id", "node_activity_id", name="uq_user_node_activity"),
        {"schema": "fluency"},
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("auth.users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    node_activity_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("fluency.node_activities.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    status: Mapped[ActivityStatus] = mapped_column(
        Enum(ActivityStatus, name="activity_status_enum", schema="fluency"),
        nullable=False,
        default=ActivityStatus.not_started,
    )
    score: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    response_data: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    node_activity: Mapped["NodeActivity"] = relationship(back_populates="user_progresses")
