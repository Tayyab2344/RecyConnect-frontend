import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';

class AdminCollectorsScreen extends StatelessWidget {
  const AdminCollectorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collectors Management"),
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
