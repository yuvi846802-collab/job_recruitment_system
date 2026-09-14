class JobModel {
  final int id;
  final int companyId;
  final String companyName;
  final String? companyLogo;
  final int categoryId;
  final String? categoryName;
  final String title;
  final String description;
  final String? responsibilities;
  final String? requirements;
  final String? skillsRequired;
  final int experienceYears;
  final double salaryMin;
  final double salaryMax;
  final String jobType; // Full Time, Part Time, Internship, Contract
  final String workMode; // On-site, Remote, Hybrid
  final String location;
  final int openings;
  final String? deadline;
  final String status;
  final String createdAt;
  final bool isApplied;
  final bool isSaved;
  final int applicantCount;

  JobModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.categoryId,
    this.categoryName,
    required this.title,
    required this.description,
    this.responsibilities,
    this.requirements,
    this.skillsRequired,
    this.experienceYears = 0,
    this.salaryMin = 0.0,
    this.salaryMax = 0.0,
    this.jobType = 'Full Time',
    this.workMode = 'On-site',
    required this.location,
    this.openings = 1,
    this.deadline,
    this.status = 'active',
    required this.createdAt,
    this.isApplied = false,
    this.isSaved = false,
    this.applicantCount = 0,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      companyName: json['company_name'] ?? 'Company',
      companyLogo: json['logo_url'] ?? json['company_logo'],
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      responsibilities: json['responsibilities'],
      requirements: json['requirements'],
      skillsRequired: json['skills_required'],
      experienceYears: json['experience_years'] ?? 0,
      salaryMin: double.tryParse(json['salary_min']?.toString() ?? '0') ?? 0.0,
      salaryMax: double.tryParse(json['salary_max']?.toString() ?? '0') ?? 0.0,
      jobType: json['job_type'] ?? 'Full Time',
      workMode: json['work_mode'] ?? 'On-site',
      location: json['location'] ?? '',
      openings: json['openings'] ?? 1,
      deadline: json['deadline'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      isApplied: json['is_applied'] == true,
      isSaved: json['is_saved'] == true,
      applicantCount: json['applicant_count'] ?? 0,
    );
  }
}
