import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/admin_colors.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_activities_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _bgAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AdminDrawer(currentRoute: 'dashboard'),
      body: Stack(
        children: [
          // 1. Animated gradient background
          _buildBackground(isDark),

          // 2. Floating particles (dark mode only)
          if (isDark) _buildFloatingParticles(),

          // 3. Main content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState(isDark)
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      slivers: [
                       
                        SliverToBoxAdapter(
                          child: _buildCustomAppBar(isDark, isMobile),
                        ),

                       
                        SliverPadding(
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                             
                              _buildWelcomeHeader(isDark, isMobile),
                              const SizedBox(height: 24),

                             
                              _buildModernStatsCards(screenWidth, isMobile, isTablet, isDark),
                              const SizedBox(height: 24),

                             
                              _buildModernCharts(isMobile, isDark),
                              const SizedBox(height: 24),

                            
                              _buildModernQuickActions(screenWidth, isMobile, isTablet, isDark),
                              const SizedBox(height: 24),

                              // Recent Activities
                              _buildModernRecentActivities(isMobile, isDark),
                              const SizedBox(height: 20),
                            ]),
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

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AdminColors.getBackgroundGradient(isDark),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlesPainter(
            animationValue: _bgAnimController.value,
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(bool isDark, bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 10, isMobile ? 16 : 24, 0),
      child: Row(
        children: [
          // Menu button
          Builder(
            builder: (context) => _buildIconButton(
              icon: Icons.menu_rounded,
              isDark: isDark,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextPrimary(isDark),
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AdminColors.success,
                        boxShadow: isDark
                            ? AdminColors.getGlowShadow(AdminColors.success, intensity: 0.5)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'All systems operational',
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification button
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildIconButton(
                icon: Icons.notifications_outlined,
                isDark: isDark,
                onTap: () {},
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: AdminColors.redGradient,
                    shape: BoxShape.circle,
                    boxShadow: isDark
                        ? AdminColors.getGlowShadow(AdminColors.error, intensity: 0.5)
                        : null,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
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
              borderRadius: BorderRadius.circular(14),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: isDark
                    ? AdminColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AdminColors.neonCyan.withValues(alpha: 0.1 * _pulseAnimation.value),
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
              color: isDark ? AdminColors.neonCyan : AdminColors.primaryGreen,
              size: 22,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? AdminColors.neonCyan : AdminColors.primaryGreen,
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark, bool isMobile) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return _GlassCard(
          isDark: isDark,
          pulseValue: _pulseAnimation.value,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Row(
              children: [
                // Animated Icon
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? AdminColors.neonGradient
                              : AdminColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AdminColors.getGlowShadow(
                            isDark ? AdminColors.neonGreen : AdminColors.primaryGreen,
                            intensity: 0.4,
                          ),
                        ),
                        child: Icon(
                          Icons.waving_hand_rounded,
                          color: isDark ? AdminColors.darkBackground : Colors.white,
                          size: 28,
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
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Here's what's happening with RecyConnect today",
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminColors.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernStatsCards(double screenWidth, bool isMobile, bool isTablet, bool isDark) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);
    double childAspectRatio = isMobile ? 1.0 : (isTablet ? 1.2 : 1.15);

    final stats = [
      {'icon': Icons.people_rounded, 'title': 'Total Users', 'value': '1,234', 'trend': '+12%', 'color': AdminColors.accentBlue},
      {'icon': Icons.local_shipping_rounded, 'title': 'Collectors', 'value': '89', 'trend': '+8%', 'color': AdminColors.accentOrange},
      {'icon': Icons.shopping_bag_rounded, 'title': 'Orders', 'value': '567', 'trend': '+23%', 'color': AdminColors.accentPurple},
      {'icon': Icons.attach_money_rounded, 'title': 'Revenue', 'value': '\$12.5K', 'trend': '+15%', 'color': AdminColors.success},
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: childAspectRatio,
      children: stats.map((stat) {
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return _GlassCard(
              isDark: isDark,
              pulseValue: _pulseAnimation.value,
              glowColor: stat['color'] as Color,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (stat['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: (stat['color'] as Color).withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 22),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, size: 12, color: AdminColors.success),
                              const SizedBox(width: 4),
                              Text(
                                stat['trend'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AdminColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['value'] as String,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: AdminColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildModernCharts(bool isMobile, bool isDark) {
    if (isMobile) {
      return Column(
        children: [
          _buildChartCard('Waste Collection', 'Last 7 days', _buildBarChart(isMobile, isDark), isDark),
          const SizedBox(height: 16),
          _buildChartCard('Revenue Trend', 'Monthly overview', _buildLineChart(isMobile, isDark), isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildChartCard('Waste Collection', 'Last 7 days', _buildBarChart(isMobile, isDark), isDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildChartCard('Revenue Trend', 'Monthly overview', _buildLineChart(isMobile, isDark), isDark),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart, bool isDark) {
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AdminColors.neonCyan : AdminColors.primaryGreen).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: isDark ? AdminColors.neonCyan : AdminColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(height: 200, child: chart),
              ],
            ),
          ),
        );
      },
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
            getTooltipColor: (_) => isDark ? AdminColors.neonGreen : AdminColors.primaryGreen,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} kg',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    style: TextStyle(
                      fontSize: 10,
                      color: AdminColors.getTextSecondary(isDark),
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
          _buildBarGroup(0, 65, isMobile, isDark),
          _buildBarGroup(1, 80, isMobile, isDark),
          _buildBarGroup(2, 45, isMobile, isDark),
          _buildBarGroup(3, 90, isMobile, isDark),
          _buildBarGroup(4, 70, isMobile, isDark),
          _buildBarGroup(5, 55, isMobile, isDark),
          _buildBarGroup(6, 85, isMobile, isDark),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isMobile, bool isDark) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: isDark
                ? [AdminColors.neonGreen, AdminColors.neonCyan]
                : [AdminColors.primaryGreen, const Color(0xFF45A049)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: isMobile ? 18 : 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: AdminColors.getTextSecondary(isDark),
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
            getTooltipColor: (_) => AdminColors.accentBlue,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toInt()}K',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            gradient: LinearGradient(
              colors: isDark
                  ? [AdminColors.neonCyan, AdminColors.accentBlue]
                  : [AdminColors.accentBlue, const Color(0xFF1D4ED8)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: isDark ? AdminColors.neonCyan : AdminColors.accentBlue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (isDark ? AdminColors.neonCyan : AdminColors.accentBlue).withValues(alpha: 0.3),
                  (isDark ? AdminColors.neonCyan : AdminColors.accentBlue).withValues(alpha: 0.0),
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

  Widget _buildModernQuickActions(double screenWidth, bool isMobile, bool isTablet, bool isDark) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextPrimary(isDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isDark ? AdminColors.neonGradient : AdminColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14, color: isDark ? AdminColors.darkBackground : Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Fast Access',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AdminColors.darkBackground : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.1 : 1.2,
          children: [
            _buildQuickActionCard(Icons.add_shopping_cart_rounded, 'New Order', AdminColors.accentOrange, isDark),
            _buildQuickActionCard(Icons.analytics_rounded, 'View Reports', AdminColors.success, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, Color color, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {},
          child: _GlassCard(
            isDark: isDark,
            pulseValue: _pulseAnimation.value,
            glowColor: color,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: isDark ? Border.all(color: color.withValues(alpha: 0.3)) : null,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernRecentActivities(bool isMobile, bool isDark) {
    final activities = [
      {'icon': Icons.person_add_rounded, 'title': 'New user registered', 'subtitle': 'John Doe joined the platform', 'time': '5 min ago', 'color': AdminColors.accentBlue},
      {'icon': Icons.shopping_bag_rounded, 'title': 'New order placed', 'subtitle': 'Order #1234 - Plastic waste collection', 'time': '15 min ago', 'color': AdminColors.accentOrange},
      {'icon': Icons.trending_up_rounded, 'title': 'Price updated', 'subtitle': 'Plastic price updated to 110 PKR/kg', 'time': '1 hour ago', 'color': AdminColors.accentPurple},
      {'icon': Icons.star_rounded, 'title': 'New 5-star rating', 'subtitle': 'Ahmed Khan received excellent review', 'time': '2 hours ago', 'color': AdminColors.accentYellow},
    ];

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return _GlassCard(
          isDark: isDark,
          pulseValue: _pulseAnimation.value,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: isDark ? AdminColors.neonGradient : AdminColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.history,
                            color: isDark ? AdminColors.darkBackground : Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recent Activities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.getTextPrimary(isDark),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminActivitiesScreen()),
                        );
                      },
                      icon: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AdminColors.neonCyan : AdminColors.primaryGreen,
                        ),
                      ),
                      label: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: isDark ? AdminColors.neonCyan : AdminColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...activities.asMap().entries.map((entry) {
                  final activity = entry.value;
                  final isLast = entry.key == activities.length - 1;
                  return Column(
                    children: [
                      _buildActivityItem(activity, isDark),
                      if (!isLast)
                        Divider(
                          height: 16,
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: isDark
                  ? Border.all(color: (activity['color'] as Color).withValues(alpha: 0.3))
                  : null,
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: TextStyle(
              fontSize: 11,
              color: AdminColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUPPORTING WIDGETS
// ============================================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double pulseValue;
  final BorderRadius? borderRadius;
  final Color? glowColor;

  const _GlassCard({
    required this.child,
    required this.isDark,
    required this.pulseValue,
    this.borderRadius,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final glow = glowColor ?? (isDark ? AdminColors.neonCyan : AdminColors.primaryGreen);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: AdminColors.getCardGradient(isDark),
            border: Border.all(
              color: isDark
                  ? glow.withValues(alpha: 0.15 + 0.1 * pulseValue)
                  : Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: glow.withValues(alpha: 0.08 * pulseValue),
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

class _ParticlesPainter extends CustomPainter {
  final double animationValue;

  _ParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AdminColors.neonCyan.withValues(alpha: 0.3)
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
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
