from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, Field

from app.models.fluency_track import ActivityStatus, ActivityType, FluencyTrackType


class UserActivityProgressOut(BaseModel):
    id: UUID
    node_activity_id: UUID
    status: ActivityStatus
    score: float = 0.0
    response_data: dict[str, Any] = Field(default_factory=dict)
    completed_at: datetime | None = None

    class Config:
        from_attributes = True


class NodeActivityOut(BaseModel):
    id: UUID
    stage_node_id: UUID
    activity_type: ActivityType
    config: dict[str, Any] = Field(default_factory=dict)
    is_active: bool
    progress: UserActivityProgressOut | None = None

    class Config:
        from_attributes = True


class StageNodeOut(BaseModel):
    id: UUID
    stage_id: UUID
    sequence: int
    is_active: bool
    activities: list[NodeActivityOut] = Field(default_factory=list)

    class Config:
        from_attributes = True


class StageOut(BaseModel):
    id: UUID
    fluency_track_id: UUID
    name: str
    sequence: int
    is_active: bool
    nodes: list[StageNodeOut] = Field(default_factory=list)

    class Config:
        from_attributes = True


class FluencyTrackOut(BaseModel):
    id: UUID
    name: str
    type: FluencyTrackType
    is_active: bool
    stages: list[StageOut] = Field(default_factory=list)

    class Config:
        from_attributes = True


class ActivityProgressCreateRequest(BaseModel):
    status: ActivityStatus = ActivityStatus.completed
    score: float = 100.0
    response_data: dict[str, Any] = Field(default_factory=dict)


class FluencyTracksLibraryOut(BaseModel):
    tracks: list[FluencyTrackOut]
    current_track_id: UUID | None = None
    completed_activity_ids: list[UUID] = Field(default_factory=list)
