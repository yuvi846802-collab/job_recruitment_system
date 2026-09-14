class EducationModel {
  final int id;
  final String degree;
  final String institution;
  final String? fieldOfStudy;
  final int? startYear;
  final int? endYear;
  final String? grade;

  EducationModel({
    required this.id,
    required this.degree,
    required this.institution,
    this.fieldOfStudy,
    this.startYear,
    this.endYear,
    this.grade,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] ?? 0,
      degree: json['degree'] ?? '',
      institution: json['institution'] ?? '',
      fieldOfStudy: json['field_of_study'],
      startYear: json['start_year'],
      endYear: json['end_year'],
      grade: json['grade'],
    );
  }
}

class ExperienceModel {
  final int id;
  final String jobTitle;
  final String companyName;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  ExperienceModel({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      companyName: json['company_name'] ?? '',
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] == 1 || json['is_current'] == true,
      description: json['description'],
    );
  }
}

class CandidateModel {
  final int userId;
  final int? seekerId;
  final String fullName;
  final String email;
  final String? phone;
  final String? location;
  final String? bio;
  final String? profilePhoto;
  final String? resumeUrl;
  final String? resumeFilename;
  final List<EducationModel> education;
  final List<ExperienceModel> experience;
  final List<String> skills;

  CandidateModel({
    required this.userId,
    this.seekerId,
    required this.fullName,
    required this.email,
    this.phone,
    this.location,
    this.bio,
    this.profilePhoto,
    this.resumeUrl,
    this.resumeFilename,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    var eduList = <EducationModel>[];
    if (json['education'] != null) {
      eduList = (json['education'] as List)
          .map((e) => EducationModel.fromJson(e))
          .toList();
    }

    var expList = <ExperienceModel>[];
    if (json['experience'] != null) {
      expList = (json['experience'] as List)
          .map((e) => ExperienceModel.fromJson(e))
          .toList();
    }

    var skillList = <String>[];
    if (json['skills'] != null) {
      skillList = (json['skills'] as List)
          .map((s) => s['skill_name']?.toString() ?? s.toString())
          .toList();
    }

    return CandidateModel(
      userId: json['user_id'] ?? json['id'] ?? 0,
      seekerId: json['seeker_id'] ?? json['id'],
      fullName: json['full_name'] ?? json['candidate_name'] ?? '',
      email: json['email'] ?? json['candidate_email'] ?? '',
      phone: json['phone'] ?? json['candidate_phone'],
      location: json['location'] ?? json['candidate_location'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      resumeUrl: json['resume_url'],
      resumeFilename: json['resume_filename'],
      education: eduList,
      experience: expList,
      skills: skillList,
    );
  }
}
