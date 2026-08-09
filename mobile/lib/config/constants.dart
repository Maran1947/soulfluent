import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'FluentSoul';
  
  // Default API URL: 10.0.2.2 for Android Emulator, localhost for iOS Simulator / Web / Mac
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    return 'http://localhost:8000/api/v1';
  }

  static const String tokenKey = 'fluentsoul_jwt_token';
}
