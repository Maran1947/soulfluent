import 'package:fluentsoul_mobile/models/challenge.dart';

const Map<String, Zone> ZONES_DATA = {
  'confidence': Zone(
    id: 'confidence',
    name: 'Confidence zone',
    icon: 'ti-heart',
    color: 'pink',
    tagline: 'Face the nerves, on purpose',
  ),
  'speed': Zone(
    id: 'speed',
    name: 'Speed zone',
    icon: 'ti-bolt',
    color: 'teal',
    tagline: 'Think fast, talk faster',
  ),
  'social': Zone(
    id: 'social',
    name: 'Social zone',
    icon: 'ti-users',
    color: 'purple',
    tagline: 'Practice with other learners',
  ),
  'boss': Zone(
    id: 'boss',
    name: 'Boss battles',
    icon: 'ti-swords',
    color: 'coral',
    tagline: 'Rare, hard, worth it',
  ),
  'quiet': Zone(
    id: 'quiet',
    name: 'Quiet mode',
    icon: 'ti-moon',
    color: 'gray',
    tagline: 'No talking needed — keep the streak alive',
  ),
};

const List<Rank> RANKS_DATA = [
  Rank(id: 'bronze', name: 'Bronze', minXp: 0),
  Rank(id: 'silver', name: 'Silver rank', minXp: 500),
  Rank(id: 'gold', name: 'Gold rank', minXp: 1500),
  Rank(id: 'soul', name: 'Soul rank', minXp: 3500),
];

