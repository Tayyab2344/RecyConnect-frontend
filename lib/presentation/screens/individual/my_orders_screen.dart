import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/recycle_loader.dart';
import '../../widgets/skeleton_loader.dart';
import '../individual/browse_marketplace_screen.dart';
import 'package:flutter/foundation.dart';
import 'marketplace/order_details_screen.dart';

/// Premium My Orders Screen with Glassmorphism Design
/// Features: Glass cards, animated backgrounds, neon accents (dark), soft pastels (light)
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'Active'; // Active, Completed, Cancelled

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    
    _loadOrders();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final result = await _orderService.getOrders(role: 'buyer');
      setState(() {
        _orders = result['orders'];
        _filterOrders();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // Filter by status — backend statuses: CREATED, CONFIRMED, COMPLETED, CANCELLED
        bool matchesStatus = false;
        if (_selectedStatus == 'Active') {
          // "Active" includes newly created orders and confirmed-in-progress orders
          matchesStatus = order.status == 'CREATED' ||
              order.status == 'CONFIRMED' ||
              order.status == 'PENDING' ||
              order.status == 'COLLECTED';
        } else if (_selectedStatus == 'Completed') {
          matchesStatus = order.status == 'COMPLETED';
        } else if (_selectedStatus == 'Cancelled') {
          matchesStatus = order.status == 'CANCELLED';
        }

        // Filter by search
        final matchesSearch = _searchQuery.isEmpty ||
            order.materialType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.id.toString().contains(_searchQuery);

        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  double get _totalWeight {
    return _filteredOrders.fold(0.0, (sum, order) => sum + order.weight);
  }

  double get _totalMoney {
    return _filteredOrders.fold(0.0, (sum, order) => sum + (order.totalAmount > 0 ? order.totalAmount : (order.weight * 10.0)));
  }

  void _showExportOptions() {
    if (_filteredOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D2137) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Purchase Records',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred file format for export.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                ),
                title: Text('Export as PDF Document', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('Download or print a clean visual report', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToPdf();
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.grid_on, color: Colors.green),
                ),
                title: Text('Export as CSV Spreadsheet', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('Save data for Excel or other applications', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToCsv();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();
      
      final font = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('RECYCONNECT', style: pw.TextStyle(font: boldFont, fontSize: 24, textColor: PdfColor.fromHex('#4CAF50'))),
                        pw.Text('Purchases Ledger & Transactions', style: pw.TextStyle(font: font, fontSize: 14, textColor: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: pw.TextStyle(font: font, fontSize: 12, textColor: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Order ID', 'Date', 'Material Type', 'Seller Name', 'Status', 'Weight (kg)', 'Amount (Rs)'],
                data: _filteredOrders.map((order) {
                  final price = order.totalAmount > 0 ? order.totalAmount : (order.weight * 10.0);
                  return [
                    '#ORD0${order.id}',
                    DateFormat('yyyy-MM-dd').format(order.createdAt),
                    order.materialTypeDisplay,
                    order.seller?.name ?? 'Unknown Seller',
                    order.statusDisplay,
                    '${order.weight.toStringAsFixed(1)} kg',
                    'Rs ${price.toStringAsFixed(0)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#4CAF50')),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: pw.TextStyle(font: font, fontSize: 10),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex('#4CAF50'), width: 1.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Volume Purchased:', style: pw.TextStyle(font: font, fontSize: 11, textColor: PdfColors.grey700)),
                            pw.Text('${_totalWeight.toStringAsFixed(1)} kg', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                          ],
                        ),
                        pw.SizedBox(height: 6),
                        pw.Divider(color: PdfColor.fromHex('#4CAF50')),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Expense:', style: pw.TextStyle(font: boldFont, fontSize: 13, textColor: PdfColor.fromHex('#4CAF50'))),
                            pw.Text('Rs ${_totalMoney.toStringAsFixed(0)}', style: pw.TextStyle(font: boldFont, fontSize: 14, textColor: PdfColor.fromHex('#4CAF50'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Purchase_Records_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (kDebugMode) print('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportToCsv() async {
    try {
      List<List<dynamic>> csvData = [
        ['Order ID', 'Date', 'Material Type', 'Seller Name', 'Status', 'Weight (kg)', 'Amount (Rs)'],
        ..._filteredOrders.map((order) {
          final price = order.totalAmount > 0 ? order.totalAmount : (order.weight * 10.0);
          return [
            '#ORD0${order.id}',
            DateFormat('yyyy-MM-dd').format(order.createdAt),
            order.materialTypeDisplay,
            order.seller?.name ?? 'Unknown Seller',
            order.statusDisplay,
            order.weight,
            price,
          ];
        }),
        [], // Empty spacer row
        ['Total Weight (kg)', '', '', '', '', _totalWeight],
        ['Total Expense (Rs)', '', '', '', '', _totalMoney],
      ];

      String csvContent = const ListToCsvConverter().convert(csvData);
      
      await Clipboard.setData(ClipboardData(text: csvContent));
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/purchase_records_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
      await file.writeAsString(csvContent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV copied to clipboard & saved to documents folder!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error generating CSV: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate CSV: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildSummaryPanel(bool isDark) {
    if (_filteredOrders.isEmpty) return const SizedBox.shrink();

    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2137) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? accentColor.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Volume',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Spending',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_totalMoney.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _buildSummaryPanel(isDark),
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          _buildBackground(isDark),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildCustomAppBar(isDark),

                // Search Bar
                _buildSearchBar(isDark),

                // Status Filter Chips
                _buildStatusChips(isDark),

                const SizedBox(height: 16),

                // Orders List
                Expanded(
                  child: _isLoading
                      ? SkeletonLoader.list()
                      : _filteredOrders.isEmpty
                          ? _buildEmptyState(isDark)
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return _buildOrderCard(order, isDark);
                                },
                              ),
                            ),
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

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          // Back button — only show when navigated to (not embedded as a tab)
          if (Navigator.canPop(context))
            _buildIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
          if (Navigator.canPop(context))
            const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              'My Purchases',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Browse Marketplace button
          _buildPrimaryButton(
            label: 'Browse',
            icon: Icons.shopping_cart_outlined,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrowseMarketplaceScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.download_rounded,
            isDark: isDark,
            onTap: _showExportOptions,
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

  Widget _buildPrimaryButton({
    required String label,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.neonGreen, AppColors.neonCyan]
                    : [AppColors.primaryGreen, const Color(0xFF45A049)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.neonGreen : AppColors.primaryGreen)
                      .withValues(alpha: 0.4 * _pulseAnimation.value),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isDark ? const Color(0xFF0A1628) : Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF0A1628) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.8),
          border: Border.all(
            color: isDark
                ? AppColors.neonCyan.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterOrders();
              },
        ),
      ),
    );
  }

  Widget _buildStatusChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusChip('Active', isDark),
          const SizedBox(width: 10),
          _buildStatusChip('Completed', isDark),
          const SizedBox(width: 10),
          _buildStatusChip('Cancelled', isDark),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    final isSelected = _selectedStatus == status;
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _filterOrders();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
          status,
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
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? AppColors.neonCyan : AppColors.primaryGreen).withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse marketplace to place your first order',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDark) {
    final materialColor = _getMaterialColor(order.materialType);
    final statusInfo = _getStatusInfo(order.status, isDark);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(order: order),
              ),
            ).then((_) => _loadOrders()); // Reload on return to refresh unread count/status
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border.all(
                color: isDark
                    ? materialColor.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: materialColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Material Icon or Image
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: materialColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: isDark
                                ? Border.all(color: materialColor.withValues(alpha: 0.3))
                                : null,
                            image: DecorationImage(
                              image: _getImageProvider(order.imageUrl, order.materialType),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Order Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.materialTypeDisplay,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order #ORDER0${order.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: statusInfo['gradient'],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: (statusInfo['color'] as Color).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _getStatusText(order.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusInfo['textColor'],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Weight and Seller Row
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.scale_rounded,
                          '${order.weight} kg',
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoChip(
                            Icons.store_rounded,
                            order.seller?.name ?? 'Unknown Seller',
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    // Chat message preview and unread count badge
                    if (order.chat != null && order.chat!.lastMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 14,
                              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.chat!.lastMessage!.messageType == 'SYSTEM'
                                    ? '[System] ${order.chat!.lastMessage!.content}'
                                    : order.chat!.lastMessage!.content,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontStyle: order.chat!.lastMessage!.messageType == 'SYSTEM' ? FontStyle.italic : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (order.chat!.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${order.chat!.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Price and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total ',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                            Text(
                              'Rs ${(order.totalAmount > 0 ? order.totalAmount : (order.weight * 10.0)).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMM d, yyyy').format(order.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : const Color(0xFF666666),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF2196F3);
      case 'paper':
        return const Color(0xFFFFA726);
      case 'metal':
        return const Color(0xFF78909C);
      case 'e-waste':
        return const Color(0xFF9C27B0);
      case 'glass':
        return const Color(0xFF26A69A);
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getMaterialIcon(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Icons.recycling_rounded;
      case 'paper':
        return Icons.description_rounded;
      case 'metal':
        return Icons.build_rounded;
      case 'e-waste':
        return Icons.devices_rounded;
      case 'glass':
        return Icons.wine_bar_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  ImageProvider _getImageProvider(String? imageUrl, String material) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else {
        try {
          return MemoryImage(base64Decode(imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl));
        } catch (e) {
          // Fallback to default material image if base64 decoding fails
        }
      }
    }
    
    // Default material images
    switch (material.toLowerCase()) {
      case 'plastic':
        return const NetworkImage('https://images.unsplash.com/photo-1605600659873-d808a13e4d2a?auto=format&fit=crop&q=80&w=400');
      case 'paper':
        return const NetworkImage('https://images.unsplash.com/photo-1603398938378-e54eab446dde?auto=format&fit=crop&q=80&w=400');
      case 'metal':
        return const NetworkImage('https://images.unsplash.com/photo-1558231268-b80cbf376a88?auto=format&fit=crop&q=80&w=400');
      case 'e-waste':
        return const NetworkImage('https://images.unsplash.com/photo-1550005973-58ce3e70cc3d?auto=format&fit=crop&q=80&w=400');
      case 'glass':
        return const NetworkImage('https://images.unsplash.com/photo-1521124443916-29111c1e57bc?auto=format&fit=crop&q=80&w=400');
      case 'clothing':
        return const NetworkImage('https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&q=80&w=400');
      default:
        return const NetworkImage('https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&q=80&w=400');
    }
  }

  Map<String, dynamic> _getStatusInfo(String status, bool isDark) {
    switch (status) {
      case 'CREATED':
      case 'PENDING':
        return {
          'color': const Color(0xFFF59E0B),
          'gradient': LinearGradient(
            colors: isDark
                ? [const Color(0xFFF59E0B).withValues(alpha: 0.3), const Color(0xFFD97706).withValues(alpha: 0.3)]
                : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
          ),
          'textColor': isDark ? const Color(0xFFFBBF24) : const Color(0xFFF57C00),
        };
      case 'CONFIRMED':
      case 'COLLECTED':
        return {
          'color': const Color(0xFF3B82F6),
          'gradient': LinearGradient(
            colors: isDark
                ? [const Color(0xFF3B82F6).withValues(alpha: 0.3), const Color(0xFF2563EB).withValues(alpha: 0.3)]
                : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
          ),
          'textColor': isDark ? const Color(0xFF60A5FA) : const Color(0xFF1976D2),
        };
      case 'COMPLETED':
        return {
          'color': AppColors.success,
          'gradient': LinearGradient(
            colors: isDark
                ? [AppColors.success.withValues(alpha: 0.3), AppColors.success.withValues(alpha: 0.2)]
                : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
          ),
          'textColor': isDark ? AppColors.neonGreen : const Color(0xFF388E3C),
        };
      case 'CANCELLED':
        return {
          'color': AppColors.error,
          'gradient': LinearGradient(
            colors: isDark
                ? [AppColors.error.withValues(alpha: 0.3), AppColors.error.withValues(alpha: 0.2)]
                : [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)],
          ),
          'textColor': isDark ? const Color(0xFFF87171) : const Color(0xFFD32F2F),
        };
      default:
        return {
          'color': Colors.grey,
          'gradient': LinearGradient(
            colors: [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.2)],
          ),
          'textColor': isDark ? Colors.white70 : Colors.grey.shade700,
        };
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'CREATED':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PENDING':
        return 'Pending';
      case 'COLLECTED':
        return 'Collected';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
