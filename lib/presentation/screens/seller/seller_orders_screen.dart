import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: const Center(
        child: Text('Orders feature is currently disabled.'),
      ),
    );
  }
}
