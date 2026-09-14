import '../config/api_config.dart';

class ApiEndpoints {
  // Dynamic Base REST API Host
  static String get baseUrl => ApiConfig.baseUrl;
  static String get mediaBaseUrl => ApiConfig.mediaBaseUrl;

  // Auth Endpoints
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get me => '$baseUrl/auth/me';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';

  // Candidate Profile & Resume Endpoints
  static String get candidateProfile => '$baseUrl/candidates/profile';
  static String get candidateResume => '$baseUrl/candidates/resume';
  static String get candidateEducation => '$baseUrl/candidates/education';
  static String get candidateExperience => '$baseUrl/candidates/experience';

  // Company Endpoints
  static String get companies => '$baseUrl/companies';
  static String get myCompany => '$baseUrl/companies/my';
  static String get companyLogo => '$baseUrl/companies/logo';

  // Jobs Endpoints
  static String get jobs => '$baseUrl/jobs';
  static String get myJobs => '$baseUrl/jobs/my';
  static String get savedJobs => '$baseUrl/jobs/saved';
  static String saveJob(int jobId) => '$baseUrl/jobs/$jobId/save';

  // Applications Endpoints
  static String get applications => '$baseUrl/applications';
  static String get myApplications => '$baseUrl/applications/my';
  static String jobApplicants(int jobId) => '$baseUrl/applications/job/$jobId';
  static String updateAppStatus(int appVal) => '$baseUrl/applications/$appVal/status';

  // Interviews Endpoints
  static String get interviews => '$baseUrl/interviews';
  static String get myInterviews => '$baseUrl/interviews/my';

  // Notifications & Categories Endpoints
  static String get notifications => '$baseUrl/notifications';
  static String get markAllNotificationsRead => '$baseUrl/notifications/read-all';
  static String get categories => '$baseUrl/categories';

  // Admin Endpoints
  static String get adminAnalytics => '$baseUrl/admin/analytics';
  static String get adminUsers => '$baseUrl/admin/users';
  static String toggleUserStatus(int userId) => '$baseUrl/admin/users/$userId/status';
}
