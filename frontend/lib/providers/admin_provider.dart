import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  Map<String, dynamic>? _analyticsData;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get analyticsData => _analyticsData;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiEndpoints.adminAnalytics);
      if (res['success'] == true && res['data'] != null) {
        _analyticsData = res['data'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers({String role = 'all', String search = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiEndpoints.adminUsers).replace(queryParameters: {
        if (role != 'all') 'role': role,
        if (search.isNotEmpty) 'search': search,
      });

      final res = await ApiService.get(uri.toString());
      if (res['success'] == true && res['data'] != null) {
        _users = (res['data'] as List).map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleUserStatus(int userId, bool newStatus) async {
    try {
      final res = await ApiService.patch(
        ApiEndpoints.toggleUserStatus(userId),
        {'is_active': newStatus},
      );
      if (res['success'] == true) {
        fetchUsers();
        fetchAnalytics();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
