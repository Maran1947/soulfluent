import uuid
from datetime import datetime

from pydantic import BaseModel


class FeedbackReportOut(BaseModel):
    id: uuid.UUID
    session_id: uuid.UUID
    overall_score: float
    fluency_metrics: dict
    vocabulary_metrics: dict
    argument_metrics: dict
    sub_scores: dict
    highlight_reel: dict
    recommendation: str
    total_tokens: int
    total_cost_usd: float
    created_at: datetime

    class Config:
        from_attributes = True
