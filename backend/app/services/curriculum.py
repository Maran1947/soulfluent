"""Curriculum service definitions for FluentSoul.

Roadmap data is loaded dynamically from PostgreSQL database.
"""

from typing import Any

# ---------------------------------------------------------------------------
# PERSONAS
# ---------------------------------------------------------------------------

PERSONAS_INFO: dict[str, dict[str, Any]] = {
    "riya": {
        "name": "Riya",
        "initial": "R",
        "color": "#FF8B5E",
        "sub": "🇮🇳 Empathetic Peacemaker",
        "flag": "🇮🇳",
    },
    "rohan": {
        "name": "Rohan",
        "initial": "R",
        "color": "#E3B23C",
        "sub": "🇮🇳 Structured Strategist",
        "flag": "🇮🇳",
    },
    "emily": {
        "name": "Emily",
        "initial": "E",
        "color": "#F0455C",
        "sub": "🇺🇸 Sharp Orator",
        "flag": "🇺🇸",
    },
    "alex": {
        "name": "Alex",
        "initial": "A",
        "color": "#9B7CF2",
        "sub": "🇺🇸 Analytical Contrarian",
        "flag": "🇺🇸",
    },
    "panel": {
        "name": "Group Room",
        "initial": "◆",
        "color": "#3FC1A8",
        "sub": "Riya · Rohan · Emily · Alex",
        "flag": "🌐",
    },
}

DEFAULT_RESCUE_PHRASES: list[str] = [
    "Give me a sec...",
    "Let me think about that...",
    "How do I say this...",
    "Hmm, good question...",
]

BEGINNER_RESCUE_PHRASES: list[str] = [
    "Wait, please...",
    "One moment...",
    "I think... umm...",
]

MOOD_OPTIONS: list[str] = ["😰 Nervous", "😐 Neutral", "😊 Confident"]

TRACK_A_STAGES: list[dict[str, Any]] = []
TRACK_B_STAGES: list[dict[str, Any]] = []

STAGES_DATA = TRACK_A_STAGES

TRACKS: dict[str, dict[str, Any]] = {
    "track_a": {
        "id": "track_a",
        "name": "Unfreeze",
        "subtitle": "For learners who understand English but blank when speaking",
        "stages": TRACK_A_STAGES,
    },
    "track_b": {
        "id": "track_b",
        "name": "From Scratch",
        "subtitle": "For true beginners — builds into Track A automatically",
        "stages": TRACK_B_STAGES,
    },
}


def get_track(track_id: str) -> dict[str, Any] | None:
    """Return the full track object ('track_a' or 'track_b')."""
    return TRACKS.get(track_id)


def get_all_days(track_id: str) -> list[dict[str, Any]]:
    """Flatten all days for a given track, in order."""
    track = get_track(track_id)
    if not track:
        return []
    days: list[dict[str, Any]] = []
    stages = track.get("stages", [])
    for s in stages:
        days.extend(s.get("nodes") or s.get("days", []))
    return days


def get_day_by_number(track_id: str, day_num: int) -> dict[str, Any] | None:
    """Get a specific day's data from a specific track."""
    for d in get_all_days(track_id):
        if d["d"] == day_num:
            return d
    return None


def get_stage_for_day(track_id: str, day_num: int) -> dict[str, Any] | None:
    """Return the stage block (title/range) that contains the given day number."""
    track = get_track(track_id)
    if not track:
        return None
    stages = track.get("stages", [])
    for s in stages:
        nodes = s.get("nodes") or s.get("days", [])
        if any(d["d"] == day_num for d in nodes):
            return s
    return None


def recommend_track(placement_result: str) -> str:
    """Simple placement-test router.

    placement_result: 'blank_on_speaking' | 'true_beginner'
    Use this at onboarding to route the user into the right track.
    """
    if placement_result == "true_beginner":
        return "track_b"
    return "track_a"


def is_graduation_day(track_id: str, day_num: int) -> bool:
    """True if completing this day should trigger the Track B -> Track A handoff."""
    day = get_day_by_number(track_id, day_num)
    return bool(day and day.get("graduatesToTrackA"))


def get_lightweight_day_display(day: dict[str, Any], track_id: str = "track_a") -> dict[str, Any]:
    """Derived display layer for UI rendering."""
    ai_line = day.get("aiLine", "")

    if " — " in ai_line:
        short_hook = ai_line.split(" — ")[0].strip() + "."
    elif "." in ai_line:
        short_hook = ai_line.split(".")[0].strip() + "."
    elif "!" in ai_line:
        short_hook = ai_line.split("!")[0].strip() + "!"
    elif "?" in ai_line:
        short_hook = ai_line.split("?")[0].strip() + "?"
    else:
        short_hook = ai_line

    instruction = day.get("instruction", "")
    if "." in instruction:
        short_instruction = instruction.split(".")[0].strip() + "."
    else:
        short_instruction = instruction

    wpm = day.get("wpm")
    wpm_str = f"⏱️ {wpm} WPM" if wpm else "⏱️ Free Pace"
    filler = day.get("filler", "n/a")
    filler_str = f"🎯 {filler}"
    rescue_phrases = day.get("rescuePhrases") or []
    rescue_str = "🛟 Rescue on" if rescue_phrases else "🛟 Standard"

    track_key = track_id.lower()
    if track_key in ("track_a", "a"):
        phrases = day.get("phrasesA") or day.get("phrasesB") or []
    else:
        phrases = day.get("phrasesB") or day.get("phrasesA") or []

    primary_phrase = phrases[0] if phrases else None
    remaining_phrases_count = max(0, len(phrases) - 1)

    return {
        **day,
        "shortHook": short_hook,
        "shortInstruction": short_instruction,
        "statChips": [wpm_str, filler_str, rescue_str],
        "primaryPhrase": primary_phrase,
        "remainingPhrasesCount": remaining_phrases_count,
        "allPhrases": phrases,
        "hasFullAiLine": len(ai_line.strip()) > len(short_hook.strip()),
        "hasFullInstruction": len(instruction.strip()) > len(short_instruction.strip()),
        "hasSampleExchange": bool(day.get("script")),
        "hasShadow": bool(day.get("shadowLine")),
        "hasMoodCheckin": bool(day.get("moodCheckIn")),
    }
