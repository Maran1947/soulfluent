class SessionMetrics {
  final int durationSeconds;
  final int totalTurns;
  final int userTurnCount;
  final int userWordCount;
  final double userWpm;
  final double userTalkTimePct;
  final int fillerWordCount;
  final Map<String, dynamic> fillerWordsBreakdown;
  final Map<String, dynamic> personaTurnCounts;

  SessionMetrics({
    required this.durationSeconds,
    required this.totalTurns,
    required this.userTurnCount,
    required this.userWordCount,
    required this.userWpm,
    required this.userTalkTimePct,
    required this.fillerWordCount,
    required this.fillerWordsBreakdown,
    required this.personaTurnCounts,
  });

  factory SessionMetrics.fromJson(Map<String, dynamic> json) {
    return SessionMetrics(
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      totalTurns: (json['total_turns'] as num?)?.toInt() ?? 0,
      userTurnCount: (json['user_turn_count'] as num?)?.toInt() ?? 0,
      userWordCount: (json['user_word_count'] as num?)?.toInt() ?? 0,
      userWpm: (json['user_wpm'] as num?)?.toDouble() ?? 0.0,
      userTalkTimePct: (json['user_talk_time_pct'] as num?)?.toDouble() ?? 0.0,
      fillerWordCount: (json['filler_word_count'] as num?)?.toInt() ?? 0,
      fillerWordsBreakdown:
          json['filler_words_breakdown'] as Map<String, dynamic>? ?? {},
      personaTurnCounts:
          json['persona_turn_counts'] as Map<String, dynamic>? ?? {},
    );
  }
}

class FluencyMetrics {
  final double wordsPerMinute;
  final int fillerWordCount;
  final double averageSentenceLength;
  final double sentenceCompletionRate;

  FluencyMetrics({
    required this.wordsPerMinute,
    required this.fillerWordCount,
    required this.averageSentenceLength,
    required this.sentenceCompletionRate,
  });

  factory FluencyMetrics.fromJson(Map<String, dynamic> json) {
    return FluencyMetrics(
      wordsPerMinute: (json['words_per_minute'] as num?)?.toDouble() ?? 0.0,
      fillerWordCount: (json['filler_word_count'] as num?)?.toInt() ?? 0,
      averageSentenceLength:
          (json['average_sentence_length'] as num?)?.toDouble() ?? 0.0,
      sentenceCompletionRate:
          (json['sentence_completion_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class VocabularyMetrics {
  final List<String> grammarErrors;
  final List<String> phrasesToAvoid;
  final List<String> replacementSuggestions;
  final List<String> repeatedPhrases;
  final double vocabularyRichnessScore;

  VocabularyMetrics({
    required this.grammarErrors,
    required this.phrasesToAvoid,
    required this.replacementSuggestions,
    required this.repeatedPhrases,
    required this.vocabularyRichnessScore,
  });

  factory VocabularyMetrics.fromJson(Map<String, dynamic> json) {
    return VocabularyMetrics(
      grammarErrors: (json['grammar_errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      phrasesToAvoid: (json['phrases_to_avoid'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      replacementSuggestions:
          (json['replacement_suggestions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      repeatedPhrases: (json['repeated_phrases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      vocabularyRichnessScore:
          (json['vocabulary_richness_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ArgumentMetrics {
  final double relevanceScore;
  final int distinctPointsMade;
  final double talkTimePercentage;
  final int pointsChallengedByAi;
  final int pointsSuccessfullyDefended;

  ArgumentMetrics({
    required this.relevanceScore,
    required this.distinctPointsMade,
    required this.talkTimePercentage,
    required this.pointsChallengedByAi,
    required this.pointsSuccessfullyDefended,
  });

  factory ArgumentMetrics.fromJson(Map<String, dynamic> json) {
    return ArgumentMetrics(
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      distinctPointsMade: (json['distinct_points_made'] as num?)?.toInt() ?? 0,
      talkTimePercentage:
          (json['talk_time_percentage'] as num?)?.toDouble() ?? 0.0,
      pointsChallengedByAi:
          (json['points_challenged_by_ai'] as num?)?.toInt() ?? 0,
      pointsSuccessfullyDefended:
          (json['points_successfully_defended'] as num?)?.toInt() ?? 0,
    );
  }
}

class HighlightReel {
  final List<String> bestMoments;
  final List<String> improvementAreas;

  HighlightReel({
    required this.bestMoments,
    required this.improvementAreas,
  });

  factory HighlightReel.fromJson(Map<String, dynamic> json) {
    return HighlightReel(
      bestMoments: (json['best_moments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      improvementAreas: (json['improvement_areas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class FeedbackReport {
  final String id;
  final String sessionId;
  final int overallScore;
  final String summary;
  final List<String> strengths;
  final List<String> growthAreas;
  final SessionMetrics metrics;
  final FluencyMetrics fluencyMetrics;
  final VocabularyMetrics vocabularyMetrics;
  final ArgumentMetrics argumentMetrics;
  final Map<String, double> subScores;
  final HighlightReel highlightReel;
  final String recommendation;
  final int totalTokens;
  final double totalCostUsd;
  final String createdAt;

  FeedbackReport({
    required this.id,
    required this.sessionId,
    required this.overallScore,
    required this.summary,
    required this.strengths,
    required this.growthAreas,
    required this.metrics,
    required this.fluencyMetrics,
    required this.vocabularyMetrics,
    required this.argumentMetrics,
    required this.subScores,
    required this.highlightReel,
    required this.recommendation,
    required this.totalTokens,
    required this.totalCostUsd,
    required this.createdAt,
  });

  factory FeedbackReport.fromJson(Map<String, dynamic> json) {
    final subScoresRaw = json['sub_scores'] as Map<String, dynamic>? ?? {};
    final parsedSubScores =
        subScoresRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));

    final strengthsList = (json['strengths'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final growthList = (json['growth_areas'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final highlight = HighlightReel.fromJson(
        json['highlight_reel'] as Map<String, dynamic>? ?? {});

    return FeedbackReport(
      id: json['id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      strengths:
          strengthsList.isNotEmpty ? strengthsList : highlight.bestMoments,
      growthAreas:
          growthList.isNotEmpty ? growthList : highlight.improvementAreas,
      metrics: SessionMetrics.fromJson(
          json['metrics'] as Map<String, dynamic>? ?? {}),
      fluencyMetrics: FluencyMetrics.fromJson(
          json['fluency_metrics'] as Map<String, dynamic>? ?? {}),
      vocabularyMetrics: VocabularyMetrics.fromJson(
          json['vocabulary_metrics'] as Map<String, dynamic>? ?? {}),
      argumentMetrics: ArgumentMetrics.fromJson(
          json['argument_metrics'] as Map<String, dynamic>? ?? {}),
      subScores: parsedSubScores,
      highlightReel: highlight,
      recommendation: json['recommendation'] as String? ?? '',
      totalTokens: (json['total_tokens'] as num?)?.toInt() ?? 0,
      totalCostUsd: (json['total_cost_usd'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
