import asyncio
import logging
from typing import Any

from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import AsyncSessionLocal
from app.models.fluency_track import (
    ActivityType,
    FluencyTrack,
    FluencyTrackType,
    NodeActivity,
    Stage,
    StageNode,
)

logger = logging.getLogger(__name__)

INIT_SQL_STATEMENTS = [
    "CREATE SCHEMA IF NOT EXISTS fluency;",
    """DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'fluency_track_type_enum' AND n.nspname = 'fluency') THEN
        CREATE TYPE fluency.fluency_track_type_enum AS ENUM ('UNFREEZE', 'SCRATCH');
    END IF;
END $$;""",
    """DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'activity_type_enum' AND n.nspname = 'fluency') THEN
        CREATE TYPE fluency.activity_type_enum AS ENUM (
            'lesson', 'express_image', 'express_video', 'forming_sentence',
            'echo_repeat', 'word_picture_match', 'tpr_command', 'listen_select',
            'fill_blank', 'sentence_correction', 'dictation', 'shadow_speaking',
            'roleplay', 'free_response', 'debate', 'rescue_phrase_drill',
            'interruption', 'listen_and_order', 'quiz'
        );
    END IF;
END $$;""",
    """DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'activity_status_enum' AND n.nspname = 'fluency') THEN
        CREATE TYPE fluency.activity_status_enum AS ENUM ('not_started', 'in_progress', 'completed');
    END IF;
END $$;""",
    """CREATE TABLE IF NOT EXISTS fluency.tracks (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type fluency.fluency_track_type_enum NOT NULL DEFAULT 'UNFREEZE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.stages (
    id UUID PRIMARY KEY,
    fluency_track_id UUID NOT NULL REFERENCES fluency.tracks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sequence INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.stage_nodes (
    id UUID PRIMARY KEY,
    stage_id UUID NOT NULL REFERENCES fluency.stages(id) ON DELETE CASCADE,
    sequence INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.node_activities (
    id UUID PRIMARY KEY,
    stage_node_id UUID NOT NULL REFERENCES fluency.stage_nodes(id) ON DELETE CASCADE,
    activity_type fluency.activity_type_enum NOT NULL,
    config JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.user_activity_progress (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    node_activity_id UUID NOT NULL REFERENCES fluency.node_activities(id) ON DELETE CASCADE,
    status fluency.activity_status_enum NOT NULL DEFAULT 'not_started',
    score DOUBLE PRECISION DEFAULT 0.0,
    response_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_user_node_activity UNIQUE (user_id, node_activity_id)
);""",
]

