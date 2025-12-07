import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/admin_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

// Conditional import for web
import 'admin_reports_export_stub.dart'
    if (dart.library.html) 'admin_reports_export_web.dart' as export_helper;

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy Data
  final List<double> monthlyRevenue = [
    45000,
    52000,
    48000,
    58000,
    63000,
    65000
  ];
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  final Map<String, int> revenueByMaterial = {
    'Plastic': 95000,
    'Metal': 75000,
    'Paper': 48000,
    'E-Waste': 27000,
  };

  final Map<String, Map<String, dynamic>> collectionData = {
    'Plastic': {'weight': 2450, 'revenue': 95000, 'percentage': 40},
    'Paper': {'weight': 1890, 'revenue': 48000, 'percentage': 30},
    'Metal': {'weight': 980, 'revenue': 75000, 'percentage': 20},
    'E-Waste': {'weight': 580, 'revenue': 27000, 'percentage': 10},
  };

  final List<Map<String, dynamic>> topUsers = [
    {
      'rank': 1,
      'name': 'Sarah Khan',
      'type': 'Warehouse',
      'sales': 85000,
      'purchases': 45000
    },
    {
      'rank': 2,
      'name': 'Tech Corp',
      'type': 'Company',
      'sales': 78000,
      'purchases': 52000
    },
    {
      'rank': 3,
      'name': 'John Doe',
      'type': 'Individual',
      'sales': 65000,
      'purchases': 38000
    },
    {
      'rank': 4,
      'name': 'Green Solutions',
      'type': 'Company',
      'sales': 58000,
      'purchases': 32000
    },
    {
      'rank': 5,
      'name': 'Ali Hassan',
      'type': 'Individual',
      'sales': 52000,
      'purchases': 28000
    },
    {
      'rank': 6,
      'name': 'Metro Waste',
      'type': 'Warehouse',
      'sales': 48000,
      'purchases': 25000
    },
    {
      'rank': 7,
      'name': 'Recyclo Inc',
      'type': 'Company',
      'sales': 45000,
      'purchases': 22000
    },
    {
      'rank': 8,
      'name': 'Fatima Bibi',
      'type': 'Individual',
      'sales': 42000,
      'purchases': 20000
    },
    {
      'rank': 9,
      'name': 'Eco Hub',
      'type': 'Warehouse',
      'sales': 38000,
      'purchases': 18000
    },
    {
      'rank': 10,
      'name': 'Clean City',
      'type': 'Company',
      'sales': 35000,
      'purchases': 15000
    },
  ];

  final List<Map<String, dynamic>> topCollectors = [
    {
      'rank': 1,
      'name': 'Ahmed Khan',
      'rating': 4.9,
      'pickups': 245,
      'performance': 98
    },
    {
      'rank': 2,
      'name': 'Fatima Ali',
      'rating': 4.8,
      'pickups': 232,
      'performance': 95
    },
    {
      'rank': 3,
      'name': 'Hassan Raza',
      'rating': 4.7,
      'pickups': 218,
      'performance': 92
    },
    {
      'rank': 4,
      'name': 'Usman Sheikh',
      'rating': 4.6,
      'pickups': 205,
      'performance': 89
    },
    {
      'rank': 5,
      'name': 'Bilal Ahmed',
      'rating': 4.5,
      'pickups': 192,
      'performance': 86
    },
    {
      'rank': 6,
      'name': 'Zainab Malik',
      'rating': 4.4,
      'pickups': 180,
      'performance': 83
    },
    {
      'rank': 7,
      'name': 'Imran Qureshi',
      'rating': 4.3,
      'pickups': 168,
      'performance': 80
    },
    {
      'rank': 8,
      'name': 'Sana Tariq',
      'rating': 4.2,
      'pickups': 155,
      'performance': 77
    },
    {
      'rank': 9,
      'name': 'Kamran Iqbal',
      'rating': 4.1,
      'pickups': 142,
      'performance': 74
    },
    {
      'rank': 10,
      'name': 'Nadia Shah',
      'rating': 4.0,
      'pickups': 130,
      'performance': 71
    },
  ];

  final Map<int, int> collectorRatings = {
    5: 45,
    4: 28,
    3: 10,
    2: 3,
    1: 1,
  };

  final Map<String, int> userTypeDistribution = {
    'Individual': 680,
    'Warehouse': 380,
    'Company': 174,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==================== EXPORT FUNCTIONALITY ====================

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Revenue Report';
      case 1:
        return 'Materials Report';
      case 2:
        return 'User Performance Report';
      case 3:
        return 'Collector Performance Report';
      default:
        return 'Report';
    }
  }

  String _getFileName(int index) {
    switch (index) {
      case 0:
        return 'revenue_report';
      case 1:
        return 'materials_report';
      case 2:
        return 'users_report';
      case 3:
        return 'collectors_report';
      default:
        return 'report';
    }
  }

  Future<void> _showExportDialog() async {
    String selectedFormat = 'text';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: AdminColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Export Report',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show which report is being exported
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AdminColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AdminColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exporting: ${_getTabName(_tabController.index)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AdminColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Select format:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Format options
                _buildFormatOption(
                  icon: Icons.description_outlined,
                  title: 'Text File (.txt)',
                  subtitle: 'Plain text format',
                  value: 'text',
                  groupValue: selectedFormat,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFormat = value!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildFormatOption(
                  icon: Icons.table_chart_outlined,
                  title: 'CSV File (.csv)',
                  subtitle: 'Spreadsheet compatible',
                  value: 'csv',
                  groupValue: selectedFormat,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFormat = value!;
                    });
                  },
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AdminColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportData(selectedFormat);
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.1)
              : AdminColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AdminColors.primaryGreen : AdminColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AdminColors.primaryGreen
                  : AdminColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AdminColors.primaryGreen
                          : AdminColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AdminColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(String format) {
    String data = '';
    String filename = _getFileName(_tabController.index);
    String extension = format == 'csv' ? '.csv' : '.txt';
    String mimeType = format == 'csv' ? 'text/csv' : 'text/plain';

    // Get data based on current tab
    switch (_tabController.index) {
      case 0:
        data =
            format == 'csv' ? _generateRevenueCsv() : _generateRevenueReport();
        break;
      case 1:
        data = format == 'csv'
            ? _generateMaterialsCsv()
            : _generateMaterialsReport();
        break;
      case 2:
        data = format == 'csv' ? _generateUsersCsv() : _generateUsersReport();
        break;
      case 3:
        data = format == 'csv'
            ? _generateCollectorsCsv()
            : _generateCollectorsReport();
        break;
    }

    try {
      if (kIsWeb) {
        export_helper.downloadFile(data, '$filename$extension', mimeType);
        _showExportSuccess();
      } else {
        // For mobile, show a message that file saving is not yet implemented
        _showExportNotSupported();
      }
    } catch (e) {
      _showExportError();
    }
  }

  void _showExportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Report exported successfully!'),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showExportNotSupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Export is currently only supported on web'),
          ],
        ),
        backgroundColor: AdminColors.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showExportError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Failed to export report'),
          ],
        ),
        backgroundColor: AdminColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==================== REPORT GENERATION - TEXT FORMAT ====================

  String _generateRevenueReport() {
    final now = DateTime.now();
    final totalRevenue = revenueByMaterial.values.reduce((a, b) => a + b);

    StringBuffer sb = StringBuffer();
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('                    REVENUE REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln(
        'Generated: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('SUMMARY');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('Total Revenue:    Rs ${_formatNumber(totalRevenue)}');
    sb.writeln(
        'This Month:       Rs ${_formatNumber(monthlyRevenue.last.toInt())}');
    sb.writeln(
        'Daily Average:    Rs ${_formatNumber((monthlyRevenue.last / 30).toInt())}');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('MONTHLY BREAKDOWN');
    sb.writeln('───────────────────────────────────────────────────────────');
    for (int i = 0; i < months.length; i++) {
      sb.writeln(
          '${months[i].padRight(15)} Rs ${_formatNumber(monthlyRevenue[i].toInt())}');
    }
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('REVENUE BY MATERIAL');
    sb.writeln('───────────────────────────────────────────────────────────');
    revenueByMaterial.forEach((material, revenue) {
      final percentage = (revenue / totalRevenue * 100).round();
      sb.writeln(
          '${material.padRight(15)} Rs ${_formatNumber(revenue).padRight(10)} ($percentage%)');
    });
    sb.writeln('');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('                    END OF REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');

    return sb.toString();
  }

  String _generateMaterialsReport() {
    final now = DateTime.now();
    final totalWeight = collectionData.values
        .map((e) => e['weight'] as int)
        .reduce((a, b) => a + b);
    final totalRevenue = collectionData.values
        .map((e) => e['revenue'] as int)
        .reduce((a, b) => a + b);

    StringBuffer sb = StringBuffer();
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('              MATERIALS COLLECTION REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln(
        'Generated: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('COLLECTION SUMMARY');
    sb.writeln('───────────────────────────────────────────────────────────');
    collectionData.forEach((material, data) {
      sb.writeln(
          '${material.padRight(12)} ${_formatNumber(data['weight'] as int).padRight(8)} kg   Rs ${_formatNumber(data['revenue'] as int).padRight(10)} (${data['percentage']}%)');
    });
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('TOTALS');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('Total Collected:  ${_formatNumber(totalWeight)} kg');
    sb.writeln('Total Revenue:    Rs ${_formatNumber(totalRevenue)}');
    sb.writeln('');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('                    END OF REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');

    return sb.toString();
  }

  String _generateUsersReport() {
    final now = DateTime.now();

    StringBuffer sb = StringBuffer();
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('              USER PERFORMANCE REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln(
        'Generated: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('SUMMARY');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('Total Users:      1,234');
    sb.writeln('Growth:           +12% this month');
    sb.writeln(
        'Top Seller:       ${topUsers[0]['name']} - Rs ${_formatNumber(topUsers[0]['sales'] as int)}');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('USER TYPE DISTRIBUTION');
    sb.writeln('───────────────────────────────────────────────────────────');
    userTypeDistribution.forEach((type, count) {
      sb.writeln('${type.padRight(15)} $count users');
    });
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('TOP 10 USERS');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('Rank  Name                 Type         Sales       Purchases');
    sb.writeln(
        '────  ───────────────────  ───────────  ──────────  ──────────');
    for (var user in topUsers) {
      sb.writeln(
          '${user['rank'].toString().padRight(6)}${(user['name'] as String).padRight(21)}${(user['type'] as String).padRight(13)}Rs ${_formatNumber(user['sales'] as int).padRight(8)}Rs ${_formatNumber(user['purchases'] as int)}');
    }
    sb.writeln('');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('                    END OF REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');

    return sb.toString();
  }

  String _generateCollectorsReport() {
    final now = DateTime.now();

    StringBuffer sb = StringBuffer();
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('            COLLECTOR PERFORMANCE REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln(
        'Generated: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('SUMMARY');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('Total Collectors: 87');
    sb.writeln('Growth:           +5% this month');
    sb.writeln(
        'Top Performer:    ${topCollectors[0]['name']} - ${topCollectors[0]['pickups']} pickups');
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('RATING DISTRIBUTION');
    sb.writeln('───────────────────────────────────────────────────────────');
    collectorRatings.forEach((stars, count) {
      sb.writeln('$stars Stars:        $count collectors');
    });
    sb.writeln('');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('TOP 10 COLLECTORS');
    sb.writeln('───────────────────────────────────────────────────────────');
    sb.writeln('Rank  Name                 Rating   Pickups   Performance');
    sb.writeln('────  ───────────────────  ───────  ────────  ───────────');
    for (var collector in topCollectors) {
      sb.writeln(
          '${collector['rank'].toString().padRight(6)}${(collector['name'] as String).padRight(21)}${collector['rating'].toString().padRight(9)}${collector['pickups'].toString().padRight(10)}${collector['performance']}%');
    }
    sb.writeln('');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('                    END OF REPORT');
    sb.writeln('═══════════════════════════════════════════════════════════');

    return sb.toString();
  }

  // ==================== REPORT GENERATION - CSV FORMAT ====================

  String _generateRevenueCsv() {
    StringBuffer sb = StringBuffer();
    sb.writeln('REVENUE REPORT');
    sb.writeln('Generated,${DateTime.now().toIso8601String()}');
    sb.writeln('');
    sb.writeln('MONTHLY REVENUE');
    sb.writeln('Month,Revenue (Rs)');
    for (int i = 0; i < months.length; i++) {
      sb.writeln('${months[i]},${monthlyRevenue[i].toInt()}');
    }
    sb.writeln('');
    sb.writeln('REVENUE BY MATERIAL');
    sb.writeln('Material,Revenue (Rs),Percentage');
    final totalRevenue = revenueByMaterial.values.reduce((a, b) => a + b);
    revenueByMaterial.forEach((material, revenue) {
      final percentage = (revenue / totalRevenue * 100).round();
      sb.writeln('$material,$revenue,$percentage%');
    });
    return sb.toString();
  }

  String _generateMaterialsCsv() {
    StringBuffer sb = StringBuffer();
    sb.writeln('MATERIALS COLLECTION REPORT');
    sb.writeln('Generated,${DateTime.now().toIso8601String()}');
    sb.writeln('');
    sb.writeln('Material,Weight (kg),Revenue (Rs),Percentage');
    collectionData.forEach((material, data) {
      sb.writeln(
          '$material,${data['weight']},${data['revenue']},${data['percentage']}%');
    });
    return sb.toString();
  }

  String _generateUsersCsv() {
    StringBuffer sb = StringBuffer();
    sb.writeln('USER PERFORMANCE REPORT');
    sb.writeln('Generated,${DateTime.now().toIso8601String()}');
    sb.writeln('');
    sb.writeln('TOP USERS');
    sb.writeln('Rank,Name,Type,Sales (Rs),Purchases (Rs)');
    for (var user in topUsers) {
      sb.writeln(
          '${user['rank']},${user['name']},${user['type']},${user['sales']},${user['purchases']}');
    }
    sb.writeln('');
    sb.writeln('USER TYPE DISTRIBUTION');
    sb.writeln('Type,Count');
    userTypeDistribution.forEach((type, count) {
      sb.writeln('$type,$count');
    });
    return sb.toString();
  }

  String _generateCollectorsCsv() {
    StringBuffer sb = StringBuffer();
    sb.writeln('COLLECTOR PERFORMANCE REPORT');
    sb.writeln('Generated,${DateTime.now().toIso8601String()}');
    sb.writeln('');
    sb.writeln('TOP COLLECTORS');
    sb.writeln('Rank,Name,Rating,Pickups,Performance (%)');
    for (var collector in topCollectors) {
      sb.writeln(
          '${collector['rank']},${collector['name']},${collector['rating']},${collector['pickups']},${collector['performance']}');
    }
    sb.writeln('');
    sb.writeln('RATING DISTRIBUTION');
    sb.writeln('Stars,Collectors');
    collectorRatings.forEach((stars, count) {
      sb.writeln('$stars,$count');
    });
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded,
                color: theme.appBarTheme.foregroundColor),
            tooltip: 'Export Report',
            onPressed: _showExportDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart, size: 20), text: 'Revenue'),
            Tab(icon: Icon(Icons.inventory_2, size: 20), text: 'Materials'),
            Tab(icon: Icon(Icons.people, size: 20), text: 'Users'),
            Tab(icon: Icon(Icons.local_shipping, size: 20), text: 'Collectors'),
          ],
        ),
      ),
      drawer: const AdminDrawer(currentRoute: 'reports'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRevenueTab(),
          _buildMaterialsTab(),
          _buildUsersTab(),
          _buildCollectorsTab(),
        ],
      ),
    );
  }

  // ==================== REVENUE TAB ====================
  Widget _buildRevenueTab() {
    return RefreshIndicator(
      color: AdminColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueSummaryCards(),
            const SizedBox(height: 20),
            _buildRevenueChartCard(),
            const SizedBox(height: 20),
            _buildRevenueByMaterialCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummaryCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            icon: Icons.account_balance_wallet,
            iconColor: AdminColors.primaryGreen,
            iconBgColor: AdminColors.primaryGreen.withValues(alpha: 0.1),
            label: 'Total Revenue',
            value: 'Rs 2,45,000',
            trend: '+15% from last month',
            trendPositive: true,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            icon: Icons.calendar_month,
            iconColor: AdminColors.accentBlue,
            iconBgColor: AdminColors.accentBlue.withValues(alpha: 0.1),
            label: 'This Month',
            value: 'Rs 65,000',
            trend: '+8% from last month',
            trendPositive: true,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            icon: Icons.trending_up,
            iconColor: AdminColors.accentOrange,
            iconBgColor: AdminColors.accentOrange.withValues(alpha: 0.1),
            label: 'Daily Average',
            value: 'Rs 2,167',
            trend: '+5% from last month',
            trendPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required String trend,
    required bool trendPositive,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AdminColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AdminColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: trendPositive ? AdminColors.success : AdminColors.error,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(
                    color:
                        trendPositive ? AdminColors.success : AdminColors.error,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Revenue Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Last 6 months',
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.show_chart, color: AdminColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20000,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AdminColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20000,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}K',
                          style: const TextStyle(
                            color: AdminColors.textSecondary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                color: AdminColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 80000,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      monthlyRevenue.length,
                      (index) =>
                          FlSpot(index.toDouble(), monthlyRevenue[index]),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: const LinearGradient(
                      colors: [
                        AdminColors.primaryGreen,
                        AdminColors.primaryGreenDark
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AdminColors.primaryGreen,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AdminColors.primaryGreen.withValues(alpha: 0.3),
                          AdminColors.primaryGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AdminColors.textPrimary,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'Rs ${spot.y.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByMaterialCard() {
    final theme = Theme.of(context);
    final total = revenueByMaterial.values.reduce((a, b) => a + b);
    final colors = [
      AdminColors.accentBlue,
      AdminColors.accentOrange,
      AdminColors.primaryGreen,
      AdminColors.accentPurple,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Breakdown by Material',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...revenueByMaterial.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final material = entry.value.key;
            final revenue = entry.value.value;
            final percentage = (revenue / total * 100).round();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        material,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Rs ${_formatNumber(revenue)} ($percentage%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 12,
                      backgroundColor: colors[index].withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(colors[index]),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Revenue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                'Rs ${_formatNumber(total)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MATERIALS TAB ====================
  Widget _buildMaterialsTab() {
    return RefreshIndicator(
      color: AdminColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaterialSummaryGrid(),
            const SizedBox(height: 20),
            _buildPieChartCard(),
            const SizedBox(height: 20),
            _buildStackedBarChartCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialSummaryGrid() {
    final materials = [
      {
        'name': 'Plastic',
        'icon': Icons.water_drop,
        'color': AdminColors.accentBlue,
        'weight': 2450,
        'revenue': 95000,
        'percentage': 40,
      },
      {
        'name': 'Paper',
        'icon': Icons.description,
        'color': AdminColors.primaryGreen,
        'weight': 1890,
        'revenue': 48000,
        'percentage': 30,
      },
      {
        'name': 'Metal',
        'icon': Icons.build,
        'color': AdminColors.accentOrange,
        'weight': 980,
        'revenue': 75000,
        'percentage': 20,
      },
      {
        'name': 'E-Waste',
        'icon': Icons.phone_android,
        'color': AdminColors.accentPurple,
        'weight': 580,
        'revenue': 27000,
        'percentage': 10,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        final material = materials[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AdminColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (material['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  material['icon'] as IconData,
                  color: material['color'] as Color,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatNumber(material['weight'] as int)} kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs ${_formatNumber(material['revenue'] as int)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AdminColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          (material['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${material['percentage']}% of total',
                      style: TextStyle(
                        fontSize: 11,
                        color: material['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChartCard() {
    final theme = Theme.of(context);
    final colors = [
      AdminColors.accentBlue,
      AdminColors.primaryGreen,
      AdminColors.accentOrange,
      AdminColors.accentPurple,
    ];
    final materials = ['Plastic', 'Paper', 'Metal', 'E-Waste'];
    final percentages = [40.0, 30.0, 20.0, 10.0];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collection Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: List.generate(4, (index) {
                  return PieChartSectionData(
                    color: colors[index],
                    value: percentages[index],
                    title: '${percentages[index].toInt()}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: List.generate(4, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${materials[index]} (${percentages[index].toInt()}%)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedBarChartCard() {
    final theme = Theme.of(context);
    // Monthly collection data for stacked bar chart
    final monthlyCollectionData = [
      [1200.0, 900.0, 500.0, 300.0], // Jan
      [1400.0, 1000.0, 600.0, 350.0], // Feb
      [1300.0, 950.0, 550.0, 320.0], // Mar
      [1500.0, 1100.0, 650.0, 400.0], // Apr
      [1600.0, 1200.0, 700.0, 450.0], // May
      [1700.0, 1300.0, 750.0, 500.0], // Jun
    ];

    final colors = [
      AdminColors.accentBlue,
      AdminColors.primaryGreen,
      AdminColors.accentOrange,
      AdminColors.accentPurple,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Material Collection Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monthly breakdown by material type (kg)',
            style: TextStyle(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AdminColors.textPrimary,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final materials = [
                        'Plastic',
                        'Paper',
                        'Metal',
                        'E-Waste'
                      ];
                      final total = monthlyCollectionData[groupIndex]
                          .reduce((a, b) => a + b);
                      return BarTooltipItem(
                        '${months[groupIndex]}\nTotal: ${total.toInt()} kg',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}K',
                          style: const TextStyle(
                            color: AdminColors.textSecondary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                color: AdminColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AdminColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(6, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyCollectionData[index]
                            .reduce((a, b) => a + b),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        rodStackItems: [
                          BarChartRodStackItem(
                              0, monthlyCollectionData[index][0], colors[0]),
                          BarChartRodStackItem(
                            monthlyCollectionData[index][0],
                            monthlyCollectionData[index][0] +
                                monthlyCollectionData[index][1],
                            colors[1],
                          ),
                          BarChartRodStackItem(
                            monthlyCollectionData[index][0] +
                                monthlyCollectionData[index][1],
                            monthlyCollectionData[index][0] +
                                monthlyCollectionData[index][1] +
                                monthlyCollectionData[index][2],
                            colors[2],
                          ),
                          BarChartRodStackItem(
                            monthlyCollectionData[index][0] +
                                monthlyCollectionData[index][1] +
                                monthlyCollectionData[index][2],
                            monthlyCollectionData[index]
                                .reduce((a, b) => a + b),
                            colors[3],
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Plastic', colors[0]),
              _buildLegendItem('Paper', colors[1]),
              _buildLegendItem('Metal', colors[2]),
              _buildLegendItem('E-Waste', colors[3]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== USERS TAB ====================
  Widget _buildUsersTab() {
    return RefreshIndicator(
      color: AdminColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserStatsCards(),
            const SizedBox(height: 20),
            _buildTopUsersTable(),
            const SizedBox(height: 20),
            _buildUserTypeDistributionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            icon: Icons.people,
            iconColor: AdminColors.accentBlue,
            iconBgColor: AdminColors.accentBlue.withValues(alpha: 0.1),
            label: 'Total Users',
            value: '1,234',
            trend: '+12% this month',
            trendPositive: true,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            icon: Icons.emoji_events,
            iconColor: AdminColors.accentOrange,
            iconBgColor: AdminColors.accentOrange.withValues(alpha: 0.1),
            label: 'Top Seller',
            value: 'Sarah Khan',
            trend: 'Rs 85,000 sales',
            trendPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsersTable() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Performing Users',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Icon(Icons.leaderboard, color: AdminColors.accentOrange),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = topUsers[index];
              return Container(
                color: index % 2 == 0 ? Colors.white : AdminColors.surfaceLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildRankBadge(user['rank'] as int),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getTypeColor(user['type'] as String)
                          .withValues(alpha: 0.2),
                      child: Text(
                        (user['name'] as String).substring(0, 1),
                        style: TextStyle(
                          color: _getTypeColor(user['type'] as String),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getTypeColor(user['type'] as String)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user['type'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getTypeColor(user['type'] as String),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs ${_formatNumber(user['sales'] as int)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AdminColors.primaryGreen,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs ${_formatNumber(user['purchases'] as int)}',
                          style: const TextStyle(
                            color: AdminColors.accentBlue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? iconData;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
        iconData = Icons.emoji_events;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
        iconData = Icons.emoji_events;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        iconData = Icons.emoji_events;
        break;
      default:
        badgeColor = AdminColors.textSecondary;
        iconData = null;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: rank <= 3
            ? badgeColor.withValues(alpha: 0.2)
            : AdminColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Center(
        child: rank <= 3
            ? Icon(iconData, size: 16, color: badgeColor)
            : Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Warehouse':
        return AdminColors.accentBlue;
      case 'Company':
        return AdminColors.accentPurple;
      case 'Individual':
        return AdminColors.primaryGreen;
      default:
        return AdminColors.textSecondary;
    }
  }

  Widget _buildUserTypeDistributionCard() {
    final theme = Theme.of(context);
    final maxValue =
        userTypeDistribution.values.reduce((a, b) => a > b ? a : b);
    final colors = [
      AdminColors.primaryGreen,
      AdminColors.accentBlue,
      AdminColors.accentPurple,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Type Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...userTypeDistribution.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value.key;
            final count = entry.value.value;
            final percentage = (count / maxValue);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$count users',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors[index].withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors[index],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== COLLECTORS TAB ====================
  Widget _buildCollectorsTab() {
    return RefreshIndicator(
      color: AdminColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCollectorStatsCards(),
            const SizedBox(height: 20),
            _buildTopCollectorsTable(),
            const SizedBox(height: 20),
            _buildCollectorRatingDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectorStatsCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            icon: Icons.local_shipping,
            iconColor: AdminColors.accentBlue,
            iconBgColor: AdminColors.accentBlue.withValues(alpha: 0.1),
            label: 'Total Collectors',
            value: '87',
            trend: '+5% this month',
            trendPositive: true,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            icon: Icons.star,
            iconColor: AdminColors.accentOrange,
            iconBgColor: AdminColors.accentOrange.withValues(alpha: 0.1),
            label: 'Top Performer',
            value: 'Ahmed Khan',
            trend: '245 pickups',
            trendPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTopCollectorsTable() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Performing Collectors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Icon(Icons.local_shipping, color: AdminColors.primaryGreen),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topCollectors.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final collector = topCollectors[index];
              return Container(
                color: index % 2 == 0 ? Colors.white : AdminColors.surfaceLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildRankBadge(collector['rank'] as int),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          AdminColors.primaryGreen.withValues(alpha: 0.2),
                      child: Text(
                        (collector['name'] as String).substring(0, 1),
                        style: const TextStyle(
                          color: AdminColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collector['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                final rating = collector['rating'] as double;
                                return Icon(
                                  i < rating.floor()
                                      ? Icons.star
                                      : (i < rating
                                          ? Icons.star_half
                                          : Icons.star_border),
                                  size: 14,
                                  color: AdminColors.accentOrange,
                                );
                              }),
                              const SizedBox(width: 4),
                              Text(
                                '${collector['rating']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2,
                              size: 14,
                              color: AdminColors.accentBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${collector['pickups']} pickups',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AdminColors.accentBlue,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AdminColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                (collector['performance'] as int) / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getPerformanceColor(
                                    collector['performance'] as int),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${collector['performance']}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: _getPerformanceColor(
                                collector['performance'] as int),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(int performance) {
    if (performance >= 90) return AdminColors.primaryGreen;
    if (performance >= 75) return AdminColors.accentBlue;
    if (performance >= 60) return AdminColors.accentOrange;
    return AdminColors.error;
  }

  Widget _buildCollectorRatingDistribution() {
    final theme = Theme.of(context);
    final ratingColors = {
      5: const Color(0xFFFFD700), // Gold
      4: AdminColors.primaryGreen,
      3: AdminColors.accentBlue,
      2: AdminColors.accentOrange,
      1: AdminColors.error,
    };

    final maxCount = collectorRatings.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collector Rating Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...collectorRatings.entries.map((entry) {
            final stars = entry.key;
            final count = entry.value;
            final color = ratingColors[stars]!;
            final percentage = count / maxCount;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        Text(
                          '$stars',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star, size: 16, color: color),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '$count collectors',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
