class CategoryModel {
  final int id;
  final String name;
  final String iconName;
  final String? description;
  final int activeJobsCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconName = 'work',
    this.description,
    this.activeJobsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      iconName: json['icon_name'] ?? 'work',
      description: json['description'],
      activeJobsCount: json['active_jobs_count'] ?? 0,
    );
  }
}
