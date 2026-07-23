"""S3-compatible (MinIO) storage for turn audio — both the user's original
recording and the AI persona's synthesized reply, so a session can be
replayed later rather than only leaving behind a text transcript.

boto3 is synchronous, so every call here is pushed through a thread via
asyncio.to_thread to avoid blocking the FastAPI event loop.
"""

import asyncio
import uuid

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

from app.config import get_settings

settings = get_settings()

_s3 = boto3.client(
    "s3",
    endpoint_url=settings.minio_endpoint_url,
    aws_access_key_id=settings.minio_access_key,
    aws_secret_access_key=settings.minio_secret_key,
    config=Config(signature_version="s3v4"),
    region_name="us-east-1",
)


def _ensure_bucket_sync() -> None:
    try:
        _s3.head_bucket(Bucket=settings.minio_bucket)
    except ClientError:
        _s3.create_bucket(Bucket=settings.minio_bucket)


async def ensure_bucket() -> None:
    """Called once on app startup — creates the bucket if it doesn't exist yet."""
    await asyncio.to_thread(_ensure_bucket_sync)


def build_audio_key(
    session_id: uuid.UUID, turn_index: int, speaker: str, extension: str
) -> str:
    return f"sessions/{session_id}/turn-{turn_index:04d}-{speaker}.{extension}"


def _put_object_sync(key: str, data: bytes, content_type: str) -> None:
    _s3.put_object(Bucket=settings.minio_bucket, Key=key, Body=data, ContentType=content_type)


async def upload_audio(key: str, data: bytes, content_type: str) -> str:
    """Uploads audio bytes under `key`, returns the key (stored on the message row)."""
    await asyncio.to_thread(_put_object_sync, key, data, content_type)
    return key


def _presigned_url_sync(key: str, expires_seconds: int) -> str:
    return _s3.generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.minio_bucket, "Key": key},
        ExpiresIn=expires_seconds,
    )


async def get_playback_url(key: str | None) -> str | None:
    """Returns a temporary signed URL for playback, or None if there's no
    stored audio for this message (e.g. rows created before this feature).
    """
    if not key:
        return None
    return await asyncio.to_thread(
        _presigned_url_sync, key, settings.minio_presigned_url_expire_seconds
    )
