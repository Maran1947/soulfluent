from typing import Any
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_optional
from app.database import get_db
from app.models.user import User
from app.services.daily_speak_service import (
    ensure_topic_scaffolding_llm,
    get_today_topic_from_db,
    get_user_daily_speak_stats,
)

router = APIRouter(prefix="/daily-speak", tags=["Daily Speak"])


@router.get("/today")
async def get_daily_speak_today(
    current_user: User | None = Depends(get_current_user_optional),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Return today's DB topic, LLM starter scaffolding, and dynamic user streaks."""
    topic_obj = await get_today_topic_from_db(db)
    talking_points, starter_phrases = await ensure_topic_scaffolding_llm(topic_obj)

    user_id = current_user.id if current_user else None
    user_stats = await get_user_daily_speak_stats(db, user_id)

    return {
        "id": str(topic_obj.id),
        "topic": topic_obj.topic,
        "subtitle": topic_obj.subtitle,
        "category": topic_obj.category,
        "duration_seconds": topic_obj.duration_seconds,
        "talking_points": talking_points,
        "starter_phrases": starter_phrases,
        **user_stats,
    }
