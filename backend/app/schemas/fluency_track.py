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
    attempt_count: int = 1
    response_data: dict[str, Any] = Field(default_factory=dict)
    started_at: datetime | None = None
    completed_at: datetime | None = None
    last_attempted_at: datetime | None = None

    class Config:
        from_attributes = True


class NodeActivityOut(BaseModel):
    id: UUID
    stage_node_id: UUID
    sequence: int = 1
    title: str = ""
    activity_type: ActivityType
    config: dict[str, Any] = Field(default_factory=dict)
    is_required: bool = True
    is_active: bool = True
    progress: UserActivityProgressOut | None = None

    class Config:
        from_attributes = True


class StageNodeOut(BaseModel):
    id: UUID
    stage_id: UUID
    sequence: int
    name: str = ""
    slug: str = "node"
    description: str = ""
    cefr_min: str = "A1"
    cefr_max: str = "C2"
    learning_goal: str = ""
    primary_skill: str = ""
    estimated_minutes: int = 10
    is_active: bool = True
    status: str = "AVAILABLE"  # AVAILABLE | IN_PROGRESS | COMPLETED | LOCKED
    completed_activities: int = 0
    total_activities: int = 0
    activities: list[NodeActivityOut] = Field(default_factory=list)

    class Config:
        from_attributes = True


class StageOut(BaseModel):
    id: UUID
    fluency_track_id: UUID
    name: str
    slug: str = "stage"
    description: str = ""
    cefr_min: str = "A1"
    cefr_max: str = "C2"
    primary_goals: list[str] = Field(default_factory=list)
    sequence: int
    is_active: bool = True
    completed_activities: int = 0
    total_activities: int = 0
    percentage: float = 0.0
    nodes: list[StageNodeOut] = Field(default_factory=list)

    class Config:
        from_attributes = True


class FluencyTrackOut(BaseModel):
    id: UUID
    name: str
    slug: str = "track"
    type: FluencyTrackType
    description: str = ""
    cefr_min: str = "A1"
    cefr_max: str = "C2"
    sequence: int = 1
    is_active: bool = True
    completed_nodes: int = 0
    total_nodes: int = 0
    percentage: float = 0.0
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
