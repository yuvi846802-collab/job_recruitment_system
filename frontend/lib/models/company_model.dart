class CompanyModel {
  final int id;
  final int recruiterId;
  final String companyName;
  final String? logoUrl;
  final String? description;
  final String? industry;
  final String? companySize;
  final String? website;
  final String? location;

  CompanyModel({
    required this.id,
    required this.recruiterId,
    required this.companyName,
    this.logoUrl,
    this.description,
    this.industry,
    this.companySize,
    this.website,
    this.location,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      recruiterId: json['recruiter_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      logoUrl: json['logo_url'],
      description: json['description'],
      industry: json['industry'],
      companySize: json['company_size'],
      website: json['website'],
      location: json['location'],
    );
  }
}
