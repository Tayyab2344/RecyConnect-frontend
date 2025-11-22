import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';

class AdminPricingScreen extends StatelessWidget {
  const AdminPricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pricing Management"),
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
