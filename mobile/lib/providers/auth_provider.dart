import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluentsoul_mobile/config/constants.dart';
import 'package:fluentsoul_mobile/models/user.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';
import 'package:fluentsoul_mobile/utils/error_utils.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  String? _token;
  bool _isInitializing = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isInitializing => _isInitializing;
  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _isInitializing || _isSubmitting;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._apiService) {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      _token = await _storage.read(key: AppConstants.tokenKey);
      if (_token != null && _token!.isNotEmpty) {
        _apiService.setAuthToken(_token);
        try {
          _currentUser = await _apiService.getMe();
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          // Only purge token if it is explicitly unauthorized/invalid (401)
          if (errStr.contains('401') ||
              errStr.contains('invalid') ||
              errStr.contains('expired')) {
            _token = null;
            _currentUser = null;
            _apiService.setAuthToken(null);
            await _storage.delete(key: AppConstants.tokenKey);
          }
        }
      }
    } catch (_) {
      _token = null;
      _currentUser = null;
      _apiService.setAuthToken(null);
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.login(email, password);
      _token = res.accessToken;
      _currentUser = res.user;
      _apiService.setAuthToken(_token);
      await _storage.write(key: AppConstants.tokenKey, value: _token);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.register(email, password, name);
      _token = res.accessToken;
      _currentUser = res.user;
      _apiService.setAuthToken(_token);
      await _storage.write(key: AppConstants.tokenKey, value: _token);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = formatUserFriendlyError(e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _apiService.setAuthToken(null);
    await _storage.delete(key: AppConstants.tokenKey);
    notifyListeners();
  }
}
