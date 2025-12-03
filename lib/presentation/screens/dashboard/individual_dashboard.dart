import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/static_data.dart';
import '../../../core/theme/app_theme.dart';
import '../individual/create_listing_screen.dart';
import '../individual/browse_marketplace_screen.dart';
import '../individual/my_listings_screen.dart';
import '../individual/my_orders_screen.dart';
import '../individual/seller_orders_screen.dart';
import '../notifications/notifications_screen.dart';
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
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
              'New York, NY',
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
    return Text(
      'RecyConnect',
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Earnings feature coming soon!')),
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

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'Sold: 10 lbs Aluminum...',
        'subtitle': 'Transaction completed',
        'time': '2h ago',
        'icon': Icons.check_circle_outline,
        'iconBg': const Color(0xFF4CAF50),
      },
      {
        'title': 'New Listing: Cardboard...',
        'subtitle': 'Visible to local buyers',
        'time': '1d ago',
        'icon': Icons.add_circle_outline,
        'iconBg': const Color(0xFF4CAF50),
      },
      {
        'title': 'Purchased: Glass Bottles',
        'subtitle': 'Order awaiting pickup',
        'time': '3d ago',
        'icon': Icons.shopping_cart_outlined,
        'iconBg': const Color(0xFF4CAF50),
      },
    ];

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
                color: Colors.white,
              ),
            ),
            Container(
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
          ],
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => Container(
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
    final notifications = [
      {
        'title': 'Message from...',
        'subtitle': "'Is this still available?'",
        'time': '5m ago',
        'icon': Icons.message_outlined,
      },
      {
        'title': 'Your listing is about to...',
        'subtitle': "'Plastic Bottles' expires in 2 days",
        'time': '1h ago',
        'icon': Icons.warning_amber_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...notifications.map((notif) => Container(
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
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notif['icon'] as IconData,
                      color: const Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notif['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    notif['time'] as String,
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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70, // Increased height for center button
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.storefront_outlined, Icons.storefront, 'Market', 1),
              _buildCenterSellButton(),
              _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Orders', 3),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterSellButton() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = 2);
        _pageController.jumpToPage(2);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isSelected ? Border.all(color: Theme.of(context).colorScheme.surface, width: 2) : null,
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.jumpToPage(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF4CAF50) : Theme.of(context).iconTheme.color?.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF4CAF50) : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
