from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import auth, daily_speak, gd, tracks
from app.config import get_settings
from app.database import AsyncSessionLocal
from app.seeds.seed_daily_speak import seed_daily_speak
from app.seeds.seed_fluency_tracks import seed_fluency_tracks
from app.services.storage_service import ensure_bucket

settings = get_settings()

app = FastAPI(title=settings.app_name, version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix=settings.api_prefix)
app.include_router(daily_speak.router, prefix=settings.api_prefix)
app.include_router(gd.router, prefix=settings.api_prefix)
app.include_router(tracks.router, prefix=settings.api_prefix)
app.include_router(tracks.curriculum_router, prefix=settings.api_prefix)


@app.on_event("startup")
async def on_startup():
    await ensure_bucket()
    try:
        async with AsyncSessionLocal() as db:
            await seed_fluency_tracks(db)
            await seed_daily_speak(db)
    except Exception as e:
        print(f"Auto-seed error on startup: {e}")



@app.get("/health")
async def health():
    return {"status": "ok", "app": settings.app_name}
