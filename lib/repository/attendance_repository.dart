import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<void> recordAttendance(Attendance attendance);
  Future<List<Attendance>> getEmployeeAttendance(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<Attendance>> getDepartmentAttendance(
    String department,
    DateTime date,
  );
  Future<Attendance?> getTodayAttendance(String employeeId);
  Future<void> updateAttendance(Attendance attendance);
  Stream<List<Attendance>> watchEmployeeAttendance(String employeeId);
  Future<List<Attendance>> getAllAttendanceReports(
    DateTime startDate,
    DateTime endDate,
  );
}
