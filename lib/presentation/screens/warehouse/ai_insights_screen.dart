import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> with SingleTickerProviderStateMixin {
  final WarehouseService _warehouseService = WarehouseService();
  List<dynamic> _insights = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  // Local Sustainability stats (calculated from active state or fallback estimates)
  double _totalInventoryWeight = 4250.0; // in kg
  double _co2SavingsKg = 3187.5; // in kg

  @override
  void initState() {
    super.initState();
    _loadAIInsights();
    _fetchInventoryMetrics();
  }

  Future<void> _loadAIInsights() async {
    setState(() => _isLoading = true);
    final data = await _warehouseService.getAIInsights();
    setState(() {
      _insights = data;
      _isLoading = false;
    });
  }

  Future<void> _fetchInventoryMetrics() async {
    final items = await _warehouseService.getInventory();
    if (items.isNotEmpty) {
      double weight = 0;
      items.forEach((item) {
        weight += (item['quantityInStock'] ?? 0.0);
      });
      setState(() {
        _totalInventoryWeight = weight > 0 ? weight : 4250.0;
        _co2SavingsKg = _totalInventoryWeight * 0.75; // average conversion factor
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen;

    // Filter insights based on tab selection
    final filteredInsights = _insights.where((insight) {
      if (_selectedCategory == 'all') return true;
      final category = (insight['category'] ?? 'finance').toString().toLowerCase();
      return category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Smart AI Insights',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadAIInsights();
          await _fetchInventoryMetrics();
        },
        color: primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Sustainability footprint banner
            SliverToBoxAdapter(
              child: _buildSustainabilityDashboard(isDark, primaryColor),
            ),

            // 2. Category Tab Filters
            SliverToBoxAdapter(
              child: _buildCategoryTabs(isDark, primaryColor),
            ),

            // 3. AI Insights List
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : filteredInsights.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(isDark),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final insight = filteredInsights[index];
                              return _buildInsightCard(insight, isDark);
                            },
                            childCount: filteredInsights.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildSustainabilityDashboard(bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warehouse Footprint',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sustainability Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFootprintStat(
                  'CO₂ SAVED',
                  '${(_co2SavingsKg / 1000.0).toStringAsFixed(2)} t',
                  Icons.cloud_done_outlined,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildFootprintStat(
                  'LANDFILL MITIGATION',
                  '${(_totalInventoryWeight / 1000.0).toStringAsFixed(2)} t',
                  Icons.delete_sweep_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFootprintStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(bool isDark, Color primaryColor) {
    final categories = [
      {'id': 'all', 'label': 'All'},
      {'id': 'inventory', 'label': 'Inventory'},
      {'id': 'finance', 'label': 'Finance'},
      {'id': 'forecasting', 'label': 'Forecasts'},
      {'id': 'market', 'label': 'Market'},
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['id'];
          final activeBg = isDark ? AppTheme.darkCardSurface : Colors.white;
          final inactiveBg = Colors.transparent;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['id']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : inactiveBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white10 : Colors.black12),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? Colors.white : AppTheme.textDark)
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(dynamic insight, bool isDark) {
    final impact = (insight['impact'] ?? 'low').toString().toLowerCase();
    final category = (insight['category'] ?? 'finance').toString().toLowerCase();

    Color impactColor;
    IconData actionIcon;
    String actionLabel;

    if (impact == 'high') {
      impactColor = Colors.red;
    } else if (impact == 'medium') {
      impactColor = Colors.orange;
    } else {
      impactColor = Colors.green;
    }

    switch (category) {
      case 'inventory':
        actionIcon = Icons.inventory_2_outlined;
        actionLabel = 'Check Stock Audit';
        break;
      case 'finance':
        actionIcon = Icons.account_balance_wallet_outlined;
        actionLabel = 'Audit Balance Sheet';
        break;
      case 'forecasting':
        actionIcon = Icons.trending_up_outlined;
        actionLabel = 'View Trends';
        break;
      case 'market':
        actionIcon = Icons.storefront_outlined;
        actionLabel = 'Trade Recyclables';
        break;
      default:
        actionIcon = Icons.arrow_forward;
        actionLabel = 'Acknowledge';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 12,
                      color: _getCategoryColor(category),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(category),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: impactColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: impactColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${impact.toUpperCase()} IMPACT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: impactColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          Text(
            insight['title'] ?? 'Business Recommendation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight['description'] ?? '',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          // Action button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Auditing recommendation: ${insight['title']}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(actionIcon, size: 14, color: _getCategoryColor(category)),
                  const SizedBox(width: 8),
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textDark,
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

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'inventory':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'forecasting':
        return Colors.purple;
      case 'market':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'inventory':
        return Icons.inventory;
      case 'finance':
        return Icons.attach_money;
      case 'forecasting':
        return Icons.show_chart;
      case 'market':
        return Icons.business;
      default:
        return Icons.lightbulb;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No insights in this category.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
