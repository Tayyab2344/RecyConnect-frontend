import 'package:flutter/material.dart';
import '../../../core/services/collector_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/premium_design_system.dart';
import '../../widgets/premium/premium_components.dart';

class OrderAssignmentScreen extends StatefulWidget {
  final Map<String, dynamic> collector;
  const OrderAssignmentScreen({super.key, required this.collector});

  @override
  State<OrderAssignmentScreen> createState() => _OrderAssignmentScreenState();
}

class _OrderAssignmentScreenState extends State<OrderAssignmentScreen> {
  final CollectorService _collectorService = CollectorService();
  String _selectedRole = 'buyer'; // 'buyer' = Pickup from Sellers, 'seller' = Deliver to Buyers
  List<Order> _orders = [];
  final Set<int> _selectedOrderIds = {};
  bool _isLoading = false;
  bool _isSubmitLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedOrderIds.clear();
    });

    try {
      final data = await _collectorService.getUnassignedOrders(role: _selectedRole);
      final fetchedOrders = (data as List).map((json) => Order.fromJson(json)).toList();
      setState(() {
        _orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _assignOrders() async {
    if (_selectedOrderIds.isEmpty) return;

    setState(() => _isSubmitLoading = true);

    try {
      final userObj = widget.collector['user'] as Map<String, dynamic>? ?? widget.collector;
      final int collectorId = userObj['id'] as int;

      await _collectorService.assignOrders(
        collectorId: collectorId,
        orderIds: _selectedOrderIds.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedOrderIds.length} orders successfully assigned to ${widget.collector['name']}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitLoading = false);
      }
    }
  }

  void _toggleSelectAll() {
    if (_selectedOrderIds.length == _orders.length) {
      setState(() => _selectedOrderIds.clear());
    } else {
      setState(() {
        _selectedOrderIds.clear();
        for (final order in _orders) {
          _selectedOrderIds.add(order.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double totalWeight = 0;
    double totalAmount = 0;
    for (final order in _orders) {
      if (_selectedOrderIds.contains(order.id)) {
        totalWeight += order.weight;
        totalAmount += order.totalAmount;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? PremiumDesignSystem.darkBackground : PremiumDesignSystem.background,
      appBar: AppBar(
        title: Text(
          'Assign Orders: ${widget.collector['name']}',
          style: PremiumDesignSystem.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: PremiumDesignSystem.primaryGradient,
          ),
        ),
        elevation: 4,
        shadowColor: PremiumDesignSystem.primary.withOpacity(0.3),
        foregroundColor: Colors.white,
        actions: [
          if (_orders.isNotEmpty && !_isLoading)
            IconButton(
              icon: Icon(
                _selectedOrderIds.length == _orders.length
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded,
                color: Colors.white,
              ),
              onPressed: _toggleSelectAll,
              tooltip: _selectedOrderIds.length == _orders.length ? 'Deselect All' : 'Select All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown filter header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? PremiumDesignSystem.darkSurface : Colors.white,
              boxShadow: PremiumDesignSystem.softShadowSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations Mode:',
                  style: PremiumDesignSystem.subtitle2.copyWith(
                    color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: isDark ? PremiumDesignSystem.darkSurface : Colors.white,
                  style: PremiumDesignSystem.body2.copyWith(
                    color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true,
                    fillColor: isDark ? PremiumDesignSystem.darkSurfaceVariant : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumDesignSystem.radiusMedium),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumDesignSystem.radiusMedium),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumDesignSystem.radiusMedium),
                      borderSide: const BorderSide(color: PremiumDesignSystem.primary, width: 1.5),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'buyer',
                      child: Text('Pickup from Sellers (Inflow)'),
                    ),
                    DropdownMenuItem(
                      value: 'seller',
                      child: Text('Deliver to Buyers (Outflow)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedRole = val);
                      _fetchOrders();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Orders list area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: PremiumDesignSystem.primary))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded, size: 64, color: PremiumDesignSystem.error),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: PremiumDesignSystem.body1.copyWith(
                                  color: PremiumDesignSystem.error,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              PremiumButton(
                                text: 'Retry',
                                icon: Icons.refresh_rounded,
                                width: 150,
                                height: 46,
                                onPressed: _fetchOrders,
                              ),
                            ],
                          ),
                        ),
                      )
                    : _orders.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: PremiumDesignSystem.primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      size: 64,
                                      color: PremiumDesignSystem.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No unassigned orders found',
                                    style: PremiumDesignSystem.h3.copyWith(
                                      color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'All orders are currently dispatched or completed.',
                                    style: PremiumDesignSystem.body2.copyWith(
                                      color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              final isSelected = _selectedOrderIds.contains(order.id);
                              final isBuying = _selectedRole == 'buyer';
                              final counterpartName = isBuying
                                  ? (order.seller?.name ?? 'Unknown Seller')
                                  : (order.buyer?.name ?? 'Unknown Buyer');
                              final address = isBuying
                                  ? (order.seller?.address ?? 'No Address Provided')
                                  : (order.buyer?.address ?? 'No Address Provided');

                              return GlassCard(
                                enableHover: true,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 14),
                                color: isSelected
                                    ? PremiumDesignSystem.primary.withOpacity(0.08)
                                    : (isDark ? PremiumDesignSystem.darkSurface : Colors.white),
                                borderRadius: BorderRadius.circular(PremiumDesignSystem.radiusLarge),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedOrderIds.remove(order.id);
                                    } else {
                                      _selectedOrderIds.add(order.id);
                                    }
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Custom Checkbox
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: AnimatedContainer(
                                        duration: PremiumDesignSystem.animationFast,
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected ? PremiumDesignSystem.primary : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? PremiumDesignSystem.primary : (isDark ? Colors.white30 : Colors.grey[400]!),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: isSelected
                                              ? PremiumDesignSystem.glowEffect(PremiumDesignSystem.primary, intensity: 0.2)
                                              : null,
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Order #ORD-${order.id}',
                                                style: PremiumDesignSystem.subtitle1.copyWith(
                                                  color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Rs ${order.totalAmount.toStringAsFixed(0)}',
                                                style: PremiumDesignSystem.subtitle1.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: PremiumDesignSystem.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          
                                          // Material Type and Weight row
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: PremiumDesignSystem.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.recycling_rounded,
                                                  size: 16,
                                                  color: PremiumDesignSystem.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${order.materialTypeDisplay} (${order.weight} kg)',
                                                style: PremiumDesignSystem.body2.copyWith(
                                                  color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          
                                          // Person Row
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 16,
                                                color: isDark ? PremiumDesignSystem.darkTextTertiary : PremiumDesignSystem.textSecondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  counterpartName,
                                                  style: PremiumDesignSystem.body2.copyWith(
                                                    color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          
                                          // Address Row
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                size: 16,
                                                color: isDark ? PremiumDesignSystem.darkTextTertiary : PremiumDesignSystem.textSecondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  address,
                                                  style: PremiumDesignSystem.caption.copyWith(
                                                    color: isDark ? PremiumDesignSystem.darkTextTertiary : PremiumDesignSystem.textSecondary,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          
          // Sticky Bottom confirmation bar
          if (_orders.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? PremiumDesignSystem.darkSurface : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(PremiumDesignSystem.radiusXXLarge),
                  topRight: Radius.circular(PremiumDesignSystem.radiusXXLarge),
                ),
                boxShadow: PremiumDesignSystem.elevatedShadow,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedOrderIds.length} Orders Selected',
                          style: PremiumDesignSystem.subtitle1.copyWith(
                            color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs ${totalAmount.toStringAsFixed(0)}',
                          style: PremiumDesignSystem.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PremiumDesignSystem.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total Weight: ${totalWeight.toStringAsFixed(1)} kg',
                      style: PremiumDesignSystem.caption.copyWith(
                        color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PremiumButton(
                      text: 'Confirm Assignment',
                      icon: Icons.assignment_turned_in_rounded,
                      onPressed: _assignOrders,
                      enabled: _selectedOrderIds.isNotEmpty && !_isSubmitLoading,
                      isLoading: _isSubmitLoading,
                      gradient: PremiumDesignSystem.primaryGradient,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
