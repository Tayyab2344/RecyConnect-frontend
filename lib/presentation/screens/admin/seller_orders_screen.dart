import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/modern_colors.dart';
import '../../../core/constants/admin_colors.dart';
import '../../../core/services/order_service.dart';
import '../../../models/order_model.dart';
import '../../widgets/admin/admin_drawer.dart'; // Ensure drawer is accessible or remove if not needed

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  String? _error;
  List<Order> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _orderService.getOrders(role: 'seller', limit: 50);
      setState(() {
        _allOrders = data['orders'] as List<Order>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchOrders();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return AdminColors.success;
      case 'pending': return AdminColors.accentOrange;
      case 'cancelled': return AdminColors.error;
      default: return AdminColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 'Completed';
      case 'pending': return 'Pending';
      case 'cancelled': return 'Cancelled';
      default: return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.check_circle;
      case 'pending': return Icons.access_time;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Sell Orders', style: TextStyle(color: theme.appBarTheme.foregroundColor, fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AdminColors.surfaceLight,
            child: Text(
              '${_allOrders.length} ${_allOrders.length == 1 ? 'Order' : 'Orders'} Found',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminColors.primaryGreen))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AdminColors.error),
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: AdminColors.textSecondary)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _fetchOrders,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primaryGreen),
                            ),
                          ],
                        ),
                      )
                    : _allOrders.isEmpty
                        ? Center(child: Text('No orders found', style: TextStyle(color: AdminColors.textSecondary, fontSize: 16)))
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            color: AdminColors.primaryGreen,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _allOrders.length,
                              itemBuilder: (context, index) {
                                final order = _allOrders[index];
                                return _buildOrderCard(order);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: ModernColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(order.status), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(_getStatusText(order.status), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AdminColors.textLight),
                const SizedBox(width: 6),
                Text('Buyer: ${order.buyerName}', style: const TextStyle(fontSize: 14, color: AdminColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 16, color: AdminColors.textLight),
                const SizedBox(width: 6),
                Text('${order.totalQuantity} items • ${NumberFormat('#,###').format(order.totalAmount)} PKR', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (order.status.toLowerCase() == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.error, side: const BorderSide(color: AdminColors.error),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success, foregroundColor: Colors.white),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
