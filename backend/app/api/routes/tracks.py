from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_user, get_current_user_optional, get_db
from app.models.fluency_track import (
    ActivityStatus,
    FluencyTrack,
    FluencyTrackType,
    NodeActivity,
    Stage,
    StageNode,
    UserActivityProgress,
)
from app.models.user import User
from app.schemas.fluency_track import (
    ActivityProgressCreateRequest,
    FluencyTrackOut,
    FluencyTracksLibraryOut,
    NodeActivityOut,
    StageNodeOut,
    StageOut,
    UserActivityProgressOut,
)

router = APIRouter(prefix="/tracks", tags=["tracks"])


@router.get("", response_model=FluencyTracksLibraryOut)
async def get_tracks(
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_current_user_optional),
):
    query = (
        select(FluencyTrack)
        .where(FluencyTrack.is_active.is_(True))
        .order_by(FluencyTrack.sequence)
        .options(
            selectinload(FluencyTrack.stages)
            .selectinload(Stage.nodes)
            .selectinload(StageNode.activities)
        )
    )
    result = await db.execute(query)
    tracks = result.scalars().all()

    user_progress_map = {}
    completed_ids = []

    if current_user:
        prog_query = select(UserActivityProgress).where(
            UserActivityProgress.user_id == current_user.id
        )
        prog_result = await db.execute(prog_query)
        progresses = prog_result.scalars().all()
        for p in progresses:
            user_progress_map[p.node_activity_id] = p
            if p.status == ActivityStatus.completed:
                completed_ids.append(p.node_activity_id)

    tracks_out: list[FluencyTrackOut] = []
    for track in tracks:
        stages_out: list[StageOut] = []
        track_total_nodes = 0
        track_completed_nodes = 0

        for stage in track.stages:
            if not stage.is_active:
                continue
            nodes_out: list[StageNodeOut] = []
            stage_total_activities = 0
            stage_completed_activities = 0

            for node in stage.nodes:
                if not node.is_active:
                    continue
                track_total_nodes += 1
                activities_out: list[NodeActivityOut] = []
                node_total_act = 0
                node_comp_act = 0

                for act in node.activities:
                    if not act.is_active:
                        continue
                    node_total_act += 1
                    p_out = None
                    if act.id in user_progress_map:
                        p_obj = user_progress_map[act.id]
                        p_out = UserActivityProgressOut.model_validate(p_obj)
                        if p_obj.status == ActivityStatus.completed:
                            node_comp_act += 1

                    activities_out.append(
                        NodeActivityOut(
                            id=act.id,
                            stage_node_id=act.stage_node_id,
                            sequence=act.sequence,
                            title=act.title or "",
                            activity_type=act.activity_type,
                            config=act.config,
                            is_required=act.is_required,
                            is_active=act.is_active,
                            progress=p_out,
                        )
                    )

                stage_total_activities += node_total_act
                stage_completed_activities += node_comp_act

                node_status = "AVAILABLE"
                if node_total_act > 0:
                    if node_comp_act == node_total_act:
                        node_status = "COMPLETED"
                        track_completed_nodes += 1
                    elif node_comp_act > 0:
                        node_status = "IN_PROGRESS"

                nodes_out.append(
                    StageNodeOut(
                        id=node.id,
                        stage_id=node.stage_id,
                        sequence=node.sequence,
                        name=node.name or f"Node {node.sequence}",
                        slug=node.slug or f"node-{node.sequence}",
                        description=node.description or "",
                        cefr_min=node.cefr_min or "A1",
                        cefr_max=node.cefr_max or "C2",
                        learning_goal=node.learning_goal or "",
                        primary_skill=node.primary_skill or "",
                        estimated_minutes=node.estimated_minutes,
                        is_active=node.is_active,
                        status=node_status,
                        completed_activities=node_comp_act,
                        total_activities=node_total_act,
                        activities=activities_out,
                    )
                )

            stage_pct = (
                round((stage_completed_activities / stage_total_activities) * 100.0, 2)
                if stage_total_activities > 0
                else 0.0
            )

            stages_out.append(
                StageOut(
                    id=stage.id,
                    fluency_track_id=stage.fluency_track_id,
                    name=stage.name,
                    slug=stage.slug or f"stage-{stage.sequence}",
                    description=stage.description or "",
                    cefr_min=stage.cefr_min or "A1",
                    cefr_max=stage.cefr_max or "C2",
                    primary_goals=stage.primary_goals or [],
                    sequence=stage.sequence,
                    is_active=stage.is_active,
                    completed_activities=stage_completed_activities,
                    total_activities=stage_total_activities,
                    percentage=stage_pct,
                    nodes=nodes_out,
                )
            )

        track_pct = (
            round((track_completed_nodes / track_total_nodes) * 100.0, 2)
            if track_total_nodes > 0
            else 0.0
        )

        tracks_out.append(
            FluencyTrackOut(
                id=track.id,
                name=track.name,
                slug=track.slug or "track",
                type=track.type,
                description=track.description or "",
                cefr_min=track.cefr_min or "A1",
                cefr_max=track.cefr_max or "C2",
                sequence=track.sequence,
                is_active=track.is_active,
                completed_nodes=track_completed_nodes,
                total_nodes=track_total_nodes,
                percentage=track_pct,
                stages=stages_out,
            )
        )

    first_track_id = tracks_out[0].id if tracks_out else None

    return FluencyTracksLibraryOut(
        tracks=tracks_out,
        current_track_id=first_track_id,
        completed_activity_ids=completed_ids,
    )


