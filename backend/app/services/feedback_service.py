"""Builds the full post-session feedback report: objective metrics computed
directly from stored message data, merged with Gemini's qualitative analysis.
"""

import re
import uuid

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.message import Message
from app.services.gemini_service import analyze_session

FILLER_WORDS = ["um", "uh", "like", "basically", "you know", "sort of", "actually", "i mean"]


def _word_count(text: str) -> int:
    return len(re.findall(r"[A-Za-z']+", text))


def _filler_breakdown(text: str) -> dict[str, int]:
    lowered = text.lower()
    return {
        w: len(re.findall(rf"\b{re.escape(w)}\b", lowered))
        for w in FILLER_WORDS
        if re.search(rf"\b{re.escape(w)}\b", lowered)
    }


def _sentence_completion_rate(user_turns: list[str]) -> float:
    if not user_turns:
        return 0.0
    completed = sum(1 for t in user_turns if t.strip().endswith((".", "!", "?")))
    return round(completed / len(user_turns), 2)


def compute_objective_metrics(messages: list[Message]) -> dict:
    user_msgs = [m for m in messages if m.speaker == "user"]
    ai_msgs = [m for m in messages if m.speaker != "user"]

    user_word_total = sum(_word_count(m.text) for m in user_msgs)
    user_duration_total = sum(m.audio_duration_seconds for m in user_msgs) or 1.0
    ai_duration_total = sum(m.audio_duration_seconds for m in ai_msgs)

    wpm = round(user_word_total / (user_duration_total / 60), 1) if user_duration_total else 0.0

    combined_fillers: dict[str, int] = {}
    for m in user_msgs:
        for word, count in _filler_breakdown(m.text).items():
            combined_fillers[word] = combined_fillers.get(word, 0) + count

    total_speaking_time = user_duration_total + ai_duration_total
    talk_time_pct = (
        round((user_duration_total / total_speaking_time) * 100, 1)
        if total_speaking_time
        else 0.0
    )

    sentence_lengths = [_word_count(m.text) for m in user_msgs if m.text.strip()]
    avg_sentence_length = (
        round(sum(sentence_lengths) / len(sentence_lengths), 1) if sentence_lengths else 0.0
    )

    unique_words = {w.lower() for m in user_msgs for w in re.findall(r"[A-Za-z']+", m.text)}
    vocab_richness = round(len(unique_words) / user_word_total, 2) if user_word_total else 0.0

    return {
        "words_per_minute": wpm,
        "filler_word_count": sum(combined_fillers.values()),
        "filler_word_breakdown": combined_fillers,
        "sentence_completion_rate": _sentence_completion_rate([m.text for m in user_msgs]),
        "average_sentence_length": avg_sentence_length,
        "talk_time_percentage": talk_time_pct,
        "raw_vocabulary_richness": vocab_richness,
        "total_user_turns": len(user_msgs),
        "total_words_spoken": user_word_total,
    }


def _build_transcript(messages: list[Message], persona_names: dict[str, str]) -> str:
    lines = []
    for m in messages:
        label = "user" if m.speaker == "user" else persona_names.get(m.speaker, m.speaker)
        lines.append(f"{label}: {m.text}")
    return "\n".join(lines)


async def build_feedback_report(
    topic: str,
    messages: list[Message],
    persona_names: dict[str, str],
    db: AsyncSession | None = None,
    session_id: uuid.UUID | None = None,
) -> dict:
    objective = compute_objective_metrics(messages)
    transcript = _build_transcript(messages, persona_names)
    qualitative = await analyze_session(
        topic=topic, transcript=transcript, db=db, session_id=session_id
    )

    fluency_metrics = {
        "words_per_minute": objective["words_per_minute"],
        "filler_word_count": objective["filler_word_count"],
        "filler_word_breakdown": objective["filler_word_breakdown"],
        "sentence_completion_rate": objective["sentence_completion_rate"],
        "average_sentence_length": objective["average_sentence_length"],
    }
    vocabulary_metrics = {
        "vocabulary_richness_score": qualitative.vocabulary_richness_score
        or objective["raw_vocabulary_richness"],
        "advanced_vocabulary_examples": qualitative.advanced_vocabulary_examples,
        "repeated_phrases": qualitative.repeated_phrases,
        "phrases_to_avoid": qualitative.phrases_to_avoid,
        "replacement_suggestions": qualitative.replacement_suggestions,
        "grammar_errors": qualitative.grammar_errors,
    }
    argument_metrics = {
        "distinct_points_made": qualitative.distinct_points_made,
        "points_challenged_by_ai": qualitative.points_challenged_by_ai,
        "points_successfully_defended": qualitative.points_successfully_defended,
        "topic_initiations": qualitative.topic_initiations,
        "talk_time_percentage": objective["talk_time_percentage"],
        "relevance_score": qualitative.relevance_score,
    }

    return {
        "overall_score": qualitative.overall_score,
        "fluency_metrics": fluency_metrics,
        "vocabulary_metrics": vocabulary_metrics,
        "argument_metrics": argument_metrics,
        "sub_scores": {
            "fluency": qualitative.sub_score_fluency,
            "vocabulary": qualitative.sub_score_vocabulary,
            "argument_quality": qualitative.sub_score_argument_quality,
            "confidence": qualitative.sub_score_confidence,
            "relevance": qualitative.sub_score_relevance,
        },
        "highlight_reel": {
            "best_moments": qualitative.best_moments,
            "improvement_areas": qualitative.improvement_areas,
        },
        "recommendation": qualitative.recommendation,
    }
