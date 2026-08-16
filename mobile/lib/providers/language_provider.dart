import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';
import 'package:fluentsoul_mobile/utils/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  String _currentLanguage =
      'Hinglish'; // Default 'Hinglish', 'Hindi', or 'English'

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final savedLang = await _storage.read(key: 'app_language');
      if (savedLang != null && savedLang.isNotEmpty) {
        _currentLanguage = savedLang;
      } else {
        _currentLanguage = 'Hinglish';
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(String lang) async {
    if (lang != 'English' && lang != 'Hindi' && lang != 'Hinglish') return;
    _currentLanguage = lang;
    notifyListeners();

    try {
      await _storage.write(key: 'app_language', value: lang);
      // Sync to backend preferences asynchronously
      await _apiService.updateUserPreferences({'app_language': lang});
    } catch (_) {}
  }

  String text(String key) {
    return AppStrings.get(key, _currentLanguage);
  }
}
