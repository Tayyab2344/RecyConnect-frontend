import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import 'warehouse_dashboard.dart';
import 'company_dashboard.dart';
import 'individual_dashboard.dart';
import '../seller/seller_dashboard.dart';
import '../marketplace/buyer_dashboard.dart';
import '../admin/admin_dashboard.dart';

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
          case 'buyer':
            return const BuyerDashboard();
          case 'admin':
            return const AdminDashboard();
          default:
            return const IndividualDashboard();
        }
      },
    );
  }
}




