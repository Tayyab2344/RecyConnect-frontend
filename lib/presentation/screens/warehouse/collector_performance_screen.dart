import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CollectorPerformanceScreen extends StatefulWidget {
  const CollectorPerformanceScreen({super.key});

  @override
  State<CollectorPerformanceScreen> createState() => _CollectorPerformanceScreenState();
}

class _CollectorPerformanceScreenState extends State<CollectorPerformanceScreen> {
  // Mock collector data
  final List<Map<String, dynamic>> _collectors = [
    {
      'id': 'COL-1234',
      'name': 'Ahmed Khan',
      'totalPickups': 145,
      'onTimeRate': 94.5,
      'avgWeight': 85.2,
      'weightAccuracy': 96.8,
      'totalEarnings': 45000,
      'rating': 4.8,
      'activeMonths': 6,
    },
    {
      'id': 'COL-5678',
      'name': 'Hassan Ali',
      'totalPickups': 98,
      'onTimeRate': 88.2,
      'avgWeight': 72.5,
      'weightAccuracy': 92.3,
      'totalEarnings': 32000,
      'rating': 4.5,
      'activeMonths': 4,
    },
    {
      'id': 'COL-9012',
      'name': 'Bilal Ahmed',
      'totalPickups': 67,
      'onTimeRate': 91.0,
      'avgWeight': 68.9,
      'weightAccuracy': 94.5,
      'totalEarnings': 22000,
      'rating': 4.6,
      'activeMonths': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'Collector Performance',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(isDark),
            const SizedBox(height: 24),
            _buildCollectorsList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(bool isDark) {
    final totalPickups = _collectors.fold<int>(0, (sum, c) => sum + (c['totalPickups'] as int));
    final avgOnTime = _collectors.fold<double>(0, (sum, c) => sum + c['onTimeRate']) / _collectors.length;
    final totalEarnings = _collectors.fold<double>(0, (sum, c) => sum + c['totalEarnings']);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Pickups',
                totalPickups.toString(),
                Icons.local_shipping_outlined,
                const Color(0xFF4CAF50),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Avg On-Time',
                '${avgOnTime.toStringAsFixed(1)}%',
                Icons.schedule,
                const Color(0xFF2196F3),
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Collectors',
                _collectors.length.toString(),
                Icons.people_outlined,
                const Color(0xFFFF9800),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Total Paid',
                'PKR ${(totalEarnings / 1000).toStringAsFixed(0)}K',
                Icons.attach_money,
                const Color(0xFF9C27B0),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorsList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Individual Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ..._collectors.asMap().entries.map((entry) {
          final index = entry.key;
          final collector = entry.value;
          return _buildCollectorCard(collector, index + 1, isDark);
        }).toList(),
      ],
    );
  }

  Widget _buildCollectorCard(Map<String, dynamic> collector, int rank, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: rank == 1
                        ? [const Color(0xFFFFD700), const Color(0xFFFFAA00)]
                        : rank == 2
                            ? [const Color(0xFFC0C0C0), const Color(0xFF909090)]
                            : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collector['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collector['id'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFAA00), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    collector['rating'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Pickups',
                  collector['totalPickups'].toString(),
                  Icons.local_shipping_outlined,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'On-Time',
                  '${collector['onTimeRate']}%',
                  Icons.schedule,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Accuracy',
                  '${collector['weightAccuracy']}%',
                  Icons.done_all,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bars
          _buildProgressBar(
            'On-Time Rate',
            collector['onTimeRate'],
            const Color(0xFF4CAF50),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            'Weight Accuracy',
            collector['weightAccuracy'],
            const Color(0xFF2196F3),
            isDark,
          ),
          const SizedBox(height: 16),
          // Earnings
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Earnings',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'PKR ${collector['totalEarnings']}'.replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, bool isDark) {
    return Column(
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
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
