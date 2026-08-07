import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.session import Difficulty, SessionStatus


class CreateSessionRequest(BaseModel):
    topic: str | None = Field(default=None, description="If omitted, a random topic is chosen")
    category: str = "general"
    difficulty: Difficulty = Difficulty.intermediate
    duration_minutes: int = Field(default=10, ge=1, le=60)
    persona_keys: list[str] | None = Field(
        default=None, description="Defaults to the two MVP personas if omitted"
    )
    day_number: int | None = None
    initial_ai_text: str | None = None
    scaffold_phrases: list[str] | None = None


class PersonaOut(BaseModel):
    key: str
    name: str
    personality: str
    voice_name: str


class SessionOut(BaseModel):
    id: uuid.UUID
    topic: str
    category: str
    difficulty: Difficulty
    duration_minutes: int
    personas: list[PersonaOut]
    status: SessionStatus
    started_at: datetime
    ended_at: datetime | None

    class Config:
        from_attributes = True


class MessageOut(BaseModel):
    id: uuid.UUID
    turn_index: int
    speaker: str
    text: str
    audio_url: str | None = None
    created_at: datetime

    class Config:
        from_attributes = True


class TurnResponse(BaseModel):
    """Returned after the user submits an audio turn."""

    user_transcript: str
    ai_speaker: str
    ai_speaker_name: str
    ai_text: str
    ai_audio_base64: str  # WAV audio, base64-encoded
    turn_index: int
    seconds_remaining: int
    session_status: SessionStatus


class TopicLibraryOut(BaseModel):
    categories: dict[str, list[str]]