const List<Challenge> ALL_CHALLENGES = [
  // ---- VOICE: Confidence zone ----
  Challenge(
    id: 'say_it_scared',
    title: 'Say it scared',
    zone: 'confidence',
    requiresVoice: true,
    timerSeconds: 60,
    timerType: 'countdown',
    description:
        'Pick a topic that makes you nervous. Talk anyway. Journal how it felt after.',
    xp: 40,
    difficulty: 'silver',
    icon: 'ti-mood-empty',
    inDailyRotation: false,
    hasMoodCheckin: true,
  ),
  Challenge(
    id: 'silence_tolerance',
    title: 'Silence tolerance',
    zone: 'confidence',
    requiresVoice: true,
    timerSeconds: null,
    timerType: 'none',
    description:
        'Pause for a full 3 seconds mid-sentence on purpose. No filling it. No panic.',
    xp: 25,
    difficulty: 'bronze',
    icon: 'ti-player-pause',
    inDailyRotation: false,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'rescue_only',
    title: 'Rescue phrase only',
    zone: 'confidence',
    requiresVoice: true,
    timerSeconds: 90,
    timerType: 'countdown',
    description:
        'You\'re only allowed to survive using rescue phrases when stuck. No perfect answers expected.',
    xp: 30,
    difficulty: 'silver',
    icon: 'ti-lifebuoy',
    inDailyRotation: false,
    hasMoodCheckin: false,
  ),

  // ---- VOICE: Speed zone ----
  Challenge(
    id: 'show_and_tell',
    title: 'Show and tell',
    zone: 'speed',
    requiresVoice: true,
    timerSeconds: 45,
    timerType: 'countdown',
    description:
        'An image appears. Describe everything you see before the timer runs out.',
    xp: 20,
    difficulty: 'bronze',
    icon: 'ti-photo',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'one_breath',
    title: 'One breath challenge',
    zone: 'speed',
    requiresVoice: true,
    timerSeconds: null,
    timerType: 'count_up',
    description:
        'Pick a topic. Talk nonstop until you run out of breath. Beat yesterday\'s word count.',
    xp: 20,
    difficulty: 'bronze',
    icon: 'ti-wind',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'story_chain',
    title: 'Story chain',
    zone: 'speed',
    requiresVoice: true,
    timerSeconds: 120,
    timerType: 'countdown',
    description:
        'AI gives a sentence, you continue the story, AI continues again. Keep it going.',
    xp: 25,
    difficulty: 'bronze',
    icon: 'ti-books',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'zero_filler_minute',
    title: 'Zero-filler minute',
    zone: 'speed',
    requiresVoice: true,
    timerSeconds: 60,
    timerType: 'countdown',
    description:
        'Talk for 60 seconds with zero um/uh. Every filler resets your combo.',
    xp: 30,
    difficulty: 'silver',
    icon: 'ti-target-arrow',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),

  // ---- VOICE: Social zone ----
  Challenge(
    id: 'streak_squad',
    title: 'Streak squad',
    zone: 'social',
    requiresVoice: true,
    timerSeconds: null,
    timerType: 'none',
    description:
        'Join a group of 3-5 learners. Everyone must speak today or the squad streak breaks.',
    xp: 15,
    difficulty: 'bronze',
    icon: 'ti-users-group',
    inDailyRotation: false,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'topic_duel',
    title: 'Topic duel',
    zone: 'social',
    requiresVoice: true,
    timerSeconds: 60,
    timerType: 'countdown',
    description:
        'You and a friend answer the same prompt separately. Compare recordings after.',
    xp: 20,
    difficulty: 'bronze',
    icon: 'ti-swords',
    inDailyRotation: false,
    hasMoodCheckin: false,
  ),

  // ---- VOICE: Boss battles ----
  Challenge(
    id: 'interruption_test',
    title: 'The interruption test',
    zone: 'boss',
    requiresVoice: true,
    timerSeconds: 180,
    timerType: 'countdown',
    description: 'All 4 personas. 3 interruptions to recover from, live.',
    xp: 120,
    difficulty: 'gold',
    icon: 'ti-swords',
    inDailyRotation: false,
    hasMoodCheckin: true,
    unlock: 'weekly',
  ),
  Challenge(
    id: 'persona_gauntlet',
    title: 'Random persona gauntlet',
    zone: 'boss',
    requiresVoice: true,
    timerSeconds: 240,
    timerType: 'countdown',
    description:
        '4 unscripted questions, one from each AI persona, back to back.',
    xp: 100,
    difficulty: 'gold',
    icon: 'ti-crown',
    inDailyRotation: false,
    hasMoodCheckin: true,
    unlock: 'weekly',
  ),

  // ---- QUIET: no voice required ----
  Challenge(
    id: 'word_search_grid',
    title: 'Word Search Grid',
    zone: 'quiet',
    requiresVoice: false,
    timerSeconds: 90,
    timerType: 'countdown',
    description:
        'A letter grid with boundaries. Read 1-line definitions and find hidden words inside!',
    xp: 50,
    difficulty: 'silver',
    icon: 'ti-grid-dots',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'word_race',
    title: 'Word race',
    zone: 'quiet',
    requiresVoice: false,
    timerSeconds: 30,
    timerType: 'countdown',
    description:
        'A category appears. Type as many matching words as you can before time runs out.',
    xp: 10,
    difficulty: 'bronze',
    icon: 'ti-keyboard',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'listen_and_order',
    title: 'Listen and order',
    zone: 'quiet',
    requiresVoice: false,
    timerSeconds: null,
    timerType: 'none',
    description:
        'Hear 3 short clips out of order. Drag them into the correct sequence.',
    xp: 10,
    difficulty: 'bronze',
    icon: 'ti-arrows-sort',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'fill_the_gap',
    title: 'Fill the gap',
    zone: 'quiet',
    requiresVoice: false,
    timerSeconds: null,
    timerType: 'none',
    description: 'A sentence appears with a blank. Tap the word that fits.',
    xp: 8,
    difficulty: 'bronze',
    icon: 'ti-forms',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'emoji_translate',
    title: 'Emoji translate',
    zone: 'quiet',
    requiresVoice: false,
    timerSeconds: null,
    timerType: 'none',
    description: 'A sentence in emojis appears. Type what it means in English.',
    xp: 8,
    difficulty: 'bronze',
    icon: 'ti-mood-smile',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
  Challenge(
    id: 'mistake_hunt',
    title: 'Mistake hunt',
    zone: 'quiet',
    requiresVoice: false,
    timerSeconds: null,
    timerType: 'none',
    description:
        'A paragraph has 3 hidden grammar errors. Tap to find and fix them.',
    xp: 10,
    difficulty: 'bronze',
    icon: 'ti-search',
    inDailyRotation: true,
    hasMoodCheckin: false,
  ),
];

const List<String> DAILY_VOICE_ROTATION = [
  'show_and_tell',
  'one_breath',
  'story_chain',
  'zero_filler_minute',
];

const int QUIET_MODE_NUDGE_THRESHOLD = 2;
const String QUIET_MODE_NUDGE_MESSAGE = 'Ready to say it out loud?';
const int QUIET_MODE_DAILY_XP_CAP = 30;

Challenge? getChallenge(String id) {
  try {
    return ALL_CHALLENGES.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

List<Challenge> getChallengesByZone(String zoneId) {
  return ALL_CHALLENGES.where((c) => c.zone == zoneId).toList();
}

List<Challenge> getQuietModeChallenges() {
  return ALL_CHALLENGES.where((c) => !c.requiresVoice).toList();
}

List<Challenge> getVoiceChallenges() {
  return ALL_CHALLENGES.where((c) => c.requiresVoice).toList();
}

List<Challenge> getBossBattles() {
  return getChallengesByZone('boss');
}

Challenge getDailyChallenge(DateTime date) {
  final epoch = DateTime(1970, 1, 1);
  final daysSinceEpoch = date.difference(epoch).inDays;
  final index = daysSinceEpoch % DAILY_VOICE_ROTATION.length;
  final targetId = DAILY_VOICE_ROTATION[index];
  return getChallenge(targetId) ?? ALL_CHALLENGES[0];
}

RankProgress getRankProgress(int xp) {
  final ranksSorted = List<Rank>.from(RANKS_DATA)
    ..sort((a, b) => a.minXp.compareTo(b.minXp));
  Rank current = ranksSorted.first;
  Rank? nxt;
  for (int i = 0; i < ranksSorted.length; i++) {
    if (xp >= ranksSorted[i].minXp) {
      current = ranksSorted[i];
      nxt = i + 1 < ranksSorted.length ? ranksSorted[i + 1] : null;
    }
  }
  if (nxt == null) {
    return RankProgress(current: current, next: null, xp: xp, progress: 1.0);
  }
  final span = nxt.minXp - current.minXp;
  final progress = span > 0 ? (xp - current.minXp) / span : 1.0;
  return RankProgress(
    current: current,
    next: nxt,
    xp: xp,
    progress: progress.clamp(0.0, 1.0),
  );
}

bool shouldNudgeToVoice(int recentQuietStreak) {
  return recentQuietStreak >= QUIET_MODE_NUDGE_THRESHOLD;
}

int capQuietXp(int xpEarnedTodayQuiet) {
  return xpEarnedTodayQuiet < QUIET_MODE_DAILY_XP_CAP
      ? xpEarnedTodayQuiet
      : QUIET_MODE_DAILY_XP_CAP;
}
