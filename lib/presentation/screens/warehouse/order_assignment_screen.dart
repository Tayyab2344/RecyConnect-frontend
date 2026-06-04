import 'package:flutter/material.dart';
import '../../../core/services/collector_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';

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
    double totalWeight = 0;
    double totalAmount = 0;
    for (final order in _orders) {
      if (_selectedOrderIds.contains(order.id)) {
        totalWeight += order.weight;
        totalAmount += order.totalAmount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Orders: ${widget.collector['name']}'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (_orders.isNotEmpty && !_isLoading)
            IconButton(
              icon: Icon(
                _selectedOrderIds.length == _orders.length
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Operations Mode:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                ),
              ],
            ),
          ),
          
          // Orders list area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No unassigned orders found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All orders are currently dispatched or completed.',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
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

                              return Card(
                                elevation: isSelected ? 4 : 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.primaryGreen
                                        : Colors.grey.withOpacity(0.2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedOrderIds.remove(order.id);
                                      } else {
                                        _selectedOrderIds.add(order.id);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Custom checkbox
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected ? AppTheme.primaryGreen : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                              : null,
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
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  Text(
                                                    'Rs ${order.totalAmount.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryGreen,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.recycling_rounded, size: 16, color: AppTheme.primaryGreen),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${order.materialTypeDisplay} (${order.weight} kg)',
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.person_rounded, size: 16, color: Colors.grey[600]),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '$counterpartName',
                                                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.location_on_rounded, size: 16, color: Colors.grey[600]),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      address,
                                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          
          // Sticky Bottom confirmation bar
          if (_orders.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Rs ${totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Weight: ${totalWeight.toStringAsFixed(1)} kg',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedOrderIds.isEmpty || _isSubmitLoading ? null : _assignOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Confirm Assignment',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
}
