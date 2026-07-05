// dart:ui import removed - BackdropFilter no longer used for performance
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/warehouse_service.dart';
import '../../../core/utils/export_helper.dart';
import 'add_warehouse_item_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final WarehouseService _warehouseService = WarehouseService();
  String _searchQuery = '';
  String _filterStatus = 'All';
  List<dynamic> _inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    
    String? statusParam;
    if (_filterStatus == 'Low Stock') {
      statusParam = 'low_stock';
    } else if (_filterStatus == 'In Stock') {
      statusParam = 'in_stock';
    }

    final data = await _warehouseService.getInventory(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      status: statusParam,
    );

    setState(() {
      _inventory = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(int id) async {
    final success = await _warehouseService.deleteInventoryItem(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
      _loadInventory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  Future<void> _showEditDialog(dynamic item) async {
    final qtyController = TextEditingController(text: item['quantityInStock'].toString());
    final reorderController = TextEditingController(text: (item['reorderLevel'] ?? 100).toString());
    final buyController = TextEditingController(text: item['purchasePrice'].toString());
    final sellController = TextEditingController(text: item['sellingPrice'].toString());
    final locationController = TextEditingController(text: item['location'] ?? '');
    final notesController = TextEditingController(text: item['notes'] ?? '');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardSurface : Colors.white,
          title: Text('Edit ${item['materialType']} (${item['category']})'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: reorderController,
                  decoration: const InputDecoration(labelText: 'Reorder Level (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: buyController,
                  decoration: const InputDecoration(labelText: 'Purchase Price (PKR/kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sellController,
                  decoration: const InputDecoration(labelText: 'Selling Price (PKR/kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Warehouse Location (Bin)'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteItem(item['id']);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                setState(() => _isLoading = true);
                
                final res = await _warehouseService.updateInventoryItem(
                  item['id'],
                  quantity: double.tryParse(qtyController.text),
                  reorderLevel: double.tryParse(reorderController.text),
                  purchasePrice: double.tryParse(buyController.text),
                  sellingPrice: double.tryParse(sellController.text),
                  location: locationController.text,
                  notes: notesController.text,
                );

                if (!mounted) return;

                if (res['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Failed to update item')),
                  );
                }
                _loadInventory();
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'Inventory Management',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen),
            onSelected: (value) async {
              if (value == 'csv') {
                await ExportHelper.exportInventoryToCsv(_inventory);
              } else if (value == 'pdf') {
                await ExportHelper.exportInventoryToPdf(_inventory);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Export PDF'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(isDark),
          _buildStatsBar(isDark),
          _buildInventoryTurnover(isDark),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _inventory.isEmpty
                    ? _buildEmptyState(isDark)
                    : RefreshIndicator(
                        onRefresh: _loadInventory,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _inventory.length,
                          itemBuilder: (context, index) {
                            final item = _inventory[index];
                            return _buildInventoryCard(item, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWarehouseItemScreen(),
            ),
          );
          _loadInventory();
        },
        backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                .withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Performance optimization: Removed BackdropFilter for low-end device support
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadInventory();
              },
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: 'Search materials or categories...',
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
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip('All', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('In Stock', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Low Stock', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _filterStatus == label;
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = label);
        _loadInventory();
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
          label,
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

  Widget _buildStatsBar(bool isDark) {
    final totalItems = _inventory.length;
    final lowStockItems = _inventory.where((item) {
      return (item['quantityInStock'] as num) <= (item['reorderLevel'] ?? 0.0);
    }).length;
    final totalValue = _inventory.fold<double>(0, (sum, item) {
      return sum + ((item['quantityInStock'] as num) * (item['sellingPrice'] as num));
    });
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                .withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Items', totalItems.toString(), Icons.inventory_2, isDark),
          _buildStatItem('Low Stock', lowStockItems.toString(), Icons.warning_amber, isDark),
          _buildStatItem('Value', 'PKR ${(totalValue / 1000).toStringAsFixed(0)}K', Icons.attach_money, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(dynamic item, bool isDark) {
    final double qty = (item['quantityInStock'] as num).toDouble();
    final double reorder = (item['reorderLevel'] ?? 0.0).toDouble();
    final isLowStock = qty <= reorder;

    final double buy = (item['purchasePrice'] as num).toDouble();
    final double sell = (item['sellingPrice'] as num).toDouble();
    final profit = sell - buy;
    final margin = sell > 0 ? (profit / sell * 100) : 0.0;
    final totalValue = qty * sell;
    
    final supplierName = item['supplier']?['businessName'] ?? item['supplier']?['name'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowStock
              ? AppTheme.errorRed.withValues(alpha: 0.3)
              : (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                  .withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          item['materialType'].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supplier: $supplierName',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber, size: 14, color: AppTheme.errorRed),
                      SizedBox(width: 4),
                      Text(
                        'Low Stock',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetric('Stock', '${qty.toInt()} kg', isDark),
              _buildMetric('Buy', 'PKR ${buy.toInt()}', isDark),
              _buildMetric('Sell', 'PKR ${sell.toInt()}', isDark),
              _buildMetric('Margin', '${margin.toStringAsFixed(1)}%', isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Value: PKR ${totalValue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(item),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTurnover(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Status Alert',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _inventory.any((item) => (item['quantityInStock'] as num) <= (item['reorderLevel'] ?? 0.0))
                ? '⚠️ You have items below the reorder point. Check Low Stock items.'
                : '✅ All materials stock levels are healthy.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No inventory items found',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
