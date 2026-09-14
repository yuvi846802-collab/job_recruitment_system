class ApplicationModel {
  final int applicationId;
  final int jobId;
  final String jobTitle;
  final String companyName;
  final String? logoUrl;
  final int seekerId;
  final String? candidateName;
  final String? candidateEmail;
  final String? candidatePhone;
  final String? candidateLocation;
  final String? resumeUrl;
  final String? resumeFilename;
  final String status; // Applied, Under Review, Shortlisted, Interview Scheduled, Selected, Rejected
  final String? coverLetter;
  final String appliedAt;

  ApplicationModel({
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.logoUrl,
    required this.seekerId,
    this.candidateName,
    this.candidateEmail,
    this.candidatePhone,
    this.candidateLocation,
    this.resumeUrl,
    this.resumeFilename,
    required this.status,
    this.coverLetter,
    required this.appliedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['application_id'] ?? json['id'] ?? 0,
      jobId: json['job_id'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      companyName: json['company_name'] ?? '',
      logoUrl: json['logo_url'],
      seekerId: json['seeker_id'] ?? 0,
      candidateName: json['candidate_name'],
      candidateEmail: json['candidate_email'],
      candidatePhone: json['candidate_phone'],
      candidateLocation: json['candidate_location'],
      resumeUrl: json['resume_url'],
      resumeFilename: json['resume_filename'],
      status: json['status'] ?? 'Applied',
      coverLetter: json['cover_letter'],
      appliedAt: json['applied_at'] ?? '',
    );
  }
}
