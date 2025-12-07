import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

class AdminActivity {
  final String id;
  final String type;
  final String description;
  final String status;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;

  AdminActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
  });
}

// User Activity Model
class UserActivity {
  final String id;
  final String userName;
  final String userType;
  final String activityType;
  final String description;
  final String status;
  final DateTime timestamp;
  final String? location;
  final IconData icon;
  final Color iconColor;

  UserActivity({
    required this.id,
    required this.userName,
    required this.userType,
    required this.activityType,
    required this.description,
    required this.status,
    required this.timestamp,
    this.location,
    required this.icon,
    required this.iconColor,
  });
}

class AdminActivitiesScreen extends StatefulWidget {
  const AdminActivitiesScreen({super.key});

  @override
  State<AdminActivitiesScreen> createState() => _AdminActivitiesScreenState();
}

class _AdminActivitiesScreenState extends State<AdminActivitiesScreen>
    with TickerProviderStateMixin {
  late TabController _mainTabController;

  // Admin filters
  String _adminActivityTypeFilter = 'all';
  String _adminStatusFilter = 'all';
  String _adminDateFilter = 'all';
  DateTimeRange? _adminCustomDateRange;

  // User filters
  String _userTypeFilter = 'all';
  String _userActivityTypeFilter = 'all';
  String _userStatusFilter = 'all';
  String _userDateFilter = 'all';
  DateTimeRange? _userCustomDateRange;

  // Data
  List<AdminActivity> _allAdminActivities = [];
  List<AdminActivity> _filteredAdminActivities = [];
  List<UserActivity> _allUserActivities = [];
  List<UserActivity> _filteredUserActivities = [];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _initDummyData();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  void _initDummyData() {
    final now = DateTime.now();

    // Admin Activities (40+ activities)
    _allAdminActivities = [
      AdminActivity(
        id: 'a1',
        type: 'Login',
        description: 'Admin logged into system',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 2)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a2',
        type: 'Update Price',
        description: 'Updated Plastic buying price from 100 to 110 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 3)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a3',
        type: 'User Management',
        description: 'Suspended user: John Doe',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 5)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a4',
        type: 'Login',
        description: 'Failed login attempt from unknown IP',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 1)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a5',
        type: 'Order Management',
        description: 'Marked order #12345 as completed',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 2)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a6',
        type: 'Update Price',
        description: 'Updated Metal buying price from 80 to 95 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a7',
        type: 'System Settings',
        description: 'Changed notification settings for all users',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        icon: Icons.settings,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a8',
        type: 'Logout',
        description: 'Admin logged out of system',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 3)),
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
      AdminActivity(
        id: 'a9',
        type: 'User Management',
        description: 'Approved new warehouse registration: ABC Warehouse',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 3, hours: 2)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a10',
        type: 'Order Management',
        description: 'Cancelled order #12340 due to customer request',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 3, hours: 5)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a11',
        type: 'Login',
        description: 'Admin logged into system from mobile device',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 4)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a12',
        type: 'Update Price',
        description: 'Updated Paper buying price from 25 to 30 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 4, hours: 1)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a13',
        type: 'User Management',
        description: 'Rejected company registration: Fake Corp (fraudulent)',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 4, hours: 3)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a14',
        type: 'System Settings',
        description: 'Updated system backup schedule',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 5)),
        icon: Icons.settings,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a15',
        type: 'Order Management',
        description: 'Assigned collector to order #12335',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 5, hours: 2)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a16',
        type: 'Login',
        description: 'Failed login attempt - wrong password',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 5, hours: 4)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a17',
        type: 'Update Price',
        description: 'Updated Glass buying price from 15 to 18 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 6)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a18',
        type: 'User Management',
        description: 'Reactivated suspended user: Mike Wilson',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 6, hours: 2)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a19',
        type: 'Logout',
        description: 'Admin session expired - auto logout',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 7)),
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
      AdminActivity(
        id: 'a20',
        type: 'Order Management',
        description: 'Resolved dispute for order #12330',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 7, hours: 3)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a21',
        type: 'System Settings',
        description: 'Enabled two-factor authentication',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 8)),
        icon: Icons.settings,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a22',
        type: 'Login',
        description: 'Admin logged into system',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 8, hours: 2)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a23',
        type: 'Update Price',
        description: 'Updated E-waste buying price from 200 to 220 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 9)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a24',
        type: 'User Management',
        description: 'Verified identity for user: Sarah Khan',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 9, hours: 4)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a25',
        type: 'Order Management',
        description: 'Updated order #12325 status to In Progress',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 10)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a26',
        type: 'Login',
        description: 'Admin logged into system from new device',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 11)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a27',
        type: 'System Settings',
        description: 'Updated email notification templates',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 12)),
        icon: Icons.settings,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a28',
        type: 'Update Price',
        description: 'Bulk updated all prices by 5%',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 13)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a29',
        type: 'User Management',
        description: 'Exported user data report',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 14)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a30',
        type: 'Order Management',
        description: 'Generated monthly order report',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 15)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a31',
        type: 'Logout',
        description: 'Admin logged out of system',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 16)),
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
      AdminActivity(
        id: 'a32',
        type: 'Login',
        description: 'Failed login - account temporarily locked',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 17)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a33',
        type: 'System Settings',
        description: 'Configured automatic price adjustment rules',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 18)),
        icon: Icons.settings,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a34',
        type: 'Update Price',
        description: 'Updated Rubber buying price from 50 to 55 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 19)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a35',
        type: 'User Management',
        description: 'Added new admin user: Jane Admin',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 20)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a36',
        type: 'Order Management',
        description: 'Cancelled bulk orders due to system error',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 21)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a37',
        type: 'Login',
        description: 'Admin logged into system',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 22)),
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a38',
        type: 'System Settings',
        description: 'Reset system cache',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 23)),
        icon: Icons.settings,
        iconColor: AdminColors.accentBlue,
      ),
      AdminActivity(
        id: 'a39',
        type: 'Update Price',
        description: 'Updated Cardboard buying price from 20 to 25 PKR/kg',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 24)),
        icon: Icons.attach_money,
        iconColor: AdminColors.primaryGreen,
      ),
      AdminActivity(
        id: 'a40',
        type: 'User Management',
        description: 'Sent password reset link to multiple users',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 25)),
        icon: Icons.people,
        iconColor: AdminColors.accentPurple,
      ),
      AdminActivity(
        id: 'a41',
        type: 'Order Management',
        description: 'Archived old completed orders',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 26)),
        icon: Icons.inventory,
        iconColor: AdminColors.accentOrange,
      ),
      AdminActivity(
        id: 'a42',
        type: 'Logout',
        description: 'Admin logged out of system',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 27)),
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
    ];

    // User Activities (40+ activities)
    _allUserActivities = [
      UserActivity(
        id: 'u1',
        userName: 'John Doe',
        userType: 'Individual',
        activityType: 'Sell',
        description: 'Sold 50kg Plastic for 5,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 1)),
        location: 'Downtown, Lahore',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u2',
        userName: 'Sarah Khan',
        userType: 'Warehouse',
        activityType: 'Buy',
        description: 'Purchased 30kg Paper for 1,500 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 2)),
        location: 'Westside, Karachi',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u3',
        userName: 'Tech Corp',
        userType: 'Company',
        activityType: 'Login',
        description: 'Logged into account',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 3)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u4',
        userName: 'Mike Wilson',
        userType: 'Individual',
        activityType: 'Sell',
        description: 'Sold 20kg Metal for 3,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 4)),
        location: 'Uptown, Islamabad',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u5',
        userName: 'Lisa Brown',
        userType: 'Warehouse',
        activityType: 'Order Placed',
        description: 'Placed pickup order #10234',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 5)),
        location: 'Eastend, Lahore',
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u6',
        userName: 'Green Industries',
        userType: 'Company',
        activityType: 'Buy',
        description: 'Purchased 100kg E-waste for 22,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 6)),
        location: 'Industrial Area, Faisalabad',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u7',
        userName: 'Ahmed Ali',
        userType: 'Individual',
        activityType: 'Profile Update',
        description: 'Updated phone number and address',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 8)),
        location: null,
        icon: Icons.person,
        iconColor: AdminColors.accentPurple,
      ),
      UserActivity(
        id: 'u8',
        userName: 'City Recyclers',
        userType: 'Warehouse',
        activityType: 'Sell',
        description: 'Sold 200kg Mixed recyclables for 15,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(hours: 10)),
        location: 'Central, Lahore',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u9',
        userName: 'Maria Garcia',
        userType: 'Individual',
        activityType: 'Login',
        description: 'Login failed - wrong password',
        status: 'Failed',
        timestamp: now.subtract(const Duration(hours: 12)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u10',
        userName: 'Eco Solutions',
        userType: 'Company',
        activityType: 'Order Placed',
        description: 'Placed bulk pickup order #10235',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 1)),
        location: 'Business District, Karachi',
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u11',
        userName: 'Fatima Zahra',
        userType: 'Individual',
        activityType: 'Sell',
        description: 'Sold 15kg Glass for 270 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        location: 'Gulberg, Lahore',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u12',
        userName: 'Metro Warehouse',
        userType: 'Warehouse',
        activityType: 'Buy',
        description: 'Purchased 80kg Cardboard for 2,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        location: 'Metro Area, Rawalpindi',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u13',
        userName: 'Waste Masters Ltd',
        userType: 'Company',
        activityType: 'Profile Update',
        description: 'Updated company registration documents',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        location: null,
        icon: Icons.person,
        iconColor: AdminColors.accentPurple,
      ),
      UserActivity(
        id: 'u14',
        userName: 'Hassan Raza',
        userType: 'Individual',
        activityType: 'Logout',
        description: 'Logged out of account',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        location: null,
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
      UserActivity(
        id: 'u15',
        userName: 'Quick Recycle Hub',
        userType: 'Warehouse',
        activityType: 'Login',
        description: 'Logged into account',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 2)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u16',
        userName: 'Clean Earth Corp',
        userType: 'Company',
        activityType: 'Sell',
        description: 'Sold 500kg Industrial waste for 40,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        location: 'Industrial Zone, Multan',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u17',
        userName: 'Aisha Malik',
        userType: 'Individual',
        activityType: 'Order Placed',
        description: 'Placed pickup order #10236',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        location: 'Model Town, Lahore',
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u18',
        userName: 'Central Depot',
        userType: 'Warehouse',
        activityType: 'Sell',
        description: 'Sold 150kg Plastic for 16,500 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 3)),
        location: 'Central Depot, Karachi',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u19',
        userName: 'Usman Shah',
        userType: 'Individual',
        activityType: 'Buy',
        description: 'Purchase failed - insufficient balance',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 3, hours: 2)),
        location: 'DHA, Lahore',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u20',
        userName: 'Recycle Pro Inc',
        userType: 'Company',
        activityType: 'Login',
        description: 'Logged into account from new device',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u21',
        userName: 'Zainab Ahmed',
        userType: 'Individual',
        activityType: 'Sell',
        description: 'Sold 25kg Paper for 750 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 4)),
        location: 'Johar Town, Lahore',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u22',
        userName: 'Prime Warehouse',
        userType: 'Warehouse',
        activityType: 'Profile Update',
        description: 'Updated warehouse capacity details',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 4, hours: 2)),
        location: null,
        icon: Icons.person,
        iconColor: AdminColors.accentPurple,
      ),
      UserActivity(
        id: 'u23',
        userName: 'Green Tech Solutions',
        userType: 'Company',
        activityType: 'Buy',
        description: 'Purchased 300kg Metal for 28,500 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 4, hours: 5)),
        location: 'Tech Park, Islamabad',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u24',
        userName: 'Ali Hassan',
        userType: 'Individual',
        activityType: 'Order Placed',
        description: 'Placed pickup order #10237',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 5)),
        location: 'Cantt, Rawalpindi',
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u25',
        userName: 'Mega Recycle',
        userType: 'Warehouse',
        activityType: 'Logout',
        description: 'Logged out of account',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 5, hours: 3)),
        location: null,
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
      UserActivity(
        id: 'u26',
        userName: 'Eco Friendly Ltd',
        userType: 'Company',
        activityType: 'Sell',
        description: 'Sold 1000kg Mixed recyclables for 75,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 6)),
        location: 'Industrial Estate, Sialkot',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u27',
        userName: 'Nadia Hussain',
        userType: 'Individual',
        activityType: 'Login',
        description: 'Logged into account',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 6, hours: 2)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u28',
        userName: 'Super Store Warehouse',
        userType: 'Warehouse',
        activityType: 'Buy',
        description: 'Purchased 60kg Rubber for 3,300 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 7)),
        location: 'Super Market Area, Lahore',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u29',
        userName: 'Reuse Corp',
        userType: 'Company',
        activityType: 'Order Placed',
        description: 'Order placement failed - server error',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 7, hours: 4)),
        location: 'Corporate Center, Karachi',
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u30',
        userName: 'Tariq Mehmood',
        userType: 'Individual',
        activityType: 'Sell',
        description: 'Sold 40kg E-waste for 8,800 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 8)),
        location: 'Bahria Town, Lahore',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u31',
        userName: 'City Center Depot',
        userType: 'Warehouse',
        activityType: 'Sell',
        description: 'Sold 250kg Cardboard for 6,250 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 9)),
        location: 'City Center, Faisalabad',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u32',
        userName: 'Sustainable Solutions',
        userType: 'Company',
        activityType: 'Profile Update',
        description: 'Updated business license information',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 10)),
        location: null,
        icon: Icons.person,
        iconColor: AdminColors.accentPurple,
      ),
      UserActivity(
        id: 'u33',
        userName: 'Bilal Ahmed',
        userType: 'Individual',
        activityType: 'Buy',
        description: 'Purchased 10kg Glass for 180 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 11)),
        location: 'Garden Town, Lahore',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u34',
        userName: 'Eastern Warehouse',
        userType: 'Warehouse',
        activityType: 'Login',
        description: 'Login failed - account suspended',
        status: 'Failed',
        timestamp: now.subtract(const Duration(days: 12)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u35',
        userName: 'Zero Waste Co',
        userType: 'Company',
        activityType: 'Buy',
        description: 'Purchased 400kg Plastic for 44,000 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 13)),
        location: 'Zero Waste Zone, Lahore',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
      UserActivity(
        id: 'u36',
        userName: 'Sana Fatima',
        userType: 'Individual',
        activityType: 'Order Placed',
        description: 'Placed pickup order #10238',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 14)),
        location: 'Iqbal Town, Lahore',
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u37',
        userName: 'National Recyclers',
        userType: 'Warehouse',
        activityType: 'Sell',
        description: 'Sold 180kg Metal for 17,100 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 15)),
        location: 'National Highway, Karachi',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u38',
        userName: 'Circular Economy Inc',
        userType: 'Company',
        activityType: 'Logout',
        description: 'Logged out of account',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 16)),
        location: null,
        icon: Icons.logout,
        iconColor: AdminColors.textSecondary,
      ),
      UserActivity(
        id: 'u39',
        userName: 'Imran Khan',
        userType: 'Individual',
        activityType: 'Sell',
        description: 'Sold 35kg Paper for 1,050 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 17)),
        location: 'Shadman, Lahore',
        icon: Icons.sell,
        iconColor: AdminColors.primaryGreen,
      ),
      UserActivity(
        id: 'u40',
        userName: 'Global Recycle Hub',
        userType: 'Warehouse',
        activityType: 'Profile Update',
        description: 'Updated contact information',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 18)),
        location: null,
        icon: Icons.person,
        iconColor: AdminColors.accentPurple,
      ),
      UserActivity(
        id: 'u41',
        userName: 'Eco Warriors Ltd',
        userType: 'Company',
        activityType: 'Login',
        description: 'Logged into account',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 19)),
        location: null,
        icon: Icons.login,
        iconColor: AdminColors.accentBlue,
      ),
      UserActivity(
        id: 'u42',
        userName: 'Saima Nawaz',
        userType: 'Individual',
        activityType: 'Buy',
        description: 'Purchased 5kg Rubber for 275 PKR',
        status: 'Success',
        timestamp: now.subtract(const Duration(days: 20)),
        location: 'Township, Lahore',
        icon: Icons.shopping_cart,
        iconColor: AdminColors.accentOrange,
      ),
    ];

    // Initialize filtered lists with all data
    _filteredAdminActivities = List.from(_allAdminActivities);
    _filteredUserActivities = List.from(_allUserActivities);
  }

  // Filter admin activities
  void _applyAdminFilters() {
    setState(() {
      _filteredAdminActivities = _allAdminActivities.where((activity) {
        // Activity type filter
        if (_adminActivityTypeFilter != 'all' &&
            activity.type.toLowerCase() !=
                _adminActivityTypeFilter.toLowerCase()) {
          return false;
        }

        // Status filter
        if (_adminStatusFilter != 'all' &&
            activity.status.toLowerCase() != _adminStatusFilter.toLowerCase()) {
          return false;
        }

        // Date filter
        if (_adminDateFilter != 'all') {
          final now = DateTime.now();
          DateTime startDate;

          switch (_adminDateFilter) {
            case 'today':
              startDate = DateTime(now.year, now.month, now.day);
              break;
            case 'week':
              startDate = now.subtract(const Duration(days: 7));
              break;
            case 'month':
              startDate = now.subtract(const Duration(days: 30));
              break;
            case 'custom':
              if (_adminCustomDateRange != null) {
                if (activity.timestamp.isBefore(_adminCustomDateRange!.start) ||
                    activity.timestamp.isAfter(_adminCustomDateRange!.end)) {
                  return false;
                }
              }
              return true;
            default:
              return true;
          }

          if (activity.timestamp.isBefore(startDate)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  // Filter user activities
  void _applyUserFilters() {
    setState(() {
      _filteredUserActivities = _allUserActivities.where((activity) {
        // User type filter
        if (_userTypeFilter != 'all' &&
            activity.userType.toLowerCase() != _userTypeFilter.toLowerCase()) {
          return false;
        }

        // Activity type filter
        if (_userActivityTypeFilter != 'all' &&
            activity.activityType.toLowerCase() !=
                _userActivityTypeFilter.toLowerCase()) {
          return false;
        }

        // Status filter
        if (_userStatusFilter != 'all' &&
            activity.status.toLowerCase() != _userStatusFilter.toLowerCase()) {
          return false;
        }

        // Date filter
        if (_userDateFilter != 'all') {
          final now = DateTime.now();
          DateTime startDate;

          switch (_userDateFilter) {
            case 'today':
              startDate = DateTime(now.year, now.month, now.day);
              break;
            case 'week':
              startDate = now.subtract(const Duration(days: 7));
              break;
            case 'month':
              startDate = now.subtract(const Duration(days: 30));
              break;
            case 'custom':
              if (_userCustomDateRange != null) {
                if (activity.timestamp.isBefore(_userCustomDateRange!.start) ||
                    activity.timestamp.isAfter(_userCustomDateRange!.end)) {
                  return false;
                }
              }
              return true;
            default:
              return true;
          }

          if (activity.timestamp.isBefore(startDate)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  // Clear admin filters
  void _clearAdminFilters() {
    setState(() {
      _adminActivityTypeFilter = 'all';
      _adminStatusFilter = 'all';
      _adminDateFilter = 'all';
      _adminCustomDateRange = null;
      _filteredAdminActivities = List.from(_allAdminActivities);
    });
  }

  // Clear user filters
  void _clearUserFilters() {
    setState(() {
      _userTypeFilter = 'all';
      _userActivityTypeFilter = 'all';
      _userStatusFilter = 'all';
      _userDateFilter = 'all';
      _userCustomDateRange = null;
      _filteredUserActivities = List.from(_allUserActivities);
    });
  }

  // Check if admin filters are active
  bool get _hasActiveAdminFilters =>
      _adminActivityTypeFilter != 'all' ||
      _adminStatusFilter != 'all' ||
      _adminDateFilter != 'all';

  // Check if user filters are active
  bool get _hasActiveUserFilters =>
      _userTypeFilter != 'all' ||
      _userActivityTypeFilter != 'all' ||
      _userStatusFilter != 'all' ||
      _userDateFilter != 'all';

  // Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year} - ${hour == 0 ? 12 : hour}:${timestamp.minute.toString().padLeft(2, '0')} $period';
    }
  }

  // Get user type color
  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'individual':
        return AdminColors.accentBlue;
      case 'warehouse':
        return AdminColors.accentOrange;
      case 'company':
        return AdminColors.accentPurple;
      default:
        return AdminColors.textSecondary;
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Simulate refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Activity Logs',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list,
                color: theme.appBarTheme.foregroundColor),
            onSelected: (value) {
              // Handle quick filter selection
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'today',
                child: Row(
                  children: [
                    Icon(Icons.today, size: 20),
                    SizedBox(width: 8),
                    Text('Today'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 20),
                    SizedBox(width: 8),
                    Text('Last 7 Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 8),
                    Text('Last 30 Days'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: AdminColors.textWhite,
          indicatorWeight: 3,
          labelColor: AdminColors.textWhite,
          unselectedLabelColor: AdminColors.textWhite.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 18),
                  SizedBox(width: 6),
                  Text('Admin Activities'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 6),
                  Text('User Activities'),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: const AdminDrawer(currentRoute: 'logs'),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildAdminActivitiesTab(),
          _buildUserActivitiesTab(),
        ],
      ),
    );
  }

  // Admin Activities Tab
  Widget _buildAdminActivitiesTab() {
    return Column(
      children: [
        // Filter indicator
        if (_hasActiveAdminFilters) _buildFilterIndicator(isAdmin: true),

        // Filter section
        _buildAdminFilterSection(),

        // Activities list
        Expanded(
          child: _filteredAdminActivities.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AdminColors.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredAdminActivities.length,
                    itemBuilder: (context, index) {
                      return _buildAdminActivityCard(
                          _filteredAdminActivities[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // User Activities Tab
  Widget _buildUserActivitiesTab() {
    return Column(
      children: [
        // Filter indicator
        if (_hasActiveUserFilters) _buildFilterIndicator(isAdmin: false),

        // User type sub-tabs
        _buildUserTypeChips(),

        // Filter section
        _buildUserFilterSection(),

        // Activities list
        Expanded(
          child: _filteredUserActivities.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AdminColors.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredUserActivities.length,
                    itemBuilder: (context, index) {
                      return _buildUserActivityCard(
                          _filteredUserActivities[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // Filter indicator banner
  Widget _buildFilterIndicator({required bool isAdmin}) {
    final activeFilters = <String>[];

    if (isAdmin) {
      if (_adminActivityTypeFilter != 'all') {
        activeFilters.add(_adminActivityTypeFilter);
      }
      if (_adminStatusFilter != 'all') {
        activeFilters.add(_adminStatusFilter);
      }
      if (_adminDateFilter != 'all') {
        activeFilters.add(_adminDateFilter == 'custom'
            ? 'Custom Date'
            : _adminDateFilter.capitalize());
      }
    } else {
      if (_userTypeFilter != 'all') {
        activeFilters.add(_userTypeFilter);
      }
      if (_userActivityTypeFilter != 'all') {
        activeFilters.add(_userActivityTypeFilter);
      }
      if (_userStatusFilter != 'all') {
        activeFilters.add(_userStatusFilter);
      }
      if (_userDateFilter != 'all') {
        activeFilters.add(_userDateFilter == 'custom'
            ? 'Custom Date'
            : _userDateFilter.capitalize());
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AdminColors.primaryGreen.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: AdminColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filters: ${activeFilters.join(', ')}',
              style: const TextStyle(
                color: AdminColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: isAdmin ? _clearAdminFilters : _clearUserFilters,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: AdminColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Admin filter section
  Widget _buildAdminFilterSection() {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Activity Type Filter
            _buildFilterDropdown(
              label: 'Activity Type',
              icon: Icons.category,
              value: _adminActivityTypeFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Activities')),
                DropdownMenuItem(value: 'login', child: Text('Login')),
                DropdownMenuItem(value: 'logout', child: Text('Logout')),
                DropdownMenuItem(
                    value: 'update price', child: Text('Update Price')),
                DropdownMenuItem(
                    value: 'user management', child: Text('User Management')),
                DropdownMenuItem(
                    value: 'order management', child: Text('Order Management')),
                DropdownMenuItem(
                    value: 'system settings', child: Text('System Settings')),
              ],
              onChanged: (value) {
                setState(() {
                  _adminActivityTypeFilter = value ?? 'all';
                });
                _applyAdminFilters();
              },
            ),
            const SizedBox(width: 8),

            // Status Filter
            _buildFilterDropdown(
              label: 'Status',
              icon: Icons.check_circle,
              value: _adminStatusFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'success', child: Text('Success')),
                DropdownMenuItem(value: 'failed', child: Text('Failed')),
              ],
              onChanged: (value) {
                setState(() {
                  _adminStatusFilter = value ?? 'all';
                });
                _applyAdminFilters();
              },
            ),
            const SizedBox(width: 8),

            // Date Filter
            _buildFilterDropdown(
              label: 'Date',
              icon: Icons.calendar_today,
              value: _adminDateFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Time')),
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: 'week', child: Text('Last 7 Days')),
                DropdownMenuItem(value: 'month', child: Text('Last 30 Days')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
              ],
              onChanged: (value) async {
                if (value == 'custom') {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AdminColors.primaryGreen,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (dateRange != null) {
                    setState(() {
                      _adminDateFilter = 'custom';
                      _adminCustomDateRange = dateRange;
                    });
                    _applyAdminFilters();
                  }
                } else {
                  setState(() {
                    _adminDateFilter = value ?? 'all';
                    _adminCustomDateRange = null;
                  });
                  _applyAdminFilters();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // User filter section
  Widget _buildUserFilterSection() {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Activity Type Filter
            _buildFilterDropdown(
              label: 'Activity Type',
              icon: Icons.category,
              value: _userActivityTypeFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Activities')),
                DropdownMenuItem(value: 'login', child: Text('Login')),
                DropdownMenuItem(value: 'logout', child: Text('Logout')),
                DropdownMenuItem(value: 'sell', child: Text('Sell')),
                DropdownMenuItem(value: 'buy', child: Text('Buy')),
                DropdownMenuItem(
                    value: 'profile update', child: Text('Profile Update')),
                DropdownMenuItem(
                    value: 'order placed', child: Text('Order Placed')),
              ],
              onChanged: (value) {
                setState(() {
                  _userActivityTypeFilter = value ?? 'all';
                });
                _applyUserFilters();
              },
            ),
            const SizedBox(width: 8),

            // Status Filter
            _buildFilterDropdown(
              label: 'Status',
              icon: Icons.check_circle,
              value: _userStatusFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'success', child: Text('Success')),
                DropdownMenuItem(value: 'failed', child: Text('Failed')),
              ],
              onChanged: (value) {
                setState(() {
                  _userStatusFilter = value ?? 'all';
                });
                _applyUserFilters();
              },
            ),
            const SizedBox(width: 8),

            // Date Filter
            _buildFilterDropdown(
              label: 'Date',
              icon: Icons.calendar_today,
              value: _userDateFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Time')),
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: 'week', child: Text('Last 7 Days')),
                DropdownMenuItem(value: 'month', child: Text('Last 30 Days')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
              ],
              onChanged: (value) async {
                if (value == 'custom') {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AdminColors.primaryGreen,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (dateRange != null) {
                    setState(() {
                      _userDateFilter = 'custom';
                      _userCustomDateRange = dateRange;
                    });
                    _applyUserFilters();
                  }
                } else {
                  setState(() {
                    _userDateFilter = value ?? 'all';
                    _userCustomDateRange = null;
                  });
                  _applyUserFilters();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // User type chips
  Widget _buildUserTypeChips() {
    final theme = Theme.of(context);
    final userTypes = ['all', 'Individual', 'Warehouse', 'Company'];

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: userTypes.map((type) {
            final isSelected =
                _userTypeFilter.toLowerCase() == type.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(type == 'all' ? 'All Users' : type),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AdminColors.textWhite
                      : AdminColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                backgroundColor: AdminColors.surfaceLight,
                selectedColor: AdminColors.primaryGreen,
                checkmarkColor: AdminColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AdminColors.primaryGreen
                        : AdminColors.border,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    _userTypeFilter = type.toLowerCase();
                  });
                  _applyUserFilters();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Filter dropdown widget
  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AdminColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(
            color: AdminColors.textPrimary,
            fontSize: 13,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Admin activity card
  Widget _buildAdminActivityCard(AdminActivity activity) {
    final theme = Theme.of(context);
    final isSuccess = activity.status.toLowerCase() == 'success';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left border
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: isSuccess ? AdminColors.success : AdminColors.error,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activity.iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity.icon,
                            color: activity.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Activity type
                        Expanded(
                          child: Text(
                            activity.type,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isSuccess
                                    ? AdminColors.success
                                    : AdminColors.error)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuccess ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: isSuccess
                                    ? AdminColors.success
                                    : AdminColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSuccess
                                      ? AdminColors.success
                                      : AdminColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom row
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: AdminColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Admin User',
                              style: TextStyle(
                                fontSize: 12,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AdminColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(activity.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User activity card
  Widget _buildUserActivityCard(UserActivity activity) {
    final theme = Theme.of(context);
    final isSuccess = activity.status.toLowerCase() == 'success';
    final userTypeColor = _getUserTypeColor(activity.userType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left border
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: isSuccess ? AdminColors.success : AdminColors.error,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activity.iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity.icon,
                            color: activity.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Activity type
                        Expanded(
                          child: Text(
                            activity.activityType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isSuccess
                                    ? AdminColors.success
                                    : AdminColors.error)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuccess ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: isSuccess
                                    ? AdminColors.success
                                    : AdminColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSuccess
                                      ? AdminColors.success
                                      : AdminColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // User name with type badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            activity.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AdminColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: userTypeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            activity.userType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: userTypeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom row
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (activity.location != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AdminColors.textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AdminColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(activity.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AdminColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No activities found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for String capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
