import 'package:flutter/material.dart';

class PersonaInfo {
  final String key;
  final String name;
  final String initial;
  final Color color;
  final String sub;
  final String flag;

  const PersonaInfo({
    required this.key,
    required this.name,
    required this.initial,
    required this.color,
    required this.sub,
    required this.flag,
  });

  factory PersonaInfo.fromJson(String key, Map<String, dynamic> json) {
    Color parseColor(String hex) {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }

    return PersonaInfo(
      key: key,
      name: json['name'] ?? key,
      initial: json['initial'] ?? (key.isNotEmpty ? key[0].toUpperCase() : 'P'),
      color: parseColor(json['color'] ?? '#FF8B5E'),
      sub: json['sub'] ?? '',
      flag: json['flag'] ?? '',
    );
  }
}

class CurriculumDay {
  final int d;
  final String theme;
  final String persona;
  final String
      mode; // 'foundation', 'debate', 'group', 'milestone', 'echo', etc.
  final String aiLine;
  final String instruction;
  final List<String> phrasesA;
  final List<String> phrasesB;
  final List<String> rescuePhrases;
  final String? shadowLine;
  final bool moodCheckIn;
  final bool textVisibleOnScreen;
  final List<String> script;
  final int wpm;
  final String filler;
  final bool milestoneReport;
  final bool graduatesToTrackA;

  const CurriculumDay({
    required this.d,
    required this.theme,
    required this.persona,
    required this.mode,
    required this.aiLine,
    required this.instruction,
    required this.phrasesA,
    required this.phrasesB,
    this.rescuePhrases = const [],
    this.shadowLine,
    this.moodCheckIn = false,
    this.textVisibleOnScreen = true,
    required this.script,
    required this.wpm,
    required this.filler,
    this.milestoneReport = false,
    this.graduatesToTrackA = false,
  });

  String get shortHook {
    final cleanAi = aiLine.trim();
    if (cleanAi.contains(' — ')) {
      return '${cleanAi.split(' — ')[0].trim()}.';
    }
    if (cleanAi.contains('.')) {
      return '${cleanAi.split('.')[0].trim()}.';
    }
    if (cleanAi.contains('!')) {
      return '${cleanAi.split('!')[0].trim()}!';
    }
    if (cleanAi.contains('?')) {
      return '${cleanAi.split('?')[0].trim()}?';
    }
    return cleanAi;
  }

  String get shortInstruction {
    final cleanInst = instruction.trim();
    if (cleanInst.contains('.')) {
      return '${cleanInst.split('.')[0].trim()}.';
    }
    return cleanInst;
  }

  List<String> getStatChips(String activeTrack) {
    final wpmStr = wpm > 0 ? '⏱️ $wpm WPM' : '⏱️ Free Pace';
    final fillerStr = '🎯 $filler';
    final rescueStr = rescuePhrases.isNotEmpty ? '🛟 Rescue on' : '🛟 Standard';
    return [wpmStr, fillerStr, rescueStr];
  }

  factory CurriculumDay.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    }

    return CurriculumDay(
      d: json['d'] ?? 1,
      theme: json['theme'] ?? '',
      persona: json['persona'] ?? 'riya',
      mode: json['mode'] ?? 'foundation',
      aiLine: json['aiLine'] ?? '',
      instruction: json['instruction'] ?? '',
      phrasesA: parseList(json['phrasesA']),
      phrasesB: parseList(json['phrasesB']),
      rescuePhrases: parseList(json['rescuePhrases']),
      shadowLine: json['shadowLine'],
      moodCheckIn: json['moodCheckIn'] ?? false,
      textVisibleOnScreen: json['textVisibleOnScreen'] ?? true,
      script: parseList(json['script']),
      wpm: json['wpm'] ?? 90,
      filler: json['filler'] ?? '≤5/min',
      milestoneReport: json['milestoneReport'] ?? false,
      graduatesToTrackA: json['graduatesToTrackA'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'd': d,
      'theme': theme,
      'persona': persona,
      'mode': mode,
      'aiLine': aiLine,
      'instruction': instruction,
      'phrasesA': phrasesA,
      'phrasesB': phrasesB,
      'rescuePhrases': rescuePhrases,
      'shadowLine': shadowLine,
      'moodCheckIn': moodCheckIn,
      'textVisibleOnScreen': textVisibleOnScreen,
      'script': script,
      'wpm': wpm,
      'filler': filler,
      'milestoneReport': milestoneReport,
      'graduatesToTrackA': graduatesToTrackA,
    };
  }
}

