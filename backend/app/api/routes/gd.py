import base64
import contextlib
import uuid
import wave
from datetime import UTC
from io import BytesIO

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_user
from app.config import get_settings
from app.database import get_db
from app.models.message import Message
from app.models.session import Session, SessionStatus
from app.models.user import User
from app.schemas.gd import (
    CreateSessionRequest,
    MessageOut,
    PersonaOut,
    SessionOut,
    TopicLibraryOut,
    TurnResponse,
)
from app.schemas.report import FeedbackReportOut
from app.services.feedback_service import build_feedback_report
from app.services.gemini_service import generate_next_turn, synthesize_speech, transcribe_audio
from app.services.persona import DEFAULT_PERSONA_KEYS, PERSONAS, get_personas
from app.services.storage_service import build_audio_key, get_playback_url, upload_audio
from app.services.topics import list_topics, random_topic
from app.services.turn_manager import init_silent_turns, seconds_remaining, update_silent_turns

router = APIRouter(prefix="/gd", tags=["group-discussion"])
settings = get_settings()


_AUDIO_EXTENSIONS = {
    "audio/webm": "webm",
    "audio/mp4": "m4a",
    "audio/m4a": "m4a",
    "audio/x-m4a": "m4a",
    "audio/aac": "aac",
    "audio/ogg": "ogg",
    "audio/wav": "wav",
    "audio/mp3": "mp3",
}


def _extension_for_mime(mime_type: str) -> str:
    return _AUDIO_EXTENSIONS.get(mime_type, "webm")


def _wav_duration_seconds(wav_bytes: bytes) -> float:
    with contextlib.closing(wave.open(BytesIO(wav_bytes), "rb")) as wf:
        return wf.getnframes() / float(wf.getframerate())


def _session_to_out(session: Session) -> SessionOut:
    personas = [
        PersonaOut(key=p.key, name=p.name, personality=p.personality, voice_name=p.voice_name)
        for p in get_personas(session.personas)
    ]
    return SessionOut(
        id=session.id,
        topic=session.topic,
        category=session.category,
        difficulty=session.difficulty,
        duration_minutes=session.duration_minutes,
        personas=personas,
        status=session.status,
        started_at=session.started_at,
        ended_at=session.ended_at,
    )


async def _get_owned_session(
    session_id: uuid.UUID, user: User, db: AsyncSession, with_messages: bool = False
) -> Session:
    stmt = select(Session).where(Session.id == session_id)
    if with_messages:
        stmt = stmt.options(selectinload(Session.messages), selectinload(Session.report))
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")
    if session.user_id != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your session")
    return session


@router.get("/topics", response_model=TopicLibraryOut)
async def get_topics(language: str = "English"):
    return TopicLibraryOut(categories=list_topics(language=language))


@router.post("/sessions", response_model=SessionOut, status_code=status.HTTP_201_CREATED)
async def create_session(
    payload: CreateSessionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    persona_keys = payload.persona_keys or DEFAULT_PERSONA_KEYS
    invalid = [k for k in persona_keys if k not in PERSONAS]
    if invalid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=f"Unknown personas: {invalid}"
        )

    topic = payload.topic or random_topic()
    config_data = {}
    if payload.day_number is not None:
        config_data["day_number"] = payload.day_number
    if payload.initial_ai_text:
        config_data["initial_ai_text"] = payload.initial_ai_text
    if payload.scaffold_phrases:
        config_data["scaffold_phrases"] = payload.scaffold_phrases

    session = Session(
        user_id=current_user.id,
        topic=topic,
        category=payload.category,
        difficulty=payload.difficulty,
        duration_minutes=payload.duration_minutes,
        personas=persona_keys,
        config=config_data,
        status=SessionStatus.active,
        turn_index=0,
        last_speaker="",
        silent_turns=init_silent_turns(persona_keys),
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)

    if payload.initial_ai_text:
        primary_persona_key = persona_keys[0]
        speaker_persona = PERSONAS.get(primary_persona_key, PERSONAS["riya"])
        try:
            ai_audio = await synthesize_speech(
                payload.initial_ai_text, speaker_persona.voice_name, db=db, session_id=session.id
            )
            ai_duration = _wav_duration_seconds(ai_audio)
            ai_audio_key = build_audio_key(session.id, 0, speaker_persona.key, "wav")
            await upload_audio(ai_audio_key, ai_audio, "audio/wav")

            ai_message = Message(
                session_id=session.id,
                turn_index=0,
                speaker=speaker_persona.key,
                text=payload.initial_ai_text,
                audio_duration_seconds=ai_duration,
                audio_key=ai_audio_key,
            )
            db.add(ai_message)
            session.turn_index = 1
            session.last_speaker = speaker_persona.key
            session.silent_turns = update_silent_turns(session, speaker_persona.key)
            await db.commit()
            await db.refresh(session)
        except Exception:
            # Fallback if TTS fails on startup
            ai_message = Message(
                session_id=session.id,
                turn_index=0,
                speaker=speaker_persona.key,
                text=payload.initial_ai_text,
                audio_duration_seconds=3.0,
                audio_key="",
            )
            db.add(ai_message)
            session.turn_index = 1
            session.last_speaker = speaker_persona.key
            await db.commit()
            await db.refresh(session)

    return _session_to_out(session)


