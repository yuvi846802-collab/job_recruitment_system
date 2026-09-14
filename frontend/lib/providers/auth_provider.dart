import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  String get userRole => _currentUser?.role ?? 'candidate';

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await StorageService.getToken();
      _currentUser = await StorageService.getUser();

      if (_token != null) {
        // Refresh profile from API
        final res = await ApiService.get(ApiEndpoints.me);
        if (res['success'] == true && res['user'] != null) {
          _currentUser = UserModel.fromJson(res['user']);
          await StorageService.saveUser(_currentUser!);
        }
      }
    } catch (_) {
      // Clear token if invalid
      _token = null;
      _currentUser = null;
      await StorageService.clearSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });

      if (res['success'] == true) {
        _token = res['token'];
        _currentUser = UserModel.fromJson(res['user']);
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(ApiEndpoints.register, {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        'phone': phone,
      });

      if (res['success'] == true) {
        _token = res['token'];
        _currentUser = UserModel.fromJson(res['user']);
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await StorageService.clearSession();
    notifyListeners();
  }
}
