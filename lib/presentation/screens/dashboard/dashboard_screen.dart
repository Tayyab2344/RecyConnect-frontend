import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Remove: import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'individual_dashboard.dart';
import 'warehouse_dashboard.dart';
import 'company_dashboard.dart';
import 'collector_dashboard.dart';
import 'admin_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final userRole = authService.userRole ?? 'individual';
        
        switch (userRole.toLowerCase()) {
          case 'individual':
            return const IndividualDashboard();
          case 'warehouse':
            return const WarehouseDashboard();
          case 'company':
            return const CompanyDashboard();
          case 'collector':
            return const CollectorDashboard();
          case 'admin':
            return const AdminDashboard();
          default:
            return const IndividualDashboard();
        }
      },
    );
  }
}



