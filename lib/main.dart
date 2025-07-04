import 'package:employeemonitor/screens/admin_login_screen.dart';
import 'package:employeemonitor/screens/registeration_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'repository/attendance_repository_impl.dart';
import 'repository/employee_repository_impl.dart';
import 'repository/leave_repository_impl.dart';
import 'repository/admin_repository_impl.dart';
import 'usecases/scan_qr_attendance.dart';
import 'usecases/get_attendance_report.dart';
import 'usecases/get_all_attendance_reports.dart'; // Import the new use case
import 'provider/auth_provider.dart';
import 'provider/attendance_provider.dart';
import 'provider/leave_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AttendanceRepositoryImpl>(
          create: (_) => AttendanceRepositoryImpl(Supabase.instance.client),
        ),
        Provider<EmployeeRepositoryImpl>(
          create: (_) => EmployeeRepositoryImpl(Supabase.instance.client),
        ),
        Provider<LeaveRepositoryImpl>(
          create: (_) => LeaveRepositoryImpl(Supabase.instance.client),
        ),
        Provider<AdminRepositoryImpl>(
          create: (_) => AdminRepositoryImpl(Supabase.instance.client),
        ),

        // Use Cases
        Provider<ScanQRAttendanceUseCase>(
          create:
              (context) => ScanQRAttendanceUseCase(
                context.read<AttendanceRepositoryImpl>(),
                context.read<EmployeeRepositoryImpl>(),
              ),
        ),
        Provider<GetAttendanceReportUseCase>(
          create:
              (context) => GetAttendanceReportUseCase(
                context.read<AttendanceRepositoryImpl>(),
                context.read<EmployeeRepositoryImpl>(),
              ),
        ),
        Provider<GetAllAttendanceReportsUseCase>(
          create:
              (context) => GetAllAttendanceReportsUseCase(
                context.read<AttendanceRepositoryImpl>(),
                context.read<EmployeeRepositoryImpl>(),
              ),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create:
              (context) => AuthProvider(
                Supabase.instance.client.auth,
                context.read<EmployeeRepositoryImpl>(),
                context.read<AdminRepositoryImpl>(),
              )..initialize(),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create:
              (context) => AttendanceProvider(
                context.read<ScanQRAttendanceUseCase>(),
                context.read<GetAttendanceReportUseCase>(),
                context
                    .read<
                      GetAllAttendanceReportsUseCase
                    >(), // Added missing argument
              ),
        ),
        ChangeNotifierProvider<LeaveProvider>(
          create:
              (context) => LeaveProvider(context.read<LeaveRepositoryImpl>()),
        ),
      ],
      child: MaterialApp(
        title: 'Employee Attendance System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login', // Set initial route
        home:
            const SizedBox.shrink(), // Placeholder to avoid direct home conflict
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder:
                  (context) => Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.isAuthenticated) {
                        if (authProvider.isAdmin) {
                          return const AdminChoiceScreen();
                        }
                        return const DashboardScreen();
                      }
                      return const LoginScreen();
                    },
                  ),
            );
          }
          return null; // Let routes handle other paths
        },
        routes: {
          '/login': (context) => const LoginScreen(),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin-choice': (context) => const AdminChoiceScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/register': (context) => const RegistrationScreen(),
        },
      ),
    );
  }
}
