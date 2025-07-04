import '../entities/leave_request.dart';

abstract class LeaveRepository {
  Future<void> submitLeaveRequest(LeaveRequest request);
  Future<List<LeaveRequest>> getEmployeeLeaveRequests(String employeeId);
  Future<List<LeaveRequest>> getPendingLeaveRequests(String supervisorId);
  Future<void> updateLeaveRequest(LeaveRequest request);
  Stream<List<LeaveRequest>> watchLeaveRequests(String employeeId);
  Future<List<LeaveRequest>> getAllLeaveRequests();
}
