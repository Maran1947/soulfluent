from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field, ConfigDict


class CurriculumDayOut(BaseModel):
    model_config = ConfigDict(extra="allow")

    d: int
    theme: str
    persona: str
    mode: str
    aiLine: str
    instruction: str
    phrasesA: List[str] = Field(default_factory=list)
    phrasesB: List[str] = Field(default_factory=list)
    rescuePhrases: List[str] = Field(default_factory=list)
    shadowLine: Optional[str] = None
    moodCheckIn: bool = False
    textVisibleOnScreen: bool = True
    script: List[str] = Field(default_factory=list)
    wpm: Optional[int] = None
    filler: str = "n/a"
    milestoneReport: bool = False


class CurriculumWeekOut(BaseModel):
    model_config = ConfigDict(extra="allow")

    title: str
    range: str
    days: List[CurriculumDayOut]


class CurriculumLibraryOut(BaseModel):
    model_config = ConfigDict(extra="allow")

    personas: Dict[str, Any]
    weeks: List[CurriculumWeekOut]
    tracks: Optional[Dict[str, Any]] = None


class CurriculumProgressOut(BaseModel):
    current_day: int = 1
    streak_days: int = 0
    active_track: str = "A"  # "A" or "B"
    review_mode: bool = False
    completed_days: List[int] = Field(default_factory=list)


class UpdateCurriculumProgressRequest(BaseModel):
    current_day: Optional[int] = None
    active_track: Optional[str] = None
    review_mode: Optional[bool] = None
    completed_day: Optional[int] = None
    reset: Optional[bool] = False

