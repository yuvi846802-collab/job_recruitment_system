import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';

class JobProvider with ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _myJobs = [];
  List<JobModel> _savedJobs = [];
  List<CategoryModel> _categories = [];
  JobModel? _selectedJob;
  bool _isLoading = false;
  String? _errorMessage;

  // Search & Filter State
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedWorkMode = 'all';
  String _selectedJobType = 'all';
  String _sortBy = 'latest';

  List<JobModel> get jobs => _jobs;
  List<JobModel> get myJobs => _myJobs;
  List<JobModel> get savedJobs => _savedJobs;
  List<CategoryModel> get categories => _categories;
  JobModel? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedWorkMode => _selectedWorkMode;
  String get selectedJobType => _selectedJobType;
  String get sortBy => _sortBy;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchJobs();
  }

  void setCategoryFilter(String categoryId) {
    _selectedCategory = categoryId;
    fetchJobs();
  }

  void setWorkModeFilter(String mode) {
    _selectedWorkMode = mode;
    fetchJobs();
  }

  void setJobTypeFilter(String type) {
    _selectedJobType = type;
    fetchJobs();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiEndpoints.jobs).replace(queryParameters: {
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        if (_selectedCategory != 'all') 'category_id': _selectedCategory,
        if (_selectedWorkMode != 'all') 'work_mode': _selectedWorkMode,
        if (_selectedJobType != 'all') 'job_type': _selectedJobType,
        'sort_by': _sortBy,
      });

      final res = await ApiService.get(uri.toString());
      if (res['success'] == true && res['data'] != null) {
        _jobs = (res['data'] as List).map((j) => JobModel.fromJson(j)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await ApiService.get(ApiEndpoints.categories);
      if (res['success'] == true && res['data'] != null) {
        _categories = (res['data'] as List).map((c) => CategoryModel.fromJson(c)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchJobDetails(int jobId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('${ApiEndpoints.jobs}/$jobId');
      if (res['success'] == true && res['data'] != null) {
        _selectedJob = JobModel.fromJson(res['data']);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get(ApiEndpoints.myJobs);
      if (res['success'] == true && res['data'] != null) {
        _myJobs = (res['data'] as List).map((j) => JobModel.fromJson(j)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSavedJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get(ApiEndpoints.savedJobs);
      if (res['success'] == true && res['data'] != null) {
        _savedJobs = (res['data'] as List).map((j) => JobModel.fromJson(j)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleSaveJob(int jobId) async {
    try {
      final res = await ApiService.post(ApiEndpoints.saveJob(jobId), {});
      if (res['success'] == true) {
        fetchSavedJobs();
        if (_selectedJob != null && _selectedJob!.id == jobId) {
          fetchJobDetails(jobId);
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createJob(Map<String, dynamic> jobData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiEndpoints.jobs, jobData);
      _isLoading = false;
      notifyListeners();
      if (res['success'] == true) {
        fetchMyJobs();
        fetchJobs();
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
