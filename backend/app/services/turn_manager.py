"""Lightweight helpers around GDSession turn/silence bookkeeping.

The actual "who speaks next" decision is delegated to Gemini in one combined
call (see gemini_service.generate_next_turn) per the PRD's urgency-scoring
intent, but simplified to a single LLM call instead of separate per-persona
scoring calls — this keeps latency and cost low for the MVP while still
producing turn-aware, non-repetitive dialogue.
"""

from app.models.gd_session import GDSession
from app.services.persona import DEFAULT_PERSONA_KEYS


def init_silent_turns(persona_keys: list[str]) -> dict[str, int]:
    return {key: 0 for key in persona_keys}


def update_silent_turns(session: GDSession, speaker: str) -> dict[str, int]:
    """Bump silence counters for everyone except whoever just spoke."""
    persona_keys = session.personas or DEFAULT_PERSONA_KEYS
    counts = dict(session.silent_turns or init_silent_turns(persona_keys))
    for key in persona_keys:
        if key == speaker:
            counts[key] = 0
        else:
            counts[key] = counts.get(key, 0) + 1
    return counts


def seconds_remaining(session: GDSession) -> int:
    from datetime import datetime, timezone

    elapsed = (datetime.now(timezone.utc) - session.started_at).total_seconds()
    total = session.duration_minutes * 60
    return max(0, int(total - elapsed))
