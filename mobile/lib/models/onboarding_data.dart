import 'dart:convert';

class OnboardingData {
  String preferredLanguage; // 'English', 'Hindi', 'Hinglish' or '' (unselected)
  String cefrLevel; // 'A1', 'A2', 'B1', 'B2', 'C1' or '' (unselected)
  List<String> selectedGoals; // Multi-select list of focus area goals
  int dailyGoalMinutes; // 5, 10, 15, 30 or 0 (unselected)
  Map<String, dynamic>
      customAnswers; // Extensible key-value map for future steps
  bool isOnboarded;

  OnboardingData({
    this.preferredLanguage = '',
    this.cefrLevel = '',
    List<String>? selectedGoals,
    this.dailyGoalMinutes = 0,
    Map<String, dynamic>? customAnswers,
    this.isOnboarded = false,
  })  : selectedGoals = selectedGoals ?? [],
        customAnswers = customAnswers ?? {};

  Map<String, dynamic> toJson() {
    return {
      'preferred_language': preferredLanguage,
      'cefr_level': cefrLevel,
      'primary_goals': selectedGoals,
      'daily_goal_minutes': dailyGoalMinutes,
      'custom_answers': customAnswers,
      'is_onboarded': isOnboarded,
    };
  }

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      preferredLanguage: json['preferred_language'] as String? ?? '',
      cefrLevel: json['cefr_level'] as String? ?? '',
      selectedGoals: (json['primary_goals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 0,
      customAnswers: (json['custom_answers'] as Map<String, dynamic>?) ?? {},
      isOnboarded: json['is_onboarded'] as bool? ?? false,
    );
  }

  String encodeJson() => jsonEncode(toJson());

  factory OnboardingData.decodeJson(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return OnboardingData.fromJson(map);
    } catch (_) {
      return OnboardingData();
    }
  }

  OnboardingData copyWith({
    String? preferredLanguage,
    String? cefrLevel,
    List<String>? selectedGoals,
    int? dailyGoalMinutes,
    Map<String, dynamic>? customAnswers,
    bool? isOnboarded,
  }) {
    return OnboardingData(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      selectedGoals: selectedGoals ?? List.from(this.selectedGoals),
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      customAnswers: customAnswers ?? Map.from(this.customAnswers),
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
