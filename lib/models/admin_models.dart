import '../entities/admin.dart';

class AdminModel {
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

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.position,
    this.hireDate,
    this.isActive = true,
    this.role = 'admin',
    this.profileImageUrl,
    required this.createdAt,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      department: map['department'] as String?,
      position: map['position'] as String?,
      hireDate:
          map['hire_date'] != null
              ? DateTime.parse(map['hire_date'] as String)
              : null,
      isActive: map['is_active'] as bool? ?? true,
      role: map['role'] as String? ?? 'admin',
      profileImageUrl: map['profile_image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'hire_date': hireDate?.toIso8601String(),
      'is_active': isActive,
      'role': role,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AdminModel.fromEntity(Admin admin) {
    return AdminModel(
      id: admin.id,
      name: admin.name,
      email: admin.email,
      phone: admin.phone,
      department: admin.department,
      position: admin.position,
      hireDate: admin.hireDate,
      isActive: admin.isActive,
      role: admin.role,
      profileImageUrl: admin.profileImageUrl,
      createdAt: admin.createdAt,
    );
  }

  Admin toEntity() {
    return Admin(
      id: id,
      name: name,
      email: email,
      phone: phone,
      department: department,
      position: position,
      hireDate: hireDate,
      isActive: isActive,
      role: role,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
    );
  }
}
