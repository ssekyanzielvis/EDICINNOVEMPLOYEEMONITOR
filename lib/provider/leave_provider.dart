import 'package:flutter/foundation.dart';
import '../entities/leave_request.dart';
import '../repository/leave_repository.dart';

class LeaveProvider extends ChangeNotifier {
  final LeaveRepository _leaveRepository;

  LeaveProvider(this._leaveRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<LeaveRequest> _leaveRequests = [];
  List<LeaveRequest> get leaveRequests => _leaveRequests;

  List<LeaveRequest> _pendingRequests = [];
  List<LeaveRequest> get pendingRequests => _pendingRequests;

  Future<bool> submitLeaveRequest(LeaveRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _leaveRepository.submitLeaveRequest(request);
      await loadEmployeeLeaveRequests(request.employeeId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadEmployeeLeaveRequests(String employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _leaveRequests = await _leaveRepository.getEmployeeLeaveRequests(
        employeeId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingRequests(String supervisorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _pendingRequests = await _leaveRepository.getPendingLeaveRequests(
        supervisorId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLeaveRequest(LeaveRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _leaveRepository.updateLeaveRequest(request);
      await loadPendingRequests(request.supervisorId ?? '');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllLeaveRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _leaveRequests = await _leaveRepository.getAllLeaveRequests();
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
