"""Storage service for turn audio — user recordings and AI persona replies.

Supports both:
1. GCP Cloud Storage natively via `google-cloud-storage` using the VM's IAM Service Account (ADC)
2. MinIO / S3 via `boto3` for local development
"""

import asyncio
from datetime import timedelta
import uuid

from app.config import get_settings

settings = get_settings()

_is_gcs = (
    "storage.googleapis.com" in settings.cloud_storage_endpoint_url
    or not settings.cloud_storage_access_key
)

if _is_gcs:
    from google.cloud import storage  # type: ignore

    _gcs_client = storage.Client()
    _gcs_bucket = _gcs_client.bucket(settings.cloud_storage_bucket)
    _s3 = None
else:
    import boto3
    from botocore.client import Config
    from botocore.exceptions import ClientError

    _gcs_client = None
    _gcs_bucket = None
    _s3 = boto3.client(
        "s3",
        endpoint_url=settings.cloud_storage_endpoint_url,
        aws_access_key_id=settings.cloud_storage_access_key,
        aws_secret_access_key=settings.cloud_storage_secret_key,
        config=Config(signature_version="s3v4"),
        region_name="us-east-1",
    )


def _ensure_bucket_sync() -> None:
    if _is_gcs and _gcs_client and _gcs_bucket:
        try:
            if not _gcs_bucket.exists():
                _gcs_client.create_bucket(settings.cloud_storage_bucket)
        except Exception as e:
            print(f"GCS bucket verification/creation note: {e}")
    elif _s3:
        try:
            _s3.head_bucket(Bucket=settings.cloud_storage_bucket)
        except Exception:
            _s3.create_bucket(Bucket=settings.cloud_storage_bucket)


async def ensure_bucket() -> None:
    """Called once on app startup — creates the bucket if it doesn't exist yet."""
    await asyncio.to_thread(_ensure_bucket_sync)


def build_audio_key(session_id: uuid.UUID, turn_index: int, speaker: str, extension: str) -> str:
    return f"sessions/{session_id}/turn-{turn_index:04d}-{speaker}.{extension}"


def _put_object_sync(key: str, data: bytes, content_type: str) -> None:
    if _is_gcs and _gcs_bucket:
        blob = _gcs_bucket.blob(key)
        blob.upload_from_string(data, content_type=content_type)
    elif _s3:
        _s3.put_object(
            Bucket=settings.cloud_storage_bucket, Key=key, Body=data, ContentType=content_type
        )


async def upload_audio(key: str, data: bytes, content_type: str) -> str:
    """Uploads audio bytes under `key`, returns the key (stored on the message row)."""
    await asyncio.to_thread(_put_object_sync, key, data, content_type)
    return key


def _presigned_url_sync(key: str, expires_seconds: int) -> str:
    if _is_gcs and _gcs_bucket:
        blob = _gcs_bucket.blob(key)
        try:
            return blob.generate_signed_url(
                version="v4",
                expiration=timedelta(seconds=expires_seconds),
                method="GET",
            )
        except Exception:
            return f"https://storage.googleapis.com/{settings.cloud_storage_bucket}/{key}"
    elif _s3:
        return _s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": settings.cloud_storage_bucket, "Key": key},
            ExpiresIn=expires_seconds,
        )
    return ""


async def get_playback_url(key: str | None) -> str | None:
    """Returns a temporary signed URL for playback, or None if there's no
    stored audio for this message (e.g. rows created before this feature).
    """
    if not key:
        return None
    return await asyncio.to_thread(
        _presigned_url_sync, key, settings.cloud_storage_presigned_url_expire_seconds
    )

