import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/models/warehouse_inventory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import 'add_warehouse_item_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  
  // Mock inventory data
  final List<Map<String, dynamic>> _mockInventory = [
    {
      'id': 1,
      'materialType': 'Plastic',
      'category': 'PET',
      'quantityInStock': 250.0,
      'purchasePrice': 50.0,
      'sellingPrice': 100.0,
      'reorderLevel': 100.0,
      'supplierName': 'ABC Traders',
    },
    {
      'id': 2,
      'materialType': 'Paper',
      'category': 'Cardboard',
      'quantityInStock': 500.0,
      'purchasePrice': 30.0,
      'sellingPrice': 60.0,
      'reorderLevel': 200.0,
      'supplierName': 'Paper Suppliers',
    },
    {
      'id': 3,
      'materialType': 'Metal',
      'category': 'Aluminum',
      'quantityInStock': 150.0,
      'purchasePrice': 180.0,
      'sellingPrice': 300.0,
      'reorderLevel': 100.0,
      'supplierName': 'Metal Corp',
    },
    {
      'id': 4,
      'materialType': 'Plastic',
      'category': 'HDPE',
      'quantityInStock': 80.0,
      'purchasePrice': 45.0,
      'sellingPrice': 90.0,
      'reorderLevel': 100.0,
      'supplierName': 'Plastic Inc',
    },
    {
      'id': 5,
      'materialType': 'Glass',
      'category': 'Clear Glass',
      'quantityInStock': 300.0,
      'purchasePrice': 20.0,
      'sellingPrice': 40.0,
      'reorderLevel': 150.0,
      'supplierName': 'Glass Works',
    },
  ];

  List<Map<String, dynamic>> get _filteredInventory {
    var items = _mockInventory;
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final material = item['materialType'].toString().toLowerCase();
        final category = item['category'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return material.contains(query) || category.contains(query);
      }).toList();
    }
    
    // Apply filter
    if (_filterStatus == 'Low Stock') {
      items = items.where((item) {
        return item['quantityInStock'] <= item['reorderLevel'];
      }).toList();
    } else if (_filterStatus == 'In Stock') {
      items = items.where((item) {
        return item['quantityInStock'] > item['reorderLevel'];
      }).toList();
    }
    
    return items;
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
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(isDark),
          _buildStatsBar(isDark),
          _buildInventoryTurnover(isDark),
          Expanded(
            child: _filteredInventory.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredInventory.length,
                    itemBuilder: (context, index) {
                      final item = _filteredInventory[index];
                      return _buildInventoryCard(item, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWarehouseItemScreen(),
            ),
          );
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
                .withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar - Premium Glassmorphism Style
          ClipRRect(
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
                  onChanged: (value) => setState(() => _searchQuery = value),
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
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips - Premium Style
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
      onTap: () => setState(() => _filterStatus = label),
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
    final totalItems = _mockInventory.length;
    final lowStockItems = _mockInventory.where((item) {
      return item['quantityInStock'] <= item['reorderLevel'];
    }).length;
    final totalValue = _mockInventory.fold<double>(0, (sum, item) {
      return sum + (item['quantityInStock'] * item['sellingPrice']);
    });
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                .withOpacity(0.3),
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

  Widget _buildInventoryCard(Map<String, dynamic> item, bool isDark) {
    final isLowStock = item['quantityInStock'] <= item['reorderLevel'];
    final profit = item['sellingPrice'] - item['purchasePrice'];
    final margin = (profit / item['sellingPrice'] * 100);
    final totalValue = item['quantityInStock'] * item['sellingPrice'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowStock
              ? AppTheme.errorRed.withOpacity(0.3)
              : (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                  .withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
                          item['materialType'],
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
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'],
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
                      'Supplier: ${item['supplierName']}',
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
                    color: AppTheme.errorRed.withOpacity(0.1),
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
          // Stats Row
          Row(
            children: [
              _buildMetric('Stock', '${item['quantityInStock'].toInt()}kg', isDark),
              _buildMetric('Buy', 'PKR ${item['purchasePrice'].toInt()}', isDark),
              _buildMetric('Sell', 'PKR ${item['sellingPrice'].toInt()}', isDark),
              _buildMetric('Margin', '${margin.toStringAsFixed(1)}%', isDark),
            ],
          ),
          const SizedBox(height: 12),
          // Value and Actions
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit ${item['materialType']}')),
                      );
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('View details for ${item['materialType']}')),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Turnover',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTurnoverItem('Fast Moving', 'Plastic (PET)', 0.8, Colors.green, isDark),
              const SizedBox(width: 12),
              _buildTurnoverItem('Slow Moving', 'Glass', 0.3, Colors.orange, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoverItem(String label, String item, double progress, Color color, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
              ),
              Icon(
                progress > 0.5 ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
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
                .withOpacity(0.5),
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
