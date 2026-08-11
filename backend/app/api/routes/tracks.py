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
        for stage in track.stages:
            if not stage.is_active:
                continue
            nodes_out: list[StageNodeOut] = []
            for node in stage.nodes:
                if not node.is_active:
                    continue
                activities_out: list[NodeActivityOut] = []
                for act in node.activities:
                    if not act.is_active:
                        continue
                    p_out = None
                    if act.id in user_progress_map:
                        p_out = UserActivityProgressOut.model_validate(user_progress_map[act.id])
                    activities_out.append(
                        NodeActivityOut(
                            id=act.id,
                            stage_node_id=act.stage_node_id,
                            activity_type=act.activity_type,
                            config=act.config,
                            is_active=act.is_active,
                            progress=p_out,
                        )
                    )
                nodes_out.append(
                    StageNodeOut(
                        id=node.id,
                        stage_id=node.stage_id,
                        sequence=node.sequence,
                        is_active=node.is_active,
                        activities=activities_out,
                    )
                )
            stages_out.append(
                StageOut(
                    id=stage.id,
                    fluency_track_id=stage.fluency_track_id,
                    name=stage.name,
                    sequence=stage.sequence,
                    is_active=stage.is_active,
                    nodes=nodes_out,
                )
            )
        tracks_out.append(
            FluencyTrackOut(
                id=track.id,
                name=track.name,
                type=track.type,
                is_active=track.is_active,
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
    for act in node.activities:
        p_out = None
        if act.id in user_progress_map:
            p_out = UserActivityProgressOut.model_validate(user_progress_map[act.id])
        activities_out.append(
            NodeActivityOut(
                id=act.id,
                stage_node_id=act.stage_node_id,
                activity_type=act.activity_type,
                config=act.config,
                is_active=act.is_active,
                progress=p_out,
            )
        )

    return StageNodeOut(
        id=node.id,
        stage_id=node.stage_id,
        sequence=node.sequence,
        is_active=node.is_active,
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

    if not progress:
        progress = UserActivityProgress(
            user_id=current_user.id,
            node_activity_id=activity_id,
            status=payload.status,
            score=payload.score,
            response_data=payload.response_data,
            completed_at=datetime.utcnow() if payload.status == ActivityStatus.completed else None,
        )
        db.add(progress)
    else:
        progress.status = payload.status
        progress.score = payload.score
        progress.response_data = payload.response_data
        if payload.status == ActivityStatus.completed and not progress.completed_at:
            progress.completed_at = datetime.utcnow()

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
