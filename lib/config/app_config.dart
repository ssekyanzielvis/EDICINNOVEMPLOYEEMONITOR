class AppConfig {
  static const String appName = 'Employee Attendance System';
  static const String version = '1.0.0';

  // Firebase Configuration
  static const bool useFirebaseEmulator = false;
  static const String firestoreHost = 'localhost';
  static const int firestorePort = 8080;

  // Debug Configuration
  static const bool enableLogging = true;
  static const bool showDebugInfo = false;

  // Feature Flags
  static const bool enableBiometricAuth = false;
  static const bool enableOfflineMode = false;
  static const bool enablePushNotifications = true;
}
