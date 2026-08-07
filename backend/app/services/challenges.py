"""Challenges module for SoulFluent.

Separate from the 30-Day Path (curriculum.py) — these are game-style side
quests, not linear curriculum days. Two modes:

  VOICE challenges   -> require speaking out loud, core product, primary XP source
  QUIET challenges   -> no speaking required (typing/tapping/listening), a bridge
                        for moments a user can't talk out loud, capped XP so they
                        never fully replace voice practice

Everything here is designed to slot straight into the Challenges tab UI:
rank/XP header, inventory row, boss battle hero card, zone list, and a
daily-rotating featured challenge.
"""

import datetime
from typing import Any, Dict, List, Optional

# ---------------------------------------------------------------------------
# ZONES
# ---------------------------------------------------------------------------

ZONES: Dict[str, Dict[str, Any]] = {
    "confidence": {
        "id": "confidence",
        "name": "Confidence zone",
        "icon": "ti-heart",
        "color": "pink",
        "tagline": "Face the nerves, on purpose",
    },
    "speed": {
        "id": "speed",
        "name": "Speed zone",
        "icon": "ti-bolt",
        "color": "teal",
        "tagline": "Think fast, talk faster",
    },
    "social": {
        "id": "social",
        "name": "Social zone",
        "icon": "ti-users",
        "color": "purple",
        "tagline": "Practice with other learners",
    },
    "boss": {
        "id": "boss",
        "name": "Boss battles",
        "icon": "ti-swords",
        "color": "coral",
        "tagline": "Rare, hard, worth it",
    },
    "quiet": {
        "id": "quiet",
        "name": "Quiet mode",
        "icon": "ti-moon",
        "color": "gray",
        "tagline": "No talking needed — keep the streak alive",
    },
}

RANKS: List[Dict[str, Any]] = [
    {"id": "bronze", "name": "Bronze", "min_xp": 0},
    {"id": "silver", "name": "Silver", "min_xp": 500},
    {"id": "gold", "name": "Gold", "min_xp": 1500},
    {"id": "soul", "name": "Soul rank", "min_xp": 3500},
]


# ---------------------------------------------------------------------------
# CHALLENGES
# Each entry: id, title, zone, requires_voice, timer, description, xp,
# difficulty (bronze/silver/gold), icon, in_daily_rotation (bool)
# ---------------------------------------------------------------------------

