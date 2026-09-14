import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../models/application_model.dart';
import '../services/api_service.dart';

class ApplicationProvider with ChangeNotifier {
  List<ApplicationModel> _myApplications = [];
  List<ApplicationModel> _jobApplicants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ApplicationModel> get myApplications => _myApplications;
  List<ApplicationModel> get jobApplicants => _jobApplicants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiEndpoints.myApplications);
      if (res['success'] == true && res['data'] != null) {
        _myApplications = (res['data'] as List)
            .map((a) => ApplicationModel.fromJson(a))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobApplicants(int jobId, {String status = 'all'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = '${ApiEndpoints.jobApplicants(jobId)}?status=$status';
      final res = await ApiService.get(url);
      if (res['success'] == true && res['data'] != null) {
        _jobApplicants = (res['data'] as List)
            .map((a) => ApplicationModel.fromJson(a))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyForJob(int jobId, String? coverLetter) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(ApiEndpoints.applications, {
        'job_id': jobId,
        'cover_letter': coverLetter,
      });

      _isLoading = false;
      notifyListeners();
      if (res['success'] == true) {
        fetchMyApplications();
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

  Future<bool> updateStatus(int applicationId, String newStatus, {int? jobId}) async {
    try {
      final res = await ApiService.patch(
        ApiEndpoints.updateAppStatus(applicationId),
        {'status': newStatus},
      );

      if (res['success'] == true) {
        if (jobId != null) {
          fetchJobApplicants(jobId);
        }
        fetchMyApplications();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