INITIAL_TRACKS: list[dict[str, Any]] = [
    {
        "name": "Unfreeze & Confidence",
        "type": FluencyTrackType.UNFREEZE,
        "stages": [
            {
                "name": "Stage 1: Icebreakers & Daily Routines",
                "sequence": 1,
                "nodes": [
                    {
                        "sequence": 1,
                        "activities": [
                            {
                                "type": ActivityType.lesson,
                                "config": {
                                    "title": "Welcome to FluentSoul",
                                    "instruction": "Learn how to speak naturally without freezing under pressure.",
                                    "script": [
                                        "Hello and welcome! In this track, you will unlock spontaneous speech.",
                                        "Don't worry about perfect grammar. Focus on momentum and flow.",
                                    ],
                                    "target_wpm": 90,
                                },
                            },
                            {
                                "type": ActivityType.echo_repeat,
                                "config": {
                                    "title": "Echo Practice - Self Intro",
                                    "phrases": [
                                        "Hi, I'm excited to practice English with you today!",
                                        "Actually, let me clarify what I mean by that.",
                                        "To be completely honest, I'm working on my fluency.",
                                    ],
                                },
                            },
                            {
                                "type": ActivityType.forming_sentence,
                                "config": {
                                    "title": "Build a Response",
                                    "prompt": "Arrange words to state your main goal.",
                                    "words": ["I", "want", "to", "speak", "english", "confidently"],
                                    "correct_sentence": "I want to speak english confidently",
                                },
                            },
                            {
                                "type": ActivityType.express_image,
                                "config": {
                                    "title": "Express Image - Morning Coffee",
                                    "image_url": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd",
                                    "prompt": "Describe what you see in 30 seconds without pausing.",
                                },
                            },
                        ],
                    },
                    {
                        "sequence": 2,
                        "activities": [
                            {
                                "type": ActivityType.rescue_phrase_drill,
                                "config": {
                                    "title": "Rescue Phrase Drill",
                                    "rescue_phrases": [
                                        "Let me rephrase that...",
                                        "What I mean to say is...",
                                        "Give me a moment to gather my thoughts...",
                                    ],
                                },
                            },
                            {
                                "type": ActivityType.roleplay,
                                "config": {
                                    "title": "Coffee Shop Order",
                                    "persona": "riya",
                                    "scenario": "Ordering an oat milk latte with custom modifications.",
                                    "ai_opening": "Hey there! What can I get started for you today?",
                                },
                            },
                            {
                                "type": ActivityType.quiz,
                                "config": {
                                    "title": "Quick Knowledge Check",
                                    "question": "Which phrase is best when you forget a word?",
                                    "options": [
                                        "Let me rephrase that",
                                        "I stop talking forever",
                                        "Silence is golden",
                                    ],
                                    "correct_index": 0,
                                },
                            },
                        ],
                    },
                ],
            },
            {
                "name": "Stage 2: Spontaneous Opinions",
                "sequence": 2,
                "nodes": [
                    {
                        "sequence": 1,
                        "activities": [
                            {
                                "type": ActivityType.shadow_speaking,
                                "config": {
                                    "title": "Shadowing Speed Speaking",
                                    "text": "In my perspective, hybrid work offers the perfect balance between focus and collaboration.",
                                    "target_wpm": 110,
                                },
                            },
                            {
                                "type": ActivityType.debate,
                                "config": {
                                    "title": "Mini Debate: Remote vs Office Work",
                                    "persona": "arjun",
                                    "topic": "Is working from home better than working from office?",
                                    "ai_opening": "I believe working in the office builds team culture much faster. What's your take?",
                                },
                            },
                        ],
                    }
                ],
            },
        ],
    },
    {
        "name": "From Scratch Beginner",
        "type": FluencyTrackType.SCRATCH,
        "stages": [
            {
                "name": "Stage 1: Basic Conversations",
                "sequence": 1,
                "nodes": [
                    {
                        "sequence": 1,
                        "activities": [
                            {
                                "type": ActivityType.listen_select,
                                "config": {
                                    "title": "Listen & Select",
                                    "audio_text": "Could you please pass the water?",
                                    "options": ["Pass water", "Open door", "Close window"],
                                    "correct_index": 0,
                                },
                            },
                            {
                                "type": ActivityType.fill_blank,
                                "config": {
                                    "title": "Fill in the Blank",
                                    "sentence": "She ___ to the store yesterday.",
                                    "options": ["went", "go", "going"],
                                    "correct_option": "went",
                                },
                            },
                        ],
                    }
                ],
            }
        ],
    },
]


async def seed_fluency_tracks(db: AsyncSession) -> None:
    # Ensure tables exist
    for stmt in INIT_SQL_STATEMENTS:
        try:
            await db.execute(text(stmt))
            await db.commit()
        except Exception as e:
            logger.debug(f"Statement execution note: {e}")

    # Check if tracks already exist
    try:
        existing = await db.execute(select(FluencyTrack))
        if existing.scalars().first():
            logger.info("Fluency tracks already seeded.")
            return
    except Exception as e:
        logger.info(f"Querying fluency tracks: {e}")

    logger.info("Seeding initial Fluency Tracks...")
    for t_data in INITIAL_TRACKS:
        track = FluencyTrack(
            name=str(t_data["name"]),
            type=t_data["type"],
            is_active=True,
        )
        db.add(track)
        await db.flush()

        stages: list[dict[str, Any]] = t_data.get("stages", [])
        for s_data in stages:
            stage = Stage(
                fluency_track_id=track.id,
                name=str(s_data["name"]),
                sequence=int(s_data["sequence"]),
                is_active=True,
            )
            db.add(stage)
            await db.flush()

            nodes: list[dict[str, Any]] = s_data.get("nodes", [])
            for n_data in nodes:
                node = StageNode(
                    stage_id=stage.id,
                    sequence=int(n_data["sequence"]),
                    is_active=True,
                )
                db.add(node)
                await db.flush()

                activities: list[dict[str, Any]] = n_data.get("activities", [])
                for a_data in activities:
                    act = NodeActivity(
                        stage_node_id=node.id,
                        activity_type=a_data["type"],
                        config=a_data.get("config", {}),
                        is_active=True,
                    )
                    db.add(act)

    await db.commit()
    logger.info("Successfully seeded Fluency Tracks!")


if __name__ == "__main__":

    async def main():
        async with AsyncSessionLocal() as db:
            await seed_fluency_tracks(db)

    asyncio.run(main())
