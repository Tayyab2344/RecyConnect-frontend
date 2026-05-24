import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final WarehouseService _warehouseService = WarehouseService();
  List<dynamic> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAIInsights();
  }

  Future<void> _loadAIInsights() async {
    setState(() => _isLoading = true);
    final data = await _warehouseService.getAIInsights();
    setState(() {
      _insights = data;
      _isLoading = false;
    });
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
          'Smart AI Insights',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAIInsights,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _insights.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _insights.length,
                    itemBuilder: (context, index) {
                      final insight = _insights[index];
                      return _buildInsightCard(insight, isDark);
                    },
                  ),
      ),
    );
  }

  Widget _buildInsightCard(dynamic insight, bool isDark) {
    final impact = (insight['impact'] ?? 'low').toString().toLowerCase();
    final category = (insight['category'] ?? 'finance').toString().toLowerCase();

    Color impactColor;
    if (impact == 'high') {
      impactColor = Colors.red;
    } else if (impact == 'medium') {
      impactColor = Colors.orange;
    } else {
      impactColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: impactColor.withOpacity(0.3),
          width: impact == 'high' ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: impactColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(category),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
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
              )
            ],
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'inventory':
        return Colors.blue;
      case 'finance':
        return Colors.emerald;
      case 'forecasting':
        return Colors.purple;
      case 'market':
        return Colors.orange;
      default:
        return Colors.grey;
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
            'Calculating insights. Please refresh...',
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
