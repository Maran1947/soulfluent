import json
import logging
import uuid
from datetime import date, datetime, timedelta
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.daily_speak_topic import DailySpeakTopic
from app.models.session import Session, SessionStatus
from app.models.user_daily_speak import UserDailySpeak
from google import genai

logger = logging.getLogger(__name__)
settings = get_settings()


async def get_today_topic_from_db(db: AsyncSession) -> DailySpeakTopic:
    """Fetch today's scheduled DailySpeakTopic or fallback to the latest active topic."""
    today = date.today()
    stmt = select(DailySpeakTopic).where(DailySpeakTopic.scheduled_date == today)
    result = await db.execute(stmt)
    topic_obj = result.scalars().first()

    if not topic_obj:
        # Fallback to the first topic in DB
        stmt_fallback = select(DailySpeakTopic).order_by(DailySpeakTopic.created_at.asc())
        res_fallback = await db.execute(stmt_fallback)
        topic_obj = res_fallback.scalars().first()

    if not topic_obj:
        # Emergency in-memory fallback
        topic_obj = DailySpeakTopic(
            id=uuid.uuid4(),
            topic="Would you rather work from home or from an office?",
            subtitle="Share your thoughts and reasons.",
            category="Work & Career",
            duration_seconds=60,
            talking_points=[
                "Remote work saves daily commute time and offers flexible hours",
                "In-office environments foster faster team collaboration and spontaneous bonding",
                "A hybrid model combines the best aspects of flexibility and human connection",
            ],
            starter_phrases=[
                "In my experience, working from home...",
                "While office collaboration is essential, I believe...",
                "The main reason I prefer...",
            ],
        )
    return topic_obj


async def ensure_topic_scaffolding_llm(topic_obj: DailySpeakTopic) -> tuple[list[str], list[str]]:
    """Generates thoughts/talking points and starter phrases using Gemini if missing."""
    if topic_obj.talking_points and topic_obj.starter_phrases:
        return topic_obj.talking_points, topic_obj.starter_phrases

    try:
        client = genai.Client(api_key=settings.gemini_api_key)
        prompt = f"""
For the speaking topic: "{topic_obj.topic}" ({topic_obj.subtitle})
Provide a JSON object with:
1. "talking_points": array of 3 bullet point thoughts/perspectives to spark ideas for a speaker.
2. "starter_phrases": array of 3 opening sentence phrases to help a speaker begin speaking.

Return ONLY valid JSON.
"""
        logger.info(f"🧠 [Gemini Scaffolding] Generating talking points & starter phrases for topic: '{topic_obj.topic}'...")
        resp = await client.aio.models.generate_content(
            model=settings.gemini_text_model,
            contents=[prompt],
        )
        text_content = (resp.text or "").strip()
        if "```json" in text_content:
            text_content = text_content.split("```json")[1].split("```")[0].strip()
        data = json.loads(text_content)
        tp = data.get("talking_points", [])
        sp = data.get("starter_phrases", [])
        if tp:
            topic_obj.talking_points = tp
        if sp:
            topic_obj.starter_phrases = sp
        logger.info(f"✨ [Gemini Scaffolding Complete] Generated {len(tp)} points and {len(sp)} phrases.")
        return tp, sp
    except Exception as e:
        logger.warning(f"Error generating LLM scaffolding for topic: {e}")
        default_tp = [
            "Consider the benefits and advantages of this topic",
            "Reflect on potential challenges or counter-arguments",
            "Share a personal experience or real-world example",
        ]
        default_sp = [
            "In my opinion...",
            "One key aspect to consider is...",
            "Looking at both sides...",
        ]
        return (
            topic_obj.talking_points or default_tp,
            topic_obj.starter_phrases or default_sp,
        )


async def get_user_daily_speak_stats(
    db: AsyncSession, user_id: uuid.UUID | None
) -> dict[str, Any]:
    """Calculates user streak, weekly progress matrix (M..S), and today's completion status."""
    if not user_id:
        return {
            "streak_days": 0,
            "completed_days_count": 0,
            "total_days_count": 7,
            "weekly_progress": [
                {"day": "M", "completed": False},
                {"day": "T", "completed": False},
                {"day": "W", "completed": False},
                {"day": "T", "completed": False},
                {"day": "F", "completed": False},
                {"day": "S", "completed": False},
                {"day": "S", "completed": False},
            ],
            "has_completed_today": False,
        }

    # Fetch completed dates from UserDailySpeak and Session tables
    today = date.today()

    # Query completed user daily speaks
    stmt_uds = select(func.date(UserDailySpeak.completed_at_date)).where(
        UserDailySpeak.user_id == user_id
    )
    res_uds = await db.execute(stmt_uds)
    dates_set = set(res_uds.scalars().all())

    # Also include completed Sessions with category 'Daily Speak'
    stmt_sess = select(func.date(Session.started_at)).where(
        Session.user_id == user_id,
        Session.category == "Daily Speak",
        Session.status == SessionStatus.completed,
    )
    res_sess = await db.execute(stmt_sess)
    dates_set.update(res_sess.scalars().all())

    # Calculate streak (consecutive days ending today or yesterday)
    streak = 0
    curr_check = today
    if curr_check not in dates_set:
        curr_check = today - timedelta(days=1)

    while curr_check in dates_set:
        streak += 1
        curr_check -= timedelta(days=1)

    # Weekly progress for current week (Monday to Sunday)
    start_of_week = today - timedelta(days=today.weekday())  # Monday
    day_labels = ["M", "T", "W", "T", "F", "S", "S"]
    weekly_progress = []
    completed_this_week = 0

    for i in range(7):
        day_date = start_of_week + timedelta(days=i)
        is_completed = day_date in dates_set
        if is_completed:
            completed_this_week += 1
        weekly_progress.append(
            {
                "day": day_labels[i],
                "completed": is_completed,
            }
        )

    has_completed_today = today in dates_set

    return {
        "streak_days": streak,
        "completed_days_count": completed_this_week,
        "total_days_count": 7,
        "weekly_progress": weekly_progress,
        "has_completed_today": has_completed_today,
    }


async def log_user_daily_speak_completion(
    db: AsyncSession, user_id: uuid.UUID, session_id: uuid.UUID | None = None
) -> None:
    """Logs user completion of today's Daily Speak in the database."""
    today_dt = datetime.now()
    today_date = date.today()

    # Check if entry already exists for today
    stmt = select(UserDailySpeak).where(
        UserDailySpeak.user_id == user_id,
        func.date(UserDailySpeak.completed_at_date) == today_date,
    )
    res = await db.execute(stmt)
    existing = res.scalars().first()

    if not existing:
        log_entry = UserDailySpeak(
            id=uuid.uuid4(),
            user_id=user_id,
            session_id=session_id,
            completed_at_date=today_dt,
        )
        db.add(log_entry)
        await db.commit()
