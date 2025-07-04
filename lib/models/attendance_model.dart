import '../entities/attendance.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.date,
    super.checkInTime,
    super.checkOutTime,
    required super.status,
    super.latitude,
    super.longitude,
    super.qrCodeData,
    super.notes,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> data) {
    return AttendanceModel(
      id: data['id'] ?? '',
      employeeId: data['employeeId'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      checkInTime:
          data['checkInTime'] != null
              ? DateTime.parse(data['checkInTime'])
              : null,
      checkOutTime:
          data['checkOutTime'] != null
              ? DateTime.parse(data['checkOutTime'])
              : null,
      status: AttendanceStatus.values.firstWhere(
        (s) => s.code == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      qrCodeData: data['qrCodeData'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status.code,
      'latitude': latitude,
      'longitude': longitude,
      'qrCodeData': qrCodeData,
      'notes': notes,
    };
  }

  factory AttendanceModel.fromEntity(Attendance attendance) {
    return AttendanceModel(
      id: attendance.id,
      employeeId: attendance.employeeId,
      date: attendance.date,
      checkInTime: attendance.checkInTime,
      checkOutTime: attendance.checkOutTime,
      status: attendance.status,
      latitude: attendance.latitude,
      longitude: attendance.longitude,
      qrCodeData: attendance.qrCodeData,
      notes: attendance.notes,
    );
  }
}
