import asyncio
import json
import logging
from pathlib import Path
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
    "DELETE FROM fluency.tracks WHERE type::text NOT IN ('UNFREEZE', 'SCRATCH');",
    "DELETE FROM fluency.tracks WHERE slug NOT IN ('scratch', 'unfreeze');",
    """CREATE TABLE IF NOT EXISTS fluency.tracks (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) DEFAULT 'track',
    type fluency.fluency_track_type_enum NOT NULL DEFAULT 'UNFREEZE',
    description TEXT DEFAULT '',
    cefr_min VARCHAR(10) DEFAULT 'A1',
    cefr_max VARCHAR(10) DEFAULT 'C2',
    sequence INT DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.stages (
    id UUID PRIMARY KEY,
    fluency_track_id UUID NOT NULL REFERENCES fluency.tracks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) DEFAULT 'stage',
    description TEXT DEFAULT '',
    cefr_min VARCHAR(10) DEFAULT 'A1',
    cefr_max VARCHAR(10) DEFAULT 'C2',
    primary_goals JSONB DEFAULT '[]'::jsonb,
    sequence INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.stage_nodes (
    id UUID PRIMARY KEY,
    stage_id UUID NOT NULL REFERENCES fluency.stages(id) ON DELETE CASCADE,
    name VARCHAR(150) DEFAULT '',
    slug VARCHAR(150) DEFAULT 'node',
    description TEXT DEFAULT '',
    cefr_min VARCHAR(10) DEFAULT 'A1',
    cefr_max VARCHAR(10) DEFAULT 'C2',
    learning_goal TEXT DEFAULT '',
    primary_skill VARCHAR(100) DEFAULT '',
    estimated_minutes INT DEFAULT 10,
    sequence INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);""",
    """CREATE TABLE IF NOT EXISTS fluency.node_activities (
    id UUID PRIMARY KEY,
    stage_node_id UUID NOT NULL REFERENCES fluency.stage_nodes(id) ON DELETE CASCADE,
    sequence INT DEFAULT 1,
    title VARCHAR(150) DEFAULT '',
    activity_type fluency.activity_type_enum NOT NULL,
    config JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_required BOOLEAN DEFAULT TRUE,
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
    attempt_count INT DEFAULT 1,
    response_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    last_attempted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_user_node_activity UNIQUE (user_id, node_activity_id)
);""",
]

INITIAL_TRACKS: list[dict[str, Any]] = [
    {
        "name": "From Scratch Beginner",
        "slug": "scratch",
        "type": FluencyTrackType.SCRATCH,
        "description": "Learn English from little or no prior knowledge.",
        "cefr_min": "PRE_A1",
        "cefr_max": "A2",
        "sequence": 1,
        "stages": [
            {
                "name": "Stage 1: Alphabet & Basic Words",
                "slug": "basic-words",
                "sequence": 1,
                "nodes": [
                    {
                        "name": "Greetings & Hello",
                        "slug": "greetings-hello",
                        "sequence": 1,
                        "activities": [
                            {
                                "sequence": 1,
                                "title": "Welcome to English",
                                "type": ActivityType.lesson,
                                "config": {
                                    "instruction": "Learn basic English greetings.",
                                    "phrases": ["Hello", "Good Morning", "Goodbye"],
                                },
                            },
                        ],
                    }
                ],
            }
        ],
    },
    {
        "name": "Unfreeze & Confidence",
        "slug": "unfreeze",
        "type": FluencyTrackType.UNFREEZE,
        "description": "Turn the English you know into confident, spontaneous conversation.",
        "cefr_min": "A2",
        "cefr_max": "C2",
        "sequence": 2,
        "stages": [],
    },
]

# Load UNFREEZE JSON data if present
json_path = Path(__file__).parent / "data" / "unfreeze_roadmap.json"
if json_path.exists():
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            roadmap_data = json.load(f)
            unfreeze_stages = roadmap_data.get("stages", [])
            for s in unfreeze_stages:
                for n in s.get("nodes", []):
                    for a in n.get("activities", []):
                        act_str = a.get("type", "lesson")
                        try:
                            a["type"] = ActivityType(act_str)
                        except ValueError:
                            a["type"] = ActivityType.lesson
            for t in INITIAL_TRACKS:
                if t["slug"] == "unfreeze":
                    t["stages"] = unfreeze_stages
    except Exception as exc:
        logger.error(f"Error loading unfreeze_roadmap.json: {exc}")


