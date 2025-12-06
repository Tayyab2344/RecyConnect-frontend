import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/static_data.dart';
import '../../../core/theme/app_theme.dart';
import '../individual/browse_marketplace_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'Active'; // Active, Completed, Cancelled

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
      print('Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // Filter by status
        bool matchesStatus = false;
        if (_selectedStatus == 'Active') {
          matchesStatus = order.status == 'PENDING' || order.status == 'COLLECTED';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BrowseMarketplaceScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Browse'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterOrders();
              },
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatusChip('Active', isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Completed', isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Cancelled', isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Orders List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    ),
                  )
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return _buildOrderCard(order, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _filterOrders();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
              : (isDark ? AppTheme.darkCardSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                : (isDark
                    ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                    : AppTheme.lightGray),
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppTheme.darkBackground : Colors.white)
                : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDark) {
    final materialColor = _getMaterialColor(order.materialType);
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
              : AppTheme.lightGray,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Material Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: materialColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getMaterialIcon(order.materialType),
                      color: materialColor,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

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
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #ORDER0${order.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor['background'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor['text'],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Weight and Seller
            Row(
              children: [
                Icon(
                  Icons.scale,
                  size: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.weight} kg',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.store,
                  size: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.seller?.name ?? 'Unknown Seller',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rs ${(order.weight * 10).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('M/d/yyyy').format(order.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
        return const Color(0xFF9E9E9E);
      case 'e-waste':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getMaterialIcon(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Icons.recycling;
      case 'paper':
        return Icons.description;
      case 'metal':
        return Icons.build;
      case 'e-waste':
        return Icons.devices;
      default:
        return Icons.inventory_2;
    }
  }

  Map<String, Color> _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return {
          'background': const Color(0xFFFFF3E0),
          'text': const Color(0xFFF57C00),
        };
      case 'COLLECTED':
        return {
          'background': const Color(0xFFE3F2FD),
          'text': const Color(0xFF1976D2),
        };
      case 'COMPLETED':
        return {
          'background': const Color(0xFFE8F5E9),
          'text': const Color(0xFF388E3C),
        };
      case 'CANCELLED':
        return {
          'background': const Color(0xFFFFEBEE),
          'text': const Color(0xFFD32F2F),
        };
      default:
        return {
          'background': Colors.grey.shade100,
          'text': Colors.grey.shade700,
        };
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'pending';
      case 'COLLECTED':
        return 'collected';
      case 'COMPLETED':
        return 'completed';
      case 'CANCELLED':
        return 'cancelled';
      default:
        return status.toLowerCase();
    }
  }
}
