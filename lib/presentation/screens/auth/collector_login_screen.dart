import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CollectorLoginScreen extends StatelessWidget {
  const CollectorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Login'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Collector Login Screen'),
      ),
    );
  }
}
