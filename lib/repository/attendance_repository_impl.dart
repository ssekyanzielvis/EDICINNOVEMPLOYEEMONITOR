import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../entities/attendance.dart';
import '../repository/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  AttendanceRepositoryImpl(this._client);

  @override
  Future<void> recordAttendance(Attendance attendance) async {
    final attendanceModel = AttendanceModel.fromEntity(attendance);
    final id = attendance.id.isEmpty ? _uuid.v4() : attendance.id;

    await _client.from('attendance').insert({
      ...attendanceModel.toMap(),
      'id': id,
    });
  }

  @override
  Future<List<Attendance>> getEmployeeAttendance(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('attendance')
        .select()
        .eq('employeeId', employeeId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: false);

    return response.map((doc) => AttendanceModel.fromMap(doc)).toList();
  }

  @override
  Future<List<Attendance>> getDepartmentAttendance(
    String department,
    DateTime date,
  ) async {
    // First get employees from the department
    final employeesResponse = await _client
        .from('employees')
        .select('id')
        .eq('department', department);

    final employeeIds = employeesResponse.map((doc) => doc['id']).toList();

    if (employeeIds.isEmpty) return [];

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final attendanceResponse = await _client
        .from('attendance')
        .select()
        .inFilter('employeeId', employeeIds)
        .gte('date', startOfDay.toIso8601String())
        .lt('date', endOfDay.toIso8601String());

    return attendanceResponse
        .map((doc) => AttendanceModel.fromMap(doc))
        .toList();
  }

  @override
  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('attendance')
        .select()
        .eq('employeeId', employeeId)
        .gte('date', startOfDay.toIso8601String())
        .lt('date', endOfDay.toIso8601String())
        .limit(1);

    if (response.isEmpty) return null;

    return AttendanceModel.fromMap(response.first);
  }

  @override
  Future<void> updateAttendance(Attendance attendance) async {
    final attendanceModel = AttendanceModel.fromEntity(attendance);
    await _client
        .from('attendance')
        .update(attendanceModel.toMap())
        .eq('id', attendance.id);
  }

  @override
  Stream<List<Attendance>> watchEmployeeAttendance(String employeeId) {
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('employeeId', employeeId)
        .order('date', ascending: false)
        .limit(30)
        .map(
          (rows) => rows.map((row) => AttendanceModel.fromMap(row)).toList(),
        );
  }

  @override
  Future<List<Attendance>> getAllAttendanceReports(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _client
          .from('attendance')
          .select()
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);
      return response.map((doc) => AttendanceModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load all attendance reports: $e');
    }
  }
}
