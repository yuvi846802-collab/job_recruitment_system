class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role; // admin, recruiter, candidate
  final String? phone;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      role: json['role'] ?? 'candidate',
      phone: json['phone'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'is_active': isActive,
    };
  }
}
