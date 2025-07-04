class AppConstants {
  // Office Location (Replace with actual coordinates)
  static const double officeLatitude = 37.7749;
  static const double officeLongitude = -122.4194;

  // QR Code Configuration
  static const String qrCodePrefix = 'ATTENDANCE_';
  static const String validQRCode = '${qrCodePrefix}OFFICE_CHECKIN';

  // Time Configuration
  static const int workStartHour = 9; // 9 AM
  static const int workEndHour = 17; // 5 PM
  static const int lateThresholdMinutes = 15;

  // Attendance Status Colors
  static const Map<String, int> statusColors = {
    'present': 0xFF4CAF50,
    'absent': 0xFFF44336,
    'late': 0xFFFF9800,
    'early': 0xFF2196F3,
    'on_leave': 0xFF9C27B0,
  };

  // Error Messages
  static const String invalidQRCode =
      'Invalid QR code. Please scan the correct attendance QR code.';
  static const String locationError =
      'Unable to get your location. Please check location permissions.';
  static const String distanceError =
      'You are too far from the office to check in.';
  static const String alreadyCheckedIn = 'You have already checked in today.';
  static const String networkError =
      'Network error. Please check your internet connection.';
}
