import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/curved/curved_bottom_nav.dart';

import '../individual/create_listing_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../individual/my_listings_screen.dart';
import '../individual/my_orders_screen.dart';
import '../individual/seller_orders_screen.dart';
import '../profile/profile_screen.dart';
import '../warehouse/inventory_list_screen.dart';
import '../warehouse/financial_dashboard_screen.dart';
import '../warehouse/analytics_dashboard_screen.dart';
import '../warehouse/reports_screen.dart';
import '../warehouse/reports_screen.dart';
import '../warehouse/collector_performance_screen.dart';
import '../warehouse/collector_management_screen.dart';

class WarehouseDashboard extends StatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  State<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends State<WarehouseDashboard> {
  final ListingService _listingService = ListingService();
  final OrderService _orderService = OrderService();
  
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Real data from APIs
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);
    try {
      final listingStats = await _listingService.getListingStats();
      final orderStats = await _orderService.getOrderStats();
      
      setState(() {
        _stats = {
          'listings': listingStats,
          'orders': orderStats,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          _buildHomeTab(),
          const MarketplaceScreen(),
          const CreateListingScreen(),
          const MyOrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeTab() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        gradient: Theme.of(context).brightness == Brightness.dark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B3A2F), Color(0xFF0F1F19)],
              )
            : null,
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBrandingTitle(),
                const SizedBox(height: 24),
                _buildStatsOverview(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildMarketRates(),
                const SizedBox(height: 24),
                _buildPendingOrders(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.warehouse_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Consumer<AuthService>(
              builder: (context, authService, _) {
                return Text(
                  authService.currentUser?['businessName'] ?? 'Warehouse Operations',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              4,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RecyConnect',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.primaryGreen,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Warehouse Management',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textDark).withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    // Mock data for now, replacing with real data where possible
    final stats = [
      {
        'title': 'Total Revenue',
        'value': 'Rs 125.5K',
        'change': '+12%',
        'icon': Icons.attach_money,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Net Profit',
        'value': 'Rs 45.2K',
        'change': '+8%',
        'icon': Icons.trending_up,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Active Orders',
        'value': '28',
        'change': '+5',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFFFFA726),
      },
      {
        'title': 'Inventory Value',
        'value': 'Rs 85K',
        'change': '-3%',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF9C27B0),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                  Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat['change'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stat['color'] as Color,
                      ),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _buildQuickActionCard('Sell Items', Icons.add_circle_outline, const Color(0xFF4CAF50), () {
              _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }),
            _buildQuickActionCard('Browse', Icons.search, const Color(0xFF2196F3), () {
              _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }),
            _buildQuickActionCard('Inventory', Icons.inventory_outlined, const Color(0xFFFFA726), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryListScreen()));
            }),
            _buildQuickActionCard('Finance', Icons.account_balance_wallet_outlined, const Color(0xFF9C27B0), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialDashboardScreen()));
            }),
            _buildQuickActionCard('Analytics', Icons.analytics_outlined, const Color(0xFFE91E63), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsDashboardScreen()));
            }),
            _buildQuickActionCard('Reports', Icons.description_outlined, const Color(0xFF607D8B), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
            }),
            _buildQuickActionCard('Collectors', Icons.people_alt_outlined, Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CollectorManagementScreen()));
            }),
            _buildQuickActionCard('Analytics', Icons.analytics_outlined, const Color(0xFF00BCD4), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsDashboardScreen()));
            }),
            _buildQuickActionCard('Reports', Icons.description_outlined, const Color(0xFFE91E63), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketRates() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Rates (Last 7 Days)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Trending ↗',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 40,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 65),
                      const FlSpot(1, 70),
                      const FlSpot(2, 68),
                      const FlSpot(3, 75),
                      const FlSpot(4, 72),
                      const FlSpot(5, 80),
                      const FlSpot(6, 85),
                    ],
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
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

  Widget _buildPendingOrders() {
    final orders = [
      {
        'id': '#ORD-2401',
        'material': 'Aluminum Scrap',
        'quantity': '50 tons',
        'status': 'Awaiting Pickup',
        'supplier': 'Green Warehouse Co.',
        'date': '2 days ago',
      },
      {
        'id': '#ORD-2402',
        'material': 'Plastic Mix',
        'quantity': '30 tons',
        'status': 'In Transit',
        'supplier': 'EcoSupply Ltd.',
        'date': '1 day ago',
      },
      {
        'id': '#ORD-2403',
        'material': 'Glass Bottles',
        'quantity': '20 tons',
        'status': 'Processing',
        'supplier': 'RecyclePro Inc.',
        'date': '3 hours ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: Color(0xFF4CAF50))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...orders.map((order) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['status'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFA726),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                order['material'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.scale, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    order['quantity'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.business, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order['supplier'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'New Order Received',
        'subtitle': 'Plastic (PET) - 50kg',
        'time': '2h ago',
        'icon': Icons.shopping_bag_outlined,
        'iconBg': const Color(0xFF4CAF50),
      },
      {
        'title': 'Low Stock Alert',
        'subtitle': 'Metal (Aluminum) below 100kg',
        'time': '5h ago',
        'icon': Icons.warning_amber_outlined,
        'iconBg': const Color(0xFFFF9800),
      },
      {
        'title': 'Payment Received',
        'subtitle': 'Order #WH-1234 - Rs 12,500',
        'time': '1d ago',
        'icon': Icons.payment,
        'iconBg': const Color(0xFF2196F3),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        ...activities.map((activity) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (activity['iconBg'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: activity['iconBg'] as Color,
                  size: 22,
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
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                activity['time'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return CurvedBottomNav(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        _pageController.jumpToPage(index);
      },
      items: const [
        CurvedBottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        CurvedBottomNavItem(
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          label: 'Market',
        ),
        CurvedBottomNavItem.simple(
          icon: Icons.add,
          label: 'Sell',
        ),
        CurvedBottomNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Orders',
        ),
        CurvedBottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ],
      floatingButton: CurvedNavFAB(
        icon: Icons.add,
        isSelected: _selectedIndex == 2,
        onTap: () {
          setState(() => _selectedIndex = 2);
          _pageController.jumpToPage(2);
        },
      ),
    );
  }
}
