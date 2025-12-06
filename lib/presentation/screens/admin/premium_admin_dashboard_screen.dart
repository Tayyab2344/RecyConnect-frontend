import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/premium_design_system.dart';
import '../../../core/navigation/premium_transitions.dart';
import '../../widgets/admin/premium_admin_drawer.dart';
import '../../widgets/premium/premium_components.dart';
import 'admin_activities_screen.dart';

class PremiumAdminDashboardScreen extends StatefulWidget {
  const PremiumAdminDashboardScreen({super.key});

  @override
  State<PremiumAdminDashboardScreen> createState() =>
      _PremiumAdminDashboardScreenState();
}

class _PremiumAdminDashboardScreenState
    extends State<PremiumAdminDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: PremiumDesignSystem.animationSlow,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: PremiumDesignSystem.animationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: PremiumDesignSystem.animationCurve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: PremiumDesignSystem.animationCurve,
      ),
    );

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: isDark
          ? PremiumDesignSystem.darkBackground
          : PremiumDesignSystem.background,
      drawer: const PremiumAdminDrawer(currentRoute: 'dashboard'),
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          _buildPremiumAppBar(isDark, isMobile),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingState(isMobile)
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Header
                            _buildWelcomeHeader(isDark, isMobile),
                            SizedBox(
                                height: isMobile
                                    ? PremiumDesignSystem.spacing24
                                    : PremiumDesignSystem.spacing32),

                            // Stats Cards
                            _buildStatsSection(isMobile, isTablet, isDark),
                            const SizedBox(height: PremiumDesignSystem.spacing32),

                            // Charts Section
                            _buildChartsSection(isMobile, isDark),
                            const SizedBox(height: PremiumDesignSystem.spacing32),

                            // Quick Actions
                            _buildQuickActionsSection(isMobile, isTablet, isDark),
                            const SizedBox(height: PremiumDesignSystem.spacing32),

                            // Recent Activity
                            _buildRecentActivitySection(isMobile, isDark),
                            const SizedBox(height: PremiumDesignSystem.spacing24),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar(bool isDark, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 120 : 140,
      floating: false,
      pinned: true,
      backgroundColor:
          isDark ? PremiumDesignSystem.darkSurface : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PremiumDesignSystem.darkSurface,
                      PremiumDesignSystem.darkSurfaceVariant,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      PremiumDesignSystem.surface,
                    ],
                  ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(PremiumDesignSystem.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: PremiumDesignSystem.h2.copyWith(
                      color: isDark
                          ? PremiumDesignSystem.darkTextPrimary
                          : PremiumDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PremiumDesignSystem.success,
                          boxShadow: PremiumDesignSystem.glowEffect(
                            PremiumDesignSystem.success,
                            intensity: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'All systems operational',
                        style: PremiumDesignSystem.caption.copyWith(
                          color: isDark
                              ? PremiumDesignSystem.darkTextSecondary
                              : PremiumDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Search button
        _buildAppBarIconButton(
          icon: Icons.search_rounded,
          onPressed: () {},
          isDark: isDark,
        ),
        // Notification button with badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildAppBarIconButton(
              icon: Icons.notifications_outlined,
              onPressed: () {},
              isDark: isDark,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: PremiumDesignSystem.errorGradient,
                  shape: BoxShape.circle,
                  boxShadow: PremiumDesignSystem.glowEffect(
                    PremiumDesignSystem.error,
                    intensity: 0.5,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    '3',
                    style: PremiumDesignSystem.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDark
              ? PremiumDesignSystem.darkTextPrimary
              : PremiumDesignSystem.textPrimary,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          PremiumShimmer(
            width: double.infinity,
            height: 80,
            borderRadius: PremiumDesignSystem.borderRadiusLarge,
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: List.generate(
              4,
              (index) => PremiumShimmer(
                width: double.infinity,
                height: 120,
                borderRadius: PremiumDesignSystem.borderRadiusXLarge,
              ),
            ),
          ),
          const SizedBox(height: 24),
          PremiumShimmer(
            width: double.infinity,
            height: 300,
            borderRadius: PremiumDesignSystem.borderRadiusXLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark, bool isMobile) {
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      child: Row(
        children: [
          // Animated Icon
          TweenAnimationBuilder(
            duration: PremiumDesignSystem.animationSlow,
            tween: Tween<double>(begin: 0, end: 1),
            curve: PremiumDesignSystem.animationCurveElastic,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: PremiumDesignSystem.primaryGradient,
                    borderRadius: PremiumDesignSystem.borderRadiusLarge,
                    boxShadow: PremiumDesignSystem.glowEffect(
                      PremiumDesignSystem.primary,
                      intensity: 0.4,
                    ),
                  ),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: (isMobile
                          ? PremiumDesignSystem.h3
                          : PremiumDesignSystem.h2)
                      .copyWith(
                    color: isDark
                        ? PremiumDesignSystem.darkTextPrimary
                        : PremiumDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's what's happening with RecyConnect today",
                  style: PremiumDesignSystem.body2.copyWith(
                    color: isDark
                        ? PremiumDesignSystem.darkTextSecondary
                        : PremiumDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile, bool isTablet, bool isDark) {
    final stats = [
      {
        'icon': Icons.people_rounded,
        'title': 'Total Users',
        'value': '1,234',
        'trend': '+12%',
        'isPositive': true,
        'gradient': PremiumDesignSystem.blueGradient,
      },
      {
        'icon': Icons.local_shipping_rounded,
        'title': 'Collectors',
        'value': '89',
        'trend': '+8%',
        'isPositive': true,
        'gradient': PremiumDesignSystem.orangeGradient,
      },
      {
        'icon': Icons.shopping_bag_rounded,
        'title': 'Orders',
        'value': '567',
        'trend': '+23%',
        'isPositive': true,
        'gradient': PremiumDesignSystem.purpleGradient,
      },
      {
        'icon': Icons.attach_money_rounded,
        'title': 'Revenue',
        'value': '\$12.5K',
        'trend': '+15%',
        'isPositive': true,
        'gradient': PremiumDesignSystem.successGradient,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : (isTablet ? 2 : 4),
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
        childAspectRatio: isMobile ? 1.0 : (isTablet ? 1.2 : 1.15),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return PremiumStatCard(
          icon: stat['icon'] as IconData,
          title: stat['title'] as String,
          value: stat['value'] as String,
          trend: stat['trend'] as String?,
          isPositive: stat['isPositive'] as bool?,
          gradient: stat['gradient'] as Gradient,
        );
      },
    );
  }

  Widget _buildChartsSection(bool isMobile, bool isDark) {
    if (isMobile) {
      return Column(
        children: [
          _buildChartCard(
            title: 'Waste Collection',
            subtitle: 'Last 7 days',
            child: _buildBarChart(isMobile, isDark),
            isDark: isDark,
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            title: 'Revenue Trend',
            subtitle: 'Monthly overview',
            child: _buildLineChart(isMobile, isDark),
            isDark: isDark,
            isMobile: isMobile,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildChartCard(
            title: 'Waste Collection',
            subtitle: 'Last 7 days',
            child: _buildBarChart(isMobile, isDark),
            isDark: isDark,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildChartCard(
            title: 'Revenue Trend',
            subtitle: 'Monthly overview',
            child: _buildLineChart(isMobile, isDark),
            isDark: isDark,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
    required bool isDark,
    required bool isMobile,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isMobile
                            ? PremiumDesignSystem.subtitle1
                            : PremiumDesignSystem.h4)
                        .copyWith(
                      color: isDark
                          ? PremiumDesignSystem.darkTextPrimary
                          : PremiumDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: PremiumDesignSystem.caption.copyWith(
                      color: isDark
                          ? PremiumDesignSystem.darkTextSecondary
                          : PremiumDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PremiumDesignSystem.primary.withOpacity(0.1),
                  borderRadius: PremiumDesignSystem.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: PremiumDesignSystem.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 180 : 220,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isMobile, bool isDark) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => PremiumDesignSystem.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} kg',
                PremiumDesignSystem.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[value.toInt()],
                    style: PremiumDesignSystem.caption.copyWith(
                      color: isDark
                          ? PremiumDesignSystem.darkTextTertiary
                          : PremiumDesignSystem.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 65, isMobile),
          _buildBarGroup(1, 80, isMobile),
          _buildBarGroup(2, 45, isMobile),
          _buildBarGroup(3, 90, isMobile),
          _buildBarGroup(4, 70, isMobile),
          _buildBarGroup(5, 55, isMobile),
          _buildBarGroup(6, 85, isMobile),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isMobile) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: PremiumDesignSystem.primaryGradientVertical,
          width: isMobile ? 16 : 20,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(bool isMobile, bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: PremiumDesignSystem.caption.copyWith(
                        color: isDark
                            ? PremiumDesignSystem.darkTextTertiary
                            : PremiumDesignSystem.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => PremiumDesignSystem.accentBlue,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toInt()}K',
                  PremiumDesignSystem.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 40),
              FlSpot(1, 55),
              FlSpot(2, 45),
              FlSpot(3, 70),
              FlSpot(4, 60),
              FlSpot(5, 85),
            ],
            isCurved: true,
            gradient: PremiumDesignSystem.blueGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: PremiumDesignSystem.accentBlue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  PremiumDesignSystem.accentBlue.withOpacity(0.3),
                  PremiumDesignSystem.accentBlue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(bool isMobile, bool isTablet, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: (isMobile
                      ? PremiumDesignSystem.h4
                      : PremiumDesignSystem.h3)
                  .copyWith(
                color: isDark
                    ? PremiumDesignSystem.darkTextPrimary
                    : PremiumDesignSystem.textPrimary,
              ),
            ),
            AnimatedBadge(
              text: 'Fast Access',
              icon: Icons.bolt_rounded,
              gradient: PremiumDesignSystem.primaryGradient,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.2 : 1.3,
          children: [
            _buildQuickActionCard(
              icon: Icons.person_add_rounded,
              title: 'Add User',
              gradient: PremiumDesignSystem.blueGradient,
              onTap: () {},
              isDark: isDark,
            ),
            _buildQuickActionCard(
              icon: Icons.add_shopping_cart_rounded,
              title: 'New Order',
              gradient: PremiumDesignSystem.orangeGradient,
              onTap: () {},
              isDark: isDark,
            ),
            _buildQuickActionCard(
              icon: Icons.analytics_rounded,
              title: 'View Reports',
              gradient: PremiumDesignSystem.successGradient,
              onTap: () {},
              isDark: isDark,
            ),
            _buildQuickActionCard(
              icon: Icons.settings_rounded,
              title: 'Settings',
              gradient: PremiumDesignSystem.purpleGradient,
              onTap: () {},
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: PremiumDesignSystem.borderRadiusMedium,
              boxShadow: PremiumDesignSystem.softShadowMedium,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: PremiumDesignSystem.subtitle2.copyWith(
              color: isDark
                  ? PremiumDesignSystem.darkTextPrimary
                  : PremiumDesignSystem.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(bool isMobile, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: PremiumDesignSystem.primaryGradient,
                      borderRadius: PremiumDesignSystem.borderRadiusMedium,
                      boxShadow: PremiumDesignSystem.glowEffect(
                        PremiumDesignSystem.primary,
                        intensity: 0.3,
                      ),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Activities',
                    style: (isMobile
                            ? PremiumDesignSystem.subtitle1
                            : PremiumDesignSystem.h4)
                        .copyWith(
                      color: isDark
                          ? PremiumDesignSystem.darkTextPrimary
                          : PremiumDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
              PremiumButton(
                text: 'View All',
                onPressed: () {
                  Navigator.push(
                    context,
                    PremiumPageTransitions.slideFromRight(
                      const AdminActivitiesScreen(),
                    ),
                  );
                },
                gradient: PremiumDesignSystem.primaryGradient,
                height: 36,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityItem(
            icon: Icons.person_add_rounded,
            title: 'New user registered',
            subtitle: 'John Doe joined the platform',
            time: '5 min ago',
            gradient: PremiumDesignSystem.blueGradient,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildActivityItem(
            icon: Icons.shopping_bag_rounded,
            title: 'New order placed',
            subtitle: 'Order #1234 - Plastic waste collection',
            time: '15 min ago',
            gradient: PremiumDesignSystem.orangeGradient,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildActivityItem(
            icon: Icons.trending_up_rounded,
            title: 'Price updated',
            subtitle: 'Plastic price updated to 110 PKR/kg',
            time: '1 hour ago',
            gradient: PremiumDesignSystem.purpleGradient,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildActivityItem(
            icon: Icons.star_rounded,
            title: 'New 5-star rating',
            subtitle: 'Ahmed Khan received excellent review',
            time: '2 hours ago',
            gradient: PremiumDesignSystem.warningGradient,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Gradient gradient,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: PremiumDesignSystem.borderRadiusMedium,
              boxShadow: PremiumDesignSystem.softShadowSmall,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PremiumDesignSystem.subtitle2.copyWith(
                    color: isDark
                        ? PremiumDesignSystem.darkTextPrimary
                        : PremiumDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: PremiumDesignSystem.caption.copyWith(
                    color: isDark
                        ? PremiumDesignSystem.darkTextSecondary
                        : PremiumDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: PremiumDesignSystem.caption.copyWith(
              color: isDark
                  ? PremiumDesignSystem.darkTextTertiary
                  : PremiumDesignSystem.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.1),
    );
  }
}
