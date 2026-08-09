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
    final rawSpeaker =
        json['speaker'] as String? ?? json['speaker_type'] as String? ?? 'user';
    final isUser = rawSpeaker == 'user';
    return GDMessage(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      personaKey:
          isUser ? null : (json['persona_key'] as String? ?? rawSpeaker),
      speakerType: isUser ? 'user' : 'persona',
      transcript:
          json['text'] as String? ?? json['transcript'] as String? ?? '',
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
      difficulty: json['difficulty'] as String? ?? 'intermediate',
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
  final String userTranscript;
  final String aiSpeaker;
  final String aiSpeakerName;
  final String aiText;
  final String aiAudioBase64;
  final int turnIndex;
  final int secondsRemaining;
  final String sessionStatus;

  TurnResponse({
    required this.userTranscript,
    required this.aiSpeaker,
    required this.aiSpeakerName,
    required this.aiText,
    required this.aiAudioBase64,
    required this.turnIndex,
    required this.secondsRemaining,
    required this.sessionStatus,
  });

  factory TurnResponse.fromJson(Map<String, dynamic> json) {
    return TurnResponse(
      userTranscript: json['user_transcript'] as String? ?? '',
      aiSpeaker: json['ai_speaker'] as String? ?? '',
      aiSpeakerName: json['ai_speaker_name'] as String? ?? '',
      aiText: json['ai_text'] as String? ?? '',
      aiAudioBase64: json['ai_audio_base64'] as String? ?? '',
      turnIndex: (json['turn_index'] as num?)?.toInt() ?? 0,
      secondsRemaining: (json['seconds_remaining'] as num?)?.toInt() ?? 0,
      sessionStatus: json['session_status'] as String? ?? 'active',
    );
  }
}