@router.get("/sessions", response_model=list[SessionOut])
async def list_sessions(
    current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Session)
        .where(Session.user_id == current_user.id)
        .order_by(Session.started_at.desc())
    )
    return [_session_to_out(s) for s in result.scalars().all()]


@router.get("/sessions/{session_id}", response_model=SessionOut)
async def get_session(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session = await _get_owned_session(session_id, current_user, db)
    return _session_to_out(session)


@router.get("/sessions/{session_id}/messages", response_model=list[MessageOut])
async def get_session_messages(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session = await _get_owned_session(session_id, current_user, db, with_messages=True)
    out = []
    for m in session.messages:
        audio_url = await get_playback_url(m.audio_key)
        out.append(
            MessageOut(
                id=m.id,
                turn_index=m.turn_index,
                speaker=m.speaker,
                text=m.text,
                audio_url=audio_url,
                created_at=m.created_at,
            )
        )
    return out


@router.post("/sessions/{session_id}/turn", response_model=TurnResponse)
async def submit_turn(
    session_id: uuid.UUID,
    audio: UploadFile = File(...),
    duration_seconds: float = Form(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session = await _get_owned_session(session_id, current_user, db, with_messages=True)
    if session.status != SessionStatus.active:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Session is not active")

    audio_bytes = await audio.read()
    filename = (audio.filename or "").lower()
    mime_type = audio.content_type
    if not mime_type or mime_type in ("application/octet-stream", "binary/octet-stream"):
        if filename.endswith(".m4a") or filename.endswith(".mp4"):
            mime_type = "audio/mp4"
        elif filename.endswith(".wav"):
            mime_type = "audio/wav"
        elif filename.endswith(".aac"):
            mime_type = "audio/aac"
        else:
            mime_type = "audio/webm"
    if mime_type in ("audio/x-m4a", "audio/m4a"):
        mime_type = "audio/mp4"

    user_transcript = await transcribe_audio(audio_bytes, mime_type, db=db, session_id=session.id)
    if not user_transcript:
        user_transcript = "Shared thoughts on the daily topic."

    user_turn_index = session.turn_index
    user_audio_key = build_audio_key(
        session.id, user_turn_index, "user", _extension_for_mime(mime_type)
    )
    await upload_audio(user_audio_key, audio_bytes, mime_type)
    user_message = Message(
        session_id=session.id,
        turn_index=user_turn_index,
        speaker="user",
        text=user_transcript,
        audio_duration_seconds=duration_seconds,
        audio_key=user_audio_key,
    )
    db.add(user_message)
    session.turn_index += 1
    session.silent_turns = update_silent_turns(session, "user")
    session.last_speaker = "user"

    remaining = seconds_remaining(session)
    personas = get_personas(session.personas)
    recent_turns = [{"speaker": m.speaker, "text": m.text} for m in session.messages] + [
        {"speaker": "user", "text": user_transcript}
    ]

    next_turn = await generate_next_turn(
        topic=session.topic,
        personas=personas,
        recent_turns=recent_turns,
        last_speaker="user",
        silent_turns=session.silent_turns,
        time_remaining_seconds=remaining,
        db=db,
        session_id=session.id,
    )
    speaker_persona = PERSONAS.get(next_turn.speaker, personas[0])
    ai_audio = await synthesize_speech(
        next_turn.text, speaker_persona.voice_name, db=db, session_id=session.id
    )
    ai_duration = _wav_duration_seconds(ai_audio)

    ai_turn_index = session.turn_index
    ai_audio_key = build_audio_key(session.id, ai_turn_index, speaker_persona.key, "wav")
    await upload_audio(ai_audio_key, ai_audio, "audio/wav")
    ai_message = Message(
        session_id=session.id,
        turn_index=ai_turn_index,
        speaker=speaker_persona.key,
        text=next_turn.text,
        audio_duration_seconds=ai_duration,
        audio_key=ai_audio_key,
    )
    db.add(ai_message)
    session.turn_index += 1
    session.silent_turns = update_silent_turns(session, speaker_persona.key)
    session.last_speaker = speaker_persona.key

    remaining_after = seconds_remaining(session)
    if remaining_after <= 0:
        session.status = SessionStatus.completed
        from datetime import datetime

        session.ended_at = datetime.now(UTC)

    await db.commit()

    return TurnResponse(
        user_transcript=user_transcript,
        ai_speaker=speaker_persona.key,
        ai_speaker_name=speaker_persona.name,
        ai_text=next_turn.text,
        ai_audio_base64=base64.b64encode(ai_audio).decode("utf-8"),
        turn_index=ai_turn_index,
        seconds_remaining=remaining_after,
        session_status=session.status,
    )


@router.post("/sessions/{session_id}/end", response_model=FeedbackReportOut)
async def end_session(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    from datetime import datetime

    from sqlalchemy import func

    from app.models.feedback_report import FeedbackReport
    from app.models.llm_usage import LLMUsageLog

    session = await _get_owned_session(session_id, current_user, db, with_messages=True)

    if session.report is not None:
        return FeedbackReportOut.model_validate(session.report)

    if session.status == SessionStatus.active:
        session.status = SessionStatus.completed
        session.ended_at = datetime.now(UTC)

    if session.category.lower() == "daily speak" or session.category == "Daily Speak":
        from app.services.daily_speak_service import log_user_daily_speak_completion
        try:
            await log_user_daily_speak_completion(db, current_user.id, session.id)
        except Exception:
            pass

    if not session.messages:

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot generate a report for a session with no turns",
        )

    persona_names = {p.key: p.name for p in PERSONAS.values()}
    report_data = await build_feedback_report(
        session.topic, session.messages, persona_names, db=db, session_id=session.id
    )

    report = FeedbackReport(session_id=session.id, **report_data)
    db.add(report)
    await db.commit()  # persists the report AND every usage log added during this session

    totals = await db.execute(
        select(
            func.coalesce(func.sum(LLMUsageLog.total_tokens), 0),
            func.coalesce(func.sum(LLMUsageLog.cost_usd), 0.0),
        ).where(LLMUsageLog.session_id == session.id)
    )
    total_tokens, total_cost_usd = totals.one()
    report.total_tokens = int(total_tokens)
    report.total_cost_usd = float(total_cost_usd)
    await db.commit()
    await db.refresh(report)
    return FeedbackReportOut.model_validate(report)


@router.get("/sessions/{session_id}/report", response_model=FeedbackReportOut)
async def get_report(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session = await _get_owned_session(session_id, current_user, db)
    result = await db.execute(
        select(Session).where(Session.id == session_id).options(selectinload(Session.report))
    )
    session = result.scalar_one()
    if session.report is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Report not generated yet"
        )
    return FeedbackReportOut.model_validate(session.report)


@router.get("/sessions/{session_id}/usage")
async def get_session_usage(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Raw Gemini usage log for a session — per-call token counts and cost,
    broken down by call type (stt/turn/tts/analysis), plus totals.
    """
    from sqlalchemy import func

    from app.models.llm_usage import LLMUsageLog

    await _get_owned_session(session_id, current_user, db)

    result = await db.execute(
        select(LLMUsageLog)
        .where(LLMUsageLog.session_id == session_id)
        .order_by(LLMUsageLog.created_at)
    )
    logs = result.scalars().all()

    totals = await db.execute(
        select(
            func.coalesce(func.sum(LLMUsageLog.total_tokens), 0),
            func.coalesce(func.sum(LLMUsageLog.cost_usd), 0.0),
        ).where(LLMUsageLog.session_id == session_id)
    )
    total_tokens, total_cost_usd = totals.one()

    return {
        "total_tokens": int(total_tokens),
        "total_cost_usd": float(total_cost_usd),
        "calls": [
            {
                "call_type": log.call_type,
                "model": log.model,
                "input_tokens": log.input_tokens,
                "output_tokens": log.output_tokens,
                "total_tokens": log.total_tokens,
                "cost_usd": log.cost_usd,
                "created_at": log.created_at,
            }
            for log in logs
        ],
    }
