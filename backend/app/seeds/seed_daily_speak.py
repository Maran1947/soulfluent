import logging
from datetime import date, timedelta
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.daily_speak_topic import DailySpeakTopic

logger = logging.getLogger(__name__)

INIT_DAILY_SPEAK_SQL = [
    "CREATE SCHEMA IF NOT EXISTS daily_speak;",
    """CREATE TABLE IF NOT EXISTS daily_speak.topics (
    id UUID PRIMARY KEY,
    topic VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500) DEFAULT '',
    category VARCHAR(100) DEFAULT 'General',
    scheduled_date DATE,
    duration_seconds INT DEFAULT 60,
    talking_points JSONB DEFAULT '[]'::jsonb,
    starter_phrases JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS daily_speak.user_daily_speaks (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES daily_speak.topics(id) ON DELETE SET NULL,
    session_id UUID REFERENCES conversation.sessions(id) ON DELETE SET NULL,
    completed_at_date TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_user_daily_speak_date UNIQUE (user_id, completed_at_date)
);""",
]

DEFAULT_SEED_TOPICS = [
    {
        "topic": "Would you rather work from home or from an office?",
        "subtitle": "Share your thoughts on productivity, work-life balance, and collaboration.",
        "category": "Career & Work",
        "duration_seconds": 60,
        "talking_points": [
            "Remote work saves daily commute time and offers flexible hours",
            "In-office environments foster faster team collaboration and spontaneous bonding",
            "A hybrid model combines the best aspects of flexibility and human connection",
        ],
        "starter_phrases": [
            "In my experience, working from home...",
            "While office collaboration is essential, I believe...",
            "The main reason I prefer...",
            "On the balance, a hybrid approach...",
        ],
    },
    {
        "topic": "Should artificial intelligence replace traditional written exams?",
        "subtitle": "Discuss how AI assessments could shape the future of education.",
        "category": "Technology & Education",
        "duration_seconds": 60,
        "talking_points": [
            "AI can provide adaptive, personalized feedback in real-time",
            "Traditional exams test memory retention rather than practical problem solving",
            "Human oversight remains vital to ensure fairness, empathy, and ethical standards",
        ],
        "starter_phrases": [
            "From my point of view, AI in education...",
            "One major argument in favor of this is...",
            "However, we should not overlook the importance of...",
            "Overall, I think the ideal approach is...",
        ],
    },
    {
        "topic": "Is social media doing more harm than good to personal relationships?",
        "subtitle": "Evaluate digital connectivity versus real-world presence.",
        "category": "Society & Lifestyle",
        "duration_seconds": 60,
        "talking_points": [
            "Social media keeps long-distance friends and families connected",
            "Excessive screen time reduces meaningful, face-to-face conversations",
            "Curated online personas can create unrealistic social expectations",
        ],
        "starter_phrases": [
            "I personally feel that social media...",
            "Although it connects people globally...",
            "A key issue worth considering is...",
            "To build genuine relationships, we need to...",
        ],
    },
    {
        "topic": "What is the single most valuable habit for personal success?",
        "subtitle": "Reflect on consistency, continuous learning, time management, or health.",
        "category": "Personal Growth",
        "duration_seconds": 60,
        "talking_points": [
            "Consistency over intensity yields sustainable long-term results",
            "Daily reading and active listening expand perspectives",
            "Prioritizing physical and mental well-being fuels high performance",
        ],
        "starter_phrases": [
            "If I had to choose one key habit...",
            "What has worked best for me is...",
            "Many successful people emphasize...",
            "In conclusion, cultivating this habit...",
        ],
    },
]


async def seed_daily_speak(db: AsyncSession) -> None:
    """Creates daily_speak schema, tables, and populates initial topics."""
    for stmt in INIT_DAILY_SPEAK_SQL:
        try:
            await db.execute(text(stmt))
            await db.commit()
        except Exception as e:
            await db.rollback()
            logger.warning(f"Error executing daily_speak SQL statement: {e}")

    # Check existing topics
    result = await db.execute(select(DailySpeakTopic))
    existing = result.scalars().all()

    today = date.today()
    if not existing:
        logger.info("Seeding initial Daily Speak topics into DB...")
        for idx, item in enumerate(DEFAULT_SEED_TOPICS):
            scheduled = today + timedelta(days=idx)
            topic_obj = DailySpeakTopic(
                topic=item["topic"],
                subtitle=item["subtitle"],
                category=item["category"],
                duration_seconds=item["duration_seconds"],
                talking_points=item["talking_points"],
                starter_phrases=item["starter_phrases"],
                scheduled_date=scheduled,
            )
            db.add(topic_obj)
        await db.commit()
        logger.info("Daily Speak topics seeded successfully.")