@router.get("/nodes/{node_id}", response_model=StageNodeOut)
async def get_node_details(
    node_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_current_user_optional),
):
    query = (
        select(StageNode).where(StageNode.id == node_id).options(selectinload(StageNode.activities))
    )
    result = await db.execute(query)
    node = result.scalar_one_or_none()
    if not node:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Stage node not found")

    user_progress_map = {}
    if current_user:
        act_ids = [act.id for act in node.activities]
        if act_ids:
            prog_query = select(UserActivityProgress).where(
                UserActivityProgress.user_id == current_user.id,
                UserActivityProgress.node_activity_id.in_(act_ids),
            )
            prog_result = await db.execute(prog_query)
            for p in prog_result.scalars().all():
                user_progress_map[p.node_activity_id] = p

    activities_out = []
    node_total_act = 0
    node_comp_act = 0

    for act in node.activities:
        if not act.is_active:
            continue
        node_total_act += 1
        p_out = None
        if act.id in user_progress_map:
            p_obj = user_progress_map[act.id]
            p_out = UserActivityProgressOut.model_validate(p_obj)
            if p_obj.status == ActivityStatus.completed:
                node_comp_act += 1

        activities_out.append(
            NodeActivityOut(
                id=act.id,
                stage_node_id=act.stage_node_id,
                sequence=act.sequence,
                title=act.title or "",
                activity_type=act.activity_type,
                config=act.config,
                is_required=act.is_required,
                is_active=act.is_active,
                progress=p_out,
            )
        )

    node_status = "AVAILABLE"
    if node_total_act > 0:
        if node_comp_act == node_total_act:
            node_status = "COMPLETED"
        elif node_comp_act > 0:
            node_status = "IN_PROGRESS"

    return StageNodeOut(
        id=node.id,
        stage_id=node.stage_id,
        sequence=node.sequence,
        name=node.name or f"Node {node.sequence}",
        slug=node.slug or f"node-{node.sequence}",
        description=node.description or "",
        cefr_min=node.cefr_min or "A1",
        cefr_max=node.cefr_max or "C2",
        learning_goal=node.learning_goal or "",
        primary_skill=node.primary_skill or "",
        estimated_minutes=node.estimated_minutes,
        is_active=node.is_active,
        status=node_status,
        completed_activities=node_comp_act,
        total_activities=node_total_act,
        activities=activities_out,
    )


