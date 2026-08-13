import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'FluentSoul';

  static const String prodApiUrl = 'http://fluentsoul-api.qurutu.com/api/v1';

  // Dynamic API URL:
  // - Respects --dart-define=API_URL=... if specified
  // - Debug mode (flutter run): defaults to localhost:8000 (10.0.2.2 for Android emulator)
  // - Release mode (flutter build): defaults to production subdomain (http://fluentsoul-api.qurutu.com/api/v1)
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) return customUrl;

    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1';
      }
      return 'http://localhost:8000/api/v1';
    }

    return prodApiUrl;
  }

  static const String tokenKey = 'fluentsoul_jwt_token';
  static const String onboardingKey = 'fluentsoul_onboarding_data';
  static const String isOnboardedKey = 'fluentsoul_is_onboarded';
}
