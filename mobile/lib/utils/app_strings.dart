class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    // Greetings & App Header
    'good_morning': {
      'English': 'Good Morning',
      'Hindi': 'सुप्रभात',
      'Hinglish': 'Good Morning',
    },
    'good_afternoon': {
      'English': 'Good Afternoon',
      'Hindi': 'नमस्कार',
      'Hinglish': 'Good Afternoon',
    },
    'good_evening': {
      'English': 'Good Evening',
      'Hindi': 'शुभ संध्या',
      'Hinglish': 'Good Evening',
    },
    'keep_showing_up': {
      'English': 'Keep showing up',
      'Hindi': 'अभ्यास जारी रखें',
      'Hinglish': 'Practice jari rakhein',
    },

    // Main Navigation Tabs
    'tab_path': {
      'English': 'Fluency Track',
      'Hindi': 'फ्लूएंसी ट्रैक',
      'Hinglish': 'Fluency Track',
    },
    'tab_practice': {
      'English': 'Arena',
      'Hindi': 'एरिना',
      'Hinglish': 'Arena',
    },
    'tab_challenges': {
      'English': 'Daily Challenges',
      'Hindi': 'दैनिक चुनौतियाँ',
      'Hinglish': 'Daily Challenges',
    },

    // Home Stepper Steps
    'step_mode_title': {
      'English': 'Practice Mode',
      'Hindi': 'अभ्यास मोड चुनें',
      'Hinglish': 'Practice Mode select karein',
    },
    'step_partners_title': {
      'English': 'AI Voice Partners',
      'Hindi': 'AI पार्टनर चुनें',
      'Hinglish': 'AI Voice Partners select karein',
    },
    'step_topic_title': {
      'English': 'Category & Topic',
      'Hindi': 'श्रेणी और विषय',
      'Hinglish': 'Category & Topic',
    },
    'step_difficulty_title': {
      'English': 'Difficulty Level',
      'Hindi': 'कठिनाई का स्तर',
      'Hinglish': 'Difficulty Level',
    },

    // Mode Selection
    'mode_gd': {
      'English': 'Group Discussion',
      'Hindi': 'समूह चर्चा (GD)',
      'Hinglish': 'Group Discussion (GD)',
    },
    'mode_gd_desc': {
      'English': 'Practice with 2-4 AI participants in a realistic GD environment',
      'Hindi': '2-4 AI प्रतिभागियों के साथ वास्तविक वातावरण में अभ्यास करें',
      'Hinglish': '2-4 AI participants ke saath realistic GD mein practice karein',
    },
    'mode_debate': {
      'English': '1:1 Debate',
      'Hindi': '1:1 वाद-विवाद',
      'Hinglish': '1:1 Debate',
    },
    'mode_debate_desc': {
      'English': 'Face a dedicated opponent who challenges your arguments directly',
      'Hindi': 'एक AI प्रतिद्वंद्वी से सीधे अपने तर्कों की चुनौती लें',
      'Hinglish': 'AI opponent ke saath direct debate karein aur logic test karein',
    },

    // Difficulty Labels
    'diff_beginner': {
      'English': 'Beginner',
      'Hindi': 'शुरुआती (Beginner)',
      'Hinglish': 'Beginner (आसान)',
    },
    'diff_intermediate': {
      'English': 'Intermediate',
      'Hindi': 'मध्यम (Intermediate)',
      'Hinglish': 'Intermediate (मध्यम)',
    },
    'diff_advanced': {
      'English': 'Advanced',
      'Hindi': 'उन्नत (Advanced)',
      'Hinglish': 'Advanced (कठिन)',
    },

    // Action Buttons
    'start_discussion': {
      'English': 'Start Session',
      'Hindi': 'शुरू करें',
      'Hinglish': 'Start Karein',
    },
    'start_debate': {
      'English': 'Start Session',
      'Hindi': 'शुरू करें',
      'Hinglish': 'Start Karein',
    },
    'next': {
      'English': 'Next',
      'Hindi': 'आगे बढ़ें',
      'Hinglish': 'Next',
    },
    'back': {
      'English': 'Back',
      'Hindi': 'पीछे',
      'Hinglish': 'Back',
    },

    // Arena Controls
    'ai_speaking': {
      'English': 'AI is speaking...',
      'Hindi': 'AI बोल रहा है...',
      'Hinglish': 'AI bol raha hai...',
    },
    'your_turn': {
      'English': 'Your turn to speak',
      'Hindi': 'आपकी बोलने की बारी',
      'Hinglish': 'Aapki turn hai bolne ki',
    },
    'hold_to_speak': {
      'English': 'Hold to Speak',
      'Hindi': 'बोलने के लिए दबाएं',
      'Hinglish': 'Hold to Speak',
    },
    'end_session': {
      'English': 'End Discussion',
      'Hindi': 'चर्चा समाप्त करें',
      'Hinglish': 'Session end karein',
    },

    // Profile & Settings Modal
    'profile_title': {
      'English': 'Profile & Settings',
      'Hindi': 'प्रोफ़ाइल और सेटिंग्स',
      'Hinglish': 'Profile & Settings',
    },
    'app_language': {
      'English': 'App Content Language',
      'Hindi': 'ऐप की भाषा (Language)',
      'Hinglish': 'App Content Language',
    },
    'learner_track': {
      'English': 'Learner Track',
      'Hindi': 'सीखने का ट्रैक',
      'Hinglish': 'Learner Track',
    },
    'theme': {
      'English': 'Theme',
      'Hindi': 'थीम',
      'Hinglish': 'Theme',
    },
    'session_history': {
      'English': 'Session History',
      'Hindi': 'सत्र का इतिहास',
      'Hinglish': 'Session History',
    },
    'logout': {
      'English': 'Log out',
      'Hindi': 'लॉग आउट',
      'Hinglish': 'Log out',
    },
  };

  static String get(String key, String language) {
    if (!_localizedValues.containsKey(key)) {
      return key;
    }
    final map = _localizedValues[key]!;
    return map[language] ?? map['English'] ?? key;
  }
}
