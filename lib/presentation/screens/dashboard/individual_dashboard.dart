import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/static_data.dart';
import '../../widgets/curved/curved_bottom_nav.dart';
import '../../widgets/recycle_loader.dart';
import '../individual/create_listing_screen.dart';
import '../individual/browse_marketplace_screen.dart';
import '../individual/my_listings_screen.dart';
import '../individual/my_orders_screen.dart';
import '../individual/seller_orders_screen.dart';
import '../individual/transactions_screen.dart';
import '../profile/profile_screen.dart';


class IndividualDashboard extends StatefulWidget {
  const IndividualDashboard({Key? key}) : super(key: key);

  @override
  State<IndividualDashboard> createState() => _IndividualDashboardState();
}

class _IndividualDashboardState extends State<IndividualDashboard> {
  final ListingService _listingService = ListingService();
  final OrderService _orderService = OrderService();
  
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Map<String, dynamic>? _stats;
  String _location = 'Loading...';
  bool _isLoading = true;
  List<Listing> _recentListings = [];
  List<Order> _recentOrders = [];

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
      final authService = Provider.of<AuthService>(context, listen: false);
      final profile = await authService.fetchProfile();

      String location = 'Unknown Location';
      if (profile['success'] == true) {
        final userData = profile['data']['data'];
        final city = userData['city'];
        final area = userData['area'] ?? userData['address'];
        if (city != null && city.toString().isNotEmpty) {
          location = (area != null && area.toString().isNotEmpty && !area.toString().contains(city))
              ? '$area, $city'
              : city;
        } else if (area != null && area.toString().isNotEmpty) {
          location = area;
        } else if (userData['address'] != null && userData['address'].toString().isNotEmpty) {
          location = userData['address'];
        } else {
          location = 'Set Location';
        }
      }

      // Load stats, recent listings, and recent orders in parallel
      final results = await Future.wait([
        _listingService.getListingStats(),
        _orderService.getOrderStats(),
        _listingService.getListings(limit: 3),
        _orderService.getOrders(limit: 3),
      ]);

      if (!mounted) return;
      setState(() {
        _location = location;
        _stats = {
          'listings': results[0],
          'orders': results[1],
        };
        _recentListings = (results[2] as Map<String, dynamic>)['listings'] as List<Listing>? ?? [];
        _recentOrders = (results[3] as Map<String, dynamic>)['orders'] as List<Order>? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
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
          const BrowseMarketplaceScreen(),
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
          child: _isLoading
              ? const RecycleLoadingScreen(message: 'Loading your dashboard...')
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationHeader(),
                      const SizedBox(height: 24),
                      _buildBrandingTitle(),
                      const SizedBox(height: 24),
                      _buildActionCards(),
                      const SizedBox(height: 32),
                      _buildRecentActivity(),
                      const SizedBox(height: 24),
                      _buildNotifications(),
                      const SizedBox(height: 80), // Extra space for bottom nav
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              _location,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF4CAF50),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Eco-friendly Marketplace',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A)).withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          'Sell Your\nRecyclables',
          'List items for sale',
          Icons.add_circle_outline,
          const Color(0xFF4CAF50),
          () => _pageController.animateToPage(2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut),
        ),
        _buildActionCard(
          'Find Materials',
          'Browse local listings',
          Icons.search,
          const Color(0xFF4CAF50),
          () => _pageController.animateToPage(1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut),
        ),
        _buildActionCard(
          'My Active\nListings',
          'Manage your items',
          Icons.local_offer_outlined,
          const Color(0xFF4CAF50),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyListingsScreen()),
          ),
        ),
        _buildActionCard(
          'My Purchases',
          'View order history',
          Icons.shopping_bag_outlined,
          const Color(0xFF4CAF50),
          () => _pageController.animateToPage(3,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut),
        ),
        _buildActionCard(
          'Manage Sales',
          'Track incoming orders',
          Icons.point_of_sale_outlined,
          const Color(0xFF2196F3),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SellerOrdersScreen()),
          ),
        ),
        _buildActionCard(
          'My Earnings',
          'View sales report',
          Icons.monetization_on_outlined,
          const Color(0xFFFFA726),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransactionsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
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
            Icon(icon, size: 32, color: iconColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildRecentActivity() {
    // Build unified activity list from real listings + orders
    final List<Map<String, dynamic>> activities = [];

    for (final listing in _recentListings) {
      activities.add({
        'title': 'Listed: ${listing.displayTitle}',
        'subtitle': listing.statusDisplay,
        'time': _timeAgo(listing.createdAt),
        'icon': Icons.add_circle_outline,
        'iconBg': const Color(0xFF4CAF50),
        'date': listing.createdAt,
      });
    }

    for (final order in _recentOrders) {
      activities.add({
        'title': 'Order: ${order.weight} kg of ${order.materialTypeDisplay}',
        'subtitle': order.statusDisplay,
        'time': _timeAgo(order.createdAt),
        'icon': Icons.shopping_cart_outlined,
        'iconBg': const Color(0xFF2196F3),
        'date': order.createdAt,
      });
    }

    // Sort by most recent
    activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final displayActivities = activities.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (displayActivities.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 40,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text(
                    'No recent activity',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...displayActivities.map((activity) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (activity['iconBg'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: activity['iconBg'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      activity['time'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildNotifications() {
    // Build real alerts from live data
    final pendingListings = _recentListings.where((l) => l.status == 'PENDING').toList();
    final pendingOrders = _recentOrders.where((o) => o.status == 'PENDING').toList();
    final completedOrders = _recentOrders.where((o) => o.status == 'COMPLETED').toList();

    final List<Map<String, dynamic>> alerts = [];

    for (final listing in pendingListings) {
      alerts.add({
        'title': 'Listing awaiting buyer',
        'subtitle': '${listing.displayTitle} — ${listing.pickupAddress}',
        'icon': Icons.local_offer_outlined,
        'color': const Color(0xFFFFA726),
      });
    }

    for (final order in pendingOrders) {
      alerts.add({
        'title': 'Order pending pickup',
        'subtitle': '${order.weight} kg of ${order.materialTypeDisplay} — ${order.paymentMethodDisplay}',
        'icon': Icons.pending_actions_outlined,
        'color': const Color(0xFF2196F3),
      });
    }

    for (final order in completedOrders) {
      alerts.add({
        'title': 'Order completed!',
        'subtitle': '${order.weight} kg of ${order.materialTypeDisplay} — ${_timeAgo(order.updatedAt)}',
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF4CAF50),
      });
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (alert['color'] as Color).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (alert['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      alert['icon'] as IconData,
                      color: alert['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
