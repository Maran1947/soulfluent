"""Wraps all Gemini API interactions: speech-to-text (audio understanding),
persona turn generation (structured JSON output), text-to-speech, and
post-session feedback analysis.
"""

import io
import uuid
import wave

from google import genai
from google.genai import types
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.llm_usage import CallType
from app.services.persona import Persona
from app.services.usage_service import log_usage

settings = get_settings()
_client = genai.Client(api_key=settings.gemini_api_key)


# ---------------------------------------------------------------------------
# Speech-to-text
# ---------------------------------------------------------------------------
async def transcribe_audio(
    audio_bytes: bytes,
    mime_type: str = "audio/webm",
    db: AsyncSession | None = None,
    session_id: uuid.UUID | None = None,
) -> str:
    """Transcribe a user's spoken turn using Gemini's audio understanding."""
    response = await _client.aio.models.generate_content(
        model=settings.gemini_text_model,
        contents=[
            types.Part.from_bytes(data=audio_bytes, mime_type=mime_type),
            (
                "Transcribe the spoken audio exactly as said, in English. "
                "Return ONLY the transcript text, no commentary, no quotes."
            ),
        ],
    )
    await log_usage(db, session_id, CallType.stt, settings.gemini_text_model, response)
    return (response.text or "").strip()


# ---------------------------------------------------------------------------
# GD turn generation (turn-manager + persona response combined in one call)
# ---------------------------------------------------------------------------
class NextTurn(BaseModel):
    speaker: str = Field(description="persona key of whoever should speak next")
    text: str = Field(description="what that persona says, in character")


def _build_turn_prompt(
    topic: str,
    personas: list[Persona],
    recent_turns: list[dict],
    last_speaker: str,
    silent_turns: dict[str, int],
    time_remaining_seconds: int,
) -> str:
    persona_block = "\n\n".join(
        f'### {p.name} (key: "{p.key}")\n{p.system_prompt()}' for p in personas
    )
    history_block = (
        "\n".join(f"{t['speaker']}: {t['text']}" for t in recent_turns[-10:])
        or "(discussion just started)"
    )

    silence_notes = (
        ", ".join(
            f"{key} has been silent for {count} turn(s)" for key, count in silent_turns.items()
        )
        or "no one has been silent long"
    )

    return f"""
You are the turn-selection engine for a voice Group Discussion practice app.

Topic: "{topic}"
Time remaining in session: {time_remaining_seconds} seconds.
Participants available to speak next: {", ".join(p.key for p in personas)}.
Last speaker: {last_speaker or "none"}.
Silence tracking: {silence_notes}.

Recent conversation:
{history_block}

{persona_block}

Decide which ONE participant should speak next, considering:
- A participant directly addressed by name should usually respond.
- A participant with a strong counterpoint to the last statement should often respond.
- Don't let the same participant speak twice in a row unless clearly warranted.
- A participant silent for 2+ turns should be prioritized occasionally.
- If time is almost up, keep responses brief and wrap toward a natural close.

Then generate that participant's response IN CHARACTER, reacting specifically
to the last thing said (not a generic statement). Keep it natural, spoken
English, under their word limit.

Respond with the chosen speaker's persona key and their response text.
""".strip()


async def generate_next_turn(
    topic: str,
    personas: list[Persona],
    recent_turns: list[dict],
    last_speaker: str,
    silent_turns: dict[str, int],
    time_remaining_seconds: int,
    db: AsyncSession | None = None,
    session_id: uuid.UUID | None = None,
) -> NextTurn:
    prompt = _build_turn_prompt(
        topic, personas, recent_turns, last_speaker, silent_turns, time_remaining_seconds
    )
    response = await _client.aio.models.generate_content(
        model=settings.gemini_text_model,
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=NextTurn,
            temperature=0.9,
        ),
    )
    await log_usage(db, session_id, CallType.turn, settings.gemini_text_model, response)
    return NextTurn.model_validate_json(response.text or "{}")


