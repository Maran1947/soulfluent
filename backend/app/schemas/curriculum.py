from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class CurriculumDayOut(BaseModel):
    model_config = ConfigDict(extra="allow")

    d: int
    theme: str
    persona: str
    mode: str
    aiLine: str
    instruction: str
    phrasesA: list[str] = Field(default_factory=list)
    phrasesB: list[str] = Field(default_factory=list)
    rescuePhrases: list[str] = Field(default_factory=list)
    shadowLine: str | None = None
    moodCheckIn: bool = False
    textVisibleOnScreen: bool = True
    script: list[str] = Field(default_factory=list)
    wpm: int | None = None
    filler: str = "n/a"
    milestoneReport: bool = False


class CurriculumWeekOut(BaseModel):
    model_config = ConfigDict(extra="allow")

    title: str
    range: str
    days: list[CurriculumDayOut]


class CurriculumLibraryOut(BaseModel):
    model_config = ConfigDict(extra="allow")

    personas: dict[str, Any]
    weeks: list[CurriculumWeekOut]
    tracks: dict[str, Any] | None = None


class CurriculumProgressOut(BaseModel):
    current_day: int = 1
    streak_days: int = 0
    active_track: str = "A"  # "A" or "B"
    review_mode: bool = False
    completed_days: list[int] = Field(default_factory=list)


class UpdateCurriculumProgressRequest(BaseModel):
    current_day: int | None = None
    active_track: str | None = None
    review_mode: bool | None = None
    completed_day: int | None = None
    reset: bool | None = False
