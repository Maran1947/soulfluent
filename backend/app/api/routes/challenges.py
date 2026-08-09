from fastapi import APIRouter

from app.schemas.challenges import (
    ChallengeOut,
    ChallengesLibraryOut,
    RankProgressOut,
)
from app.services.challenges import (
    CHALLENGES,
    RANKS,
    ZONES,
    get_daily_challenge,
    get_rank_progress,
)

router = APIRouter(prefix="/challenges", tags=["challenges"])


@router.get("", response_model=ChallengesLibraryOut)
async def get_challenges_library():
    daily = get_daily_challenge()
    return {
        "zones": ZONES,
        "ranks": RANKS,
        "challenges": CHALLENGES,
        "daily_featured": daily,
    }


@router.get("/daily", response_model=ChallengeOut)
async def get_daily_featured():
    return get_daily_challenge()


@router.get("/rank_progress", response_model=RankProgressOut)
async def get_user_rank_progress(xp: int = 0):
    return get_rank_progress(xp)
