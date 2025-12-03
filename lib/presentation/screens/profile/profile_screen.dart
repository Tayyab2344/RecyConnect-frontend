import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'settings_screen.dart';
import 'purchase_history_screen.dart';
import 'sales_history_screen.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    final authService = context.read<AuthService>();
    try {
      await authService.fetchProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh profile: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;

          if (authService.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              ),
            );
          }

          if (user == null) {
            return const Center(child: Text('No user data available'));
          }

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user, isDark),
                
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardSurface : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
                    indicatorColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Personal'),
                      Tab(text: 'Stats'),
                      Tab(text: 'Activity'),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalTab(user, isDark, authService),
                      _buildStatsTab(isDark, authService),
                      _buildActivityTab(isDark, authService),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user, bool isDark) {
    final hasProfileImage = user['profileImage'] != null && (user['profileImage'] as String).isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppTheme.darkCardSurface : Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: hasProfileImage
                  ? Image.network(
                      user['profileImage'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: isDark ? AppTheme.darkBackground : Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        final displayName = (user['role'] == 'warehouse' || user['role'] == 'company')
                            ? (user['businessName'] as String? ?? user['name'] as String?)
                            : (user['name'] as String?);
                        return Center(
                          child: Text(
                            (displayName?.isNotEmpty == true ? displayName![0].toUpperCase() : 'U'),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkBackground : Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Builder(
                        builder: (context) {
                          final displayName = (user['role'] == 'warehouse' || user['role'] == 'company')
                              ? (user['businessName'] as String? ?? user['name'] as String?)
                              : (user['name'] as String?);
                          return Text(
                            (displayName?.isNotEmpty == true ? displayName![0].toUpperCase() : 'U'),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkBackground : Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 20),
          // Name and Edit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (user['role'] == 'warehouse' || user['role'] == 'company')
                      ? (user['businessName'] as String? ?? user['name'] as String? ?? 'Unknown Business')
                      : (user['name'] as String? ?? 'Unknown User'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    (user['role'] as String? ?? 'User').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] as String? ?? 'No email',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      if (result == true) {
                        _refreshProfile();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      side: BorderSide(
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(Map<String, dynamic> user, bool isDark, AuthService authService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Contact Info Card
          _buildSectionCard(
            title: 'Contact Information',
            isDark: isDark,
            children: [
              _buildDetailRow(Icons.phone_outlined, user['contactNo'] as String? ?? 'Not provided', isDark),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.email_outlined, user['email'] as String? ?? 'Not provided', isDark),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Member since ${_getFormattedDate(user['createdAt'] != null ? DateTime.tryParse(user['createdAt'].toString()) : null)}',
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Address Card
          _buildSectionCard(
            title: 'Address & Location',
            isDark: isDark,
            action: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location update feature coming soon!')),
                );
              },
              child: const Text('Update'),
            ),
            children: [
              _buildDetailRow(
                Icons.location_on_outlined,
                user['address'] as String? ?? 'No address provided',
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KYC Documents (Warehouse/Company only)
          if (user['role'] == 'warehouse' || user['role'] == 'company')
            _buildDocumentsSection(user, isDark),
          
          if (user['role'] == 'warehouse' || user['role'] == 'company')
            const SizedBox(height: 20),

          // Account Settings
          _buildSectionCard(
            title: 'Account Settings',
            isDark: isDark,
            children: [
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                isDark: isDark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              _buildSettingsTile(
                icon: Icons.lock_outlined,
                title: 'Change Password',
                isDark: isDark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
              ),
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                isDark: isDark,
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, authService),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(bool isDark, AuthService authService) {
    final userRole = authService.currentUser?['role'];
    final isWarehouse = userRole == 'warehouse' || userRole == 'company';
    
    if (isWarehouse) {
      // Warehouse Business Stats
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Rs 125.5K',
                    'Total Revenue',
                    Icons.trending_up,
                    const Color(0xFF4CAF50),
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Rs 45.2K',
                    'Net Profit',
                    Icons.attach_money,
                    const Color(0xFF2196F3),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '28',
                    'Active Orders',
                    Icons.shopping_cart_outlined,
                    const Color(0xFFFF9800),
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Rs 85K',
                    'Inventory Value',
                    Icons.inventory_2_outlined,
                    const Color(0xFF9C27B0),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              '36%',
              'Profit Margin',
              Icons.percent,
              isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              isDark,
              fullWidth: true,
            ),
            const SizedBox(height: 20),
            // Business Impact
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.darkPrimaryGreen, AppTheme.darkSecondaryGreen]
                      : [AppTheme.primaryGreen, const Color(0xFF45A049)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.business_center, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Business Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your warehouse processed 156 inventory items and completed 28 orders this month with a healthy 36% profit margin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Individual User Stats (original)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '12',
                  'Items Sold',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '8',
                  'Items Bought',
                  Icons.shopping_bag_outlined,
                  const Color(0xFF2196F3),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Rs 2,450',
            'Total Earnings',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF9C27B0),
            isDark,
            fullWidth: true,
          ),
          const SizedBox(height: 20),
          // Eco Impact Placeholder
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppTheme.darkPrimaryGreen.withOpacity(0.2), AppTheme.darkSecondaryGreen.withOpacity(0.2)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFE0F2F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkPrimaryGreen.withOpacity(0.3) : AppTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.eco, size: 40, color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen),
                const SizedBox(height: 12),
                Text(
                  'Your Eco Impact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have saved approximately 45kg of CO2 emissions by recycling!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(bool isDark, AuthService authService) {
    final userRole = authService.currentUser?['role'];
    final isWarehouse = userRole == 'warehouse' || userRole == 'company';
    
    if (isWarehouse) {
      // Warehouse Business Activity
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildActivityTile(
            icon: Icons.inventory_outlined,
            title: 'Inventory Management',
            subtitle: 'View and manage your inventory',
            color: const Color(0xFF9C27B0),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context); // Close profile
              // Dashboard is already accessible from home
            },
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Financial Overview',
            subtitle: 'Revenue, expenses, and P&L statements',
            color: const Color(0xFFFF9800),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            icon: Icons.analytics_outlined,
            title: 'Business Analytics',
            subtitle: 'Charts, trends, and insights',
            color: const Color(0xFFE91E63),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            icon: Icons.people_outlined,
            title: 'Collector Performance',
            subtitle: 'Track collector metrics and earnings',
            color: const Color(0xFF00BCD4),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            icon: Icons.receipt_long_outlined,
            title: 'Order Management',
            subtitle: 'View and track all orders',
            color: const Color(0xFF4CAF50),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            icon: Icons.description_outlined,
            title: 'Generate Reports',
            subtitle: 'PDF/Excel business reports',
            color: const Color(0xFF795548),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    }
    
    // Individual User Activity (original)
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildActivityTile(
          icon: Icons.receipt_long_outlined,
          title: 'Sales History',
          subtitle: 'View your past sales and earnings',
          color: Colors.orange,
          isDark: isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen())),
        ),
        const SizedBox(height: 12),
        _buildActivityTile(
          icon: Icons.shopping_cart_outlined,
          title: 'Purchase History',
          subtitle: 'Track your purchases and orders',
          color: Colors.blue,
          isDark: isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen())),
        ),
        const SizedBox(height: 12),
        _buildActivityTile(
          icon: Icons.message_outlined,
          title: 'Messages',
          subtitle: 'Chats with buyers and sellers',
          color: Colors.purple,
          isDark: isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen())),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required bool isDark,
    required List<Widget> children,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              if (action != null) action,
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(Map<String, dynamic> user, bool isDark) {
    final documents = user['documents'] as List<dynamic>? ?? [];

    if (documents.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'KYC Documents',
      isDark: isDark,
      children: documents.map((doc) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              final url = Uri.parse(doc['fileUrl']);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open document')),
                  );
                }
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: isDark ? AppTheme.darkSecondaryGreen : AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['docType'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      if (doc['fileName'] != null)
                        Text(
                          doc['fileName'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppTheme.darkSecondaryGreen : AppTheme.primaryGreen,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? AppTheme.errorRed : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppTheme.errorRed : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime? date) {
    if (date == null) return 'January 2024';
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}