@router.post("/activities/{activity_id}/progress", response_model=UserActivityProgressOut)
async def submit_activity_progress(
    activity_id: UUID,
    payload: ActivityProgressCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    act_query = select(NodeActivity).where(NodeActivity.id == activity_id)
    act_res = await db.execute(act_query)
    activity = act_res.scalar_one_or_none()
    if not activity:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Activity not found")

    prog_query = select(UserActivityProgress).where(
        UserActivityProgress.user_id == current_user.id,
        UserActivityProgress.node_activity_id == activity_id,
    )
    prog_res = await db.execute(prog_query)
    progress = prog_res.scalar_one_or_none()

    now = datetime.utcnow()
    if not progress:
        progress = UserActivityProgress(
            user_id=current_user.id,
            node_activity_id=activity_id,
            status=payload.status,
            score=payload.score,
            attempt_count=1,
            response_data=payload.response_data,
            started_at=now,
            completed_at=now if payload.status == ActivityStatus.completed else None,
            last_attempted_at=now,
        )
        db.add(progress)
    else:
        progress.attempt_count += 1
        progress.status = payload.status
        progress.score = payload.score
        progress.response_data = payload.response_data
        progress.last_attempted_at = now
        if payload.status == ActivityStatus.completed and not progress.completed_at:
            progress.completed_at = now

    await db.commit()
    await db.refresh(progress)

    return UserActivityProgressOut.model_validate(progress)


@router.get("/progress", response_model=list[UserActivityProgressOut])
async def get_user_progress(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = select(UserActivityProgress).where(UserActivityProgress.user_id == current_user.id)
    res = await db.execute(query)
    progresses = res.scalars().all()
    return [UserActivityProgressOut.model_validate(p) for p in progresses]


# Compatibility routes for legacy /curriculum endpoint calls
curriculum_router = APIRouter(prefix="/curriculum", tags=["curriculum"])


@curriculum_router.get("", include_in_schema=False)
@curriculum_router.get("/", include_in_schema=False)
async def get_curriculum_legacy(
    track: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_current_user_optional),
):
    tracks_out = await get_tracks(db=db, current_user=current_user)
    res_dict = tracks_out.model_dump()

    target_track = None
    if track:
        tr_norm = track.strip().upper()
        for t in tracks_out.tracks:
            t_type_str = t.type.value.upper() if hasattr(t.type, "value") else str(t.type).upper()
            t_slug_str = (t.slug or "").upper()
            if tr_norm in ["B", "SCRATCH"] and (t_type_str == "SCRATCH" or t_slug_str == "SCRATCH"):
                target_track = t
                break
            elif tr_norm in ["A", "UNFREEZE"] and (t_type_str == "UNFREEZE" or t_slug_str == "UNFREEZE"):
                target_track = t
                break
            elif tr_norm == t_slug_str or tr_norm == t_type_str or tr_norm == str(t.id).upper():
                target_track = t
                break

    if not target_track:
        for t in tracks_out.tracks:
            t_type_str = t.type.value.upper() if hasattr(t.type, "value") else str(t.type).upper()
            if t_type_str == "UNFREEZE":
                target_track = t
                break
        if not target_track and tracks_out.tracks:
            target_track = tracks_out.tracks[0]

    weeks = []
    global_day_counter = 1
    personas_map = {
        "riya": {
            "name": "Riya",
            "initial": "R",
            "color": "#FF8B5E",
            "sub": "Fluency Coach",
            "flag": "🇮🇳",
        },
        "rohan": {
            "name": "Rohan",
            "initial": "R",
            "color": "#4A90E2",
            "sub": "Structure Coach",
            "flag": "🇮🇳",
        },
        "emily": {
            "name": "Emily",
            "initial": "E",
            "color": "#50E3C2",
            "sub": "Spontaneity Coach",
            "flag": "🇬🇧",
        },
        "alex": {
            "name": "Alex",
            "initial": "A",
            "color": "#B8E986",
            "sub": "Debate Coach",
            "flag": "🇺🇸",
        },
    }

    if target_track:
        for stage in target_track.stages:
            days = []
            for node in stage.nodes:
                persona_key = "riya"
                if stage.sequence in [3, 4]:
                    persona_key = "rohan"
                elif stage.sequence in [5, 6, 7, 8]:
                    persona_key = "emily"
                elif stage.sequence in [9, 10, 11, 12]:
                    persona_key = "alex"

                activities_payload = []
                phrases_a = []
                phrases_b = []
                rescue_phrases = []
                ai_line = None

                for act in node.activities:
                    act_type_str = act.activity_type.value if hasattr(act.activity_type, "value") else str(act.activity_type)
                    cfg = act.config or {}
                    activities_payload.append(
                        {
                            "id": str(act.id),
                            "sequence": act.sequence,
                            "title": act.title,
                            "type": act_type_str,
                            "config": cfg,
                        }
                    )

                    if not ai_line and cfg.get("instruction"):
                        ai_line = cfg.get("instruction")

                    content = cfg.get("content", {})
                    if isinstance(content, dict):
                        if "items" in content:
                            for it in content["items"]:
                                if isinstance(it, dict):
                                    val = it.get("example") or it.get("word") or it.get("phrase")
                                    if val and val not in phrases_a:
                                        phrases_a.append(val)
                        if "sentence_starters" in content:
                            for st in content["sentence_starters"]:
                                if isinstance(st, str) and st not in phrases_b:
                                    phrases_b.append(st)
                        if "prompts" in content:
                            for pr in content["prompts"]:
                                if isinstance(pr, str) and pr not in phrases_b:
                                    phrases_b.append(pr)
                                elif isinstance(pr, dict):
                                    text_val = pr.get("text") or pr.get("prompt")
                                    if text_val and text_val not in phrases_b:
                                        phrases_b.append(text_val)

                if not phrases_a:
                    phrases_a = [f"Let's practice {node.name}.", f"Focus on core expressions for {node.name}."]
                if not phrases_b:
                    phrases_b = [f"In my opinion...", f"I think..."]
                if not rescue_phrases:
                    rescue_phrases = ["Give me a sec...", "Let me think about that...", "How do I say this..."]

                node_instruction = node.learning_goal or node.description or f"Complete activities for {node.name}."
                if not ai_line:
                    ai_line = f"Let's practice {node.name}. Focus on flow and speed."

                days.append(
                    {
                        "id": str(node.id),
                        "d": global_day_counter,
                        "unit": global_day_counter,
                        "theme": node.name or f"Node {node.sequence}",
                        "persona": persona_key,
                        "mode": "foundation",
                        "aiLine": ai_line,
                        "instruction": node_instruction,
                        "phrasesA": phrases_a,
                        "phrasesB": phrases_b,
                        "rescuePhrases": rescue_phrases,
                        "script": [f"{persona_key.capitalize()}: Ready to practice {node.name}?", f"You: Yes, let's start!"],
                        "wpm": 80 + (stage.sequence * 3),
                        "filler": "≤5/min",
                        "milestoneReport": (node.sequence == len(stage.nodes)),
                        "graduatesToTrackA": False,
                        "activities": activities_payload,
                    }
                )
                global_day_counter += 1

            weeks.append(
                {
                    "title": stage.name,
                    "range": f"Nodes 1–{len(stage.nodes)}",
                    "days": days,
                }
            )

    res_dict["weeks"] = weeks
    res_dict["personas"] = personas_map
    return res_dict


@curriculum_router.get("/progress", include_in_schema=False)
async def get_curriculum_progress_legacy():
    return {
        "current_day": 1,
        "streak_days": 0,
        "active_track": "UNFREEZE",
        "review_mode": False,
        "completed_days": [],
    }


@curriculum_router.post("/progress", include_in_schema=False)
async def update_curriculum_progress_legacy():
    return {
        "current_day": 1,
        "streak_days": 0,
        "active_track": "UNFREEZE",
        "review_mode": False,
        "completed_days": [],
    }
