import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../widgets/recycle_loader.dart';
import 'package:flutter/foundation.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
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
      final result = await _orderService.getOrders(role: 'seller');
      if (mounted) {
        setState(() {
          _orders = result['orders'];
          _filterOrders();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading seller orders: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: 'Failed to load orders: ${e.toString()}',
          onRetry: _loadOrders,
        );
      }
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
            order.id.toString().contains(_searchQuery) ||
            (order.buyer?.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Order Status'),
          content: Text('Change order status to ${_getStatusDisplayText(newStatus)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: RecycleLoader()),
        );

        await _orderService.updateOrderStatus(order.id, newStatus);

        // Close loading
        if (mounted) Navigator.pop(context);

        // Reload orders
        await _loadOrders();

        // Show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order status updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading if open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: 'Failed to update order: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Sales'),
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                ),
                filled: true,
                fillColor: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterOrders();
              },
            ),
          ),

          // Status Filter Chips
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStatusChip('Active', isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Completed', isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Cancelled', isDark),
              ],
            ),
          ),

          // Orders Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredOrders.length} Orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? Center(
                    child: RecycleLoader(
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
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Orders from buyers will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: AppTheme.primaryGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                : (isDark
                    ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                    : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppTheme.darkBackground : Colors.white)
                  : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
            ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                    borderRadius: BorderRadius.circular(12),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.toString().padLeft(5, '0')}',
                        style: TextStyle(
                          fontSize: 13,
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
                    order.statusDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor['text'],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Buyer Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray,
                    child: Icon(Icons.person, size: 18, color: isDark ? Colors.white : Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buyer',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                        Text(
                          order.buyer?.name ?? 'Unknown Buyer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.buyer?.contactNo != null)
                    IconButton(
                      icon: Icon(Icons.phone, color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen),
                      onPressed: () {
                        // Show contact info
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contact: ${order.buyer!.contactNo}')),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Weight and Date
            Row(
              children: [
                Icon(
                  Icons.scale,
                  size: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.weight} kg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, y').format(order.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Payment Method
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  order.paymentMethodDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),

            // Action Buttons (only for active orders)
            if (order.status == 'PENDING' || order.status == 'COLLECTED') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (order.status == 'PENDING')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateOrderStatus(order, 'COLLECTED'),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark Collected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          side: BorderSide(
                            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (order.status == 'COLLECTED') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order, 'COMPLETED'),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateOrderStatus(order, 'CANCELLED'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

  String _getStatusDisplayText(String status) {
    switch (status) {
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
