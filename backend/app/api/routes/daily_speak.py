from typing import Any
from fastapi import APIRouter

router = APIRouter(prefix="/daily-speak", tags=["Daily Speak"])


@router.get("/today")
async def get_daily_speak_today() -> dict[str, Any]:
    """Return hardcoded today's topic and weekly progress for Daily Speak."""
    return {
        "id": "ds_today_1",
        "topic": "Would you rather work from home or from an office?",
        "subtitle": "Share your thoughts and reasons.",
        "duration_seconds": 60,
        "streak_days": 4,
        "completed_days_count": 4,
        "total_days_count": 7,
        "weekly_progress": [
            {"day": "M", "completed": True},
            {"day": "T", "completed": True},
            {"day": "W", "completed": True},
            {"day": "T", "completed": True},
            {"day": "F", "completed": False},
            {"day": "S", "completed": False},
            {"day": "S", "completed": False},
        ],
        "has_completed_today": False,
    }
