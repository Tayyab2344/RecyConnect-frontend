import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
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

/// Premium My Profile Screen for RecyConnect
/// Features: Glassmorphism, Holographic Background, Neon Accents, Animated Elements
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late AnimationController _bgAnimController;
  late Animation<double> _pulseAnimation;

  @override
  bool get wantKeepAlive => true; // Keep the profile screen alive

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Pulse animation for glowing effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Background animation
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Defer the profile fetch to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _bgAnimController.dispose();
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          _buildBackground(isDark),

          // 2. Floating Particles (Dark mode only)
          if (isDark) _buildFloatingParticles(),

          // 3. Main Content
          SafeArea(
            child: Consumer<AuthService>(
              builder: (context, authService, child) {
                final user = authService.currentUser;

                if (authService.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                    ),
                  );
                }

                if (user == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No user data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Simple Column layout with scrollable content
                return Column(
                  children: [
                    // Custom App Bar
                    _buildCustomAppBar(isDark),
                    
                    // Scrollable content
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshProfile,
                        color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              // Profile Header Card
                              _buildProfileHeader(user, isDark),
                              
                              // Tab Bar
                              _buildTabBar(isDark),
                              
                              // Tab Content - Fixed height container
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
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
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A1628), // Deep navy
                  const Color(0xFF0D2137), // Dark teal-navy
                  const Color(0xFF0F2847), // Medium navy
                  const Color(0xFF0A1E35), // Back to deep navy
                ]
              : [
                  const Color(0xFFFFFFFF), // Pure white
                  const Color(0xFFF0F9F7), // Soft white-teal
                  const Color(0xFFE8F5F2), // Light teal
                  const Color(0xFFDFF2ED), // Soft teal
                ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ParticlesPainter(
            animationValue: _bgAnimController.value,
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          _buildIconButton(
            icon: Icons.settings_outlined,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.1 * _pulseAnimation.value),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              size: 22,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user, bool isDark) {
    final hasProfileImage = user['profileImage'] != null &&
        (user['profileImage'] as String).isNotEmpty;
    final displayName = (user['role'] == 'warehouse' || user['role'] == 'company')
        ? (user['businessName'] as String? ?? user['name'] as String? ?? 'Unknown Business')
        : (user['name'] as String? ?? 'Unknown User');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return _GlassCard(
            isDark: isDark,
            pulseValue: _pulseAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar with glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isDark
                            ? [
                                AppColors.neonCyan.withValues(alpha: 0.3 * _pulseAnimation.value),
                                Colors.transparent,
                              ]
                            : [
                                AppColors.primaryGreen.withValues(alpha: 0.2 * _pulseAnimation.value),
                                Colors.transparent,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.neonCyan.withValues(alpha: 0.3 * _pulseAnimation.value)
                              : AppColors.primaryGreen.withValues(alpha: 0.2 * _pulseAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                        border: Border.all(
                          color: isDark
                              ? AppColors.neonCyan.withValues(alpha: 0.5)
                              : Colors.white,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: hasProfileImage
                            ? Image.network(
                                user['profileImage'],
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildAvatarPlaceholder(displayName, isDark);
                                },
                              )
                            : _buildAvatarPlaceholder(displayName, isDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.neonCyan.withValues(alpha: 0.2), AppColors.neonGreen.withValues(alpha: 0.2)]
                            : [AppColors.primaryGreen.withValues(alpha: 0.1), AppColors.primaryGreen.withValues(alpha: 0.2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.5)
                            : AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      (user['role'] as String? ?? 'User').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Text(
                    user['email'] as String? ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : const Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  _buildPrimaryButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    isDark: isDark,
                    onTap: () async {
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String displayName, bool isDark) {
    return Center(
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF0A1628) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final buttonColor = isDark ? AppColors.neonGreen : AppColors.primaryGreen;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.4 * _pulseAnimation.value),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.neonGreen, AppColors.neonCyan]
                        : [AppColors.primaryGreen, const Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: isDark ? const Color(0xFF0A1628) : Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF0A1628) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TabBar(
            controller: _tabController,
            labelColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade600,
            indicatorColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Personal'),
              Tab(text: 'Stats'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
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
            icon: Icons.contact_mail_outlined,
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
            icon: Icons.location_on_outlined,
            isDark: isDark,
            action: _buildSmallButton(
              label: 'Update',
              isDark: isDark,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location update feature coming soon!')),
                );
              },
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
            icon: Icons.settings_outlined,
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
          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildStatsTab(bool isDark, AuthService authService) {
    final userRole = authService.currentUser?['role'];
    final isWarehouse = userRole == 'warehouse' || userRole == 'company';

    if (isWarehouse) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Rs 125.5K', 'Total Revenue', Icons.trending_up, AppColors.neonGreen, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Rs 45.2K', 'Net Profit', Icons.attach_money, AppColors.neonCyan, isDark)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('28', 'Active Orders', Icons.shopping_cart_outlined, const Color(0xFFFF9800), isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Rs 85K', 'Inventory Value', Icons.inventory_2_outlined, const Color(0xFF9C27B0), isDark)),
              ],
            ),
            const SizedBox(height: 20),
            _buildBusinessImpactCard(isDark),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    // Individual User Stats
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('12', 'Items Sold', Icons.trending_up, AppColors.neonGreen, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('8', 'Items Bought', Icons.shopping_bag_outlined, AppColors.neonCyan, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard('Rs 2,450', 'Total Earnings', Icons.account_balance_wallet_outlined, const Color(0xFF9C27B0), isDark, fullWidth: true),
          const SizedBox(height: 20),
          _buildEcoImpactCard(isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, bool isDark, {bool fullWidth = false}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return _GlassCard(
          isDark: isDark,
          pulseValue: _pulseAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: color.withValues(alpha: 0.3)) : null,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEcoImpactCard(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.neonGreen.withValues(alpha: 0.2), AppColors.neonCyan.withValues(alpha: 0.2)]
                  : [AppColors.primaryGreen, const Color(0xFF45A049)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: AppColors.neonGreen.withValues(alpha: 0.5))
                : null,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.neonGreen.withValues(alpha: 0.2 * _pulseAnimation.value)
                    : AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.eco,
                size: 48,
                color: isDark ? AppColors.neonGreen : Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Eco Impact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have saved approximately 45kg of CO2 emissions by recycling!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessImpactCard(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.neonCyan.withValues(alpha: 0.2), AppColors.neonGreen.withValues(alpha: 0.2)]
                  : [AppColors.primaryGreen, const Color(0xFF45A049)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5))
                : null,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.2 * _pulseAnimation.value)
                    : AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.business_center,
                size: 48,
                color: isDark ? AppColors.neonCyan : Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Business Performance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your warehouse processed 156 inventory items and completed 28 orders this month with a healthy 36% profit margin!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab(bool isDark, AuthService authService) {
    final userRole = authService.currentUser?['role'];
    final isWarehouse = userRole == 'warehouse' || userRole == 'company';

    final activities = isWarehouse
        ? [
            _ActivityItem(Icons.inventory_outlined, 'Inventory Management', 'View and manage your inventory', const Color(0xFF9C27B0)),
            _ActivityItem(Icons.account_balance_wallet_outlined, 'Financial Overview', 'Revenue, expenses, and P&L', const Color(0xFFFF9800)),
            _ActivityItem(Icons.analytics_outlined, 'Business Analytics', 'Charts, trends, and insights', const Color(0xFFE91E63)),
            _ActivityItem(Icons.people_outlined, 'Collector Performance', 'Track collector metrics', const Color(0xFF00BCD4)),
            _ActivityItem(Icons.receipt_long_outlined, 'Order Management', 'View and track orders', AppColors.neonGreen),
          ]
        : [
            _ActivityItem(Icons.receipt_long_outlined, 'Sales History', 'View your past sales and earnings', const Color(0xFFFF9800)),
            _ActivityItem(Icons.shopping_cart_outlined, 'Purchase History', 'Track your purchases and orders', AppColors.neonCyan),
            _ActivityItem(Icons.message_outlined, 'Messages', 'Chats with buyers and sellers', const Color(0xFF9C27B0)),
          ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length + 1, // +1 for bottom padding
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == activities.length) {
          return const SizedBox(height: 60);
        }
        return _buildActivityTile(activities[index], isDark, isWarehouse, authService);
      },
    );
  }

  Widget _buildActivityTile(_ActivityItem item, bool isDark, bool isWarehouse, AuthService authService) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (!isWarehouse) {
              if (item.title == 'Sales History') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
              } else if (item.title == 'Purchase History') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen()));
              } else if (item.title == 'Messages') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
              }
            }
          },
          child: _GlassCard(
            isDark: isDark,
            pulseValue: _pulseAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: isDark
                          ? Border.all(color: item.color.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
    Widget? action,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return _GlassCard(
          isDark: isDark,
          pulseValue: _pulseAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    if (action != null) action,
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.transparent, AppColors.neonCyan.withValues(alpha: 0.3), Colors.transparent]
                          : [Colors.transparent, Colors.grey.shade300, Colors.transparent],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.neonCyan.withValues(alpha: 0.1)
                : AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF333333),
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
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.neonCyan : AppColors.primaryGreen);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? AppColors.error
                        : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(Map<String, dynamic> user, bool isDark) {
    final documents = user['documents'] as List<dynamic>? ?? [];

    if (documents.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'KYC Documents',
      icon: Icons.description_outlined,
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
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.neonGreen.withValues(alpha: 0.1)
                        : AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['docType'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (doc['fileName'] != null)
                        Text(
                          doc['fileName'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : const Color(0xFF666666),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1A2A3A) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUPPORTING WIDGETS & PAINTERS
// ============================================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double pulseValue;
  final BorderRadius? borderRadius;

  const _GlassCard({
    required this.child,
    required this.isDark,
    required this.pulseValue,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.65),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? AppColors.neonCyan.withValues(alpha: 0.15 + 0.1 * pulseValue)
                  : Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.08 * pulseValue),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  _ProfileTabBarDelegate({required this.child, required this.isDark});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark
          ? const Color(0xFF0A1628).withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.9),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabBarDelegate oldDelegate) {
    return child != oldDelegate.child || isDark != oldDelegate.isDark;
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + animationValue * size.height * 0.3) % size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _ActivityItem(this.icon, this.title, this.subtitle, this.color);
}
