class InterviewModel {
  final int id;
  final int applicationId;
  final String jobTitle;
  final String companyName;
  final String? candidateName;
  final String scheduledDate;
  final String scheduledTime;
  final String interviewMode; // Online, In-Person, Telephonic
  final String locationOrLink;
  final String interviewerName;
  final String? notes;
  final String status; // Scheduled, Rescheduled, Completed, Cancelled

  InterviewModel({
    required this.id,
    required this.applicationId,
    required this.jobTitle,
    required this.companyName,
    this.candidateName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.interviewMode,
    required this.locationOrLink,
    required this.interviewerName,
    this.notes,
    required this.status,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      id: json['id'] ?? 0,
      applicationId: json['application_id'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      companyName: json['company_name'] ?? '',
      candidateName: json['candidate_name'],
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      interviewMode: json['interview_mode'] ?? 'Online',
      locationOrLink: json['location_or_link'] ?? '',
      interviewerName: json['interviewer_name'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'Scheduled',
    );
  }
}
