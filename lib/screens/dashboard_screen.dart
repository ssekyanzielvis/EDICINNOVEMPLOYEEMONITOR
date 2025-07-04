import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'qr_scanner_screen.dart';
import 'attendance_report_screen.dart';
import 'leave_requests_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final employee = authProvider.currentEmployee;
            if (employee == null) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Dashboard'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No employee data available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Data may not be loaded or unavailable. Try refreshing or contact support.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => authProvider.refreshEmployee(),
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          }
                        },
                        child: const Text('Logout and Return to Login'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text('Welcome, ${employee.firstName}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => authProvider.refreshEmployee(),
                    tooltip: 'Refresh',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        _showLogoutDialog(context, authProvider);
                      } else if (value == 'profile') {
                        _showProfileDialog(context, employee);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Profile'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Logout'),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                employee.profileImageUrl != null
                                    ? NetworkImage(employee.profileImageUrl!)
                                    : const NetworkImage(
                                      'https://via.placeholder.com/150',
                                    ),
                            child:
                                employee.profileImageUrl == null
                                    ? Text(
                                      employee.firstName[0] +
                                          employee.lastName[0],
                                      style: const TextStyle(fontSize: 40),
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${employee.firstName} ${employee.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            employee.email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text('QR Scanner'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QRScannerScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.assessment),
                      title: const Text('Attendance Report'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AttendanceReportScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event_busy),
                      title: const Text('Leave Requests'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeaveRequestsScreen(),
                          ),
                        );
                      },
                    ),
                    if (employee.isSupervisor)
                      ListTile(
                        leading: const Icon(Icons.group),
                        title: const Text('Team Management'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Team Management - Coming Soon'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      MediaQuery.of(context).size.width < 600 ? 1.2 : 1.5,
                  children: [
                    _buildDashboardCard(
                      context,
                      'QR Scanner',
                      Icons.qr_code_scanner,
                      Colors.blue,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QRScannerScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Attendance Report',
                      Icons.assessment,
                      Colors.green,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AttendanceReportScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Leave Requests',
                      Icons.event_busy,
                      Colors.orange,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LeaveRequestsScreen(),
                        ),
                      ),
                    ),
                    if (employee.isSupervisor)
                      _buildDashboardCard(
                        context,
                        'Team Management',
                        Icons.group,
                        Colors.purple,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Team Management - Coming Soon'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showProfileDialog(BuildContext context, dynamic employee) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (employee.profileImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(employee.profileImageUrl!),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?semt=ais_hybrid&w=740',
                      ),
                    ),
                  ),
                Text('Name: ${employee.firstName} ${employee.lastName}'),
                Text('Email: ${employee.email}'),
                Text('Department: ${employee.department ?? 'N/A'}'),
                Text('Role: ${employee.role}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