CHALLENGES: List[Dict[str, Any]] = [
    # ---- VOICE: Confidence zone ----
    {
        "id": "say_it_scared",
        "title": "Say it scared",
        "zone": "confidence",
        "requires_voice": True,
        "timer_seconds": 60,
        "timer_type": "countdown",
        "description": "Pick a topic that makes you nervous. Talk anyway. Journal how it felt after.",
        "xp": 40,
        "difficulty": "silver",
        "icon": "ti-mood-empty",
        "in_daily_rotation": False,
        "has_mood_checkin": True,
    },
    {
        "id": "silence_tolerance",
        "title": "Silence tolerance",
        "zone": "confidence",
        "requires_voice": True,
        "timer_seconds": None,
        "timer_type": "none",
        "description": "Pause for a full 3 seconds mid-sentence on purpose. No filling it. No panic.",
        "xp": 25,
        "difficulty": "bronze",
        "icon": "ti-player-pause",
        "in_daily_rotation": False,
        "has_mood_checkin": False,
    },
    {
        "id": "rescue_only",
        "title": "Rescue phrase only",
        "zone": "confidence",
        "requires_voice": True,
        "timer_seconds": 90,
        "timer_type": "countdown",
        "description": "You're only allowed to survive using rescue phrases when stuck. No perfect answers expected.",
        "xp": 30,
        "difficulty": "silver",
        "icon": "ti-lifebuoy",
        "in_daily_rotation": False,
        "has_mood_checkin": False,
    },

    # ---- VOICE: Speed zone (daily-timer friendly) ----
    {
        "id": "show_and_tell",
        "title": "Show and tell",
        "zone": "speed",
        "requires_voice": True,
        "timer_seconds": 45,
        "timer_type": "countdown",
        "description": "An image appears. Describe everything you see before the timer runs out.",
        "xp": 20,
        "difficulty": "bronze",
        "icon": "ti-photo",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "one_breath",
        "title": "One breath challenge",
        "zone": "speed",
        "requires_voice": True,
        "timer_seconds": None,
        "timer_type": "count_up",
        "description": "Pick a topic. Talk nonstop until you run out of breath. Beat yesterday's word count.",
        "xp": 20,
        "difficulty": "bronze",
        "icon": "ti-wind",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "story_chain",
        "title": "Story chain",
        "zone": "speed",
        "requires_voice": True,
        "timer_seconds": 120,
        "timer_type": "countdown",
        "description": "AI gives a sentence, you continue the story, AI continues again. Keep it going.",
        "xp": 25,
        "difficulty": "bronze",
        "icon": "ti-books",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "zero_filler_minute",
        "title": "Zero-filler minute",
        "zone": "speed",
        "requires_voice": True,
        "timer_seconds": 60,
        "timer_type": "countdown",
        "description": "Talk for 60 seconds with zero um/uh. Every filler resets your combo.",
        "xp": 30,
        "difficulty": "silver",
        "icon": "ti-target-arrow",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },

    # ---- VOICE: Social zone ----
    {
        "id": "streak_squad",
        "title": "Streak squad",
        "zone": "social",
        "requires_voice": True,
        "timer_seconds": None,
        "timer_type": "none",
        "description": "Join a group of 3-5 learners. Everyone must speak today or the squad streak breaks.",
        "xp": 15,
        "difficulty": "bronze",
        "icon": "ti-users-group",
        "in_daily_rotation": False,
        "has_mood_checkin": False,
    },
    {
        "id": "topic_duel",
        "title": "Topic duel",
        "zone": "social",
        "requires_voice": True,
        "timer_seconds": 60,
        "timer_type": "countdown",
        "description": "You and a friend answer the same prompt separately. Compare recordings after.",
        "xp": 20,
        "difficulty": "bronze",
        "icon": "ti-swords",
        "in_daily_rotation": False,
        "has_mood_checkin": False,
    },

    # ---- VOICE: Boss battles (rare, gated) ----
    {
        "id": "interruption_test",
        "title": "The interruption test",
        "zone": "boss",
        "requires_voice": True,
        "timer_seconds": 180,
        "timer_type": "countdown",
        "description": "All 4 personas. 3 interruptions to recover from, live.",
        "xp": 120,
        "difficulty": "gold",
        "icon": "ti-swords",
        "in_daily_rotation": False,
        "has_mood_checkin": True,
        "unlock": "weekly",
    },
    {
        "id": "persona_gauntlet",
        "title": "Random persona gauntlet",
        "zone": "boss",
        "requires_voice": True,
        "timer_seconds": 240,
        "timer_type": "countdown",
        "description": "4 unscripted questions, one from each AI persona, back to back.",
        "xp": 100,
        "difficulty": "gold",
        "icon": "ti-crown",
        "in_daily_rotation": False,
        "has_mood_checkin": True,
        "unlock": "weekly",
    },

    # ---- QUIET: no voice required ----
    {
        "id": "word_race",
        "title": "Word race",
        "zone": "quiet",
        "requires_voice": False,
        "timer_seconds": 30,
        "timer_type": "countdown",
        "description": "A category appears. Type as many matching words as you can before time runs out.",
        "xp": 10,
        "difficulty": "bronze",
        "icon": "ti-keyboard",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "listen_and_order",
        "title": "Listen and order",
        "zone": "quiet",
        "requires_voice": False,
        "timer_seconds": None,
        "timer_type": "none",
        "description": "Hear 3 short clips out of order. Drag them into the correct sequence.",
        "xp": 10,
        "difficulty": "bronze",
        "icon": "ti-arrows-sort",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "fill_the_gap",
        "title": "Fill the gap",
        "zone": "quiet",
        "requires_voice": False,
        "timer_seconds": None,
        "timer_type": "none",
        "description": "A sentence appears with a blank. Tap the word that fits.",
        "xp": 8,
        "difficulty": "bronze",
        "icon": "ti-forms",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "emoji_translate",
        "title": "Emoji translate",
        "zone": "quiet",
        "requires_voice": False,
        "timer_seconds": None,
        "timer_type": "none",
        "description": "A sentence in emojis appears. Type what it means in English.",
        "xp": 8,
        "difficulty": "bronze",
        "icon": "ti-mood-smile",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
    {
        "id": "mistake_hunt",
        "title": "Mistake hunt",
        "zone": "quiet",
        "requires_voice": False,
        "timer_seconds": None,
        "timer_type": "none",
        "description": "A paragraph has 3 hidden grammar errors. Tap to find and fix them.",
        "xp": 10,
        "difficulty": "bronze",
        "icon": "ti-search",
        "in_daily_rotation": True,
        "has_mood_checkin": False,
    },
]

# Daily voice rotation for the timer slot — cycles so each day trains a
# different skill without repeating the same format two days in a row.
DAILY_VOICE_ROTATION: List[str] = ["show_and_tell", "one_breath", "story_chain", "zero_filler_minute"]

# Quiet-mode nudge: after this many quiet challenges in a row, prompt the
# user back toward a voice challenge instead of letting quiet mode replace
# voice practice entirely.
QUIET_MODE_NUDGE_THRESHOLD = 2
QUIET_MODE_NUDGE_MESSAGE = "Ready to say it out loud?"

# XP cap quiet-mode challenges can contribute per day, so a user can't rank
# up purely on quiet games — keeps voice practice as the primary path.
QUIET_MODE_DAILY_XP_CAP = 30


# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

def get_challenge(challenge_id: str) -> Optional[Dict[str, Any]]:
    for c in CHALLENGES:
        if c["id"] == challenge_id:
            return c
    return None


def get_challenges_by_zone(zone_id: str) -> List[Dict[str, Any]]:
    return [c for c in CHALLENGES if c["zone"] == zone_id]


def get_quiet_mode_challenges() -> List[Dict[str, Any]]:
    return [c for c in CHALLENGES if not c["requires_voice"]]


def get_voice_challenges() -> List[Dict[str, Any]]:
    return [c for c in CHALLENGES if c["requires_voice"]]


def get_boss_battles() -> List[Dict[str, Any]]:
    return get_challenges_by_zone("boss")


def get_daily_challenge(date: Optional[datetime.date] = None) -> Dict[str, Any]:
    """Deterministic daily pick from the voice rotation — same challenge for
    all users on a given date, so it can double as a shared daily ritual."""
    date = date or datetime.date.today()
    index = date.toordinal() % len(DAILY_VOICE_ROTATION)
    return get_challenge(DAILY_VOICE_ROTATION[index]) or CHALLENGES[0]


def get_rank(xp: int) -> Dict[str, Any]:
    current = RANKS[0]
    for r in RANKS:
        if xp >= r["min_xp"]:
            current = r
    return current


def get_rank_progress(xp: int) -> Dict[str, Any]:
    """Returns current rank, next rank, and progress fraction toward it —
    everything the XP bar in the UI needs."""
    ranks_sorted = sorted(RANKS, key=lambda r: r["min_xp"])
    current = ranks_sorted[0]
    nxt = None
    for i, r in enumerate(ranks_sorted):
        if xp >= r["min_xp"]:
            current = r
            nxt = ranks_sorted[i + 1] if i + 1 < len(ranks_sorted) else None
    if nxt is None:
        return {"current": current, "next": None, "xp": xp, "progress": 1.0}
    span = nxt["min_xp"] - current["min_xp"]
    progress = (xp - current["min_xp"]) / span if span else 1.0
    return {"current": current, "next": nxt, "xp": xp, "progress": round(progress, 2)}


def should_nudge_to_voice(recent_quiet_streak: int) -> bool:
    """recent_quiet_streak = consecutive quiet-mode challenges completed
    without a voice challenge in between."""
    return recent_quiet_streak >= QUIET_MODE_NUDGE_THRESHOLD


def cap_quiet_xp(xp_earned_today_quiet: int) -> int:
    """Apply the daily quiet-mode XP cap."""
    return min(xp_earned_today_quiet, QUIET_MODE_DAILY_XP_CAP)
