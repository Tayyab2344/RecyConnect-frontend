import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import 'warehouse_dashboard.dart';
import 'company_dashboard.dart';
import 'individual_dashboard.dart';
import 'collector_dashboard.dart';
import '../seller/seller_dashboard.dart';
import '../marketplace/buyer_dashboard.dart';
import '../admin/admin_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? currentBackPressTime;

  @override

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final now = DateTime.now();
        if (currentBackPressTime == null || 
            now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Exit app
        Navigator.of(context).pop();
      },
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          final userRole = authService.userRole ?? 'individual';
          
          switch (userRole.toLowerCase()) {
            case 'individual':
              return const IndividualDashboard();
            case 'warehouse':
              return const WarehouseDashboard();
            case 'company':
              return const CompanyDashboard();
            case 'buyer':
              return const BuyerDashboard();
            case 'admin':
              return const AdminDashboardScreen();
            default:
              return const IndividualDashboard();
          }
        },
      ),
    );
  }
}




