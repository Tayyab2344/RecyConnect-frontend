import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = '30 Days';
  
  // Mock analytics data
  final Map<String, dynamic> _analyticsData = {
    'profitTrend': [
      {'date': 'Week 1', 'value': 8500.0},
      {'date': 'Week 2', 'value': 10200.0},
      {'date': 'Week 3', 'value': 9800.0},
      {'date': 'Week 4', 'value': 11500.0},
    ],
    'topMaterials': [
      {'name': 'Metal', 'revenue': 50000, 'percentage': 40},
      {'name': 'Plastic', 'revenue': 45000, 'percentage': 36},
      {'name': 'Paper', 'revenue': 30000, 'percentage': 24},
    ],
    'topCustomers': [
      {'name': 'ABC Corp', 'orders': 15, 'value': 45000},
      {'name': 'XYZ Ltd', 'orders': 12, 'value': 38000},
      {'name': 'Tech Industries', 'orders': 10, 'value': 32000},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'Business Analytics',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
        actions: [
          _buildPeriodSelector(isDark),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsightsCards(isDark),
            const SizedBox(height: 24),
            _buildProfitTrendChart(isDark),
            const SizedBox(height: 24),
            _buildTopMaterials(isDark),
            const SizedBox(height: 24),
            _buildTopCustomers(isDark),
            const SizedBox(height: 24),
            _buildActivityHeatmap(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedPeriod = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '7 Days', child: Text('Last 7 Days')),
        const PopupMenuItem(value: '30 Days', child: Text('Last 30 Days')),
        const PopupMenuItem(value: '90 Days', child: Text('Last 90 Days')),
        const PopupMenuItem(value: 'Year', child: Text('This Year')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardSurface : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                .withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Text(
              _selectedPeriod,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            'Avg Order Value',
            'PKR 4,480',
            '+15%',
            Icons.shopping_bag_outlined,
            const Color(0xFF2196F3),
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            'Orders/Day',
            '3.2',
            '+8%',
            Icons.trending_up,
            const Color(0xFF4CAF50),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String label,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
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
              Text(
                change,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTrendChart(bool isDark) {
    final maxValue = 12000.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profit Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Weekly profit performance',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _analyticsData['profitTrend'].map<Widget>((data) {
                final percentage = data['value'] / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'PKR ${(data['value'] / 1000).toStringAsFixed(1)}K',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 160.0 * (data['value'] as double) / maxValue,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                                (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                    .withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['date'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMaterials(bool isDark) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Materials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: _analyticsData['topMaterials']
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    final index = entry.key;
                    final material = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[index],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'PKR ${material['revenue']}'.replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${material['percentage']}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors[index],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 24),
              // Pie chart representation
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: PieChartPainter(
                    percentages: _analyticsData['topMaterials']
                        .map<double>((m) => m['percentage'].toDouble())
                        .toList(),
                    colors: colors,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Customers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ..._analyticsData['topCustomers'].asMap().entries.map((entry) {
            final index = entry.key;
            final customer = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '${customer['orders']} orders',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'PKR ${(customer['value'] / 1000).toStringAsFixed(0)}K',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap(bool isDark) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hours = ['Morning', 'Afternoon', 'Evening'];
    
    // Mock activity data (0-10 scale)
    final activities = [
      [7, 8, 5],
      [9, 10, 6],
      [8, 9, 7],
      [10, 8, 4],
      [9, 7, 3],
      [4, 3, 2],
      [2, 1, 1],
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Heatmap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Peak business hours',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  children: hours.map((hour) => Container(
                    height: 40,
                    alignment: Alignment.centerRight,
                    child: Text(
                      hour,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: days.map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 4),
                    ...List.generate(3, (rowIndex) {
                      return Row(
                        children: List.generate(7, (colIndex) {
                          final intensity = activities[colIndex][rowIndex] / 10;
                          return Expanded(
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                    .withOpacity(intensity),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple pie chart painter
class PieChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  PieChartPainter({required this.percentages, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = -90 * 3.14159 / 180; // Start from top
    
    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = (percentages[i] / 100) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
