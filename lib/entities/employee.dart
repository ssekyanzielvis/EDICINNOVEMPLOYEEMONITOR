class Employee {
  final String id;
  final String employeeCode;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String department;
  final String? position;
  final DateTime? hireDate;
  final bool isActive;
  final String role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.department,
    this.position,
    this.hireDate,
    this.isActive = true,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isEmployee => role == 'employee';
  bool get isSupervisor => role == 'supervisor';
}
