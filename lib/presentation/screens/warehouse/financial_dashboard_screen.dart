import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/expense.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  State<FinancialDashboardScreen> createState() => _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  // Mock financial data
  final Map<String, double> _financialSummary = {
    'totalRevenue': 125450.0,
    'cogs': 50000.0,
    'totalExpenses': 68250.0,
    'stripeFees': 3625.0,
    'netProfit': 45200.0,
  };

  final List<Map<String, dynamic>> _recentExpenses = [
    {
      'category': 'OPERATIONAL',
      'amount': 25000.0,
      'description': 'Monthly warehouse operations',
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'category': 'TRANSPORTATION',
      'amount': 15000.0,
      'description': 'Delivery truck fuel & maintenance',
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'category': 'EMPLOYEE',
      'amount': 30000.0,
      'description': 'Staff salaries',
      'date': DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      'category': 'UTILITIES',
      'amount': 8000.0,
      'description': 'Electricity & water bills',
      'date': DateTime.now().subtract(const Duration(days: 10)),
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
          'Financial Dashboard',
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
            _buildProfitLossCard(isDark),
            const SizedBox(height: 20),
            _buildRevenueBreakdown(isDark),
            const SizedBox(height: 20),
            _buildExpenseBreakdown(isDark),
            const SizedBox(height: 20),
            _buildRecentExpenses(isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add expense screen coming soon')),
          );
        },
        backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildProfitLossCard(bool isDark) {
    final profitMargin = (_financialSummary['netProfit']! / _financialSummary['totalRevenue']!) * 100;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.darkPrimaryGreen, AppTheme.darkSecondaryGreen]
              : [AppTheme.primaryGreen, const Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Net Profit',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${profitMargin.toStringAsFixed(1)}% margin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PKR ${_financialSummary['netProfit']!.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              const Text(
                '+8.2% from last month',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown(bool isDark) {
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
            'Revenue Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildFinancialRow(
            'Total Revenue',
            _financialSummary['totalRevenue']!,
            Icons.trending_up,
            const Color(0xFF4CAF50),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildFinancialRow(
            'Cost of Goods Sold',
            -_financialSummary['cogs']!,
            Icons.shopping_cart,
            const Color(0xFFFF9800),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildFinancialRow(
            'Operating Expenses',
            -_financialSummary['totalExpenses']!,
            Icons.receipt_long,
            const Color(0xFFE91E63),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildFinancialRow(
            'Stripe Fees',
            -_financialSummary['stripeFees']!,
            Icons.credit_card,
            const Color(0xFF9C27B0),
            isDark,
          ),
          const Divider(height: 24),
          _buildFinancialRow(
            'Net Profit',
            _financialSummary['netProfit']!,
            Icons.attach_money,
            const Color(0xFF2196F3),
            isDark,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    double amount,
    IconData icon,
    Color color,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
        ),
        Text(
          'PKR ${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: amount >= 0
                ? const Color(0xFF4CAF50)
                : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdown(bool isDark) {
    final Map<String, double> categoryTotals = {
      'OPERATIONAL': 25000,
      'EMPLOYEE': 30000,
      'TRANSPORTATION': 15000,
      'UTILITIES': 8000,
      'PACKAGING': 5000,
      'COLLECTOR': 12000,
    };

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
            'Expense Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final percentage = (entry.value / _financialSummary['totalExpenses']!) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ExpenseCategory.getDisplayName(entry.key),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'PKR ${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                          .withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                      minHeight: 6,
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

  Widget _buildRecentExpenses(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full expense history coming soon')),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentExpenses.map((expense) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      size: 20,
                      color: AppTheme.errorRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ExpenseCategory.getDisplayName(expense['category']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          expense['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${expense['amount'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(expense['date']),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