class CurriculumWeek {
  final String title;
  final String range;
  final List<CurriculumDay> days;

  const CurriculumWeek({
    required this.title,
    required this.range,
    required this.days,
  });

  factory CurriculumWeek.fromJson(Map<String, dynamic> json) {
    return CurriculumWeek(
      title: json['title'] ?? '',
      range: json['range'] ?? '',
      days: (json['days'] as List? ?? [])
          .map((d) => CurriculumDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CurriculumProgress {
  final int currentDay;
  final int streakDays;
  final String activeTrack; // 'A' or 'B'
  final bool reviewMode;
  final List<int> completedDays;

  const CurriculumProgress({
    this.currentDay = 1,
    this.streakDays = 0,
    this.activeTrack = 'A',
    this.reviewMode = false,
    this.completedDays = const [],
  });

  factory CurriculumProgress.fromJson(Map<String, dynamic> json) {
    return CurriculumProgress(
      currentDay: json['current_day'] ?? 1,
      streakDays: json['streak_days'] ?? 0,
      activeTrack: json['active_track'] ?? 'A',
      reviewMode: json['review_mode'] ?? false,
      completedDays: List<int>.from(json['completed_days'] ?? []),
    );
  }
}

final List<Map<String, dynamic>> WEEKS_DATA = [
  {
    "title": "Warm-Up · Break the Silence",
    "range": "Days 1–7",
    "days": [
      {
        "d": 1,
        "theme": "Introduce Yourself",
        "persona": "riya",
        "mode": "foundation",
        "aiLine":
            "Hey! I'm Riya. Before we jump in — just tell me who you are. Don't rehearse it, just talk.",
        "instruction":
            "Tap the mic and introduce yourself for 30 seconds. Say your name, where you're from, and one thing you like. No perfect grammar needed.",
        "phrasesA": ["I'm from...", "One thing about me is...", "I enjoy..."],
        "phrasesB": [
          "I am...",
          "My name is...",
          "I am from...",
          "Nice to meet you"
        ],
        "script": [
          "Riya: What should I call you?",
          "You: I'm Aditya, I'm from Pune."
        ],
        "wpm": 80,
        "filler": "≤6/min",
      },
      {
        "d": 2,
        "theme": "Daily Routine",
        "persona": "riya",
        "mode": "foundation",
        "aiLine":
            "Walk me through your morning — start from the moment you wake up.",
        "instruction":
            "Describe your daily routine out loud. Use present tense. Try for 5 sentences without stopping.",
        "phrasesA": ["Right after I wake up...", "Before I leave for work..."],
        "phrasesB": [
          "I wake up at...",
          "I eat breakfast",
          "I go to...",
          "I sleep at..."
        ],
        "script": [
          "Riya: What's the first thing you do after waking up?",
          "You: I check my phone, then I make tea."
        ],
        "wpm": 82,
        "filler": "≤6/min",
      },
      {
        "d": 3,
        "theme": "Family & People",
        "persona": "riya",
        "mode": "foundation",
        "aiLine": "Tell me about someone important in your life.",
        "instruction":
            "Pick 3 people close to you. Describe each one in 2–3 sentences — who they are and one thing about them.",
        "phrasesA": [
          "What stands out about them is...",
          "We're close because..."
        ],
        "phrasesB": [
          "This is my...",
          "He is...",
          "She is...",
          "We live together"
        ],
        "script": [
          "Riya: Who's someone you talk to every day?",
          "You: My sister — she is funny and very supportive."
        ],
        "wpm": 84,
        "filler": "≤5/min",
      },
      {
        "d": 4,
        "theme": "Likes & Dislikes",
        "persona": "riya",
        "mode": "foundation",
        "aiLine": "What do you love? And what can you totally skip?",
        "instruction":
            "Share 3 things you like and 3 you don't — and give a quick reason for each.",
        "phrasesA": ["What I really enjoy is...", "I could do without..."],
        "phrasesB": ["I like...", "I don't like...", "...because"],
        "script": [
          "Riya: Coffee or tea?",
          "You: Tea — I don't like coffee, it's too strong for me."
        ],
        "wpm": 86,
        "filler": "≤5/min",
      },
      {
        "d": 5,
        "theme": "Numbers & Time",
        "persona": "riya",
        "mode": "foundation",
        "aiLine":
            "Quick fire round — tell me your phone number, no pausing between digits.",
        "instruction":
            "Say your age, phone number, and today's date out loud without hesitating.",
        "phrasesA": ["It's currently...", "My number is..."],
        "phrasesB": ["Numbers 1–100", "It's... o'clock", "Today is..."],
        "script": [
          "Riya: What time do you usually start work?",
          "You: Around nine thirty in the morning."
        ],
        "wpm": 88,
        "filler": "≤5/min",
      },
      {
        "d": 6,
        "theme": "Asking Questions",
        "persona": "riya",
        "mode": "foundation",
        "aiLine": "Your turn — ask me three questions about myself.",
        "instruction":
            "Ask Riya 3 questions using What, Where, or How. Listen to her answer before asking the next.",
        "phrasesA": ["Can I ask you something?", "What made you..."],
        "phrasesB": ["What...", "Where...", "When...", "Who...", "How..."],
        "script": [
          "You: Where are you from, Riya?",
          "Riya: I'm based in Bengaluru! Your turn to ask another."
        ],
        "wpm": 90,
        "filler": "≤4/min",
      },
      {
        "d": 7,
        "theme": "Milestone: The 60-Second Intro",
        "persona": "riya",
        "mode": "milestone",
        "aiLine":
            "Give me your best 60 seconds. I'm recording this one for your report.",
        "instruction":
            "Introduce yourself for a full 60 seconds — no script, no notes. This recording becomes your Week 1 baseline.",
        "phrasesA": ["(no scaffold — speak freely)"],
        "phrasesB": ["Use any phrases from Day 1–6"],
        "script": [
          "Riya: Ready when you are — just press and talk.",
          "You: (60-second free response)"
        ],
        "wpm": 92,
        "filler": "≤4/min",
        "milestoneReport": true,
      },
    ],
  },
  {
    "title": "Form & Technique · Build Real Sentences",
    "range": "Days 8–14",
    "days": [
      {
        "d": 8,
        "theme": "Food & Ordering",
        "persona": "rohan",
        "mode": "foundation",
        "aiLine":
            "Let's structure this: greeting, order, one follow-up question. Ready to order?",
        "instruction":
            "Roleplay ordering food at a restaurant. Greet, place your order, then answer Rohan's follow-up.",
        "phrasesA": [
          "I'll have the...",
          "Could I also get...",
          "Actually, can you make that..."
        ],
        "phrasesB": ["I would like...", "Can I get...", "For here or to go"],
        "script": [
          "Rohan: What can I get you today?",
          "You: I'd like a coffee and a sandwich, please."
        ],
        "wpm": 94,
        "filler": "≤4/min",
      },
      {
        "d": 9,
        "theme": "Directions",
        "persona": "rohan",
        "mode": "foundation",
        "aiLine":
            "Break it into three steps — where you are, where you're going, how to get there.",
        "instruction":
            "Give Rohan directions to a place near you. Then ask him for directions somewhere.",
        "phrasesA": [
          "Head towards...",
          "You can't miss it",
          "It's just past the..."
        ],
        "phrasesB": [
          "Turn left",
          "Turn right",
          "Go straight",
          "It's next to..."
        ],
        "script": [
          "Rohan: How do I get to the station from here?",
          "You: Go straight, then turn left at the signal."
        ],
        "wpm": 96,
        "filler": "≤4/min",
      },
      {
        "d": 10,
        "theme": "Shopping",
        "persona": "rohan",
        "mode": "foundation",
        "aiLine":
            "Let's map the negotiation — ask the price, counter it, then confirm.",
        "instruction":
            "Roleplay buying something. Ask the price, try negotiating once, then agree on a final price.",
        "phrasesA": ["Is that the best you can do?", "I'll take it for..."],
        "phrasesB": [
          "How much is this?",
          "Can I get a discount?",
          "I'll take it"
        ],
        "script": [
          "Rohan: That'll be 500 rupees.",
          "You: Can you do 400? I'll take two."
        ],
        "wpm": 98,
        "filler": "≤3/min",
      },
      {
        "d": 11,
        "theme": "Weather & Small Talk",
        "persona": "rohan",
        "mode": "foundation",
        "aiLine":
            "Structured small talk still needs a plan — opener, comment, question back.",
        "instruction":
            "Make small talk with Rohan for 1 minute. Comment on the weather, then ask him a question back.",
        "phrasesA": [
          "Can you believe this weather?",
          "How's your day going so far?"
        ],
        "phrasesB": ["It is hot/cold/sunny", "Nice weather today"],
        "script": [
          "Rohan: It's really humid today, isn't it?",
          "You: Yes, definitely. Do you like this season?"
        ],
        "wpm": 100,
        "filler": "≤3/min",
      },
      {
        "d": 12,
        "theme": "Past Tense Stories",
        "persona": "rohan",
        "mode": "foundation",
        "aiLine": "Sequence it for me — what happened first, next, and last?",
        "instruction":
            "Tell Rohan 3 things you did yesterday, in order, using past tense.",
        "phrasesA": ["Right after that, I...", "By the end of the day..."],
        "phrasesB": ["I worked", "I watched", "I called", "I walked"],
        "script": [
          "Rohan: What did you do yesterday evening?",
          "You: I finished work, then I called my friend."
        ],
        "wpm": 102,
        "filler": "≤3/min",
      },
      {
        "d": 13,
        "theme": "Future Plans",
        "persona": "rohan",
        "mode": "foundation",
        "aiLine": "Structure your plan — goal, steps, timeline.",
        "instruction":
            "Tell Rohan your plan for this weekend. Include at least 2 things you'll do.",
        "phrasesA": ["My plan is to...", "I'm hoping to..."],
        "phrasesB": ["I will...", "I am going to..."],
        "script": [
          "Rohan: Any plans this weekend?",
          "You: I'm going to visit my parents on Saturday."
        ],
        "wpm": 104,
        "filler": "≤3/min",
      },
      {
        "d": 14,
        "theme": "Milestone: First Group Discussion",
        "persona": "panel",
        "mode": "milestone",
        "aiLine":
            "Three pillars today — your ideas, your evidence, your turn-taking. Riya and I are both in the room.",
        "instruction":
            "Join a 2-minute group discussion with Riya and Rohan on a simple topic. Take at least 2 turns.",
        "phrasesA": ["(no scaffold — speak freely)"],
        "phrasesB": ["Use any phrases from Week 1–2"],
        "script": [
          "Rohan: Let's discuss — is remote work better than office work?",
          "Riya: I'd love to hear your take first!"
        ],
        "wpm": 106,
        "filler": "≤3/min",
        "milestoneReport": true,
      },
    ],
  },
  {
    "title": "Sparring · Real Conversations",
    "range": "Days 15–21",
    "days": [
      {
        "d": 15,
        "theme": "Phone Calls",
        "persona": "emily",
        "mode": "foundation",
        "aiLine":
            "Confidence starts with your opening line. Let's hear it — the phone's ringing.",
        "instruction":
            "Roleplay answering and making a phone call with Emily. Open, respond, and close politely.",
        "phrasesA": [
          "Speaking, how can I help?",
          "Could you repeat that, please?"
        ],
        "phrasesB": ["Hello, this is...", "Can I take a message?"],
        "script": [
          "Emily: Hi, is this Aditya?",
          "You: Yes, speaking. How can I help you?"
        ],
        "wpm": 108,
        "filler": "≤3/min",
      },
      {
        "d": 16,
        "theme": "Job Interview Basics",
        "persona": "emily",
        "mode": "foundation",
        "aiLine": "Tell me about yourself — and make me remember it.",
        "instruction":
            "Answer 2 common interview questions from Emily in under 60 seconds each.",
        "phrasesA": [
          "What sets me apart is...",
          "I'm particularly proud of..."
        ],
        "phrasesB": ["I have experience in...", "My strengths are..."],
        "script": [
          "Emily: Why should we hire you?",
          "You: I bring strong problem-solving skills and I learn fast."
        ],
        "wpm": 110,
        "filler": "≤2/min",
      },
      {
        "d": 17,
        "theme": "Expressing Opinions",
        "persona": "emily",
        "mode": "foundation",
        "aiLine": "I disagree — convince me otherwise.",
        "instruction":
            "Pick a simple topic. State your opinion, then respond when Emily pushes back.",
        "phrasesA": [
          "I see it differently because...",
          "That's fair, but consider..."
        ],
        "phrasesB": ["I think...", "In my opinion..."],
        "script": [
          "Emily: I think remote work hurts collaboration.",
          "You: I see your point, but it also removes commute stress."
        ],
        "wpm": 112,
        "filler": "≤2/min",
      },
      {
        "d": 18,
        "theme": "Problem Solving & Complaints",
        "persona": "emily",
        "mode": "foundation",
        "aiLine": "Stay calm — state the problem, then propose the fix.",
        "instruction":
            "Roleplay a complaint call. Explain the issue clearly and ask for a solution.",
        "phrasesA": ["Here's exactly what happened...", "What I'd like is..."],
        "phrasesB": ["There is a problem with...", "Can you help me fix..."],
        "script": [
          "Emily: What seems to be the issue?",
          "You: There's a problem with my order — it arrived damaged."
        ],
        "wpm": 114,
        "filler": "≤2/min",
      },
      {
        "d": 19,
        "theme": "Emotions & Feelings",
        "persona": "emily",
        "mode": "foundation",
        "aiLine": "Good and bad are boring words — give me something sharper.",
        "instruction":
            "Describe how you feel today using 3 different feeling words, and explain why for each.",
        "phrasesA": [
          "I'm a bit overwhelmed because...",
          "Honestly, I feel relieved that..."
        ],
        "phrasesB": ["I feel happy", "I feel tired", "I feel worried"],
        "script": [
          "Emily: How are you feeling about this week?",
          "You: A little tired, but hopeful about the weekend."
        ],
        "wpm": 116,
        "filler": "≤2/min",
      },
      {
        "d": 20,
        "theme": "Travel English",
        "persona": "emily",
        "mode": "foundation",
        "aiLine": "Handle the whole check-in. Don't let me throw you off.",
        "instruction":
            "Roleplay a hotel check-in from greeting to getting your room key.",
        "phrasesA": ["I have a reservation under...", "Is breakfast included?"],
        "phrasesB": ["I'd like to check in", "Here is my ID"],
        "script": [
          "Emily: Welcome! Do you have a reservation?",
          "You: Yes, it's under Aditya Sharma."
        ],
        "wpm": 118,
        "filler": "≤2/min",
      },
      {
        "d": 21,
        "theme": "Milestone: Free Conversation",
        "persona": "emily",
        "mode": "milestone",
        "aiLine": "Surprise topic, no prep. Go.",
        "instruction":
            "Have a free 3-minute conversation with Emily on a topic she picks. No scaffolding this time.",
        "phrasesA": ["(no scaffold — speak freely)"],
        "phrasesB": ["Use any phrases from Week 3"],
        "script": [
          "Emily: Let's talk about something unexpected — favorite childhood memory?",
          "You: (free response)"
        ],
        "wpm": 120,
        "filler": "≤2/min",
        "milestoneReport": true,
      },
    ],
  },
  {
    "title": "Competition Pace · Spontaneity & Debate",
    "range": "Days 22–28",
    "days": [
      {
        "d": 22,
        "theme": "Random Topic Speaking",
        "persona": "alex",
        "mode": "debate",
        "aiLine":
            "What if I hand you a topic you've never thought about? Talk anyway.",
        "instruction":
            "Alex will give you a random topic. Speak for 60 seconds with zero prep time.",
        "phrasesA": ["My initial reaction is...", "Thinking about it more..."],
        "phrasesB": ["I think... because...", "One example is..."],
        "script": [
          "Alex: Should schools teach coding from age 5?",
          "You: (60-second impromptu response)"
        ],
        "wpm": 122,
        "filler": "≤2/min",
      },
      {
        "d": 23,
        "theme": "Debate & Disagree Politely",
        "persona": "alex",
        "mode": "debate",
        "aiLine": "Challenge the core assumption — why must it be true?",
        "instruction":
            "Take a side in a mini-debate with Alex. Defend it for 2 exchanges.",
        "phrasesA": ["That assumes... but what if...", "I'd push back on..."],
        "phrasesB": ["I see your point, but...", "I disagree because..."],
        "script": [
          "Alex: Social media does more harm than good — agree?",
          "You: I see your point, but it also connects people globally."
        ],
        "wpm": 124,
        "filler": "≤1/min",
      },
      {
        "d": 24,
        "theme": "Storytelling",
        "persona": "alex",
        "mode": "debate",
        "aiLine": "Give me structure — setup, tension, resolution.",
        "instruction":
            "Tell Alex a 1-minute personal story with a clear beginning, middle, and end.",
        "phrasesA": ["It all started when...", "In the end..."],
        "phrasesB": ["First...", "Then...", "Finally..."],
        "script": [
          "Alex: Tell me about a time something went wrong.",
          "You: It all started when I missed my train..."
        ],
        "wpm": 126,
        "filler": "≤1/min",
      },
      {
        "d": 25,
        "theme": "Presenting an Idea",
        "persona": "alex",
        "mode": "debate",
        "aiLine": "Pitch it in 90 seconds. I'm timing you.",
        "instruction":
            "Pitch one idea to Alex in under 90 seconds. State the idea, why it matters, and one next step.",
        "phrasesA": ["The core idea is...", "Here's why this matters..."],
        "phrasesB": ["I want to talk about...", "My idea is..."],
        "script": [
          "Alex: What's your idea?",
          "You: I want to talk about a way to reduce commute time for teams."
        ],
        "wpm": 128,
        "filler": "≤1/min",
      },
      {
        "d": 26,
        "theme": "Handling Interruptions",
        "persona": "alex",
        "mode": "debate",
        "aiLine": "I'm going to cut you off mid-sentence. Recover.",
        "instruction":
            "Answer Alex's question. He'll interrupt you once — pick your sentence back up smoothly.",
        "phrasesA": ["As I was saying...", "Let me just finish this point..."],
        "phrasesB": ["Sorry, let me finish", "Can I continue?"],
        "script": [
          "Alex: Wait, that can't be — (interrupts)",
          "You: Sorry, let me finish — what I meant was..."
        ],
        "wpm": 130,
        "filler": "≤1/min",
      },
      {
        "d": 27,
        "theme": "Natural Fillers & Flow",
        "persona": "alex",
        "mode": "debate",
        "aiLine":
            "Even I say 'well, actually' sometimes — use it on purpose, not by accident.",
        "instruction":
            "Free-talk for 1 minute, deliberately using 2 natural connectors instead of silence.",
        "phrasesA": ["Well, actually...", "You know, ...", "That said..."],
        "phrasesB": ["So...", "Basically..."],
        "script": [
          "Alex: What do you think about AI in classrooms?",
          "You: Well, actually, I think it depends on the age group."
        ],
        "wpm": 132,
        "filler": "Controlled use",
      },
      {
        "d": 28,
        "theme": "Milestone: Group Discussion, All 4 Voices",
        "persona": "panel",
        "mode": "milestone",
        "aiLine": "Four perspectives, one topic. Hold your ground.",
        "instruction":
            "Join a 3-minute unscripted group discussion with all 4 AI partners. Speak at least 3 times.",
        "phrasesA": ["(no scaffold — speak freely)"],
        "phrasesB": ["Use any phrases from Week 4"],
        "script": [
          "Rohan: Let's structure the debate first.",
          "Alex: Or let's just dive in — what do you think?"
        ],
        "wpm": 134,
        "filler": "Minimal",
        "milestoneReport": true,
      },
    ],
  },
  {
    "title": "Test Match · Capstone",
    "range": "Days 29–30",
    "days": [
      {
        "d": 29,
        "theme": "Mixed Review: Surprise Panel",
        "persona": "panel",
        "mode": "group",
        "aiLine":
            "Three scenarios, zero warning. Let's see everything you've built.",
        "instruction":
            "Complete 3 surprise scenarios pulled from Weeks 1–4, back to back, no prep between them.",
        "phrasesA": ["(no scaffold — speak freely)"],
        "phrasesB": ["Use any phrase from the whole program"],
        "script": [
          "Riya: Scenario 1 — introduce yourself to a new colleague.",
          "You: (free response, then Alex jumps in with Scenario 2)"
        ],
        "wpm": 135,
        "filler": "0–1/min",
      },
      {
        "d": 30,
        "theme": "Final Certification: 1:1 Debate vs Alex",
        "persona": "alex",
        "mode": "milestone",
        "aiLine": "Last round. Convince me you've changed my mind.",
        "instruction":
            "Debate Alex for 3 minutes on a topic of his choice. This session generates your final certificate.",
        "phrasesA": ["(no scaffold — speak freely)"],
        "phrasesB": ["Use any phrase from the whole program"],
        "script": [
          "Alex: Final round — is remote learning as effective as in-person?",
          "You: (free 3-minute debate)"
        ],
        "wpm": 135,
        "filler": "0 Filler",
        "milestoneReport": true,
      },
    ],
  },
];
