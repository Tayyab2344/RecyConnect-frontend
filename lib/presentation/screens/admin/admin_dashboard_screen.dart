import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/admin_colors.dart';
import '../../../core/constants/modern_colors.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/admin/modern_widgets.dart';
import 'admin_activities_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildModernAppBar(theme, isMobile),
      drawer: const AdminDrawer(currentRoute: 'dashboard'),
      body: _isLoading
          ? _buildLoadingState()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Welcome Section
                    AnimatedWelcomeHeader(
                      title: 'Welcome back, Admin! ',
                      subtitle: "Here's what's happening with RecyConnect today",
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 24),

                    // Modern Stats Cards
                    _buildModernStatsCards(screenWidth, isMobile, isTablet),
                    const SizedBox(height: 24),

                    // Charts Section
                    _buildModernCharts(context, isMobile),
                    const SizedBox(height: 24),

                    // Quick Actions Section
                    _buildModernQuickActions(context, screenWidth, isMobile, isTablet),
                    const SizedBox(height: 24),

                    // Recent Activities
                    _buildModernRecentActivities(context, isMobile),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme, bool isMobile) {
    return AppBar(
      title: Text(
        'Admin Dashboard',
        style: TextStyle(
          color: theme.appBarTheme.foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 18 : 20,
        ),
      ),
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
      actions: [
        // Notification button with badge
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.appBarTheme.foregroundColor,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  gradient: ModernColors.redGradient,
                  shape: BoxShape.circle,
                ),
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
        if (!isMobile)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: const Text(
                'AD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primaryGreen,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ShimmerLoading(itemCount: 1, itemHeight: 100),
          const SizedBox(height: 20),
          ShimmerStatsGrid(count: 4, crossAxisCount: 2),
          const SizedBox(height: 20),
          ShimmerLoading(itemCount: 2, itemHeight: 250),
        ],
      ),
    );
  }

  Widget _buildModernStatsCards(double screenWidth, bool isMobile, bool isTablet) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);
    double childAspectRatio = isMobile ? 1.1 : (isTablet ? 1.4 : 1.4);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: childAspectRatio,
      children: [
        ModernStatCard(
          icon: Icons.people_rounded,
          title: 'Total Users',
          value: '1,234',
          trend: '+12%',
          isPositive: true,
          color: AdminColors.accentBlue,
        ),
        ModernStatCard(
          icon: Icons.local_shipping_rounded,
          title: 'Collectors',
          value: '89',
          trend: '+8%',
          isPositive: true,
          color: AdminColors.accentOrange,
        ),
        ModernStatCard(
          icon: Icons.shopping_bag_rounded,
          title: 'Orders',
          value: '567',
          trend: '+23%',
          isPositive: true,
          color: AdminColors.accentPurple,
        ),
        ModernStatCard(
          icon: Icons.attach_money_rounded,
          title: 'Revenue',
          value: '\$12.5K',
          trend: '+15%',
          isPositive: true,
          color: AdminColors.success,
        ),
      ],
    );
  }

  Widget _buildModernCharts(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildGlassChartCard(
            context: context,
            title: 'Waste Collection',
            subtitle: 'Last 7 days',
            isMobile: isMobile,
            child: _buildBarChart(isMobile),
          ),
          const SizedBox(height: 16),
          _buildGlassChartCard(
            context: context,
            title: 'Revenue Trend',
            subtitle: 'Monthly overview',
            isMobile: isMobile,
            child: _buildLineChart(isMobile),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildGlassChartCard(
            context: context,
            title: 'Waste Collection',
            subtitle: 'Last 7 days',
            isMobile: isMobile,
            child: _buildBarChart(isMobile),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassChartCard(
            context: context,
            title: 'Revenue Trend',
            subtitle: 'Monthly overview',
            isMobile: isMobile,
            child: _buildLineChart(isMobile),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassChartCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isMobile,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernColors.softShadowMedium,
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_horiz,
                  color: AdminColors.primaryGreen,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 180 : 200,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isMobile) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AdminColors.primaryGreenDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} kg',
                const TextStyle(
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
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: theme.textTheme.bodyMedium?.color,
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
          _buildAnimatedBarGroup(0, 65, isMobile),
          _buildAnimatedBarGroup(1, 80, isMobile),
          _buildAnimatedBarGroup(2, 45, isMobile),
          _buildAnimatedBarGroup(3, 90, isMobile),
          _buildAnimatedBarGroup(4, 70, isMobile),
          _buildAnimatedBarGroup(5, 55, isMobile),
          _buildAnimatedBarGroup(6, 85, isMobile),
        ],
      ),
    );
  }

  BarChartGroupData _buildAnimatedBarGroup(int x, double y, bool isMobile) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: isMobile ? 18 : 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  Widget _buildLineChart(bool isMobile) {
    final theme = Theme.of(context);
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
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
                        fontSize: isMobile ? 10 : 12,
                        color: theme.textTheme.bodyMedium?.color,
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
                  const TextStyle(
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
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
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
                  strokeColor: const Color(0xFF3B82F6),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.3),
                  const Color(0xFF3B82F6).withOpacity(0.0),
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

  Widget _buildModernQuickActions(
    BuildContext context,
    double screenWidth,
    bool isMobile,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 16,
                    color: AdminColors.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Fast Access',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.primaryGreen,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
            ModernQuickActionCard(
              icon: Icons.add_shopping_cart_rounded,
              title: 'New Order',
              color: AdminColors.accentOrange,
              onTap: () {},
            ),
            ModernQuickActionCard(
              icon: Icons.analytics_rounded,
              title: 'View Reports',
              color: AdminColors.success,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernRecentActivities(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernColors.softShadowMedium,
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: ModernColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminActivitiesScreen(),
                    ),
                  );
                },
                icon: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primaryGreen,
                  ),
                ),
                label: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AdminColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernActivityItem(
            icon: Icons.person_add_rounded,
            title: 'New user registered',
            subtitle: 'John Doe joined the platform',
            time: '5 min ago',
            color: AdminColors.accentBlue,
          ),
          Divider(height: 8, color: Colors.grey.withOpacity(0.1)),
          ModernActivityItem(
            icon: Icons.shopping_bag_rounded,
            title: 'New order placed',
            subtitle: 'Order #1234 - Plastic waste collection',
            time: '15 min ago',
            color: AdminColors.accentOrange,
          ),
          Divider(height: 8, color: Colors.grey.withOpacity(0.1)),
          ModernActivityItem(
            icon: Icons.trending_up_rounded,
            title: 'Price updated',
            subtitle: 'Plastic price updated to 110 PKR/kg',
            time: '1 hour ago',
            color: AdminColors.accentPurple,
          ),
          Divider(height: 8, color: Colors.grey.withOpacity(0.1)),
          ModernActivityItem(
            icon: Icons.star_rounded,
            title: 'New 5-star rating',
            subtitle: 'Ahmed Khan received excellent review',
            time: '2 hours ago',
            color: const Color(0xFFFBBF24),
          ),
        ],
      ),
    );
  }
}
