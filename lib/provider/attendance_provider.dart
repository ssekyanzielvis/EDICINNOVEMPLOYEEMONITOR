import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../entities/attendance.dart';
import '../usecases/scan_qr_attendance.dart';
import '../usecases/get_attendance_report.dart';
import '../usecases/get_all_attendance_reports.dart';

class AttendanceProvider extends ChangeNotifier {
  final ScanQRAttendanceUseCase _scanQRAttendanceUseCase;
  final GetAttendanceReportUseCase _getAttendanceReportUseCase;
  final GetAllAttendanceReportsUseCase _getAllAttendanceReportsUseCase;

  AttendanceProvider(
    this._scanQRAttendanceUseCase,
    this._getAttendanceReportUseCase,
    this._getAllAttendanceReportsUseCase,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Attendance? _todayAttendance;
  Attendance? get todayAttendance => _todayAttendance;

  AttendanceReport? _currentReport;
  AttendanceReport? get currentReport => _currentReport;

  List<AttendanceReport> _allReports = [];
  List<AttendanceReport> get allReports => _allReports;

  Future<bool> scanQRCode({
    required String employeeId,
    required String qrCodeData,
    required Position position,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _scanQRAttendanceUseCase.execute(
        employeeId: employeeId,
        qrCodeData: qrCodeData,
        position: position,
      );

      if (result.isSuccess) {
        _todayAttendance = result.attendance;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> generateReport({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentReport = await _getAttendanceReportUseCase.execute(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateAllReports({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allReports = await _getAllAttendanceReportsUseCase.execute(
        startDate: startDate,
        endDate: endDate,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
