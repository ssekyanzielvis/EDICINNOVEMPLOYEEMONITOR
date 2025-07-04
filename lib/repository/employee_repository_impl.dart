import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/employee.dart';
import '../repository/employee_repository.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final SupabaseClient _client;

  EmployeeRepositoryImpl(this._client);

  @override
  Future<Employee?> getEmployee(String id) async {
    try {
      final response =
          await _client
              .from('employees')
              .select()
              .eq('id', id)
              .eq('is_active', true)
              .maybeSingle();

      if (response == null) return null;
      return EmployeeModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch employee by ID: $e');
    }
  }

  @override
  Future<Employee?> getEmployeeByEmail(String email) async {
    try {
      final response =
          await _client
              .from('employees')
              .select()
              .eq('email', email)
              .eq('is_active', true)
              .maybeSingle();

      if (response == null) return null;
      return EmployeeModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch employee by email: $e');
    }
  }

  @override
  Future<Employee?> getEmployeeByCode(String employeeCode) async {
    try {
      final response =
          await _client
              .from('employees')
              .select()
              .eq('employee_code', employeeCode)
              .eq('is_active', true)
              .maybeSingle();

      if (response == null) return null;
      return EmployeeModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch employee by code: $e');
    }
  }

  @override
  Future<List<Employee>> getAllEmployees() async {
    try {
      final response = await _client
          .from('employees')
          .select()
          .eq('is_active', true)
          .order('first_name')
          .order('last_name');

      return response.map((doc) => EmployeeModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all employees: $e');
    }
  }

  @override
  Future<List<Employee>> getDepartmentEmployees(String department) async {
    try {
      final response = await _client
          .from('employees')
          .select()
          .eq('department', department)
          .eq('is_active', true)
          .order('first_name')
          .order('last_name');

      return response.map((doc) => EmployeeModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch department employees: $e');
    }
  }

  @override
  Future<List<Employee>> getSupervisors() async {
    try {
      final response = await _client
          .from('employees')
          .select()
          .or(
            'role.eq.supervisor,role.eq.admin',
          ) // Correct way to check multiple roles
          .eq('is_active', true)
          .order('first_name')
          .order('last_name');

      return response.map((doc) => EmployeeModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch supervisors: $e');
    }
  }

  @override
  Future<Employee> insertEmployee(Employee employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      final response =
          await _client
              .from('employees')
              .insert({
                ...employeeModel.toMap(),
                'id': employee.id.isEmpty ? null : employee.id,
              })
              .select()
              .single();

      return EmployeeModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to insert employee: $e');
    }
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      await _client
          .from('employees')
          .update({
            'first_name': employeeModel.firstName,
            'last_name': employeeModel.lastName,
            'email': employeeModel.email,
            'phone': employeeModel.phone,
            'department': employeeModel.department,
            'position': employeeModel.position,
            'role': employeeModel.role,
            'employee_code': employeeModel.employeeCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', employee.id);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  @override
  Future<void> deactivateEmployee(String id) async {
    try {
      await _client
          .from('employees')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to deactivate employee: $e');
    }
  }

  @override
  Stream<Employee?> watchEmployee(String id) {
    return _client
        .from('employees')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map(
          (event) =>
              event.isNotEmpty ? EmployeeModel.fromMap(event.first) : null,
        );
  }

  Stream<List<Employee>> watchAllEmployees() {
    return _client
        .from('employees')
        .stream(primaryKey: ['id'])
        .order('first_name')
        .order('last_name')
        .map(
          (event) =>
              event
                  .where((row) => row['is_active'] == true)
                  .map((row) => EmployeeModel.fromMap(row))
                  .toList(),
        );
  }
}
