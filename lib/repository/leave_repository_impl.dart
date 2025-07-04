import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../entities/leave_request.dart';
import '../repository/leave_repository.dart';
import '../models/leave_request_model.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  LeaveRepositoryImpl(this._client);

  @override
  Future<void> submitLeaveRequest(LeaveRequest request) async {
    final requestModel = LeaveRequestModel.fromEntity(request);
    final id = request.id.isEmpty ? _uuid.v4() : request.id;

    await _client.from('leaves').insert({...requestModel.toMap(), 'id': id});
  }

  @override
  Future<List<LeaveRequest>> getEmployeeLeaveRequests(String employeeId) async {
    final response = await _client
        .from('leaves')
        .select()
        .eq('employeeId', employeeId)
        .order('createdAt', ascending: false);

    return response.map((doc) => LeaveRequestModel.fromMap(doc)).toList();
  }

  @override
  Future<List<LeaveRequest>> getPendingLeaveRequests(
    String supervisorId,
  ) async {
    final response = await _client
        .from('leaves')
        .select()
        .eq('status', 'pending')
        .eq('supervisorId', supervisorId)
        .order('createdAt', ascending: false);

    return response.map((doc) => LeaveRequestModel.fromMap(doc)).toList();
  }

  @override
  Future<void> updateLeaveRequest(LeaveRequest request) async {
    final requestModel = LeaveRequestModel.fromEntity(request);
    await _client
        .from('leaves')
        .update(requestModel.toMap())
        .eq('id', request.id);
  }

  @override
  Stream<List<LeaveRequest>> watchLeaveRequests(String employeeId) {
    return _client
        .from('leaves')
        .stream(primaryKey: ['id'])
        .eq('employeeId', employeeId)
        .order('createdAt', ascending: false)
        .map(
          (rows) => rows.map((row) => LeaveRequestModel.fromMap(row)).toList(),
        );
  }

  @override
  Future<List<LeaveRequest>> getAllLeaveRequests() async {
    try {
      final response = await _client
          .from('leaves')
          .select()
          .order('createdAt', ascending: false);
      return response.map((doc) => LeaveRequestModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load all leave requests: $e');
    }
  }
}
