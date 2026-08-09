import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluentsoul_mobile/models/session.dart';
import 'package:fluentsoul_mobile/models/report.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';
import 'package:fluentsoul_mobile/services/audio_service.dart';

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

  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isProcessingTurn => _isProcessingTurn;
  String? get activeSpeaker => _activeSpeaker;
  int get secondsRemaining => _secondsRemaining;
  String? get errorMessage => _errorMessage;
  AudioService get audioService => _audioService;

  GDProvider(this._apiService);

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
  }

  void setReviewMode(bool mode) {
    _reviewMode = mode;
    notifyListeners();
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTopics() async {
    try {
      final res = await _apiService.getTopics();
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

      _messages = [];
      _secondsRemaining = durationMinutes * 60;
      _startTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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

      final turnRes =
          await _apiService.submitTurn(_currentSession!.id, filePath);

      _messages.add(turnRes.userMessage);
      _messages.add(turnRes.aiMessage);
      _secondsRemaining = turnRes.secondsRemaining;

      // Set active AI speaker and play audio
      _activeSpeaker = turnRes.aiMessage.personaKey;
      notifyListeners();

      if (turnRes.aiMessage.audioUrl != null) {
        await _audioService.playAudioUrl(turnRes.aiMessage.audioUrl!);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _errorMessage = e.toString();
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