async def seed_fluency_tracks(db: AsyncSession) -> None:
    for stmt in INIT_SQL_STATEMENTS:
        try:
            await db.execute(text(stmt))
            await db.commit()
        except Exception as e:
            logger.debug(f"Statement execution note: {e}")

    logger.info("Seeding initial Fluency Tracks...")
    for t_data in INITIAL_TRACKS:
        res = await db.execute(select(FluencyTrack).where(FluencyTrack.slug == t_data["slug"]))
        track = res.scalars().first()
        if not track:
            track = FluencyTrack(
                name=t_data["name"],
                slug=t_data["slug"],
                type=t_data["type"],
                description=t_data.get("description", ""),
                cefr_min=t_data.get("cefr_min", "A1"),
                cefr_max=t_data.get("cefr_max", "C2"),
                sequence=t_data.get("sequence", 1),
                is_active=True,
            )
            db.add(track)
            await db.flush()
        else:
            track.name = t_data["name"]
            track.description = t_data.get("description", "")
            track.cefr_min = t_data.get("cefr_min", "A1")
            track.cefr_max = t_data.get("cefr_max", "C2")
            track.sequence = t_data.get("sequence", 1)

        stages: list[dict[str, Any]] = t_data.get("stages", [])
        for s_data in stages:
            res_s = await db.execute(
                select(Stage).where(
                    Stage.fluency_track_id == track.id,
                    Stage.sequence == s_data["sequence"],
                )
            )
            stage = res_s.scalars().first()
            if not stage:
                stage = Stage(
                    fluency_track_id=track.id,
                    name=s_data["name"],
                    slug=s_data.get("slug", f"stage-{s_data['sequence']}"),
                    description=s_data.get("description", ""),
                    cefr_min=s_data.get("cefr_min", "A1"),
                    cefr_max=s_data.get("cefr_max", "C2"),
                    primary_goals=s_data.get("primary_goals", []),
                    sequence=s_data["sequence"],
                    is_active=True,
                )
                db.add(stage)
                await db.flush()
            else:
                stage.name = s_data["name"]
                stage.slug = s_data.get("slug", stage.slug)
                stage.description = s_data.get("description", stage.description)

            nodes: list[dict[str, Any]] = s_data.get("nodes", [])
            for n_data in nodes:
                res_n = await db.execute(
                    select(StageNode).where(
                        StageNode.stage_id == stage.id,
                        StageNode.sequence == n_data["sequence"],
                    )
                )
                node = res_n.scalars().first()
                if not node:
                    node = StageNode(
                        stage_id=stage.id,
                        name=n_data.get("name", f"Node {n_data['sequence']}"),
                        slug=n_data.get("slug", f"node-{n_data['sequence']}"),
                        description=n_data.get("description", ""),
                        cefr_min=n_data.get("cefr_min", "A1"),
                        cefr_max=n_data.get("cefr_max", "C2"),
                        learning_goal=n_data.get("learning_goal", ""),
                        primary_skill=n_data.get("primary_skill", ""),
                        estimated_minutes=n_data.get("estimated_minutes", 10),
                        sequence=n_data["sequence"],
                        is_active=True,
                    )
                    db.add(node)
                    await db.flush()
                else:
                    node.name = n_data.get("name", node.name)
                    node.slug = n_data.get("slug", node.slug)

                activities: list[dict[str, Any]] = n_data.get("activities", [])
                for idx, a_data in enumerate(activities, start=1):
                    res_a = await db.execute(
                        select(NodeActivity).where(
                            NodeActivity.stage_node_id == node.id,
                            NodeActivity.sequence == a_data.get("sequence", idx),
                        )
                    )
                    act = res_a.scalars().first()
                    if not act:
                        act = NodeActivity(
                            stage_node_id=node.id,
                            sequence=a_data.get("sequence", idx),
                            title=a_data.get("title", ""),
                            activity_type=a_data["type"],
                            config=a_data.get("config", {}),
                            is_required=a_data.get("is_required", True),
                            is_active=True,
                        )
                        db.add(act)
                    else:
                        act.title = a_data.get("title", act.title)
                        act.config = a_data.get("config", act.config)

    await db.commit()
    logger.info("Successfully seeded Fluency Tracks!")


if __name__ == "__main__":

    async def main():
        async with AsyncSessionLocal() as db:
            await seed_fluency_tracks(db)

    asyncio.run(main())
