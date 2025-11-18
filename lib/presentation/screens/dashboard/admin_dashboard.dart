import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/dashboard_card.dart';
import '../admin/admin_logs_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  return Text(
                    'Welcome, ${authService.user?['name'] ?? 'Admin'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'System Administration Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 32),

              // Admin Actions Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    DashboardCard(
                      title: 'Activity Logs',
                      value: 'View All',
                      icon: Icons.history,
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLogsScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'User Management',
                      value: 'Manage',
                      icon: Icons.people,
                      color: AppTheme.primaryGreen,
                      onTap: () {
                        // TODO: Navigate to user management
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('User management coming soon')),
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'System Stats',
                      value: 'View',
                      icon: Icons.analytics,
                      color: Colors.orange,
                      onTap: () {
                        // TODO: Navigate to system statistics
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('System stats coming soon')),
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'Settings',
                      value: 'Configure',
                      icon: Icons.settings,
                      color: AppTheme.textLight,
                      onTap: () {
                        // TODO: Navigate to admin settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Admin settings coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
