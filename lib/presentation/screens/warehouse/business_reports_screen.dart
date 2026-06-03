import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class BusinessReportsScreen extends StatefulWidget {
  const BusinessReportsScreen({super.key});

  @override
  State<BusinessReportsScreen> createState() => _BusinessReportsScreenState();
}

class _BusinessReportsScreenState extends State<BusinessReportsScreen> {
  final WarehouseService _warehouseService = WarehouseService();
  String _selectedReportType = 'general'; // general, sales, purchases, expenses
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isGenerating = false;
  Map<String, dynamic>? _reportResult;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _reportResult = null;
    });

    final sStr = "${_startDate.year}-${_startDate.month}-${_startDate.day}";
    final eStr = "${_endDate.year}-${_endDate.month}-${_endDate.day}";

    final result = await _warehouseService.getReport(
      type: _selectedReportType,
      startDate: sStr,
      endDate: eStr,
    );

    setState(() {
      _reportResult = result;
      _isGenerating = false;
    });
  }

  void _printReportMock() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Report'),
          content: Text(
            'We are preparing your ${_selectedReportType.toUpperCase()} report in PDF/Excel format.\n'
            'The file is ready for download.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report PDF downloaded successfully!')),
                );
              },
              child: const Text('Download'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedRange =
        "${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}";

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
            _buildConfigurationPanel(formattedRange, isDark),
            const SizedBox(height: 20),
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_reportResult != null) _buildReportOutputSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationPanel(String rangeStr, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Scope',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedReportType,
            decoration: const InputDecoration(labelText: 'Report Type'),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('Profit & Loss Summary')),
              DropdownMenuItem(value: 'sales', child: Text('Sales Inflow Registry')),
              DropdownMenuItem(value: 'purchases', child: Text('Purchases Outflow Registry')),
              DropdownMenuItem(value: 'expenses', child: Text('Operational Expenses Ledger')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedReportType = val);
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Timeframe Date Range', style: TextStyle(fontSize: 12)),
            subtitle: Text(
              rangeStr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            trailing: const Icon(Icons.date_range),
            onTap: _pickDateRange,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Generate Document', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportOutputSection(bool isDark) {
    final type = _reportResult!['type'] ?? 'Report Summary';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.download_for_offline, color: Colors.blue),
                onPressed: _printReportMock,
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          if (_selectedReportType == 'general') ...[
            _buildMetricsRow('Revenue Inflows', 'PKR ${(_reportResult!['metrics']?['revenue'] ?? 0.0).toStringAsFixed(0)}', isDark),
            _buildMetricsRow('Inventory Purchases', 'PKR ${(_reportResult!['metrics']?['purchases'] ?? 0.0).toStringAsFixed(0)}', isDark),
            _buildMetricsRow('Operating Overhead', 'PKR ${(_reportResult!['metrics']?['expenses'] ?? 0.0).toStringAsFixed(0)}', isDark),
            const Divider(),
            _buildMetricsRow('Estimated Net Profit', 'PKR ${(_reportResult!['metrics']?['netProfit'] ?? 0.0).toStringAsFixed(0)}', isDark, isHighlight: true),
          ] else ...[
            Text(
              'Total Records: ${_reportResult!['count'] ?? 0}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (_reportResult!['records'] as List?)?.length ?? 0,
              itemBuilder: (context, index) {
                final rec = _reportResult!['records'][index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['description'] ?? rec['category'] ?? 'Record',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            rec['createdAt'] ?? rec['date'] ?? '',
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        'PKR ${(rec['netAmount'] ?? rec['amount'] ?? 0.0).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                );
              },
            )
          ]
        ],
      ),
    );
  }

  Widget _buildMetricsRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen) : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen) : null,
            ),
          )
        ],
      ),
    );
  }
}
