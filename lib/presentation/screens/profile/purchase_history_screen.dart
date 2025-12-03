import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/order_model.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _purchases = [];
  bool _isLoading = true;

  // Filters
  String? _filterStatus;
  DateTimeRange? _dateRange;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() => _isLoading = true);
    try {
      final result = await _orderService.getOrders(
        role: 'buyer',
        status: _filterStatus == 'All' ? null : _filterStatus,
        startDate: _dateRange?.start.toIso8601String(),
        endDate: _dateRange?.end.toIso8601String(),
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _purchases = (result['orders'] as List<Order>);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load purchases: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Purchases',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Filter
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('All', isDark, setModalState),
                    _buildFilterChip('PENDING', isDark, setModalState),
                    _buildFilterChip('COLLECTED', isDark, setModalState),
                    _buildFilterChip('COMPLETED', isDark, setModalState),
                    _buildFilterChip('CANCELLED', isDark, setModalState),
                  ],
                ),

                const SizedBox(height: 24),

                // Date Range Filter
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                              onPrimary: Colors.white,
                              surface: isDark ? AppTheme.darkCardSurface : Colors.white,
                              onSurface: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setModalState(() => _dateRange = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateRange == null
                              ? 'Select Date Range'
                              : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = _filterStatus;
                        _dateRange = _dateRange;
                      });
                      _loadPurchases();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildFilterChip(String label, bool isDark, StateSetter setModalState) {
    final isSelected = _filterStatus == label || (_filterStatus == null && label == 'All');
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          if (label == 'All') {
            _filterStatus = null;
          } else {
            _filterStatus = selected ? label : null;
          }
        });
      },
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
      selectedColor: isDark ? AppTheme.darkPrimaryGreen.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.2),
      checkmarkColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
            : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
              : (isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Purchase History'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
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
                hintText: 'Search purchases...',
                prefixIcon: Icon(Icons.search, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
                filled: true,
                fillColor: isDark ? AppTheme.darkCardSurface : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                // Debounce could be added
                _loadPurchases();
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    ),
                  )
                : _purchases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No purchase history found',
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
                        itemCount: _purchases.length,
                        itemBuilder: (context, index) {
                          final purchase = _purchases[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCardSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${purchase.id}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                      ),
                                    ),
                                    _buildStatusBadge(purchase.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  purchase.materialTypeDisplay,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Amount: ${purchase.weight} kg',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Paid',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rs 0', // Placeholder as Order model doesn't have price yet
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Seller',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          purchase.seller?.name ?? 'Unknown Seller',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      case 'COLLECTED':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
