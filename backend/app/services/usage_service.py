"""Tracks per-call Gemini token usage and cost against a GD session.

Every Gemini response object exposes `usage_metadata` (prompt_token_count,
candidates_token_count, total_token_count). We read that off each call and
record it here rather than trusting any single hardcoded estimate — the
`gemini_pricing` table in config.py converts tokens to USD, and should be
kept in sync with https://ai.google.dev/gemini-api/docs/pricing since Google
updates rates periodically (especially for "-preview" models like the TTS
one this app uses).
"""

import uuid

from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.llm_usage import CallType, LLMUsageLog

settings = get_settings()


def estimate_cost_usd(model: str, input_tokens: int, output_tokens: int) -> float:
    prices = settings.gemini_pricing.get(model)
    if not prices:
        return 0.0
    return (input_tokens / 1_000_000) * prices["input"] + (
        output_tokens / 1_000_000
    ) * prices["output"]


async def log_usage(
    db: AsyncSession | None,
    session_id: uuid.UUID | None,
    call_type: CallType,
    model: str,
    response,
) -> None:
    """Adds a usage row to the session (does NOT commit — piggybacks on the
    caller's existing transaction so usage rows land atomically with
    whatever else that request is persisting).
    """
    if db is None or session_id is None:
        return

    usage = getattr(response, "usage_metadata", None)
    if usage is None:
        return

    input_tokens = getattr(usage, "prompt_token_count", None) or 0
    output_tokens = getattr(usage, "candidates_token_count", None) or 0

    db.add(
        LLMUsageLog(
            session_id=session_id,
            call_type=call_type,
            model=model,
            input_tokens=input_tokens,
            output_tokens=output_tokens,
            total_tokens=input_tokens + output_tokens,
            cost_usd=estimate_cost_usd(model, input_tokens, output_tokens),
        )
    )
