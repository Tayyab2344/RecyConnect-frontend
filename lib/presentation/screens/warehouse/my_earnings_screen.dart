import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

/// My Earnings Screen - History/Transaction Style
/// Features: Glassmorphism, earnings history list, summary stats
class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year', 'All Time'];

  // Mock earnings data
  final List<Map<String, dynamic>> _earnings = [
    {
      'id': 'TXN001',
      'type': 'Sale',
      'material': 'Plastic (PET)',
      'weight': 150.0,
      'amount': 7500.0,
      'buyer': 'GreenCycle Industries',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Completed',
    },
    {
      'id': 'TXN002',
      'type': 'Sale',
      'material': 'Metal (Aluminum)',
      'weight': 80.0,
      'amount': 24000.0,
      'buyer': 'MetalWorks Ltd.',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Completed',
    },
    {
      'id': 'TXN003',
      'type': 'Sale',
      'material': 'Paper (Cardboard)',
      'weight': 200.0,
      'amount': 6000.0,
      'buyer': 'PaperRecycle Co.',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Pending',
    },
    {
      'id': 'TXN004',
      'type': 'Sale',
      'material': 'E-Waste',
      'weight': 25.0,
      'amount': 12500.0,
      'buyer': 'TechRecycle Hub',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Completed',
    },
    {
      'id': 'TXN005',
      'type': 'Sale',
      'material': 'Glass',
      'weight': 100.0,
      'amount': 4000.0,
      'buyer': 'GlassWorks Inc.',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Completed',
    },
    {
      'id': 'TXN006',
      'type': 'Sale',
      'material': 'Plastic (HDPE)',
      'weight': 120.0,
      'amount': 5400.0,
      'buyer': 'PlastiCorp',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Completed',
    },
  ];

  double get _totalEarnings =>
      _earnings.fold(0, (sum, e) => sum + (e['amount'] as double));
  
  double get _pendingEarnings => _earnings
      .where((e) => e['status'] == 'Pending')
      .fold(0, (sum, e) => sum + (e['amount'] as double));

  int get _totalTransactions => _earnings.length;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          _buildBackground(isDark),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(isDark),

                // Summary Cards
                _buildSummaryCards(isDark),

                // Period Filter
                _buildPeriodFilter(isDark),

                const SizedBox(height: 16),

                // Earnings List
                Expanded(
                  child: _buildEarningsList(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A1628),
                  const Color(0xFF0D2137),
                  const Color(0xFF0F2847),
                  const Color(0xFF0A1E35),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF0F9F7),
                  const Color(0xFFE8F5F2),
                  const Color(0xFFDFF2ED),
                ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            isDark: isDark,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'My Earnings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          _buildIconButton(
            icon: Icons.download_outlined,
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.1 * _pulseAnimation.value),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Earnings',
              'Rs ${NumberFormat('#,##0').format(_totalEarnings)}',
              Icons.account_balance_wallet_outlined,
              AppColors.neonGreen,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              'Rs ${NumberFormat('#,##0').format(_pendingEarnings)}',
              Icons.pending_outlined,
              const Color(0xFFF59E0B),
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Transactions',
              '$_totalTransactions',
              Icons.receipt_long_outlined,
              AppColors.neonCyan,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.85),
                          Colors.white.withValues(alpha: 0.65),
                        ],
                ),
                border: Border.all(
                  color: isDark
                      ? color.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.6),
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1 * _pulseAnimation.value),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodFilter(bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = _selectedPeriod == period;
          final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
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
                period,
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
        },
      ),
    );
  }

  Widget _buildEarningsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _earnings.length,
      itemBuilder: (context, index) {
        final earning = _earnings[index];
        return _buildEarningCard(earning, isDark);
      },
    );
  }

  Widget _buildEarningCard(Map<String, dynamic> earning, bool isDark) {
    final materialColor = _getMaterialColor(earning['material'] as String);
    final isCompleted = earning['status'] == 'Completed';
    final date = earning['date'] as DateTime;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.65),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? materialColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    // Material Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: materialColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark
                            ? Border.all(color: materialColor.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Icon(
                        _getMaterialIcon(earning['material'] as String),
                        color: materialColor,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  earning['material'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '+Rs ${NumberFormat('#,##0').format(earning['amount'])}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.scale_outlined,
                                size: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${earning['weight']}kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.business_outlined,
                                size: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  earning['buyer'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? (isDark ? AppColors.neonGreen : AppColors.primaryGreen).withValues(alpha: 0.15)
                                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  earning['status'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isCompleted
                                        ? (isDark ? AppColors.neonGreen : AppColors.primaryGreen)
                                        : const Color(0xFFF59E0B),
                                  ),
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
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Color _getMaterialColor(String material) {
    if (material.contains('Plastic')) return const Color(0xFF2196F3);
    if (material.contains('Metal')) return const Color(0xFF78909C);
    if (material.contains('Paper')) return const Color(0xFFFFA726);
    if (material.contains('E-Waste')) return const Color(0xFF9C27B0);
    if (material.contains('Glass')) return const Color(0xFF26A69A);
    return AppColors.primaryGreen;
  }

  IconData _getMaterialIcon(String material) {
    if (material.contains('Plastic')) return Icons.recycling_rounded;
    if (material.contains('Metal')) return Icons.build_rounded;
    if (material.contains('Paper')) return Icons.description_rounded;
    if (material.contains('E-Waste')) return Icons.devices_rounded;
    if (material.contains('Glass')) return Icons.wine_bar_rounded;
    return Icons.inventory_2_rounded;
  }
}
