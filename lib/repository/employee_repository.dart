import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Employee?> getEmployee(String id);
  Future<Employee?> getEmployeeByEmail(String email);
  Future<Employee?> getEmployeeByCode(String employeeCode);
  Future<List<Employee>> getAllEmployees();
  Future<List<Employee>> getDepartmentEmployees(String department);
  Future<List<Employee>> getSupervisors();
  Future<Employee> insertEmployee(Employee employee);
  Future<void> updateEmployee(Employee employee);
  Future<void> deactivateEmployee(String id);
  Stream<Employee?> watchEmployee(String id);
}
