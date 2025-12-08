import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_system.dart';
import '../../../core/navigation/premium_transitions.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/constants/admin_colors.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/admin/admin_collectors_screen.dart';
import '../../screens/admin/admin_orders_screen.dart';
import '../../screens/admin/admin_pricing_screen.dart';
import '../../screens/admin/admin_activities_screen.dart';
import '../../screens/admin/admin_reports_screen.dart';
import '../../screens/admin/admin_notifications_screen.dart';
import '../../screens/admin/admin_settings_screen.dart';
import '../../screens/auth/login_screen.dart';

class PremiumAdminDrawer extends StatefulWidget {
  final String currentRoute;

  const PremiumAdminDrawer({
    super.key,
    this.currentRoute = 'dashboard',
  });

  @override
  State<PremiumAdminDrawer> createState() => _PremiumAdminDrawerState();
}

class _PremiumAdminDrawerState extends State<PremiumAdminDrawer>
    with TickerProviderStateMixin {
  String _selectedItem = 'dashboard';
  late AnimationController _mainController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<AnimationController> _itemControllers;

  // Admin info
  String _adminName = 'Admin User';
  String _adminEmail = 'panel.quantix@gmail.com';

  // Menu items data
  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard_rounded,
      'title': 'Dashboard',
      'route': 'dashboard',
      'screen': const AdminDashboardScreen(),
      'gradient': PremiumDesignSystem.primaryGradient,
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Users Management',
      'route': 'users',
      'screen': const AdminUsersScreen(),
      'gradient': PremiumDesignSystem.blueGradient,
    },
    {
      'icon': Icons.local_shipping_rounded,
      'title': 'Collectors',
      'route': 'collectors',
      'screen': const AdminCollectorsScreen(),
      'gradient': PremiumDesignSystem.orangeGradient,
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'title': 'Orders',
      'route': 'orders',
      'screen': const AdminOrdersScreen(),
      'gradient': PremiumDesignSystem.purpleGradient,
    },
    {
      'icon': Icons.attach_money_rounded,
      'title': 'Pricing',
      'route': 'pricing',
      'screen': const AdminPricingScreen(),
      'gradient': PremiumDesignSystem.successGradient,
    },
    {
      'icon': Icons.history_rounded,
      'title': 'Activity Logs',
      'route': 'logs',
      'screen': const AdminActivitiesScreen(),
      'gradient': PremiumDesignSystem.tealGradient,
    },
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Reports & Analytics',
      'route': 'reports',
      'screen': const AdminReportsScreen(),
      'gradient': PremiumDesignSystem.purpleGradient,
    },
    {
      'icon': Icons.notifications_rounded,
      'title': 'Notifications',
      'route': 'notifications',
      'screen': const AdminNotificationsScreen(),
      'gradient': PremiumDesignSystem.pinkGradient,
      'badge': '3',
    },
    {
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'route': 'settings',
      'screen': const AdminSettingsScreen(),
      'gradient': PremiumDesignSystem.blueGradient,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.currentRoute;

    // Main animations
    _mainController = AnimationController(
      duration: PremiumDesignSystem.animationSlow,
      vsync: this,
    );
    _headerController = AnimationController(
      duration: PremiumDesignSystem.animationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: PremiumDesignSystem.animationCurve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: PremiumDesignSystem.animationCurve,
      ),
    );

    // Item animations
    _itemControllers = List.generate(
      _menuItems.length,
      (index) => AnimationController(
        duration: PremiumDesignSystem.animationNormal,
        vsync: this,
      ),
    );

    _loadAdminInfo();
    _mainController.forward();
    _headerController.forward();

    // Stagger item animations
    _staggerItemAnimations();
  }

  void _staggerItemAnimations() {
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  Future<void> _loadAdminInfo() async {
    final name = await PreferencesService.getAdminName();
    final email = await PreferencesService.getAdminEmail();
    if (mounted) {
      setState(() {
        _adminName = name;
        _adminEmail = email;
      });
    }
  }

  String _getInitials() {
    if (_adminName.isEmpty) return 'AD';
    final words = _adminName.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.length == 1 && words[0].isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'AD';
  }

  @override
  void dispose() {
    _mainController.dispose();
    _headerController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateTo(String route, Widget screen) {
    setState(() => _selectedItem = route);
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      PremiumPageTransitions.sharedAxis(screen),
    );
  }

  void _showLogoutDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: PremiumDesignSystem.animationNormal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: _buildLogoutDialog(context),
          ),
        );
      },
    );
  }

  Widget _buildLogoutDialog(BuildContext dialogContext) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? PremiumDesignSystem.darkSurface : Colors.white,
          borderRadius: PremiumDesignSystem.borderRadiusXLarge,
          boxShadow: PremiumDesignSystem.elevatedShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: PremiumDesignSystem.errorGradient,
                  shape: BoxShape.circle,
                  boxShadow: PremiumDesignSystem.glowEffect(
                    PremiumDesignSystem.error,
                    intensity: 0.4,
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Confirm Logout',
                style: PremiumDesignSystem.h3.copyWith(
                  color: isDark
                      ? PremiumDesignSystem.darkTextPrimary
                      : PremiumDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Are you sure you want to logout from the admin panel?',
                textAlign: TextAlign.center,
                style: PremiumDesignSystem.body2.copyWith(
                  color: isDark
                      ? PremiumDesignSystem.darkTextSecondary
                      : PremiumDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(dialogContext),
                      isPrimary: false,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDialogButton(
                      text: 'Logout',
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushAndRemoveUntil(
                          context,
                          PremiumPageTransitions.fadeTransition(
                            const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      isPrimary: true,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Container(
      height: 48,
      decoration: isPrimary
          ? BoxDecoration(
              gradient: PremiumDesignSystem.errorGradient,
              borderRadius: PremiumDesignSystem.borderRadiusMedium,
              boxShadow: PremiumDesignSystem.softShadowMedium,
            )
          : BoxDecoration(
              color: isDark
                  ? PremiumDesignSystem.darkSurfaceVariant
                  : PremiumDesignSystem.surfaceVariant,
              borderRadius: PremiumDesignSystem.borderRadiusMedium,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: PremiumDesignSystem.borderRadiusMedium,
          child: Center(
            child: Text(
              text,
              style: PremiumDesignSystem.button.copyWith(
                color: isPrimary
                    ? Colors.white
                    : (isDark
                        ? PremiumDesignSystem.darkTextPrimary
                        : PremiumDesignSystem.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF8FAFC),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Premium Header
              _buildPremiumHeader(isDark),
              const SizedBox(height: 8),

              // Menu Items
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      children: [
                        // Menu items
                        ..._menuItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildPremiumMenuItem(
                            index: index,
                            icon: item['icon'],
                            title: item['title'],
                            route: item['route'],
                            screen: item['screen'],
                            gradient: item['gradient'],
                            badge: item['badge'],
                            isDark: isDark,
                          );
                        }),

                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Divider(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Logout Item
                        _buildLogoutItem(isDark),
                      ],
                    ),
                  ),
                ),
              ),

              // Premium Footer
              _buildPremiumFooter(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PremiumDesignSystem.primary.withOpacity(0.2),
                  PremiumDesignSystem.primaryDark.withOpacity(0.1),
                ],
              )
            : PremiumDesignSystem.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: PremiumDesignSystem.softShadowMedium,
      ),
      child: Column(
        children: [
          // Animated Avatar
          TweenAnimationBuilder(
            duration: PremiumDesignSystem.animationSlow,
            tween: Tween<double>(begin: 0, end: 1),
            curve: PremiumDesignSystem.animationCurveElastic,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: _buildAvatar(isDark),
              );
            },
          ),
          const SizedBox(height: 16),

          // Name with animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              _adminName,
              style: PremiumDesignSystem.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              _adminEmail,
              style: PremiumDesignSystem.caption.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // Role Badge
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: PremiumDesignSystem.borderRadiusXLarge,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: PremiumDesignSystem.glowEffect(
                  Colors.white,
                  intensity: 0.1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Administrator',
                    style: PremiumDesignSystem.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    PremiumDesignSystem.primaryGradient.createShader(bounds),
                child: Text(
                  _getInitials(),
                  style: PremiumDesignSystem.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Online indicator
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: PremiumDesignSystem.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: PremiumDesignSystem.glowEffect(
                    PremiumDesignSystem.success,
                    intensity: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required String route,
    required Widget screen,
    required Gradient gradient,
    String? badge,
    required bool isDark,
  }) {
    final isSelected = _selectedItem == route;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _itemControllers[index],
          curve: PremiumDesignSystem.animationCurve,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.2, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _itemControllers[index],
            curve: PremiumDesignSystem.animationCurve,
          ),
        ),
        child: _PremiumDrawerItem(
          icon: icon,
          title: title,
          isSelected: isSelected,
          gradient: gradient,
          badge: badge,
          isDark: isDark,
          onTap: () => _navigateTo(route, screen),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(bool isDark) {
    return _PremiumDrawerItem(
      icon: Icons.logout_rounded,
      title: 'Logout',
      isSelected: false,
      gradient: PremiumDesignSystem.errorGradient,
      isDark: isDark,
      isLogout: true,
      onTap: _showLogoutDialog,
    );
  }

  Widget _buildPremiumFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: PremiumDesignSystem.primaryGradient,
              borderRadius: PremiumDesignSystem.borderRadiusSmall,
              boxShadow: PremiumDesignSystem.glowEffect(
                PremiumDesignSystem.primary,
                intensity: 0.3,
              ),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RecyConnect Admin',
                style: PremiumDesignSystem.caption.copyWith(
                  color: isDark
                      ? PremiumDesignSystem.darkTextPrimary
                      : PremiumDesignSystem.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: PremiumDesignSystem.caption.copyWith(
                  fontSize: 10,
                  color: isDark
                      ? PremiumDesignSystem.darkTextTertiary
                      : PremiumDesignSystem.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 🎯 PREMIUM DRAWER ITEM
// ═══════════════════════════════════════════════════════════

class _PremiumDrawerItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final Gradient gradient;
  final String? badge;
  final bool isDark;
  final bool isLogout;
  final VoidCallback onTap;

  const _PremiumDrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.gradient,
    this.badge,
    required this.isDark,
    this.isLogout = false,
    required this.onTap,
  });

  @override
  State<_PremiumDrawerItem> createState() => _PremiumDrawerItemState();
}

class _PremiumDrawerItemState extends State<_PremiumDrawerItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: PremiumDesignSystem.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: PremiumDesignSystem.animationNormal,
            curve: PremiumDesignSystem.animationCurve,
            transform: _isHovered || widget.isSelected
                ? (Matrix4.identity()..translate(4.0, 0.0, 0.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              gradient: widget.isSelected ? widget.gradient : null,
              color: widget.isSelected
                  ? null
                  : (_isHovered
                      ? (widget.isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03))
                      : null),
              borderRadius: PremiumDesignSystem.borderRadiusMedium,
              boxShadow: widget.isSelected
                  ? PremiumDesignSystem.glowEffect(
                      PremiumDesignSystem.primary,
                      intensity: 0.3,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: PremiumDesignSystem.borderRadiusMedium,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Icon container
                      AnimatedContainer(
                        duration: PremiumDesignSystem.animationNormal,
                        padding: EdgeInsets.all(widget.isSelected ? 10 : 8),
                        decoration: BoxDecoration(
                          gradient: widget.isSelected
                              ? LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                )
                              : null,
                          color: widget.isSelected
                              ? null
                              : (widget.isLogout
                                  ? PremiumDesignSystem.error.withOpacity(0.1)
                                  : PremiumDesignSystem.primary
                                      .withOpacity(0.1)),
                          borderRadius: PremiumDesignSystem.borderRadiusSmall,
                        ),
                        child: Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isSelected
                              ? Colors.white
                              : (widget.isLogout
                                  ? PremiumDesignSystem.error
                                  : PremiumDesignSystem.primary),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title
                      Expanded(
                        child: Text(
                          widget.title,
                          style: PremiumDesignSystem.body2.copyWith(
                            fontWeight: widget.isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? Colors.white
                                : (widget.isLogout
                                    ? PremiumDesignSystem.error
                                    : (widget.isDark
                                        ? PremiumDesignSystem.darkTextPrimary
                                        : PremiumDesignSystem.textPrimary)),
                          ),
                        ),
                      ),

                      // Badge or arrow
                      if (widget.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: widget.isSelected
                                ? null
                                : PremiumDesignSystem.errorGradient,
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.3)
                                : null,
                            borderRadius:
                                PremiumDesignSystem.borderRadiusSmall,
                          ),
                          child: Text(
                            widget.badge!,
                            style: PremiumDesignSystem.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (widget.isSelected)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
