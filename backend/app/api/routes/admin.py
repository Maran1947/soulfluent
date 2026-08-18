import uuid
from datetime import datetime, date, time
from typing import Any
from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy import func, select, desc, case
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload, joinedload

from app.database import get_db
from app.models.account import Account, SignupSource
from app.models.user import User
from app.models.user_preference import UserPreference
from app.models.session import Session, SessionStatus
from app.models.message import Message
from app.models.feedback_report import FeedbackReport
from app.models.llm_usage import LLMUsageLog
from app.models.user_daily_speak import UserDailySpeak
from app.models.daily_speak_topic import DailySpeakTopic
from app.models.fluency_track import UserActivityProgress, ActivityStatus
from app.schemas.admin import (
    OverviewStatsResponse,
    SessionListItem,
    SessionDetailResponse,
    MessageItem,
    LLMUsageItem,
    DailySpeakListResponse,
    DailySpeakItem,
    UserLeaderboardItem,
)

router = APIRouter(prefix="/admin", tags=["admin"])


def parse_date_range(start_date: str | None, end_date: str | None) -> tuple[datetime | None, datetime | None]:
    start_dt = None
    end_dt = None
    if start_date:
        try:
            d = date.fromisoformat(start_date)
            start_dt = datetime.combine(d, time.min)
        except Exception:
            pass
    if end_date:
        try:
            d = date.fromisoformat(end_date)
            end_dt = datetime.combine(d, time.max)
        except Exception:
            pass
    return start_dt, end_dt


@router.get("/stats/overview", response_model=OverviewStatsResponse)
async def get_overview_stats(
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
) -> OverviewStatsResponse:
    """Read-only platform summary with optional date-wise filtering: signups, onboarded users, started tracks, sessions, daily speaks, total cost."""
    start_dt, end_dt = parse_date_range(start_date, end_date)

    # Base query for User signups
    users_q = select(func.count(User.id))
    if start_dt:
        users_q = users_q.where(User.created_at >= start_dt)
    if end_dt:
        users_q = users_q.where(User.created_at <= end_dt)
    res_users = await db.execute(users_q)
    total_signups = res_users.scalar() or 0

    # Onboarded users
    onboarded_q = select(func.count(UserPreference.id)).where(UserPreference.is_onboarded == True)
    if start_dt:
        onboarded_q = onboarded_q.where(UserPreference.created_at >= start_dt)
    if end_dt:
        onboarded_q = onboarded_q.where(UserPreference.created_at <= end_dt)
    res_onboarded = await db.execute(onboarded_q)
    onboarded_users = res_onboarded.scalar() or 0
    onboarded_pct = round((onboarded_users / total_signups * 100), 1) if total_signups > 0 else 0.0

    # Unique users who started fluency tracks
    tracks_q = select(func.count(func.distinct(UserActivityProgress.user_id)))
    if start_dt:
        tracks_q = tracks_q.where(UserActivityProgress.created_at >= start_dt)
    if end_dt:
        tracks_q = tracks_q.where(UserActivityProgress.created_at <= end_dt)
    res_started_tracks = await db.execute(tracks_q)
    started_tracks_users = res_started_tracks.scalar() or 0

    # Total sessions by status
    sess_status_q = select(Session.status, func.count(Session.id))
    if start_dt:
        sess_status_q = sess_status_q.where(Session.started_at >= start_dt)
    if end_dt:
        sess_status_q = sess_status_q.where(Session.started_at <= end_dt)
    sess_status_q = sess_status_q.group_by(Session.status)
    res_sess_status = await db.execute(sess_status_q)
    status_counts = {
        str(st.value if hasattr(st, "value") else st): cnt
        for st, cnt in res_sess_status.all()
    }
    completed_sessions_count = status_counts.get("completed", 0)
    active_sessions_count = status_counts.get("active", 0)
    abandoned_sessions_count = status_counts.get("abandoned", 0)
    total_sessions = sum(status_counts.values())

    # Total daily speaks
    uds_q = select(func.count(UserDailySpeak.id))
    if start_dt:
        uds_q = uds_q.where(UserDailySpeak.completed_at_date >= start_dt)
    if end_dt:
        uds_q = uds_q.where(UserDailySpeak.completed_at_date <= end_dt)
    res_daily_speaks = await db.execute(uds_q)
    total_daily_speaks = res_daily_speaks.scalar() or 0

    # Total platform cost USD
    cost_q = select(func.coalesce(func.sum(LLMUsageLog.cost_usd), 0.0))
    if start_dt:
        cost_q = cost_q.where(LLMUsageLog.created_at >= start_dt)
    if end_dt:
        cost_q = cost_q.where(LLMUsageLog.created_at <= end_dt)
    res_cost = await db.execute(cost_q)
    total_cost_usd = round(float(res_cost.scalar() or 0.0), 4)

    # Signup sources breakdown
    sources_q = select(Account.signup_source, func.count(Account.id))
    if start_dt:
        sources_q = sources_q.where(Account.created_at >= start_dt)
    if end_dt:
        sources_q = sources_q.where(Account.created_at <= end_dt)
    sources_q = sources_q.group_by(Account.signup_source)
    res_sources = await db.execute(sources_q)
    signup_sources = {
        str(source.value if hasattr(source, "value") else source): count
        for source, count in res_sources.all()
    }

    # CEFR distribution
    cefr_q = select(UserPreference.cefr_level, func.count(UserPreference.id))
    if start_dt:
        cefr_q = cefr_q.where(UserPreference.created_at >= start_dt)
    if end_dt:
        cefr_q = cefr_q.where(UserPreference.created_at <= end_dt)
    cefr_q = cefr_q.group_by(UserPreference.cefr_level)
    res_cefr = await db.execute(cefr_q)
    cefr_distribution = {level or "Unknown": count for level, count in res_cefr.all()}

    return OverviewStatsResponse(
        total_signups=total_signups,
        onboarded_users=onboarded_users,
        onboarded_percentage=onboarded_pct,
        started_tracks_users=started_tracks_users,
        total_sessions=total_sessions,
        completed_sessions_count=completed_sessions_count,
        active_sessions_count=active_sessions_count,
        abandoned_sessions_count=abandoned_sessions_count,
        total_daily_speaks=total_daily_speaks,
        total_cost_usd=total_cost_usd,
        signup_sources=signup_sources,
        cefr_distribution=cefr_distribution,
    )


