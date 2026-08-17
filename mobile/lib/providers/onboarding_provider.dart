import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluentsoul_mobile/config/constants.dart';
import 'package:fluentsoul_mobile/models/onboarding_data.dart';
import 'package:fluentsoul_mobile/models/onboarding_step.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/ai_preview_step_widget.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/cefr_step_widget.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/goals_step_widget.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/language_step_widget.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/plan_generator_step_widget.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/time_step_widget.dart';
import 'package:fluentsoul_mobile/widgets/onboarding/steps/voice_exercise_step_widget.dart';

class OnboardingProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  int _currentIndex = 0;
  OnboardingData _data = OnboardingData();
  bool _isLoading = true;

  int get currentIndex => _currentIndex;
  OnboardingData get data => _data;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _data.isOnboarded;

  /// Dynamic step registry with AI Preview Step 0 & Voice Exercise Step 5
  final List<OnboardingStepConfig> _steps = [
    OnboardingStepConfig(
      id: 'ai_preview',
      title: 'Welcome to FluentSoul',
      subtitle: 'Your Personal AI Spoken English Coach',
      icon: Icons.auto_awesome_rounded,
      isValid: (_) => true,
      builder: (context) => const AIPreviewStepWidget(),
    ),
    OnboardingStepConfig(
      id: 'language',
      title: 'App & Practice Language',
      subtitle: 'Select your preferred practice mode',
      icon: Icons.language_rounded,
      isValid: (data) => (data as OnboardingData).preferredLanguage.isNotEmpty,
      builder: (context) => const LanguageStepWidget(),
    ),
    OnboardingStepConfig(
      id: 'cefr',
      title: 'Speaking Assessment',
      subtitle: 'Select your current English speaking level',
      icon: Icons.bar_chart_rounded,
      isValid: (data) => (data as OnboardingData).cefrLevel.isNotEmpty,
      builder: (context) => const CEFRStepWidget(),
    ),
    OnboardingStepConfig(
      id: 'goals',
      title: 'Primary Focus Areas',
      subtitle: 'Select goals you wish to focus on',
      icon: Icons.track_changes_rounded,
      isValid: (data) => (data as OnboardingData).selectedGoals.isNotEmpty,
      builder: (context) => const GoalsStepWidget(),
    ),
    OnboardingStepConfig(
      id: 'time',
      title: 'Daily Commitment',
      subtitle: 'How much time can you commit each day?',
      icon: Icons.timer_rounded,
      isValid: (data) => (data as OnboardingData).dailyGoalMinutes > 0,
      builder: (context) => const TimeStepWidget(),
    ),
    OnboardingStepConfig(
      id: 'voice_exercise',
      title: 'Voice Warmup',
      subtitle: 'Prime your voice for daily speaking practice',
      icon: Icons.graphic_eq_rounded,
      isValid: (_) => true,
      builder: (context) => const VoiceExerciseStepWidget(),
    ),
    OnboardingStepConfig(
      id: 'plan_reveal',
      title: 'Personalized Plan',
      subtitle: 'Building your customized learning path',
      icon: Icons.stars_rounded,
      isValid: (_) => true,
      builder: (context) => const PlanGeneratorStepWidget(),
    ),
  ];

  List<OnboardingStepConfig> get steps => List.unmodifiable(_steps);
  OnboardingStepConfig get currentStep => _steps[_currentIndex];
  bool get isFirstStep => _currentIndex == 0;
  bool get isLastStep => _currentIndex == _steps.length - 1;
  double get progressRatio => (_currentIndex + 1) / _steps.length;

  OnboardingProvider() {
    initOnboarding();
  }

  Future<void> initOnboarding() async {
    try {
      final rawData = await _storage.read(key: AppConstants.onboardingKey);
      final isOnboardedStr =
          await _storage.read(key: AppConstants.isOnboardedKey);

      if (rawData != null && rawData.isNotEmpty) {
        _data = OnboardingData.decodeJson(rawData);
      }
      if (isOnboardedStr == 'true') {
        _data = _data.copyWith(isOnboarded: true);
      }
    } catch (_) {
      // fallback to default OnboardingData
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentIndex < _steps.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setLanguage(String lang) {
    _data = _data.copyWith(preferredLanguage: lang);
    notifyListeners();
  }

  void setCEFRLevel(String level) {
    _data = _data.copyWith(cefrLevel: level);
    notifyListeners();
  }

  void toggleGoal(String goalId) {
    final currentGoals = List<String>.from(_data.selectedGoals);
    if (currentGoals.contains(goalId)) {
      currentGoals.remove(goalId);
    } else {
      currentGoals.add(goalId);
    }
    _data = _data.copyWith(selectedGoals: currentGoals);
    notifyListeners();
  }

  void setDailyMinutes(int minutes) {
    _data = _data.copyWith(dailyGoalMinutes: minutes);
    notifyListeners();
  }

  void setCustomAnswer(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(_data.customAnswers);
    updated[key] = value;
    _data = _data.copyWith(customAnswers: updated);
    notifyListeners();
  }

  Future<void> completeOnboarding(BuildContext context) async {
    _data = _data.copyWith(isOnboarded: true);
    await _storage.write(
        key: AppConstants.onboardingKey, value: _data.encodeJson());
    await _storage.write(key: AppConstants.isOnboardedKey, value: 'true');
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  int _voiceExerciseLine = 0;
  int get voiceExerciseLine => _voiceExerciseLine;
  bool get isVoiceExerciseLastLine => _voiceExerciseLine >= 5;

  void setVoiceExerciseLine(int index) {
    _voiceExerciseLine = index;
    notifyListeners();
  }

  void nextVoiceExerciseLine() {
    if (_voiceExerciseLine < 5) {
      _voiceExerciseLine++;
      notifyListeners();
    }
  }

  void prevVoiceExerciseLine() {
    if (_voiceExerciseLine > 0) {
      _voiceExerciseLine--;
      notifyListeners();
    }
  }

  Future<void> resetOnboarding() async {
    _currentIndex = 0;
    _voiceExerciseLine = 0;
    _data = OnboardingData();
    await _storage.delete(key: AppConstants.onboardingKey);
    await _storage.delete(key: AppConstants.isOnboardedKey);
    notifyListeners();
  }
}
