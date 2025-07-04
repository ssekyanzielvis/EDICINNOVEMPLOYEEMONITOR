class Admin {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? position;
  final DateTime? hireDate;
  final bool isActive;
  final String role;
  final String? profileImageUrl;
  final DateTime createdAt;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.position,
    this.hireDate,
    required this.isActive,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
  });
}
