from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # App
    app_name: str = "FluentSoul"
    environment: str = "development"
    api_prefix: str = "/api/v1"

    # Auth
    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24 * 7  # 7 days

    # Database
    database_url: str = "postgresql+asyncpg://fluentsoul:fluentsoul@localhost:5432/flountsoul"

    # Gemini
    # gemini-2.5-flash was restricted from new API keys ahead of its official
    # Oct 2026 shutdown (Google did this months early, without much warning —
    # see https://discuss.ai.google.dev if this happens again). Currently on
    # the Gemini 3 generation instead. Re-check
    # https://ai.google.dev/gemini-api/docs/models periodically since Google's
    # model lifecycle here has been moving fast.
    gemini_api_key: str = ""
    gemini_text_model: str = "gemini-3.5-flash"
    gemini_tts_model: str = "gemini-3.1-flash-tts-preview"

    # Gemini pricing, USD per 1M tokens. Verify against
    # https://ai.google.dev/gemini-api/docs/pricing before trusting cost figures
    # for billing decisions — these are current as of July 2026 but Google
    # updates them regularly, especially for "-preview" models.
    gemini_pricing: dict[str, dict[str, float]] = {
        "gemini-3.5-flash": {"input": 1.50, "output": 9.00},
        "gemini-3.1-flash-tts-preview": {"input": 1.00, "output": 20.00},
    }

    # CORS
    frontend_origin: str = "http://localhost:3000"

    # Object storage (Cloud Storage / MinIO, S3-compatible) for user + AI turn audio
    cloud_storage_endpoint_url: str = "http://localhost:9010"
    cloud_storage_access_key: str = "fluentsoul"
    cloud_storage_secret_key: str = "fluentsoul123"
    cloud_storage_bucket: str = "fluentsoul-audio"
    cloud_storage_presigned_url_expire_seconds: int = 3600

    # GD session defaults
    max_session_duration_minutes: int = 20


@lru_cache
def get_settings() -> Settings:
    return Settings()
