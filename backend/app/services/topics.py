"""Topic library — a curated subset per PRD section 6.1 ("Topic library")."""

TOPIC_LIBRARY: dict[str, list[str]] = {
    "current_affairs": [
        "Should AI regulation be stricter to protect jobs?",
        "Is climate change action moving fast enough globally?",
        "Has startup culture glorified overwork?",
        "Is the gig economy good or bad for workers?",
    ],
    "abstract": [
        "Success is mostly luck, not hard work",
        "Cities offer a better quality of life than villages",
        "Ethics and profit cannot coexist in business",
    ],
    "case_based": [
        "Your company discovers a competitor is using unethical data practices "
        "to win contracts. Do you report it publicly?",
    ],
    "mba_specific": [
        "Did demonetisation help or hurt India's economy?",
        "Is India's education system preparing students for the real world?",
        "Is India's startup ecosystem sustainable in the long run?",
    ],
    "ielts_aligned": [
        "Should governments prioritize the environment over economic growth?",
        "Is technology making people more isolated?",
        "Should healthcare be free for everyone?",
    ],
}


def list_topics() -> dict[str, list[str]]:
    return TOPIC_LIBRARY


def random_topic() -> str:
    import random

    category = random.choice(list(TOPIC_LIBRARY.keys()))
    return random.choice(TOPIC_LIBRARY[category])
