from fastapi import APIRouter, Depends

from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.curriculum import (
    CurriculumLibraryOut,
    CurriculumProgressOut,
    UpdateCurriculumProgressRequest,
)
from app.services.curriculum import PERSONAS_INFO, TRACK_A_WEEKS, TRACKS

router = APIRouter(prefix="/curriculum", tags=["curriculum"])

# In-memory user progress store for demo (can be persisted to user model)
_USER_PROGRESS: dict[str, dict] = {}


@router.get("", response_model=CurriculumLibraryOut)
async def get_curriculum():
    return CurriculumLibraryOut.model_validate(
        {"personas": PERSONAS_INFO, "weeks": TRACK_A_WEEKS, "tracks": TRACKS}
    )


@router.get("/progress", response_model=CurriculumProgressOut)
async def get_progress(current_user: User = Depends(get_current_user)):
    user_id = str(current_user.id)
    if user_id not in _USER_PROGRESS:
        _USER_PROGRESS[user_id] = {
            "current_day": 1,
            "streak_days": 0,
            "active_track": "A",
            "review_mode": False,
            "completed_days": [],
        }
    return CurriculumProgressOut(**_USER_PROGRESS[user_id])


@router.post("/progress", response_model=CurriculumProgressOut)
async def update_progress(
    payload: UpdateCurriculumProgressRequest,
    current_user: User = Depends(get_current_user),
):
    user_id = str(current_user.id)
    if user_id not in _USER_PROGRESS:
        _USER_PROGRESS[user_id] = {
            "current_day": 1,
            "streak_days": 0,
            "active_track": "A",
            "review_mode": False,
            "completed_days": [],
        }

    if payload.reset:
        _USER_PROGRESS[user_id] = {
            "current_day": 1,
            "streak_days": 0,
            "active_track": "A",
            "review_mode": False,
            "completed_days": [],
        }
        return CurriculumProgressOut(**_USER_PROGRESS[user_id])

    p = _USER_PROGRESS[user_id]
    if payload.current_day is not None:
        p["current_day"] = payload.current_day
    if payload.active_track is not None:
        p["active_track"] = payload.active_track
    if payload.review_mode is not None:
        p["review_mode"] = payload.review_mode
    if payload.completed_day is not None and payload.completed_day not in p["completed_days"]:
        p["completed_days"].append(payload.completed_day)

    return CurriculumProgressOut(**p)
