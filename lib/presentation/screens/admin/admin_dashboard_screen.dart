import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AdminColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AdminColors.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AdminColors.textWhite),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: AdminColors.primaryGreen,
            ),
            const SizedBox(height: 20),
            const Text(
              'Admin Panel Setup Complete! ✅',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'All screens and widgets are ready',
              style: TextStyle(
                fontSize: 16,
                color: AdminColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ready to build amazing screens!'),
                    backgroundColor: AdminColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Test Button',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