@router.get("/sessions", response_model=list[SessionListItem])
async def list_sessions(
    status_filter: str | None = Query(None, alias="status"),
    mode_filter: str | None = Query(None, alias="mode"),
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> list[SessionListItem]:
    """Read-only list of user sessions with total turn count, tokens, and computed cost."""
    start_dt, end_dt = parse_date_range(start_date, end_date)

    # Subquery for per-session token usage and total cost
    usage_subq = (
        select(
            LLMUsageLog.session_id,
            func.coalesce(func.sum(LLMUsageLog.total_tokens), 0).label("total_tokens"),
            func.coalesce(func.sum(LLMUsageLog.cost_usd), 0.0).label("total_cost_usd"),
        )
        .group_by(LLMUsageLog.session_id)
        .subquery()
    )

    query = (
        select(Session, User, Account, usage_subq.c.total_tokens, usage_subq.c.total_cost_usd)
        .outerjoin(User, Session.user_id == User.id)
        .outerjoin(Account, User.account_id == Account.id)
        .outerjoin(usage_subq, Session.id == usage_subq.c.session_id)
        .order_by(desc(Session.started_at))
        .offset(offset)
        .limit(limit)
    )

    if status_filter:
        query = query.where(Session.status == status_filter)
    if mode_filter:
        query = query.where(Session.mode == mode_filter)
    if start_dt:
        query = query.where(Session.started_at >= start_dt)
    if end_dt:
        query = query.where(Session.started_at <= end_dt)

    res = await db.execute(query)
    rows = res.all()

    items = []
    for sess, usr, acc, tokens, cost in rows:
        items.append(
            SessionListItem(
                id=sess.id,
                user_id=sess.user_id,
                user_name=usr.name if usr else "Unknown User",
                user_email=acc.email if acc else "",
                mode=str(sess.mode.value if hasattr(sess.mode, "value") else sess.mode),
                topic=sess.topic,
                category=sess.category,
                status=str(sess.status.value if hasattr(sess.status, "value") else sess.status),
                duration_minutes=sess.duration_minutes,
                turn_index=sess.turn_index,
                started_at=sess.started_at,
                ended_at=sess.ended_at,
                total_tokens=int(tokens or 0),
                total_cost_usd=round(float(cost or 0.0), 4),
            )
        )
    return items


@router.get("/sessions/{session_id}", response_model=SessionDetailResponse)
async def get_session_detail(
    session_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
) -> SessionDetailResponse:
    """Read-only detail view of a session: transcript messages, feedback report, and LLM call cost log breakdown."""
    query = (
        select(Session)
        .options(
            joinedload(Session.user).joinedload(User.account),
            selectinload(Session.messages),
            selectinload(Session.report),
        )
        .where(Session.id == session_id)
    )
    res = await db.execute(query)
    sess = res.scalars().first()

    if not sess:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")

    usage_res = await db.execute(
        select(LLMUsageLog).where(LLMUsageLog.session_id == session_id).order_by(LLMUsageLog.created_at.asc())
    )
    usage_logs = usage_res.scalars().all()
    total_cost_usd = sum(log.cost_usd for log in usage_logs)
    total_tokens = sum(log.total_tokens for log in usage_logs)

    user_name = sess.user.name if sess.user else "Unknown User"
    user_email = sess.user.account.email if (sess.user and sess.user.account) else ""

    sess_item = SessionListItem(
        id=sess.id,
        user_id=sess.user_id,
        user_name=user_name,
        user_email=user_email,
        mode=str(sess.mode.value if hasattr(sess.mode, "value") else sess.mode),
        topic=sess.topic,
        category=sess.category,
        status=str(sess.status.value if hasattr(sess.status, "value") else sess.status),
        duration_minutes=sess.duration_minutes,
        turn_index=sess.turn_index,
        started_at=sess.started_at,
        ended_at=sess.ended_at,
        total_tokens=total_tokens,
        total_cost_usd=round(total_cost_usd, 4),
    )

    msg_items = [
        MessageItem(
            id=m.id,
            turn_index=m.turn_index,
            speaker=m.speaker,
            speaker_role=m.speaker_role,
            text=m.text,
            audio_duration_seconds=m.audio_duration_seconds,
            created_at=m.created_at,
        )
        for m in sorted(sess.messages, key=lambda x: x.turn_index)
    ]

    log_items = [
        LLMUsageItem(
            id=l.id,
            call_type=str(l.call_type.value if hasattr(l.call_type, "value") else l.call_type),
            model=l.model,
            input_tokens=l.input_tokens,
            output_tokens=l.output_tokens,
            total_tokens=l.total_tokens,
            cost_usd=round(l.cost_usd, 5),
            created_at=l.created_at,
        )
        for l in usage_logs
    ]

    report_dict = None
    if sess.report:
        report_dict = {
            "id": str(sess.report.id),
            "wpm": sess.report.wpm,
            "filler_words_count": sess.report.filler_words_count,
            "user_talk_time_seconds": sess.report.user_talk_time_seconds,
            "vocabulary_feedback": sess.report.vocabulary_feedback,
            "argument_quality": sess.report.argument_quality,
            "key_highlights": sess.report.key_highlights,
            "actionable_recommendations": sess.report.actionable_recommendations,
            "overall_score": sess.report.overall_score,
            "created_at": sess.report.created_at.isoformat() if sess.report.created_at else None,
        }

    return SessionDetailResponse(
        session=sess_item,
        messages=msg_items,
        usage_logs=log_items,
        report=report_dict,
        total_cost_usd=round(total_cost_usd, 4),
    )


@router.get("/daily-speak", response_model=DailySpeakListResponse)
async def list_daily_speak(
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> DailySpeakListResponse:
    """Read-only log of daily speak completions with user details, topic, and associated LLM costs."""
    start_dt, end_dt = parse_date_range(start_date, end_date)

    stmt = (
        select(UserDailySpeak, User, Account, DailySpeakTopic, Session.id)
        .outerjoin(User, UserDailySpeak.user_id == User.id)
        .outerjoin(Account, User.account_id == Account.id)
        .outerjoin(DailySpeakTopic, UserDailySpeak.topic_id == DailySpeakTopic.id)
        .outerjoin(Session, UserDailySpeak.session_id == Session.id)
        .order_by(desc(UserDailySpeak.completed_at_date))
        .offset(offset)
        .limit(limit)
    )

    if start_dt:
        stmt = stmt.where(UserDailySpeak.completed_at_date >= start_dt)
    if end_dt:
        stmt = stmt.where(UserDailySpeak.completed_at_date <= end_dt)

    res = await db.execute(stmt)
    rows = res.all()

    cnt_q = select(func.count(UserDailySpeak.id))
    if start_dt:
        cnt_q = cnt_q.where(UserDailySpeak.completed_at_date >= start_dt)
    if end_dt:
        cnt_q = cnt_q.where(UserDailySpeak.completed_at_date <= end_dt)
    cnt_res = await db.execute(cnt_q)
    total_completions = cnt_res.scalar() or 0

    items = []
    total_daily_speak_cost = 0.0

    for uds, usr, acc, topic, sess_id in rows:
        cost = 0.0
        if sess_id:
            c_res = await db.execute(
                select(func.coalesce(func.sum(LLMUsageLog.cost_usd), 0.0)).where(
                    LLMUsageLog.session_id == sess_id
                )
            )
            cost = float(c_res.scalar() or 0.0)

        total_daily_speak_cost += cost

        items.append(
            DailySpeakItem(
                id=uds.id,
                user_id=uds.user_id,
                user_name=usr.name if usr else "Learner",
                user_email=acc.email if acc else "",
                completed_at_date=uds.completed_at_date,
                topic_title=topic.topic if topic else "Daily Speaking Practice",
                session_id=sess_id,
                cost_usd=round(cost, 4),
            )
        )

    return DailySpeakListResponse(
        total_completions=total_completions,
        total_cost_usd=round(total_daily_speak_cost, 4),
        items=items,
    )


@router.get("/users/leaderboard", response_model=list[UserLeaderboardItem])
async def get_user_leaderboard(
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> list[UserLeaderboardItem]:
    """Read-only user leaderboard ranked by daily streak, total sessions, activities completed, and speak time."""
    users_query = (
        select(User)
        .options(joinedload(User.account), joinedload(User.preferences))
        .where(User.is_active == True)
        .order_by(User.created_at.asc())
    )
    users_res = await db.execute(users_query)
    users = users_res.scalars().unique().all()

    leaderboard = []
    for user in users:
        from app.services.daily_speak_service import get_user_daily_speak_stats
        speak_stats = await get_user_daily_speak_stats(db, user.id)
        streak_days = speak_stats.get("streak_days", 0)

        sess_res = await db.execute(
            select(func.count(Session.id)).where(
                Session.user_id == user.id, Session.status == SessionStatus.completed
            )
        )
        completed_sessions = sess_res.scalar() or 0

        uds_res = await db.execute(
            select(func.count(UserDailySpeak.id)).where(UserDailySpeak.user_id == user.id)
        )
        completed_daily_speaks = uds_res.scalar() or 0

        act_res = await db.execute(
            select(func.count(UserActivityProgress.id)).where(
                UserActivityProgress.user_id == user.id,
                UserActivityProgress.status == ActivityStatus.completed,
            )
        )
        completed_activities = act_res.scalar() or 0

        dur_res = await db.execute(
            select(func.coalesce(func.sum(Message.audio_duration_seconds), 0.0))
            .join(Session, Message.session_id == Session.id)
            .where(Session.user_id == user.id, Message.speaker == "user")
        )
        total_speak_seconds = float(dur_res.scalar() or 0.0)

        cefr = user.preferences.cefr_level if user.preferences else "B1"
        onboarded = user.preferences.is_onboarded if user.preferences else False

        leaderboard.append(
            {
                "user_id": user.id,
                "user_name": user.name or "Anonymous User",
                "user_email": user.account.email if user.account else "",
                "streak_days": streak_days,
                "completed_sessions": completed_sessions,
                "completed_daily_speaks": completed_daily_speaks,
                "completed_activities": completed_activities,
                "total_speak_seconds": round(total_speak_seconds, 1),
                "cefr_level": cefr,
                "is_onboarded": onboarded,
                "created_at": user.created_at,
            }
        )

    leaderboard.sort(
        key=lambda x: (
            x["streak_days"],
            x["completed_sessions"],
            x["completed_daily_speaks"],
            x["total_speak_seconds"],
        ),
        reverse=True,
    )

    result = []
    for idx, item in enumerate(leaderboard[:limit], start=1):
        result.append(UserLeaderboardItem(rank=idx, **item))

    return result
