enum AttendanceStatus {
  early('E', 'Early'),
  onTime('P', 'Present'),
  late('L', 'Late'),
  absent('A', 'Absent'),
  plannedAbsence('X', 'Planned Absence'),
  onLeave('O', 'On Leave');

  const AttendanceStatus(this.code, this.displayName);
  final String code;
  final String displayName;
}

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final double? latitude;
  final double? longitude;
  final String? qrCodeData;
  final String? notes;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.latitude,
    this.longitude,
    this.qrCodeData,
    this.notes,
  });

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    double? latitude,
    double? longitude,
    String? qrCodeData,
    String? notes,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      notes: notes ?? this.notes,
    );
  }
}
