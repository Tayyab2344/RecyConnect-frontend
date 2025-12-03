import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/admin_colors.dart';
import '../../../core/constants/modern_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

// OrderData Model
class OrderData {
  final String id;
  final String orderId;
  final String userName;
  final String userContact;
  final String collectorName;
  final String collectorContact;
  final String materialType;
  final int weight;
  final int pricePerKg;
  final int totalAmount;
  String status;
  final DateTime orderDate;
  final String location;
  final String address;

  OrderData({
    required this.id,
    required this.orderId,
    required this.userName,
    required this.userContact,
    required this.collectorName,
    required this.collectorContact,
    required this.materialType,
    required this.weight,
    required this.pricePerKg,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.location,
    required this.address,
  });
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';
  String? _selectedFilterOption;
  List<OrderData> _allOrders = [];
  List<OrderData> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _generateDummyOrders();
    _filteredOrders = List.from(_allOrders);
  }

  void _generateDummyOrders() {
    final users = [
      {'name': 'John Doe', 'contact': '+92-300-1111111'},
      {'name': 'Sarah Ali', 'contact': '+92-301-2222222'},
      {'name': 'Mike Wilson', 'contact': '+92-302-3333333'},
      {'name': 'Lisa Brown', 'contact': '+92-303-4444444'},
      {'name': 'Ahmed Raza', 'contact': '+92-304-5555555'},
      {'name': 'Fatima Noor', 'contact': '+92-305-6666666'},
      {'name': 'Hassan Shah', 'contact': '+92-306-7777777'},
      {'name': 'Zara Malik', 'contact': '+92-307-8888888'},
      {'name': 'Bilal Khan', 'contact': '+92-308-9999999'},
      {'name': 'Ayesha Tariq', 'contact': '+92-309-0000000'},
    ];

    final collectors = [
      {'name': 'Ahmed Khan', 'contact': '+92-310-1234567'},
      {'name': 'Fatima Khan', 'contact': '+92-311-2345678'},
      {'name': 'Hassan Raza', 'contact': '+92-312-3456789'},
      {'name': 'Zara Sheikh', 'contact': '+92-313-4567890'},
      {'name': 'Usman Ali', 'contact': '+92-314-5678901'},
    ];

    final locations = [
      {'location': 'Downtown', 'address': 'Block A, Downtown, Lahore'},
      {'location': 'Gulberg', 'address': 'Main Boulevard, Gulberg III, Lahore'},
      {'location': 'DHA', 'address': 'Phase 5, DHA, Lahore'},
      {'location': 'Model Town', 'address': 'Model Town Extension, Lahore'},
      {'location': 'Johar Town', 'address': 'Block E, Johar Town, Lahore'},
      {'location': 'Bahria Town', 'address': 'Sector C, Bahria Town, Lahore'},
    ];

    final materials = [
      {'type': 'Plastic', 'price': 100},
      {'type': 'Paper', 'price': 50},
      {'type': 'Metal', 'price': 150},
      {'type': 'E-Waste', 'price': 200},
    ];

    final statuses = ['completed', 'completed', 'completed', 'pending', 'pending', 'cancelled'];

    _allOrders = List.generate(30, (index) {
      final user = users[index % users.length];
      final collector = collectors[index % collectors.length];
      final loc = locations[index % locations.length];
      final material = materials[index % materials.length];
      final status = statuses[index % statuses.length];
      final weight = 10 + (index * 3) % 91;
      final pricePerKg = material['price'] as int;

      return OrderData(
        id: 'ID${10001 + index}',
        orderId: 'ORD-${10001 + index}',
        userName: user['name']!,
        userContact: user['contact']!,
        collectorName: collector['name']!,
        collectorContact: collector['contact']!,
        materialType: material['type'] as String,
        weight: weight,
        pricePerKg: pricePerKg,
        totalAmount: weight * pricePerKg,
        status: status,
        orderDate: DateTime(2025, 1, 1).add(Duration(days: index % 30)),
        location: loc['location']!,
        address: loc['address']!,
      );
    });

    // Sort by newest first
    _allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<OrderData> result = List.from(_allOrders);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((order) {
        return order.orderId.toLowerCase().contains(query) ||
            order.userName.toLowerCase().contains(query) ||
            order.collectorName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status/date filter
    if (_selectedFilterOption != null) {
      switch (_selectedFilterOption!) {
        case 'completed':
          result = result.where((o) => o.status == 'completed').toList();
          break;
        case 'pending':
          result = result.where((o) => o.status == 'pending').toList();
          break;
        case 'cancelled':
          result = result.where((o) => o.status == 'cancelled').toList();
          break;
        case 'newest':
          result.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          break;
      }
    }

    setState(() {
      _filteredOrders = result;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
        _applyFilters();
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _applyFilters();
  }

  String _getFilterLabel(String? option) {
    switch (option) {
      case 'completed':
        return 'Completed Orders';
      case 'pending':
        return 'Pending Orders';
      case 'cancelled':
        return 'Cancelled Orders';
      case 'newest':
        return 'Newest Orders';
      default:
        return 'None';
    }
  }

  void _applyFilter(String filterBy) {
    setState(() {
      _selectedFilterOption = filterBy;
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Filter: ${_getFilterLabel(filterBy)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      _selectedFilterOption = null;
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Filter cleared', style: TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: AdminColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _generateDummyOrders();
      _applyFilters();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AdminColors.success;
      case 'pending':
        return AdminColors.accentOrange;
      case 'cancelled':
        return AdminColors.error;
      default:
        return AdminColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getMaterialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return AdminColors.accentBlue;
      case 'paper':
        return AdminColors.success;
      case 'metal':
        return AdminColors.accentOrange;
      case 'e-waste':
        return AdminColors.accentPurple;
      default:
        return AdminColors.textSecondary;
    }
  }

  IconData _getMaterialIcon(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Icons.water_drop;
      case 'paper':
        return Icons.description;
      case 'metal':
        return Icons.build;
      case 'e-waste':
        return Icons.devices;
      default:
        return Icons.recycling;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Orders Management',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: theme.appBarTheme.foregroundColor),
            tooltip: 'Filter Orders',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: theme.cardColor,
            onSelected: (value) {
              if (value == 'reset') {
                _resetFilter();
              } else {
                _applyFilter(value);
              }
            },
            itemBuilder: (BuildContext context) => [
              // Header
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Filter Orders',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              const PopupMenuDivider(),

              // STATUS Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: AdminColors.accentBlue),
                    SizedBox(width: 8),
                    Text('Status',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'completed',
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Completed Orders')),
                    if (_selectedFilterOption == 'completed')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'pending',
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Pending Orders')),
                    if (_selectedFilterOption == 'pending')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'cancelled',
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Cancelled Orders')),
                    if (_selectedFilterOption == 'cancelled')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // DATE Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AdminColors.accentPurple),
                    SizedBox(width: 8),
                    Text('Date',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'newest',
                child: Row(
                  children: [
                    const Icon(Icons.new_releases, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Newest Orders')),
                    if (_selectedFilterOption == 'newest')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // RESET Option
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AdminColors.error, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Clear Filter',
                      style: TextStyle(
                        color: AdminColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: 'orders'),
      body: Column(
        children: [
          // Search Bar (toggleable)
          if (_isSearchVisible)
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by Order ID, user name, or collector...',
                  hintStyle: const TextStyle(
                    color: AdminColors.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AdminColors.primaryGreen,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AdminColors.textLight,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AdminColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

          // Order Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AdminColors.surfaceLight,
            child: Text(
              '${_filteredOrders.length} ${_filteredOrders.length == 1 ? 'Order' : 'Orders'} Found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.textSecondary,
              ),
            ),
          ),

          // Filter Indicator Banner
          if (_selectedFilterOption != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withOpacity(0.1),
                border: const Border(
                  bottom: BorderSide(color: AdminColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt,
                      size: 18, color: AdminColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filter: ${_getFilterLabel(_selectedFilterOption)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AdminColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetFilter,
                    icon: const Icon(Icons.close, size: 16, color: AdminColors.error),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: AdminColors.error, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

          // Order Cards List
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AdminColors.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderData order) {
    final statusColor = _getStatusColor(order.status);
    final materialColor = _getMaterialColor(order.materialType);
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: ModernColors.softShadow,
        ),
      child: Row(
        children: [
          // Left colored stripe
          Container(
            width: 4,
            height: 180,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP ROW: Order ID & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Order ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AdminColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${order.orderId}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(order.status),
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // USER & COLLECTOR INFO
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AdminColors.textLight),
                      const SizedBox(width: 6),
                      Text(
                        order.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping,
                          size: 16, color: AdminColors.textLight),
                      const SizedBox(width: 6),
                      Text(
                        order.collectorName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ORDER DETAILS ROW (3 columns)
                  Row(
                    children: [
                      // Material
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: materialColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getMaterialIcon(order.materialType),
                                size: 18,
                                color: materialColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.materialType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: materialColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Weight
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AdminColors.accentBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.scale,
                                size: 18,
                                color: AdminColors.accentBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.weight} kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Amount
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AdminColors.success.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_money,
                                size: 18,
                                color: AdminColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${NumberFormat('#,###').format(order.totalAmount)} PKR',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // BOTTOM ROW: Date & Location
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 12, color: AdminColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a')
                            .format(order.orderDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on,
                          size: 12, color: AdminColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        order.location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _showOrderDetailsBottomSheet(order),
                      style: TextButton.styleFrom(
                        foregroundColor: AdminColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: AdminColors.primaryGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AdminColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsBottomSheet(OrderData order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AdminColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Order ID & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${order.orderId}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(order.status),
                                    size: 16,
                                    color: _getStatusColor(order.status),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getStatusText(order.status),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(order.status),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Customer Information
                        _buildSectionTitle('Customer Information'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.person, 'Name', order.userName),
                        _buildInfoRow(Icons.phone, 'Contact', order.userContact),
                        _buildInfoRow(
                            Icons.location_on, 'Address', order.address),

                        const SizedBox(height: 20),

                        // Collector Information
                        _buildSectionTitle('Collector Information'),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            Icons.local_shipping, 'Name', order.collectorName),
                        _buildInfoRow(
                            Icons.phone, 'Contact', order.collectorContact),

                        const SizedBox(height: 20),

                        // Order Details
                        _buildSectionTitle('Order Details'),
                        const SizedBox(height: 12),
                        _buildInfoRowWithIcon(
                          _getMaterialIcon(order.materialType),
                          _getMaterialColor(order.materialType),
                          'Material',
                          order.materialType,
                        ),
                        _buildInfoRow(
                            Icons.scale, 'Weight', '${order.weight} kg'),
                        _buildInfoRow(Icons.sell, 'Price/kg',
                            '${order.pricePerKg} PKR'),
                        _buildInfoRow(
                          Icons.attach_money,
                          'Total Amount',
                          '${NumberFormat('#,###').format(order.totalAmount)} PKR',
                          valueColor: AdminColors.success,
                        ),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date & Time',
                          DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(order.orderDate),
                        ),
                        _buildInfoRow(
                            Icons.location_on, 'Location', order.location),

                        // Timeline for completed orders
                        if (order.status == 'completed') ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle('Order Timeline'),
                          const SizedBox(height: 12),
                          _buildTimelineItem(
                              'Order Placed',
                              DateFormat('MMM dd, hh:mm a')
                                  .format(order.orderDate),
                              true),
                          _buildTimelineItem(
                              'Collector Assigned',
                              DateFormat('MMM dd, hh:mm a').format(
                                  order.orderDate.add(const Duration(minutes: 15))),
                              true),
                          _buildTimelineItem(
                              'Pickup Started',
                              DateFormat('MMM dd, hh:mm a').format(
                                  order.orderDate.add(const Duration(minutes: 30))),
                              true),
                          _buildTimelineItem(
                              'Completed',
                              DateFormat('MMM dd, hh:mm a').format(
                                  order.orderDate.add(const Duration(hours: 1))),
                              true,
                              isLast: true),
                        ],

                        // Action buttons for pending orders
                        if (order.status == 'pending') ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showCancelOrderDialog(order);
                                  },
                                  icon: const Icon(Icons.cancel,
                                      color: AdminColors.error),
                                  label: const Text(
                                    'Cancel Order',
                                    style: TextStyle(
                                      color: AdminColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AdminColors.error, width: 1.5),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      order.status = 'completed';
                                    });
                                    setSheetState(() {});
                                    Navigator.pop(context);
                                    _applyFilters();
                                    _showSuccessSnackbar(
                                        'Order marked as completed');
                                  },
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text(
                                    'Mark Complete',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminColors.success,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AdminColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AdminColors.textLight),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AdminColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithIcon(
      IconData icon, Color iconColor, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AdminColors.success
                    : AdminColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted
                    ? AdminColors.success
                    : AdminColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelOrderDialog(OrderData order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AdminColors.error),
            SizedBox(width: 12),
            Text('Cancel Order?'),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel order #${order.orderId}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order.status = 'cancelled';
              });
              Navigator.pop(context);
              _applyFilters();
              _showSuccessSnackbar('Order cancelled successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
