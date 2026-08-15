import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluentsoul_mobile/models/session.dart';
import 'package:fluentsoul_mobile/models/report.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';
import 'package:fluentsoul_mobile/services/audio_service.dart';
import 'package:fluentsoul_mobile/utils/error_utils.dart';

import 'package:fluentsoul_mobile/models/curriculum.dart';

class GDProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AudioService _audioService = AudioService();

  GDSession? _currentSession;
  FeedbackReport? _currentReport;
  List<GDMessage> _messages = [];
  Map<String, dynamic> _topics = {};

  // Curriculum state
  int _currentPathDay = 1;
  int _streakDays = 0;
  String _activeTrack = 'A';
  bool _reviewMode = false;
  List<int> _completedPathDays = [];
  CurriculumDay? _activePathDay;
  List<String> _activeScaffoldPhrases = [];
  List<CurriculumWeek> _weeks = [];
  Map<String, PersonaInfo> _personas = {};
  bool _isLoadingCurriculum = false;

  bool _isLoading = false;
  bool _isRecording = false;
  bool _isProcessingTurn = false;
  String? _activeSpeaker; // null = user, or persona key like "riya" / "meera"
  int _secondsRemaining = 0;
  Timer? _timer;
  String? _errorMessage;

  GDSession? get currentSession => _currentSession;
  FeedbackReport? get currentReport => _currentReport;
  List<GDMessage> get messages => _messages;
  Map<String, dynamic> get topics => _topics;

  int get currentPathDay => _currentPathDay;
  int get streakDays => _streakDays;
  String get activeTrack => _activeTrack;
  bool get reviewMode => _reviewMode;
  List<int> get completedPathDays => _completedPathDays;
  CurriculumDay? get activePathDay => _activePathDay;
  List<String> get activeScaffoldPhrases => _activeScaffoldPhrases;
  List<CurriculumWeek> get weeks => _weeks;
  Map<String, PersonaInfo> get personas => _personas;
  bool get isLoadingCurriculum => _isLoadingCurriculum;

  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isProcessingTurn => _isProcessingTurn;
  String? get activeSpeaker => _activeSpeaker;
  int get secondsRemaining => _secondsRemaining;
  String? get errorMessage => _errorMessage;
  AudioService get audioService => _audioService;

  GDProvider(this._apiService) {
    _weeks = WEEKS_DATA
        .map((w) => CurriculumWeek.fromJson(w))
        .toList();
    fetchCurriculum();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchCurriculum({String? track}) async {
    final trackToFetch = track ?? _activeTrack;
    _isLoadingCurriculum = true;
    notifyListeners();
    try {
      final data = await _apiService.getCurriculum(track: trackToFetch);
      final rawWeeks = data['weeks'] as List?;
      if (rawWeeks != null && rawWeeks.isNotEmpty) {
        _weeks = rawWeeks
            .map((w) => CurriculumWeek.fromJson(w as Map<String, dynamic>))
            .toList();
      } else if (_weeks.isEmpty) {
        _weeks = WEEKS_DATA
            .map((w) => CurriculumWeek.fromJson(w))
            .toList();
      }

      final rawPersonas = data['personas'] as Map<String, dynamic>? ?? {};
      if (rawPersonas.isNotEmpty) {
        _personas = rawPersonas.map((k, v) => MapEntry(
              k,
              PersonaInfo.fromJson(k, v as Map<String, dynamic>),
            ));
      }
    } catch (e) {
      debugPrint('Error fetching curriculum: $e');
      if (_weeks.isEmpty) {
        _weeks = WEEKS_DATA
            .map((w) => CurriculumWeek.fromJson(w))
            .toList();
      }
    } finally {
      _isLoadingCurriculum = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurriculumProgress() async {
    try {
      final res = await _apiService.getCurriculumProgress();
      final prog = CurriculumProgress.fromJson(res);
      _currentPathDay = prog.currentDay;
      _streakDays = prog.streakDays;
      _activeTrack = prog.activeTrack;
      _reviewMode = prog.reviewMode;
      _completedPathDays = prog.completedDays;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching curriculum progress: $e');
    }
  }

  Future<void> completeDay(int dayNumber) async {
    if (!_completedPathDays.contains(dayNumber)) {
      _completedPathDays.add(dayNumber);
      _completedPathDays.sort();
    }
    if (_currentPathDay <= dayNumber) {
      _currentPathDay = dayNumber + 1;
    }
    notifyListeners();
    try {
      await _apiService.updateCurriculumProgress(
        completedDay: dayNumber,
        currentDay: _currentPathDay,
      );
    } catch (e) {
      debugPrint('Error updating curriculum progress: $e');
    }
  }

  Future<void> resetToDay1() async {
    _streakDays = 0;
    _currentPathDay = 1;
    _completedPathDays = [];
    _reviewMode = false;
    _activeTrack = 'A';
    notifyListeners();
    try {
      await _apiService.updateCurriculumProgress(reset: true);
    } catch (_) {}
  }

  void setActiveTrack(String track) {
    _activeTrack = track;
    notifyListeners();
    fetchCurriculum(track: track);
  }

  void setReviewMode(bool mode) {
    _reviewMode = mode;
    notifyListeners();
    _apiService.updateCurriculumProgress(reviewMode: mode);
  }

  Future<bool> startPathDaySession({
    required CurriculumDay day,
    required String track,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _activePathDay = day;
    _activeTrack = track;
    _activeScaffoldPhrases = track == 'A' ? day.phrasesA : day.phrasesB;
    notifyListeners();

    try {
      final List<String> personaKeys = day.persona == 'panel'
          ? ['riya', 'rohan', 'emily', 'alex']
          : [day.persona];

      _currentSession = await _apiService.createSession(
        topic: day.theme,
        category: day.mode,
        difficulty: 'intermediate',
        durationMinutes: day.mode == 'milestone' ? 5 : 3,
        personaKeys: personaKeys,
        dayNumber: day.d,
        initialAiText: day.aiLine,
        scaffoldPhrases: _activeScaffoldPhrases,
      );

      _messages = [
        GDMessage(
          id: 'initial_turn',
          sessionId: _currentSession?.id ?? '',
          personaKey: personaKeys[0],
          speakerType: 'persona',
          transcript: day.aiLine,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];
      _secondsRemaining = (day.mode == 'milestone' ? 5 : 3) * 60;
      _startTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTopics({String language = 'English'}) async {
    try {
      final res = await _apiService.getTopics(language: language);
      _topics = res['categories'] as Map<String, dynamic>? ?? {};
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching topics: $e');
    }
  }

  Future<bool> startSession({
    required String topic,
    required String category,
    required String difficulty,
    int durationMinutes = 10,
    List<String>? personaKeys,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _apiService.createSession(
        topic: topic,
        category: category,
        difficulty: difficulty,
        durationMinutes: durationMinutes,
        personaKeys: personaKeys,
      );

      try {
        _messages = await _apiService.getMessages(_currentSession!.id);
      } catch (_) {
        _messages = [];
      }

      _secondsRemaining = durationMinutes * 60;
      _startTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> startRecording() async {
    try {
      await _audioService.startRecording();
      _isRecording = true;
      _activeSpeaker = 'user';
      notifyListeners();
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
      notifyListeners();
    }
  }

  Future<void> stopRecordingAndSubmit() async {
    if (!_isRecording || _currentSession == null) return;

    _isRecording = false;
    _isProcessingTurn = true;
    _activeSpeaker = null;
    notifyListeners();

    try {
      final filePath = await _audioService.stopRecording();
      if (filePath == null) throw Exception('No audio recorded');

      final file = File(filePath);
      if (!await file.exists() || await file.length() < 2000) {
        _errorMessage = 'Please hold the mic button to speak';
        _isProcessingTurn = false;
        notifyListeners();
        return;
      }

      final turnRes =
          await _apiService.submitTurn(_currentSession!.id, filePath);

      _messages.add(GDMessage(
        id: 'user_${turnRes.turnIndex - 1}',
        sessionId: _currentSession!.id,
        speakerType: 'user',
        personaKey: null,
        transcript: turnRes.userTranscript,
        createdAt: DateTime.now().toIso8601String(),
      ));

      _messages.add(GDMessage(
        id: 'ai_${turnRes.turnIndex}',
        sessionId: _currentSession!.id,
        speakerType: 'persona',
        personaKey: turnRes.aiSpeaker,
        transcript: turnRes.aiText,
        createdAt: DateTime.now().toIso8601String(),
      ));

      _secondsRemaining = turnRes.secondsRemaining;

      // Processing done! Stop mic spinner immediately
      _isProcessingTurn = false;
      _activeSpeaker = turnRes.aiSpeaker;
      notifyListeners();

      // Play synthesized AI speech audio
      if (turnRes.aiAudioBase64.isNotEmpty) {
        await _audioService.playBase64Audio(turnRes.aiAudioBase64);
      }
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
    } finally {
      _isProcessingTurn = false;
      _activeSpeaker = null;
      notifyListeners();
    }
  }

  Future<bool> endSession() async {
    if (_currentSession == null) return false;
    _timer?.cancel();
    _isLoading = true;
    notifyListeners();

    try {
      _currentReport = await _apiService.endSession(_currentSession!.id);

      // Unlock next day if finishing a path session
      if (_activePathDay != null) {
        final finishedDayNum = _activePathDay!.d;
        if (!_completedPathDays.contains(finishedDayNum)) {
          _completedPathDays.add(finishedDayNum);
        }
        if (_currentPathDay <= finishedDayNum) {
          _currentPathDay = finishedDayNum + 1;
        }
        try {
          await _apiService.updateCurriculumProgress(
            currentDay: _currentPathDay,
            completedDay: finishedDayNum,
            activeTrack: _activeTrack,
          );
        } catch (_) {}
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadReport(String sessionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentReport = await _apiService.getReport(sessionId);
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPastSession(String sessionId) async {
    _isLoading = true;
    _currentReport = null;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentSession = await _apiService.getSession(sessionId);
      _messages = await _apiService.getMessages(sessionId);

      try {
        _currentReport = await _apiService.getReport(sessionId);
      } catch (_) {
        // If report is not generated yet and session has messages, generate it via endSession
        if (_messages.isNotEmpty) {
          _currentReport = await _apiService.endSession(sessionId);
        }
      }
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
