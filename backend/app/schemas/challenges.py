from typing import Any, Dict, List, Optional
from pydantic import BaseModel


class ZoneOut(BaseModel):
    id: str
    name: str
    icon: str
    color: str
    tagline: str


class RankOut(BaseModel):
    id: str
    name: str
    min_xp: int


class ChallengeOut(BaseModel):
    id: str
    title: str
    zone: str
    requires_voice: bool
    timer_seconds: Optional[int] = None
    timer_type: str
    description: str
    xp: int
    difficulty: str
    icon: str
    in_daily_rotation: bool
    has_mood_checkin: bool
    unlock: Optional[str] = None


class RankProgressOut(BaseModel):
    current: RankOut
    next: Optional[RankOut] = None
    xp: int
    progress: float


class ChallengesLibraryOut(BaseModel):
    zones: Dict[str, ZoneOut]
    ranks: List[RankOut]
    challenges: List[ChallengeOut]
    daily_featured: ChallengeOut
