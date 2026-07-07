import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/report_service.dart';
import '../../../core/services/app_service.dart';
import '../../../core/services/rewards_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/curved/curved_bottom_nav.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/eco_assist_sheet.dart';

import '../individual/create_listing_screen.dart';
import '../individual/browse_marketplace_screen.dart';
import '../individual/my_listings_screen.dart';
import '../individual/my_orders_screen.dart';
import '../individual/seller_orders_screen.dart';
import '../individual/transactions_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/rewards_screen.dart';
import '../messages/messages_screen.dart';
import '../../../core/services/chat_service.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  final ListingService _listingService = ListingService();
  final OrderService _orderService = OrderService();
  final ReportService _reportService = ReportService();
  final AppService _appService = AppService();

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Map<String, dynamic>? _stats;
  List<dynamic>? _recentActivity;
  List<dynamic>? _marketRates;
  bool _isLoading = true;
  int _unreadChatCount = 0;

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
      final rewardsService = Provider.of<RewardsService>(context, listen: false);
      final results = await Future.wait([
        _listingService.getListingStats(),
        _orderService.getOrderStats(),
        _reportService.getActivity(limit: 5),
        _appService.getPublicRates(),
        rewardsService.fetchRewardsStatus(),
      ]);

      setState(() {
        _stats = {
          'listings': results[0],
          'orders': results[1],
        };
        _recentActivity = results[2] as List<dynamic>?;
        _marketRates = results[3] as List<dynamic>?;
        _isLoading = false;
      });
      // Fetch chat unread count in background
      ChatService().getTotalUnreadCount().then((count) {
        if (mounted) setState(() => _unreadChatCount = count);
      });
    } catch (e) {
      if (kDebugMode) print('Error loading company dashboard stats: $e');
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
          // Map PageView index back to bottom nav index
          int navIndex = index;
          if (navIndex >= 2) {
            navIndex = navIndex + 1;
          }
          setState(() => _selectedIndex = navIndex);
        },
        children: [
          _buildHomeTab(),
          const BrowseMarketplaceScreen(),
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
                colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
              )
            : null,
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardStats,
          child: _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      SkeletonLoader.card(),
                      const SizedBox(height: 16),
                      SkeletonLoader.card(),
                      const SizedBox(height: 16),
                      SkeletonLoader.card(),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildBrandingTitle(),
                      const SizedBox(height: 20),
                      _buildGamificationCard(Theme.of(context).brightness == Brightness.dark),
                      const SizedBox(height: 24),
                      _buildStatsOverview(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildMarketRates(),
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
            Icon(Icons.business, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Consumer<AuthService>(
              builder: (context, authService, _) {
                final businessName = authService.currentUser?['companyName']
                    ?? authService.currentUser?['businessName']
                    ?? 'Company Operations';
                return Text(
                  businessName,
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
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagesScreen()),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: Theme.of(context).iconTheme.color, size: 20),
                  ),
                  if (_unreadChatCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          _unreadChatCount > 9 ? '9+' : '$_unreadChatCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  3,
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
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 20),
              ),
            ),
          ],
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
          'B2B Supply Chain',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textDark).withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    final listings = _stats?['listings'] as Map?;
    final orders = _stats?['orders'] as Map?;

    final stats = [
      {
        'title': 'Total Listings',
        'value': '${listings?['totalListings'] ?? 0}',
        'change': '+${listings?['activeListings'] ?? 0} active',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Total Orders',
        'value': '${orders?['totalOrders'] ?? 0}',
        'change': '${orders?['confirmedCount'] ?? 0} confirmed',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Active Orders',
        'value': '${orders?['pendingCount'] ?? 0}',
        'change': 'needs action',
        'icon': Icons.assignment_turned_in,
        'color': const Color(0xFFFFA726),
      },
      {
        'title': 'Total Weight',
        'value': '${listings?['totalWeight'] ?? 0}kg',
        'change': 'all time',
        'icon': Icons.scale,
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
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                      color: (stat['color'] as Color).withValues(alpha: 0.1),
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
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListingScreen()));
            }),
            _buildQuickActionCard('Browse', Icons.search, const Color(0xFF2196F3), () {
              _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }),
            _buildQuickActionCard('My Listings', Icons.local_offer_outlined, const Color(0xFFFFA726), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyListingsScreen()));
            }),
            _buildQuickActionCard('My Purchases', Icons.shopping_bag_outlined, const Color(0xFF009688), () {
              _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }),
            _buildQuickActionCard('Manage Sales', Icons.point_of_sale_outlined, Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SellerOrdersScreen()));
            }),
            _buildQuickActionCard('My Earnings', Icons.monetization_on_outlined, const Color(0xFF9C27B0), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
            }),
            _buildQuickActionCard('My Rewards', Icons.emoji_events_outlined, const Color(0xFFFF9800), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardsScreen()));
            }),
            _buildQuickActionCard('Messages', Icons.chat_bubble_outline_rounded, const Color(0xFF03A9F4), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
            }),
            _buildQuickActionCard('EcoAssist', Icons.smart_toy_outlined, const Color(0xFFE91E63), () {
              EcoAssistSheet.show(context);
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
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
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
    final rates = _marketRates ?? [];

    if (rates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Market Rates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...rates.map((rate) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rate['category'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Rs ${rate['pricePerUnit'] ?? 0} / ${rate['unit'] ?? 'kg'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      final difference = DateTime.now().difference(date);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'just now';
    } catch (e) {
      return '';
    }
  }

  Widget _buildRecentActivity() {
    final activities = _recentActivity ?? [];

    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

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
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF4CAF50),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['action'] ?? activity['title'] ?? 'Activity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity['details'] ?? activity['description'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(activity['createdAt'] ?? ''),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
        if (index == 2) {
          EcoAssistSheet.show(context);
          return;
        }
        setState(() => _selectedIndex = index);
        // Map navigation bar index to PageView index
        int pageIndex = index;
        if (index > 2) {
          pageIndex = pageIndex - 1;
        }
        _pageController.jumpToPage(pageIndex);
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
        CurvedBottomNavItem(
          icon: Icons.smart_toy_outlined,
          activeIcon: Icons.smart_toy,
          label: 'EcoAssist',
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
        icon: Icons.smart_toy_rounded,
        isSelected: false,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF00E5FF)
            : const Color(0xFF4CAF50),
        iconColor: Colors.white,
        onTap: () {
          EcoAssistSheet.show(context);
        },
      ),
    );
  }

  Widget _buildGamificationCard(bool isDark) {
    final rewardsService = context.watch<RewardsService>();
    final status = rewardsService.rewardsStatus;
    if (status == null) return const SizedBox.shrink();

    final points = status['ecoPoints'] ?? 0;
    final level = status['currentLevel'] ?? 'Beginner Recycler';
    final trustScore = status['trustScore'] ?? 100;
    final nextLevelInfo = status['nextLevelInfo'];
    final progressPercent = (nextLevelInfo?['progressPercent'] as num?)?.toDouble() ?? 0.0;
    final pointsNeeded = nextLevelInfo?['pointsNeeded'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RewardsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF161616), const Color(0xFF0C0C0C)]
                : [const Color(0xFFFFFFFF), const Color(0xFFF9F9F9)],
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF222222) : const Color(0xFFEAEAEA),
            width: 1.0,
          ),
          boxShadow: const [],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            color: isDark ? const Color(0xFF00E676) : Colors.green.shade800,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            level,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$points Eco Points',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.green.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Trust Score',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$trustScore',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF00E676) : Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level Progress',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                Text(
                  pointsNeeded > 0 ? '$pointsNeeded pts to next level' : 'Max Level',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF00E676) : Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white12 : Colors.green.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF00E676) : Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
