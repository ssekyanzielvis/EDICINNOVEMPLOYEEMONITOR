import 'package:employeemonitor/usecases/get_attendance_report.dart';
import '../entities/employee.dart';
import '../repository/attendance_repository.dart';
import '../repository/employee_repository.dart';

class GetAllAttendanceReportsUseCase {
  final AttendanceRepository _attendanceRepository;
  final EmployeeRepository _employeeRepository;

  GetAllAttendanceReportsUseCase(
    this._attendanceRepository,
    this._employeeRepository,
  );

  Future<List<AttendanceReport>> execute({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allAttendances = await _attendanceRepository.getAllAttendanceReports(
      startDate,
      endDate,
    );

    // Group attendances by employee and fetch employee data
    final Map<String, AttendanceReport> reports = {};
    final uniqueEmployeeIds = allAttendances.map((a) => a.employeeId).toSet();

    // Fetch all employees in one go (if supported) or individually
    final employeeFutures = uniqueEmployeeIds.map(
      (id) => _employeeRepository.getEmployee(id),
    );
    final employees = await Future.wait(
      employeeFutures.whereType<Future<Employee?>>(),
    );
    final employeeMap =
        {for (var e in employees) e?.id: e}.cast<String, Employee>();

    for (var attendance in allAttendances) {
      final employeeId = attendance.employeeId;
      if (!reports.containsKey(employeeId)) {
        final employee =
            employeeMap[employeeId] ??
            (await _employeeRepository.getEmployee(employeeId));
        if (employee == null) continue; // Skip if employee not found
        reports[employeeId] = AttendanceReport(
          employee: employee,
          attendanceList: [],
          startDate: startDate,
          endDate: endDate,
        );
      }
      final report = reports[employeeId]!;
      report.attendanceList.add(attendance);
    }

    return reports.values.toList();
  }
}
