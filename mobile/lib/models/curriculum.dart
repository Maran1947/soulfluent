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

typedef CurriculumDay = TrackNode;
typedef CurriculumWeek = RoadmapStage;
typedef CurriculumProgress = TrackProgress;

class TrackActivity {
  final String id;
  final int sequence;
  final String title;
  final String type;
  final Map<String, dynamic> config;
  final int estimatedMinutes;
  final bool isCompleted;

  const TrackActivity({
    required this.id,
    required this.sequence,
    required this.title,
    required this.type,
    required this.config,
    this.estimatedMinutes = 2,
    this.isCompleted = false,
  });

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'lesson':
        return 'CONTEXT LESSON';
      case 'listen_select':
      case 'echo':
        return 'LISTEN & ECHO';
      case 'forming_sentence':
      case 'production':
        return 'SENTENCE BUILD';
      case 'express_image':
        return 'IMAGE EXPRESS';
      case 'freestyle_speech':
        return 'FREE SPEECH';
      case 'ai_roleplay':
      case 'roleplay':
        return 'ROLEPLAY Practice';
      case 'debate_spar':
      case 'debate':
        return 'DEBATE SPARRING';
      case 'milestone_test':
        return 'MILESTONE TEST';
      default:
        return type.toUpperCase().replaceAll('_', ' ');
    }
  }

  factory TrackActivity.fromJson(Map<String, dynamic> json) {
    return TrackActivity(
      id: json['id']?.toString() ?? '',
      sequence: json['sequence'] ?? 1,
      title: json['title'] ?? json['type'] ?? 'Practice Activity',
      type: json['type'] ?? json['activity_type'] ?? 'lesson',
      config: json['config'] as Map<String, dynamic>? ?? {},
      estimatedMinutes: json['estimated_minutes'] ?? 2,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class TrackNode {
  final int d; // Sequence number / Unit number
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
  final List<TrackActivity> activities;

  const TrackNode({
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
    this.activities = const [],
  });

  int get unit => d;

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

  factory TrackNode.fromJson(Map<String, dynamic> json) {
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

    return TrackNode(
      d: json['d'] ?? json['unit'] ?? 1,
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
      activities: (json['activities'] as List? ?? [])
          .map((a) => TrackActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'd': d,
      'unit': d,
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

class RoadmapStage {
  final String title;
  final String range;
  final List<TrackNode> nodes;
  List<TrackNode> get days => nodes;

  const RoadmapStage({
    required this.title,
    required this.range,
    required this.nodes,
  });

  factory RoadmapStage.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List? ?? json['days'] as List? ?? [];
    return RoadmapStage(
      title: json['title'] ?? '',
      range: json['range'] ?? '',
      nodes: rawNodes
          .map((d) => TrackNode.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrackProgress {
  final int currentDay;
  final int streakDays;
  final String activeTrack; // 'UNFREEZE' or 'SCRATCH'
  final bool reviewMode;
  final List<int> completedDays;

  int get currentNode => currentDay;
  List<int> get completedNodes => completedDays;

  const TrackProgress({
    this.currentDay = 1,
    this.streakDays = 0,
    this.activeTrack = 'UNFREEZE',
    this.reviewMode = false,
    this.completedDays = const [],
  });

  factory TrackProgress.fromJson(Map<String, dynamic> json) {
    return TrackProgress(
      currentDay: json['current_day'] ?? json['current_node'] ?? 1,
      streakDays: json['streak_days'] ?? 0,
      activeTrack: json['active_track'] ?? 'UNFREEZE',
      reviewMode: json['review_mode'] ?? false,
      completedDays: List<int>.from(
          json['completed_days'] ?? json['completed_nodes'] ?? []),
    );
  }
}

final List<Map<String, dynamic>> ROADMAP_STAGES_DATA = const [];
final List<Map<String, dynamic>> WEEKS_DATA = const [];
