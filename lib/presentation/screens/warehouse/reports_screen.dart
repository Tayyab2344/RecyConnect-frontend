import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedFormat = 'PDF';
  
  final List<Map<String, dynamic>> _reportTypes = [
    {
      'title': 'Inventory Report',
      'description': 'Current stock levels and material breakdown',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF9C27B0),
    },
    {
      'title': 'Profit & Loss Statement',
      'description': 'Revenue, expenses, and net profit analysis',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Sales Report',
      'description': 'Orders by material and revenue breakdown',
      'icon': Icons.trending_up,
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Material Analysis',
      'description': 'Material performance and profitability ranking',
      'icon': Icons.analytics_outlined,
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Customer Insights',
      'description': 'Top buyers and customer lifetime value',
      'icon': Icons.people_outlined,
      'color': const Color(0xFFE91E63),
    },
    {
      'title': 'Order History',
      'description': 'All orders with status and payment details',
      'icon': Icons.receipt_long_outlined,
      'color': const Color(0xFF00BCD4),
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
          'Business Reports',
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
            _buildDateRangeSelector(isDark),
            const SizedBox(height: 24),
            _buildFormatSelector(isDark),
            const SizedBox(height: 24),
            Text(
              'Available Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ..._reportTypes.map((report) => _buildReportCard(report, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(bool isDark) {
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
          Row(
            children: [
              Icon(
                Icons.date_range,
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateButton('Start Date', _startDate, isDark, () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _startDate = date);
                }),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton('End Date', _endDate, isDark, () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _endDate = date);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime date, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                .withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelector(bool isDark) {
    final formats = ['PDF', 'Excel', 'CSV'];
    
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
          Row(
            children: [
              Icon(
                Icons.file_download_outlined,
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Export Format',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: formats.map((format) {
              final isSelected = _selectedFormat == format;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFormat = format),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                            : (isDark ? AppTheme.darkBackground : AppTheme.backgroundLight),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                              : (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
                                  .withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          format,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (report['color'] as Color).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (report['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              report['icon'] as IconData,
              color: report['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _generateReport(report['title']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Generate',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating $reportType in $_selectedFormat format...\n'
          'Period: ${_startDate.day}/${_startDate.month}/${_startDate.year} - '
          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkPrimaryGreen
            : AppTheme.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
