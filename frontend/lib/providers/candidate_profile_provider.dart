import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../models/candidate_model.dart';
import '../services/api_service.dart';

class CandidateProfileProvider with ChangeNotifier {
  CandidateModel? _candidateProfile;
  bool _isLoading = false;
  String? _errorMessage;

  CandidateModel? get candidateProfile => _candidateProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiEndpoints.candidateProfile);
      if (res['success'] == true && res['data'] != null) {
        _candidateProfile = CandidateModel.fromJson(res['data']);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String location,
    required String bio,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.put(ApiEndpoints.candidateProfile, {
        'full_name': fullName,
        'phone': phone,
        'location': location,
        'bio': bio,
      });

      _isLoading = false;
      notifyListeners();
      if (res['success'] == true) {
        fetchProfile();
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

  Future<bool> addEducation(Map<String, dynamic> data) async {
    try {
      final res = await ApiService.post(ApiEndpoints.candidateEducation, data);
      if (res['success'] == true) {
        fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addExperience(Map<String, dynamic> data) async {
    try {
      final res = await ApiService.post(ApiEndpoints.candidateExperience, data);
      if (res['success'] == true) {
        fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
