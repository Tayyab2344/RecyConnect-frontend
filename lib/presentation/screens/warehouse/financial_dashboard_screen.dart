import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  State<FinancialDashboardScreen> createState() => _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  final WarehouseService _warehouseService = WarehouseService();
  Map<String, dynamic> _summary = {};
  List<dynamic> _trends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialSummary();
  }

  Future<void> _loadFinancialSummary() async {
    setState(() => _isLoading = true);
    final data = await _warehouseService.getFinancialSummary();
    setState(() {
      _summary = data['summary'] ?? {};
      _trends = data['trends'] ?? [];
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
          'Financial Analytics',
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
        onRefresh: _loadFinancialSummary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewGrid(isDark),
                    const SizedBox(height: 24),
                    _buildTrendChartSection(isDark),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(isDark),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewGrid(bool isDark) {
    final netProfit = _summary['netProfit'] ?? 0.0;
    final isLoss = netProfit < 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildFinancialCard(
          'Total Revenue',
          'PKR ${(_summary['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
          Icons.arrow_upward,
          Colors.green,
          isDark,
        ),
        _buildFinancialCard(
          'Purchases Cost',
          'PKR ${(_summary['totalPurchases'] ?? 0.0).toStringAsFixed(0)}',
          Icons.arrow_downward,
          Colors.blue,
          isDark,
        ),
        _buildFinancialCard(
          'Operational Exp',
          'PKR ${(_summary['totalExpenses'] ?? 0.0).toStringAsFixed(0)}',
          Icons.receipt_long,
          Colors.orange,
          isDark,
        ),
        _buildFinancialCard(
          'Net Profit',
          'PKR ${netProfit.toStringAsFixed(0)}',
          isLoss ? Icons.trending_down : Icons.trending_up,
          isLoss ? Colors.red : Colors.emerald,
          isDark,
          subtitle: '${_summary['monthlyGrowth'] ?? 0.0}% growth',
        ),
      ],
    );
  }

  Widget _buildFinancialCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTrendChartSection(bool isDark) {
    if (_trends.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue & Expense Trends',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white10 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _trends.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _trends[index]['label'] ?? '',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Revenue Line
                  LineChartBarData(
                    spots: List.generate(_trends.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (_trends[index]['revenue'] as num).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  // Expenses Line (purchases + expenses)
                  LineChartBarData(
                    spots: List.generate(_trends.length, (index) {
                      final exp = (_trends[index]['purchases'] as num) +
                          (_trends[index]['expenses'] as num);
                      return FlSpot(index.toDouble(), exp.toDouble());
                    }),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('Cost & Expenses', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(bool isDark) {
    // Generate simple breakdown stats
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow('Sales Inflow', _summary['totalRevenue'] ?? 0.0, Colors.green, isDark),
          const Divider(),
          _buildBreakdownRow('Supplier Payouts', _summary['totalPurchases'] ?? 0.0, Colors.blue, isDark),
          const Divider(),
          _buildBreakdownRow('Operational Overhead', _summary['totalExpenses'] ?? 0.0, Colors.orange, isDark),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String name, double amount, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: color),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
          Text(
            'PKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
