import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language_preference';
  final ApiService _apiService = ApiService();

  Locale _locale = const Locale('hi', 'IN');

  Locale get locale => _locale;

  String get languageString {
    if (_locale.languageCode == 'hi') {
      if (_locale.countryCode == 'IN') return 'Hinglish';
      return 'Hindi';
    }
    return 'English';
  }

  LocaleProvider() {
    _initLocale();
  }

  Future<void> _initLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(_prefKey);
      if (savedLang != null && savedLang.isNotEmpty) {
        _locale = _parseLocale(savedLang);
      } else {
        _locale = const Locale('hi', 'IN');
      }
      notifyListeners();
    } catch (_) {}
  }

  static Locale _parseLocale(String lang) {
    switch (lang.trim().toLowerCase()) {
      case 'hinglish':
      case 'hi_in':
      case 'en_in':
      case 'hi_en':
        return const Locale('hi', 'IN');
      case 'hindi':
      case 'hi':
        return const Locale('hi');
      case 'english':
      case 'en':
      default:
        return const Locale('en');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageString);
      await _apiService.updateUserPreferences({'app_language': languageString});
    } catch (_) {}
  }

  Future<void> setLanguageString(String langString) async {
    final parsed = _parseLocale(langString);
    await setLocale(parsed);
  }

  Future<void> syncFromBackend(String? backendLanguage) async {
    if (backendLanguage == null || backendLanguage.isEmpty) return;
    final backendLocale = _parseLocale(backendLanguage);
    if (_locale != backendLocale) {
      _locale = backendLocale;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageString);
    }
  }
}
