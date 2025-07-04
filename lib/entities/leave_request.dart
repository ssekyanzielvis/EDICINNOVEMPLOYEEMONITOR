enum LeaveType {
  sick('Sick Leave'),
  vacation('Vacation'),
  personal('Personal Leave'),
  emergency('Emergency Leave');

  const LeaveType(this.displayName);
  final String displayName;
}

enum LeaveStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const LeaveStatus(this.displayName);
  final String displayName;
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String? supervisorId;
  final String? supervisorNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.supervisorId,
    this.supervisorNotes,
    required this.createdAt,
    this.updatedAt,
  });

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    String? supervisorId,
    String? supervisorNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorNotes: supervisorNotes ?? this.supervisorNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
