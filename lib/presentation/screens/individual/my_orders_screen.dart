import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/recycle_loader.dart';
import '../individual/browse_marketplace_screen.dart';
import 'package:flutter/foundation.dart';

/// Premium My Orders Screen with Glassmorphism Design
/// Features: Glass cards, animated backgrounds, neon accents (dark), soft pastels (light)
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'Active'; // Active, Completed, Cancelled

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _loadOrders();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final result = await _orderService.getOrders(role: 'buyer');
      setState(() {
        _orders = result['orders'];
        _filterOrders();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // Filter by status — backend statuses: CREATED, CONFIRMED, COMPLETED, CANCELLED
        bool matchesStatus = false;
        if (_selectedStatus == 'Active') {
          // "Active" includes newly created orders and confirmed-in-progress orders
          matchesStatus = order.status == 'CREATED' ||
              order.status == 'CONFIRMED' ||
              order.status == 'PENDING' ||
              order.status == 'COLLECTED';
        } else if (_selectedStatus == 'Completed') {
          matchesStatus = order.status == 'COMPLETED';
        } else if (_selectedStatus == 'Cancelled') {
          matchesStatus = order.status == 'CANCELLED';
        }

        // Filter by search
        final matchesSearch = _searchQuery.isEmpty ||
            order.materialType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.id.toString().contains(_searchQuery);

        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          _buildBackground(isDark),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildCustomAppBar(isDark),

                // Search Bar
                _buildSearchBar(isDark),

                // Status Filter Chips
                _buildStatusChips(isDark),

                const SizedBox(height: 16),

                // Orders List
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: RecycleLoader(
                            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                          ),
                        )
                      : _filteredOrders.isEmpty
                          ? _buildEmptyState(isDark)
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return _buildOrderCard(order, isDark);
                                },
                              ),
                            ),
                ),
              ],
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
                  const Color(0xFF0A1628),
                  const Color(0xFF0D2137),
                  const Color(0xFF0F2847),
                  const Color(0xFF0A1E35),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF0F9F7),
                  const Color(0xFFE8F5F2),
                  const Color(0xFFDFF2ED),
                ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          // Back button — only show when navigated to (not embedded as a tab)
          if (Navigator.canPop(context))
            _buildIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
          if (Navigator.canPop(context))
            const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              'My Purchases',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Browse Marketplace button
          _buildPrimaryButton(
            label: 'Browse',
            icon: Icons.shopping_cart_outlined,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrowseMarketplaceScreen(),
                ),
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
              borderRadius: BorderRadius.circular(14),
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
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryButton({
    required String label,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.neonGreen, AppColors.neonCyan]
                    : [AppColors.primaryGreen, const Color(0xFF45A049)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.neonGreen : AppColors.primaryGreen)
                      .withValues(alpha: 0.4 * _pulseAnimation.value),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isDark ? const Color(0xFF0A1628) : Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF0A1628) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterOrders();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusChip('Active', isDark),
          const SizedBox(width: 10),
          _buildStatusChip('Completed', isDark),
          const SizedBox(width: 10),
          _buildStatusChip('Cancelled', isDark),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    final isSelected = _selectedStatus == status;
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _filterOrders();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [AppColors.neonGreen, AppColors.neonCyan]
                      : [AppColors.primaryGreen, const Color(0xFF45A049)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? accentColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? const Color(0xFF0A1628) : Colors.white)
                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? AppColors.neonCyan : AppColors.primaryGreen).withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse marketplace to place your first order',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDark) {
    final materialColor = _getMaterialColor(order.materialType);
    final statusInfo = _getStatusInfo(order.status, isDark);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.65),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? materialColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: materialColor.withValues(alpha: 0.08),
                            blurRadius: 20,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Material Icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: materialColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: isDark
                                ? Border.all(color: materialColor.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              _getMaterialIcon(order.materialType),
                              color: materialColor,
                              size: 26,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Order Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.materialTypeDisplay,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order #ORDER0${order.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: statusInfo['gradient'],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: (statusInfo['color'] as Color).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _getStatusText(order.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusInfo['textColor'],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Weight and Seller Row
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.scale_rounded,
                          '${order.weight} kg',
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoChip(
                            Icons.store_rounded,
                            order.seller?.name ?? 'Unknown Seller',
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Price and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total ',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                            Text(
                              'Rs ${(order.weight * 10).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMM d, yyyy').format(order.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : const Color(0xFF666666),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF2196F3);
      case 'paper':
        return const Color(0xFFFFA726);
      case 'metal':
        return const Color(0xFF78909C);
      case 'e-waste':
        return const Color(0xFF9C27B0);
      case 'glass':
        return const Color(0xFF26A69A);
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getMaterialIcon(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Icons.recycling_rounded;
      case 'paper':
        return Icons.description_rounded;
      case 'metal':
        return Icons.build_rounded;
      case 'e-waste':
        return Icons.devices_rounded;
      case 'glass':
        return Icons.wine_bar_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Map<String, dynamic> _getStatusInfo(String status, bool isDark) {
    switch (status) {
      case 'CREATED':
      case 'PENDING':
        return {
          'color': const Color(0xFFF59E0B),
          'gradient': LinearGradient(
            colors: isDark
                ? [const Color(0xFFF59E0B).withValues(alpha: 0.3), const Color(0xFFD97706).withValues(alpha: 0.3)]
                : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
          ),
          'textColor': isDark ? const Color(0xFFFBBF24) : const Color(0xFFF57C00),
        };
      case 'CONFIRMED':
      case 'COLLECTED':
        return {
          'color': const Color(0xFF3B82F6),
          'gradient': LinearGradient(
            colors: isDark
                ? [const Color(0xFF3B82F6).withValues(alpha: 0.3), const Color(0xFF2563EB).withValues(alpha: 0.3)]
                : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
          ),
          'textColor': isDark ? const Color(0xFF60A5FA) : const Color(0xFF1976D2),
        };
      case 'COMPLETED':
        return {
          'color': AppColors.success,
          'gradient': LinearGradient(
            colors: isDark
                ? [AppColors.success.withValues(alpha: 0.3), AppColors.success.withValues(alpha: 0.2)]
                : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
          ),
          'textColor': isDark ? AppColors.neonGreen : const Color(0xFF388E3C),
        };
      case 'CANCELLED':
        return {
          'color': AppColors.error,
          'gradient': LinearGradient(
            colors: isDark
                ? [AppColors.error.withValues(alpha: 0.3), AppColors.error.withValues(alpha: 0.2)]
                : [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)],
          ),
          'textColor': isDark ? const Color(0xFFF87171) : const Color(0xFFD32F2F),
        };
      default:
        return {
          'color': Colors.grey,
          'gradient': LinearGradient(
            colors: [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.2)],
          ),
          'textColor': isDark ? Colors.white70 : Colors.grey.shade700,
        };
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'CREATED':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PENDING':
        return 'Pending';
      case 'COLLECTED':
        return 'Collected';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
