class Zone {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String tagline;

  const Zone({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.tagline,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
    );
  }
}

class Rank {
  final String id;
  final String name;
  final int minXp;

  const Rank({
    required this.id,
    required this.name,
    required this.minXp,
  });

  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      minXp: (json['min_xp'] as num?)?.toInt() ?? 0,
    );
  }
}

class RankProgress {
  final Rank current;
  final Rank? next;
  final int xp;
  final double progress;

  const RankProgress({
    required this.current,
    this.next,
    required this.xp,
    required this.progress,
  });
}

class Challenge {
  final String id;
  final String title;
  final String zone;
  final bool requiresVoice;
  final int? timerSeconds;
  final String timerType; // countdown, count_up, none
  final String description;
  final int xp;
  final String difficulty; // bronze, silver, gold
  final String icon;
  final bool inDailyRotation;
  final bool hasMoodCheckin;
  final String? unlock; // "weekly"

  const Challenge({
    required this.id,
    required this.title,
    required this.zone,
    required this.requiresVoice,
    this.timerSeconds,
    required this.timerType,
    required this.description,
    required this.xp,
    required this.difficulty,
    required this.icon,
    required this.inDailyRotation,
    required this.hasMoodCheckin,
    this.unlock,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      requiresVoice: json['requires_voice'] as bool? ?? true,
      timerSeconds: json['timer_seconds'] as int?,
      timerType: json['timer_type'] as String? ?? 'none',
      description: json['description'] as String? ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'bronze',
      icon: json['icon'] as String? ?? '',
      inDailyRotation: json['in_daily_rotation'] as bool? ?? false,
      hasMoodCheckin: json['has_mood_checkin'] as bool? ?? false,
      unlock: json['unlock'] as String?,
    );
  }
}
