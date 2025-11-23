import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/admin/admin_collectors_screen.dart';
import '../../screens/admin/admin_orders_screen.dart';
import '../../screens/admin/admin_pricing_screen.dart';
import '../../screens/admin/admin_activities_screen.dart';
import '../../screens/admin/admin_reports_screen.dart';
import '../../screens/admin/admin_notifications_screen.dart';
import '../../screens/admin/admin_settings_screen.dart';
import '../../screens/auth/login_screen.dart';

class AdminDrawer extends StatefulWidget {
  final String currentRoute;

  const AdminDrawer({
    super.key,
    this.currentRoute = 'dashboard',
  });

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String _selectedItem = 'dashboard';

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.currentRoute;
  }

  void _navigateTo(String route, Widget screen) {
    setState(() {
      _selectedItem = route;
    });
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: AdminColors.error),
              SizedBox(width: 12),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AdminColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AdminColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section
          _buildHeader(),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 10),
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: 'dashboard',
                  screen: const AdminDashboardScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: 'Users Management',
                  route: 'users',
                  screen: const AdminUsersScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.local_shipping,
                  title: 'Collectors Management',
                  route: 'collectors',
                  screen: const AdminCollectorsScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.shopping_bag,
                  title: 'Orders Management',
                  route: 'orders',
                  screen: const AdminOrdersScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.attach_money,
                  title: 'Pricing Management',
                  route: 'pricing',
                  screen: const AdminPricingScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Activity Logs',
                  route: 'logs',
                  screen: const AdminActivitiesScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.bar_chart,
                  title: 'Reports & Analytics',
                  route: 'reports',
                  screen: const AdminReportsScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  route: 'notifications',
                  screen: const AdminNotificationsScreen(),
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  route: 'settings',
                  screen: const AdminSettingsScreen(),
                ),

                const Divider(height: 30, thickness: 1),

                // Logout Item
                _buildLogoutItem(),
              ],
            ),
          ),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminColors.primaryGreen,
            AdminColors.primaryGreenDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AdminColors.textWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AD',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name with overflow handling
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Admin User',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textWhite,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Email with overflow handling
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'panel.quantix@gmail.com',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Role Badge with FittedBox to prevent overflow
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AdminColors.textWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Administrator',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
    required Widget screen,
  }) {
    final isSelected = _selectedItem == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminColors.primaryGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: isSelected
              ? AdminColors.primaryGreen
              : AdminColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AdminColors.primaryGreen
                : AdminColors.textPrimary,
          ),
        ),
        onTap: () => _navigateTo(route, screen),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: AdminColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          size: 22,
          color: AdminColors.error,
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AdminColors.error,
          ),
        ),
        onTap: _showLogoutDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: AdminColors.error.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'RecyConnect Admin',
                style: TextStyle(
                  fontSize: 10,
                  color: AdminColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 10,
                  color: AdminColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
