import uuid
from datetime import datetime
from typing import Any
from pydantic import BaseModel, Field


class OverviewStatsResponse(BaseModel):
    total_signups: int = 0
    onboarded_users: int = 0
    onboarded_percentage: float = 0.0
    started_tracks_users: int = 0
    total_sessions: int = 0
    completed_sessions_count: int = 0
    active_sessions_count: int = 0
    abandoned_sessions_count: int = 0
    total_daily_speaks: int = 0
    total_cost_usd: float = 0.0
    signup_sources: dict[str, int] = Field(default_factory=dict)
    cefr_distribution: dict[str, int] = Field(default_factory=dict)


class SessionListItem(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    user_name: str = ""
    user_email: str = ""
    mode: str
    topic: str
    category: str
    status: str
    duration_minutes: int
    turn_index: int
    started_at: datetime
    ended_at: datetime | None = None
    total_tokens: int = 0
    total_cost_usd: float = 0.0


class MessageItem(BaseModel):
    id: uuid.UUID
    turn_index: int
    speaker: str
    speaker_role: str
    text: str
    audio_duration_seconds: float
    created_at: datetime


class LLMUsageItem(BaseModel):
    id: uuid.UUID
    call_type: str
    model: str
    input_tokens: int
    output_tokens: int
    total_tokens: int
    cost_usd: float
    created_at: datetime


class SessionDetailResponse(BaseModel):
    session: SessionListItem
    messages: list[MessageItem] = Field(default_factory=list)
    usage_logs: list[LLMUsageItem] = Field(default_factory=list)
    report: dict[str, Any] | None = None
    total_cost_usd: float = 0.0


class DailySpeakItem(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    user_name: str = ""
    user_email: str = ""
    completed_at_date: datetime
    topic_title: str = "Daily Speak Practice"
    session_id: uuid.UUID | None = None
    cost_usd: float = 0.0


class DailySpeakListResponse(BaseModel):
    total_completions: int = 0
    total_cost_usd: float = 0.0
    items: list[DailySpeakItem] = Field(default_factory=list)


class UserLeaderboardItem(BaseModel):
    rank: int
    user_id: uuid.UUID
    user_name: str = ""
    user_email: str = ""
    streak_days: int = 0
    completed_sessions: int = 0
    completed_daily_speaks: int = 0
    completed_activities: int = 0
    total_speak_seconds: float = 0.0
    cefr_level: str = "B1"
    is_onboarded: bool = False
    created_at: datetime
