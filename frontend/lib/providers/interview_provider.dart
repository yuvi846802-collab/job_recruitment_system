import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../models/interview_model.dart';
import '../services/api_service.dart';

class InterviewProvider with ChangeNotifier {
  List<InterviewModel> _interviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InterviewModel> get interviews => _interviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyInterviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiEndpoints.myInterviews);
      if (res['success'] == true && res['data'] != null) {
        _interviews = (res['data'] as List)
            .map((i) => InterviewModel.fromJson(i))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleInterview(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(ApiEndpoints.interviews, data);
      _isLoading = false;
      notifyListeners();
      if (res['success'] == true) {
        fetchMyInterviews();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