# ---------------------------------------------------------------------------
# Text-to-speech
# ---------------------------------------------------------------------------
def _pcm_to_wav(pcm_bytes: bytes, sample_rate: int = 24000) -> bytes:
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(sample_rate)
        wf.writeframes(pcm_bytes)
    return buf.getvalue()


async def synthesize_speech(
    text: str,
    voice_name: str,
    db: AsyncSession | None = None,
    session_id: uuid.UUID | None = None,
) -> bytes:
    """Returns WAV audio bytes for the given text using a Gemini TTS voice."""
    response = await _client.aio.models.generate_content(
        model=settings.gemini_tts_model,
        contents=text,
        config=types.GenerateContentConfig(
            response_modalities=["AUDIO"],
            speech_config=types.SpeechConfig(
                voice_config=types.VoiceConfig(
                    prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name=voice_name)
                )
            ),
        ),
    )
    await log_usage(db, session_id, CallType.tts, settings.gemini_tts_model, response)
    candidates = response.candidates
    if not candidates or not candidates[0].content or not candidates[0].content.parts:
        raise RuntimeError("Gemini TTS response missing audio content")
    inline_data = candidates[0].content.parts[0].inline_data
    if not inline_data or not inline_data.data:
        raise RuntimeError("Gemini TTS response missing audio data")
    return _pcm_to_wav(inline_data.data)


# ---------------------------------------------------------------------------
# Post-session feedback analysis (qualitative portion — objective metrics like
# WPM/talk-time/filler count are computed separately in feedback_service.py)
# ---------------------------------------------------------------------------
class QualitativeFeedback(BaseModel):
    vocabulary_richness_score: float = Field(description="0-1, unique words / total words")
    advanced_vocabulary_examples: list[str]
    repeated_phrases: list[str]
    phrases_to_avoid: list[str] = Field(description="exactly 3 overused/weak phrases")
    replacement_suggestions: list[str] = Field(description="exactly 3, matching phrases_to_avoid")
    grammar_errors: list[str]
    distinct_points_made: int
    points_challenged_by_ai: int
    points_successfully_defended: int
    topic_initiations: int
    relevance_score: float = Field(description="0-1, did the user stay on topic")
    overall_score: float = Field(description="0-100 overall session score")
    # Gemini's structured-output schema doesn't support open-ended dict/map
    # types (no `additionalProperties`), so these are explicit fields instead
    # of a dict[str, float] — reassembled into a dict in feedback_service.py.
    sub_score_fluency: float = Field(description="0-100")
    sub_score_vocabulary: float = Field(description="0-100")
    sub_score_argument_quality: float = Field(description="0-100")
    sub_score_confidence: float = Field(description="0-100")
    sub_score_relevance: float = Field(description="0-100")
    best_moments: list[str] = Field(description="exactly 3 highlight quotes/moments")
    improvement_areas: list[str] = Field(description="exactly 3 priority improvements")
    recommendation: str = Field(description="what to practice in the next session")


async def analyze_session(
    topic: str,
    transcript: str,
    db: AsyncSession | None = None,
    session_id: uuid.UUID | None = None,
) -> QualitativeFeedback:
    prompt = f"""
You are an expert English-speaking and Group Discussion coach analyzing a
practice session transcript.

Topic discussed: "{topic}"

Full transcript (user's turns are labeled "user", AI participants labeled by
name):
{transcript}

Analyze ONLY the "user" turns for language quality and argument quality
(AI turns are context, not to be scored). Provide a rigorous, encouraging,
and specific analysis following the requested schema exactly.
""".strip()

    response = await _client.aio.models.generate_content(
        model=settings.gemini_text_model,
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=QualitativeFeedback,
            temperature=0.4,
        ),
    )
    await log_usage(db, session_id, CallType.analysis, settings.gemini_text_model, response)
    return QualitativeFeedback.model_validate_json(response.text or "{}")
