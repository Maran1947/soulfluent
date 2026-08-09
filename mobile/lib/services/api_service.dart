import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:fluentsoul_mobile/config/constants.dart';
import 'package:fluentsoul_mobile/models/user.dart';
import 'package:fluentsoul_mobile/models/session.dart';
import 'package:fluentsoul_mobile/models/report.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? AppConstants.baseUrl;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Auth APIs
  Future<TokenResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to log in');
    }

    return TokenResponse.fromJson(jsonDecode(response.body));
  }

  Future<TokenResponse> register(
      String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to register');
    }

    return TokenResponse.fromJson(jsonDecode(response.body));
  }

  Future<User> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ??
            'Failed to get user profile (${response.statusCode})');
      } catch (_) {
        throw Exception('Failed to get user profile (${response.statusCode})');
      }
    }

    return User.fromJson(jsonDecode(response.body));
  }

  // GD Topic & Session APIs
  Future<Map<String, dynamic>> getTopics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/gd/topics'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load topic library');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<GDSession> createSession({
    required String topic,
    required String category,
    required String difficulty,
    int durationMinutes = 10,
    List<String>? personaKeys,
    int? dayNumber,
    String? initialAiText,
    List<String>? scaffoldPhrases,
  }) async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Not authenticated. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/gd/sessions'),
      headers: _headers,
      body: jsonEncode({
        'topic': topic,
        'category': category,
        'difficulty': difficulty,
        'duration_minutes': durationMinutes,
        if (personaKeys != null && personaKeys.isNotEmpty)
          'persona_keys': personaKeys,
        if (dayNumber != null) 'day_number': dayNumber,
        if (initialAiText != null) 'initial_ai_text': initialAiText,
        if (scaffoldPhrases != null) 'scaffold_phrases': scaffoldPhrases,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create session');
    }

    return GDSession.fromJson(jsonDecode(response.body));
  }

  // Curriculum APIs
  Future<Map<String, dynamic>> getCurriculum() async {
    final response = await http.get(
      Uri.parse('$baseUrl/curriculum'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load curriculum');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurriculumProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/curriculum/progress'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load curriculum progress');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCurriculumProgress({
    int? currentDay,
    String? activeTrack,
    bool? reviewMode,
    int? completedDay,
    bool? reset,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/curriculum/progress'),
      headers: _headers,
      body: jsonEncode({
        if (currentDay != null) 'current_day': currentDay,
        if (activeTrack != null) 'active_track': activeTrack,
        if (reviewMode != null) 'review_mode': reviewMode,
        if (completedDay != null) 'completed_day': completedDay,
        if (reset != null) 'reset': reset,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update curriculum progress');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<GDSession> getSession(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gd/sessions/$sessionId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch session details');
    }

    return GDSession.fromJson(jsonDecode(response.body));
  }

  Future<List<GDSession>> listSessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/gd/sessions'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch sessions history');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((item) => GDSession.fromJson(item)).toList();
  }

  // Submit Turn (Multipart Voice Audio Upload)
  Future<TurnResponse> submitTurn(String sessionId, String filePath,
      {double durationSeconds = 5.0}) async {
    final uri = Uri.parse('$baseUrl/gd/sessions/$sessionId/turn');
    final request = http.MultipartRequest('POST', uri);

    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }

    final file = File(filePath);
    final filename = file.path.split('/').last;

    request.fields['duration_seconds'] = durationSeconds.toString();

    final isM4a = filename.toLowerCase().endsWith('.m4a');
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      filePath,
      filename: filename,
      contentType:
          isM4a ? MediaType('audio', 'm4a') : MediaType('audio', 'webm'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to submit voice turn');
    }

    return TurnResponse.fromJson(jsonDecode(response.body));
  }

  // Get Messages for Session
  Future<List<GDMessage>> getMessages(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gd/sessions/$sessionId/messages'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch session messages');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((item) => GDMessage.fromJson(item)).toList();
  }

  // End Session
  Future<FeedbackReport> endSession(String sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/gd/sessions/$sessionId/end'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to end session');
    }

    return FeedbackReport.fromJson(jsonDecode(response.body));
  }

  // Get Report
  Future<FeedbackReport> getReport(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gd/sessions/$sessionId/report'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load session report');
    }

    return FeedbackReport.fromJson(jsonDecode(response.body));
  }

  // Get Usage
  Future<Map<String, dynamic>> getUsage(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gd/sessions/$sessionId/usage'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load session usage');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
