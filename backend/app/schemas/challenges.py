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
    timer_seconds: int | None = None
    timer_type: str
    description: str
    xp: int
    difficulty: str
    icon: str
    in_daily_rotation: bool
    has_mood_checkin: bool
    unlock: str | None = None


class RankProgressOut(BaseModel):
    current: RankOut
    next: RankOut | None = None
    xp: int
    progress: float


class ChallengesLibraryOut(BaseModel):
    zones: dict[str, ZoneOut]
    ranks: list[RankOut]
    challenges: list[ChallengeOut]
    daily_featured: ChallengeOut
