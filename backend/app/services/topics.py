"""Topic library — supporting English, Hindi, and Hinglish localized content."""

TOPIC_LIBRARY: dict[str, list[dict[str, str]]] = {
    "current_affairs": [
        {
            "English": "Should AI regulation be stricter to protect jobs?",
            "Hindi": "क्या नौकरियों की सुरक्षा के लिए AI पर सख्त नियम होने चाहिए?",
            "Hinglish": "Kya jobs protect karne ke liye AI regulation stricter hona chahiye?",
        },
        {
            "English": "Is climate change action moving fast enough globally?",
            "Hindi": "क्या वैश्विक स्तर पर जलवायु परिवर्तन पर काम काफी तेजी से हो रहा है?",
            "Hinglish": "Kya global level par climate change action fast enough chal raha hai?",
        },
        {
            "English": "Has startup culture glorified overwork?",
            "Hindi": "क्या स्टार्टअप कल्चर ने ज्यादा काम करने की आदत को बढ़ावा दिया है?",
            "Hinglish": "Kya startup culture ne overwork ko glorify kar diya hai?",
        },
        {
            "English": "Is the gig economy good or bad for workers?",
            "Hindi": "क्या गीग इकॉनमी (गिग वर्कर्स) कर्मचारियों के लिए अच्छी है या बुरी?",
            "Hinglish": "Kya gig economy workers ke liye achhi hai ya kharab?",
        },
    ],
    "abstract": [
        {
            "English": "Success is mostly luck, not hard work",
            "Hindi": "सफलता ज्यादातर किस्मत है, कड़ी मेहनत नहीं",
            "Hinglish": "Success mostly luck hoti hai, hard work nahi",
        },
        {
            "English": "Cities offer a better quality of life than villages",
            "Hindi": "गांवों की तुलना में शहरों में जीवन की गुणवत्ता बेहतर होती है",
            "Hinglish": "Villages ke comparison mein cities better quality of life offer karti hain",
        },
        {
            "English": "Ethics and profit cannot coexist in business",
            "Hindi": "व्यापार में नैतिकता और मुनाफा एक साथ नहीं चल सकते",
            "Hinglish": "Business mein ethics aur profit ek saath coexist nahi kar sakte",
        },
    ],
    "mba_specific": [
        {
            "English": "Did demonetisation help or hurt India's economy?",
            "Hindi": "क्या नोटबंदी ने भारत की अर्थव्यवस्था में मदद की या नुकसान पहुंचाया?",
            "Hinglish": "Kya demonetisation ne India ki economy ko help kiya ya hurt kiya?",
        },
        {
            "English": "Is India's education system preparing students for the real world?",
            "Hindi": "क्या भारत की शिक्षा प्रणाली छात्रों को वास्तविक दुनिया के लिए तैयार कर रही है?",
            "Hinglish": "Kya India ka education system students ko real world ke liye prepare kar raha hai?",
        },
        {
            "English": "Is India's startup ecosystem sustainable in the long run?",
            "Hindi": "क्या भारत का स्टार्टअप इकोसिस्टम लंबे समय तक टिकाऊ है?",
            "Hinglish": "Kya India ka startup ecosystem long run mein sustainable hai?",
        },
    ],
    "ielts_aligned": [
        {
            "English": "Should governments prioritize the environment over economic growth?",
            "Hindi": "क्या सरकारों को आर्थिक विकास से ऊपर पर्यावरण को प्राथमिकता देनी चाहिए?",
            "Hinglish": "Kya governments ko economic growth ke bajaye environment ko prioritize karna chahiye?",
        },
        {
            "English": "Is technology making people more isolated?",
            "Hindi": "क्या तकनीक लोगों को अधिक अलग-थलग (अकेला) बना रही है?",
            "Hinglish": "Kya technology logon ko zyada isolated bana rahi hai?",
        },
        {
            "English": "Should healthcare be free for everyone?",
            "Hindi": "क्या स्वास्थ्य सेवा सभी के लिए मुफ्त होनी चाहिए?",
            "Hinglish": "Kya healthcare sabke liye free honi chahiye?",
        },
    ],
}


def list_topics(language: str = "English") -> dict[str, list[str]]:
    """Returns topics localized to the requested language (English, Hindi, Hinglish)."""
    lang_key = language if language in ("English", "Hindi", "Hinglish") else "English"
    result: dict[str, list[str]] = {}
    for cat, items in TOPIC_LIBRARY.items():
        result[cat] = [item.get(lang_key, item["English"]) for item in items]
        if not result[cat]:
            result[cat] = [item["English"] for item in items]
    return result


def random_topic(language: str = "English") -> str:
    import random

    topics_map = list_topics(language)
    category = random.choice(list(topics_map.keys()))
    return random.choice(topics_map[category])

