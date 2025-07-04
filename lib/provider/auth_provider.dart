import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/employee.dart';
import '../repository/employee_repository.dart';
import '../repository/admin_repository.dart';

class AuthProvider extends ChangeNotifier {
  final GoTrueClient _auth;
  final EmployeeRepository _employeeRepository;
  final AdminRepository _adminRepository;
  User? _currentUser;
  Employee? _currentEmployee;
  bool _isAdmin = false;
  bool _isLoading = false;

  AuthProvider(this._auth, this._employeeRepository, this._adminRepository);

  User? get currentUser => _currentUser;
  Employee? get currentEmployee => _currentEmployee;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmployee => _currentEmployee?.isEmployee ?? false;
  bool get isSupervisor => _currentEmployee?.isSupervisor ?? false;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      _currentUser = response.user;
      await _loadCurrentEmployee();
      await _checkAdminStatus(email);
      notifyListeners();
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _currentUser = null;
      _currentEmployee = null;
      _isAdmin = false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _loadCurrentEmployee() async {
    if (_currentUser != null) {
      try {
        _currentEmployee = await _employeeRepository.getEmployeeByEmail(
          _currentUser!.email!,
        );
      } catch (e) {
        print('Error loading employee: $e'); // Log for debugging
        _currentEmployee = null;
      }
      notifyListeners();
    }
  }

  Future<void> _checkAdminStatus(String email) async {
    if (_currentUser != null) {
      try {
        // Hardcoded admin email
        if (email.trim().toLowerCase() == 'abdulssekyanzi@gmail.com') {
          _isAdmin = true;
        } else {
          final admin = await _adminRepository.getAdmin(_currentUser!.id);
          _isAdmin = admin != null && admin.role == 'admin';
        }
      } catch (e) {
        print('Error checking admin status: $e'); // Log for debugging
        _isAdmin = false;
      }
      notifyListeners();
    } else {
      _isAdmin = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _auth.onAuthStateChange.listen((data) async {
      _setLoading(true);
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        try {
          await _loadCurrentEmployee();
          await _checkAdminStatus(_currentUser!.email!);
        } catch (e) {
          print('Error during auth state change: $e');
          _currentEmployee = null;
          _isAdmin = false;
        }
      } else {
        _currentEmployee = null;
        _isAdmin = false;
      }
      _setLoading(false);
      notifyListeners();
    });
  }

  Future<void> refreshEmployee() async {
    if (_currentUser != null) {
      _setLoading(true);
      try {
        await _loadCurrentEmployee();
        await _checkAdminStatus(_currentUser!.email!);
        notifyListeners();
      } finally {
        _setLoading(false);
      }
    }
  }
}
