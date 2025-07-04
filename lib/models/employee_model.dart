import '../entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.employeeCode,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    required super.department,
    super.position,
    super.hireDate,
    super.isActive,
    required super.role,
    super.profileImageUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> data) {
    return EmployeeModel(
      id: data['id'] ?? '',
      employeeCode: data['employee_code'] ?? '',
      email: data['email'] ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      phone: data['phone'],
      department: data['department'] ?? '',
      position: data['position'],
      hireDate:
          data['hire_date'] != null ? DateTime.parse(data['hire_date']) : null,
      isActive: data['is_active'] ?? true,
      role: data['role'] ?? 'employee',
      profileImageUrl: data['profile_image_url'],
      createdAt: DateTime.parse(
        data['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'department': department,
      'position': position,
      'hire_date': hireDate?.toIso8601String(),
      'is_active': isActive,
      'role': role,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory EmployeeModel.fromEntity(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      employeeCode: employee.employeeCode,
      email: employee.email,
      firstName: employee.firstName,
      lastName: employee.lastName,
      phone: employee.phone,
      department: employee.department,
      position: employee.position,
      hireDate: employee.hireDate,
      isActive: employee.isActive,
      role: employee.role,
      profileImageUrl: employee.profileImageUrl,
      createdAt: employee.createdAt,
      updatedAt: employee.updatedAt,
    );
  }
}
