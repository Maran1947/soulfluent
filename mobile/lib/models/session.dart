class Persona {
  final String key;
  final String name;
  final String personality;
  final String voiceName;

  Persona({
    required this.key,
    required this.name,
    required this.personality,
    required this.voiceName,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      personality: json['personality'] as String? ?? '',
      voiceName: json['voice_name'] as String? ?? '',
    );
  }
}

class GDMessage {
  final String id;
  final String sessionId;
  final String? personaKey;
  final String speakerType; // "user" or "persona"
  final String transcript;
  final String? audioUrl;
  final String createdAt;

  GDMessage({
    required this.id,
    required this.sessionId,
    this.personaKey,
    required this.speakerType,
    required this.transcript,
    this.audioUrl,
    required this.createdAt,
  });

  factory GDMessage.fromJson(Map<String, dynamic> json) {
    return GDMessage(
      id: json['id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      personaKey: json['persona_key'] as String?,
      speakerType: json['speaker_type'] as String? ?? 'user',
      transcript: json['transcript'] as String? ?? '',
      audioUrl: json['audio_url'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class GDSession {
  final String id;
  final String topic;
  final String category;
  final String difficulty;
  final int durationMinutes;
  final List<Persona> personas;
  final String status;
  final String startedAt;
  final String? endedAt;
  final List<GDMessage>? messages;

  GDSession({
    required this.id,
    required this.topic,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.personas,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.messages,
  });

  factory GDSession.fromJson(Map<String, dynamic> json) {
    return GDSession(
      id: json['id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'medium',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 10,
      personas: (json['personas'] as List<dynamic>?)
              ?.map((p) => Persona.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? 'active',
      startedAt: json['started_at'] as String? ?? '',
      endedAt: json['ended_at'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => GDMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TurnResponse {
  final GDMessage userMessage;
  final GDMessage aiMessage;
  final int secondsRemaining;

  TurnResponse({
    required this.userMessage,
    required this.aiMessage,
    required this.secondsRemaining,
  });

  factory TurnResponse.fromJson(Map<String, dynamic> json) {
    return TurnResponse(
      userMessage:
          GDMessage.fromJson(json['user_message'] as Map<String, dynamic>),
      aiMessage: GDMessage.fromJson(json['ai_message'] as Map<String, dynamic>),
      secondsRemaining: (json['seconds_remaining'] as num?)?.toInt() ?? 0,
    );
  }
}
