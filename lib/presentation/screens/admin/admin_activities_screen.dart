import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';

class AdminActivitiesScreen extends StatelessWidget {
  const AdminActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Activities"),
        backgroundColor: AdminColors.primaryGreen,
      ),
      body: const Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
