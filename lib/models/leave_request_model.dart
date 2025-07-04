import '../entities/leave_request.dart';

class LeaveRequestModel extends LeaveRequest {
  const LeaveRequestModel({
    required super.id,
    required super.employeeId,
    required super.type,
    required super.startDate,
    required super.endDate,
    required super.reason,
    required super.status,
    super.supervisorId,
    super.supervisorNotes,
    required super.createdAt,
    super.updatedAt,
  });

  factory LeaveRequestModel.fromMap(Map<String, dynamic> data) {
    return LeaveRequestModel(
      id: data['id'] ?? '',
      employeeId: data['employeeId'] ?? '',
      type: LeaveType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => LeaveType.personal,
      ),
      startDate: DateTime.parse(
        data['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        data['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      reason: data['reason'] ?? '',
      status: LeaveStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => LeaveStatus.pending,
      ),
      supervisorId: data['supervisorId'],
      supervisorNotes: data['supervisorNotes'],
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status.name,
      'supervisorId': supervisorId,
      'supervisorNotes': supervisorNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory LeaveRequestModel.fromEntity(LeaveRequest request) {
    return LeaveRequestModel(
      id: request.id,
      employeeId: request.employeeId,
      type: request.type,
      startDate: request.startDate,
      endDate: request.endDate,
      reason: request.reason,
      status: request.status,
      supervisorId: request.supervisorId,
      supervisorNotes: request.supervisorNotes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );
  }
}
