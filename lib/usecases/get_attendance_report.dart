import '../entities/attendance.dart';
import '../entities/employee.dart';
import '../repository/attendance_repository.dart';
import '../repository/employee_repository.dart';

class GetAttendanceReportUseCase {
  final AttendanceRepository _attendanceRepository;
  final EmployeeRepository _employeeRepository;

  GetAttendanceReportUseCase(
    this._attendanceRepository,
    this._employeeRepository,
  );

  Future<AttendanceReport> execute({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final employee = await _employeeRepository.getEmployee(employeeId);
      if (employee == null) {
        throw Exception('Employee not found');
      }

      final attendanceList = await _attendanceRepository.getEmployeeAttendance(
        employeeId,
        startDate,
        endDate,
      );

      return AttendanceReport(
        employee: employee,
        attendanceList: attendanceList,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to generate report: ${e.toString()}');
    }
  }
}

class AttendanceReport {
  final Employee employee;
  final List<Attendance> attendanceList;
  final DateTime startDate;
  final DateTime endDate;

  AttendanceReport({
    required this.employee,
    required this.attendanceList,
    required this.startDate,
    required this.endDate,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;
  int get presentDays =>
      attendanceList.where((a) => a.status != AttendanceStatus.absent).length;
  int get absentDays => totalDays - presentDays;
  int get lateDays =>
      attendanceList.where((a) => a.status == AttendanceStatus.late).length;
  double get attendancePercentage => (presentDays / totalDays) * 100;
}
