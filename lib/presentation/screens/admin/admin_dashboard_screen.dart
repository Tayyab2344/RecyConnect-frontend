import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/admin_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AdminColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        backgroundColor: AdminColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.textWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AdminColors.textWhite),
            onPressed: () {},
          ),
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.account_circle, color: AdminColors.textWhite),
              onPressed: () {},
            ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: 'dashboard'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(isMobile),
            const SizedBox(height: 24),

            // Stats Cards - Responsive Grid
            _buildResponsiveStatsCards(screenWidth, isMobile, isTablet),
            const SizedBox(height: 24),

            // Charts - Responsive Layout
            _buildResponsiveCharts(isMobile),
            const SizedBox(height: 24),

            // Quick Actions Section
            _buildResponsiveQuickActions(screenWidth, isMobile, isTablet),
            const SizedBox(height: 24),

            // Recent Activities
            _buildRecentActivities(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminColors.primaryGreen, AdminColors.primaryGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin! 👋',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textWhite,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  'Here\'s what\'s happening with RecyConnect today',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.recycling,
                size: 40,
                color: AdminColors.textWhite,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatsCards(double screenWidth, bool isMobile, bool isTablet) {
    // Mobile: 2x2 grid, Tablet: 2x2 or 4x1, Desktop: 4x1
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);
    double childAspectRatio = isMobile ? 1.3 : (isTablet ? 1.5 : 1.4);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          icon: Icons.people,
          title: 'Total Users',
          value: '1,234',
          change: '+12%',
          isPositive: true,
          color: AdminColors.accentBlue,
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.local_shipping,
          title: 'Collectors',
          value: '89',
          change: '+8%',
          isPositive: true,
          color: AdminColors.accentOrange,
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.shopping_bag,
          title: 'Orders',
          value: '567',
          change: '+23%',
          isPositive: true,
          color: AdminColors.accentPurple,
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          title: 'Revenue',
          value: '\$12.5K',
          change: '+15%',
          isPositive: true,
          color: AdminColors.success,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isMobile ? 20 : 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AdminColors.success.withOpacity(0.1)
                      : AdminColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: isMobile ? 12 : 14,
                      color: isPositive ? AdminColors.success : AdminColors.error,
                    ),
                    SizedBox(width: isMobile ? 2 : 4),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? AdminColors.success : AdminColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              color: AdminColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCharts(bool isMobile) {
    if (isMobile) {
      // Stack charts vertically on mobile
      return Column(
        children: [
          _buildWasteCollectionChart(isMobile),
          const SizedBox(height: 16),
          _buildRevenueChart(isMobile),
        ],
      );
    } else {
      // Side by side on tablet/desktop
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: _buildWasteCollectionChart(isMobile),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildRevenueChart(isMobile),
          ),
        ],
      );
    }
  }

  Widget _buildWasteCollectionChart(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.1),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waste Collection',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last 7 days',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.more_vert, color: AdminColors.textLight, size: 20),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 180 : 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
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
                              color: AdminColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
            ),
          ),
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
          gradient: const LinearGradient(
            colors: [AdminColors.primaryGreen, AdminColors.primaryGreenDark],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: isMobile ? 16 : 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.1),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trend',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monthly overview',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.more_vert, color: AdminColors.textLight, size: 20),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 180 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AdminColors.border,
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
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 100,
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
                      colors: [AdminColors.accentBlue, AdminColors.accentPurple],
                    ),
                    barWidth: isMobile ? 2.5 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isMobile ? 3 : 4,
                          color: AdminColors.cardBackground,
                          strokeWidth: 2,
                          strokeColor: AdminColors.accentBlue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AdminColors.accentBlue.withOpacity(0.2),
                          AdminColors.accentBlue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildResponsiveQuickActions(double screenWidth, bool isMobile, bool isTablet) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.2 : 1.3,
          children: [
            _buildQuickActionCard(
              icon: Icons.person_add,
              title: 'Add User',
              color: AdminColors.accentBlue,
              onTap: () {},
              isMobile: isMobile,
            ),
            _buildQuickActionCard(
              icon: Icons.add_box,
              title: 'New Order',
              color: AdminColors.accentOrange,
              onTap: () {},
              isMobile: isMobile,
            ),
            _buildQuickActionCard(
              icon: Icons.local_shipping,
              title: 'Add Collector',
              color: AdminColors.accentPurple,
              onTap: () {},
              isMobile: isMobile,
            ),
            _buildQuickActionCard(
              icon: Icons.analytics,
              title: 'View Reports',
              color: AdminColors.success,
              onTap: () {},
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: AdminColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isMobile ? 24 : 28),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.1),
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
                'Recent Activities',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.person_add,
            title: 'New user registered',
            subtitle: 'John Doe joined the platform',
            time: '5 min ago',
            color: AdminColors.accentBlue,
            isMobile: isMobile,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.shopping_bag,
            title: 'New order placed',
            subtitle: 'Order #1234 - Plastic waste collection',
            time: '15 min ago',
            color: AdminColors.accentOrange,
            isMobile: isMobile,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.check_circle,
            title: 'Collection completed',
            subtitle: 'Collector completed 5 pickups today',
            time: '1 hour ago',
            color: AdminColors.success,
            isMobile: isMobile,
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
    required Color color,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: isMobile ? 20 : 24),
        ),
        SizedBox(width: isMobile ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: AdminColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Text(
          time,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: AdminColors.textLight,
          ),
        ),
      ],
    );
  }
}
