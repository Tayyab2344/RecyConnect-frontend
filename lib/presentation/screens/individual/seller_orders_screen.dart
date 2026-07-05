import 'dart:convert';
import 'dart:io';
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
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../widgets/recycle_loader.dart';
import '../../widgets/skeleton_loader.dart';
import 'package:flutter/foundation.dart';
import 'marketplace/order_details_screen.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'Active'; // Active, Completed, Cancelled

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final result = await _orderService.getOrders(role: 'seller');
      if (mounted) {
        setState(() {
          _orders = result['orders'];
          _filterOrders();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading seller orders: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: 'Failed to load orders: ${e.toString()}',
          onRetry: _loadOrders,
        );
      }
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // Filter by status
        bool matchesStatus = false;
        if (_selectedStatus == 'Active') {
          matchesStatus = order.status == 'CREATED' ||
              order.status == 'CONFIRMED' ||
              order.status == 'PENDING' ||
              order.status == 'COLLECTED' ||
              order.status == 'PROCESSING' ||
              order.status == 'SHIPPED' ||
              order.status == 'DELIVERED' ||
              order.status == 'WAREHOUSE_ASSIGNED' ||
              order.status == 'WAITING_FOR_DISPATCH' ||
              order.status == 'COLLECTOR_ASSIGNED' ||
              order.status == 'COLLECTOR_ACCEPTED' ||
              order.status == 'TRAVELLING_TO_SELLER' ||
              order.status == 'ARRIVED_AT_PICKUP' ||
              order.status == 'MATERIAL_VERIFIED' ||
              order.status == 'PICKED_UP' ||
              order.status == 'IN_TRANSIT' ||
              order.status == 'ARRIVED_AT_BUYER' ||
              order.status == 'BUYER_VERIFICATION';
        } else if (_selectedStatus == 'Completed') {
          matchesStatus = order.status == 'COMPLETED';
        } else if (_selectedStatus == 'Cancelled') {
          matchesStatus = order.status == 'CANCELLED' ||
              order.status == 'WAREHOUSE_REJECTED' ||
              order.status == 'COLLECTOR_DECLINED' ||
              order.status == 'BUYER_CANCELLED' ||
              order.status == 'SELLER_CANCELLED' ||
              order.status == 'DELIVERY_FAILED' ||
              order.status == 'REFUND_INITIATED';
        }

        // Filter by search
        final matchesSearch = _searchQuery.isEmpty ||
            order.materialType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.id.toString().contains(_searchQuery) ||
            order.buyerName.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Order Status'),
          content: Text('Change order status to ${_getStatusDisplayText(newStatus)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!mounted) return;
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: RecycleLoader()),
        );

        await _orderService.updateOrderStatus(order.id, newStatus);

        // Close loading
        if (mounted) Navigator.pop(context);

        // Reload orders
        await _loadOrders();

        // Show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order status updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading if open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: 'Failed to update order: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _confirmOrder(Order order) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Are you sure you want to accept/confirm this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: RecycleLoader()),
        );

        await _orderService.confirmOrder(order.id);

        if (mounted) Navigator.pop(context); // Close loading

        await _loadOrders(); // Reload orders

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order confirmed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading if open
      if (mounted) {
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: 'Failed to confirm order: ${e.toString()}',
        );
      }
    }
  }

  double get _totalWeight {
    return _filteredOrders.fold(0.0, (sum, order) => sum + order.weight);
  }

  double get _totalMoney {
    return _filteredOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
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
            color: isDark ? AppTheme.darkCardSurface : Colors.white,
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
                'Export Sales Records',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred file format for export.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                ),
                title: const Text('Export as PDF Document', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Download or print a clean visual report'),
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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.grid_on, color: Colors.green),
                ),
                title: const Text('Export as CSV Spreadsheet', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Save data for Excel or other applications'),
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
                        pw.Text('RECYCONNECT', style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColor.fromHex('#4CAF50'))),
                        pw.Text('Sales Ledger & Transactions', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Order ID', 'Date', 'Material Type', 'Buyer Name', 'Status', 'Weight (kg)', 'Amount (Rs)'],
                data: _filteredOrders.map((order) => [
                  '#${order.id.toString().padLeft(5, '0')}',
                  DateFormat('yyyy-MM-dd').format(order.createdAt),
                  order.materialTypeDisplay,
                  order.buyerName,
                  order.statusDisplay,
                  '${order.weight.toStringAsFixed(1)} kg',
                  'Rs ${order.totalAmount.toStringAsFixed(0)}',
                ]).toList(),
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
                            pw.Text('Total Sales Volume:', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
                            pw.Text('${_totalWeight.toStringAsFixed(1)} kg', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                          ],
                        ),
                        pw.SizedBox(height: 6),
                        pw.Divider(color: PdfColor.fromHex('#4CAF50')),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Revenue:', style: pw.TextStyle(font: boldFont, fontSize: 13, color: PdfColor.fromHex('#4CAF50'))),
                            pw.Text('Rs ${_totalMoney.toStringAsFixed(0)}', style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColor.fromHex('#4CAF50'))),
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
        name: 'Sales_Records_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
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
        ['Order ID', 'Date', 'Material Type', 'Buyer Name', 'Status', 'Weight (kg)', 'Amount (Rs)'],
        ..._filteredOrders.map((order) => [
          '#${order.id.toString().padLeft(5, '0')}',
          DateFormat('yyyy-MM-dd').format(order.createdAt),
          order.materialTypeDisplay,
          order.buyerName,
          order.statusDisplay,
          order.weight,
          order.totalAmount,
        ]),
        [], // Empty spacer row
        ['Total Weight (kg)', '', '', '', '', _totalWeight],
        ['Total Revenue (Rs)', '', '', '', '', _totalMoney],
      ];

      String csvContent = Csv().encode(csvData);
      
      await Clipboard.setData(ClipboardData(text: csvContent));
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sales_records_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
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

    final accentColor = isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkSecondaryGreen.withValues(alpha: 0.3) : Colors.grey.shade200,
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
                  'Total Weight',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_totalMoney.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Sales'),
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Records',
            onPressed: _showExportOptions,
          ),
        ],
      ),
      bottomNavigationBar: _buildSummaryPanel(isDark),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                ),
                filled: true,
                fillColor: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterOrders();
              },
            ),
          ),

          // Status Filter Chips
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStatusChip('Active', isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Completed', isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Cancelled', isDark),
              ],
            ),
          ),

          // Orders Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredOrders.length} Orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? SkeletonLoader.list()
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Orders from buyers will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: AppTheme.primaryGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _filterOrders();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
              : (isDark ? AppTheme.darkCardSurface : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                : (isDark
                    ? AppTheme.darkSecondaryGreen.withValues(alpha: 0.3)
                    : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppTheme.darkBackground : Colors.white)
                  : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDark) {
    final materialColor = _getMaterialColor(order.materialType);
    final statusColor = _getStatusColor(order.status);

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
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.darkSecondaryGreen.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Material Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: materialColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _getImageProvider(order.imageUrl, order.materialType),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Order Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.materialTypeDisplay,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.toString().padLeft(5, '0')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor['background'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor['text'],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Buyer Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray,
                    child: Icon(Icons.person, size: 18, color: isDark ? Colors.white : Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buyer',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                        Text(
                          order.buyerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.buyer?.contactNo != null)
                    IconButton(
                      icon: Icon(Icons.phone, color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen),
                      onPressed: () {
                        // Show contact info
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contact: ${order.buyer!.contactNo}')),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Weight and Date
            Row(
              children: [
                Icon(
                  Icons.scale,
                  size: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.weight} kg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, y').format(order.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Payment Method
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  order.paymentMethodDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Total ',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      'Rs ${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Chat message preview and unread count badge
            if (order.chat != null && order.chat!.lastMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.chat!.lastMessage!.messageType == 'SYSTEM'
                            ? '[System] ${order.chat!.lastMessage!.content}'
                            : order.chat!.lastMessage!.content,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
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

            // Action Buttons (only for active orders)
            if (order.status == 'CREATED' ||
                order.status == 'CONFIRMED' ||
                order.status == 'PENDING' ||
                order.status == 'COLLECTED' ||
                order.status == 'WAREHOUSE_ASSIGNED' ||
                order.status == 'WAITING_FOR_DISPATCH' ||
                order.status == 'COLLECTOR_ASSIGNED' ||
                order.status == 'COLLECTOR_ACCEPTED' ||
                order.status == 'TRAVELLING_TO_SELLER' ||
                order.status == 'ARRIVED_AT_PICKUP' ||
                order.status == 'MATERIAL_VERIFIED' ||
                order.status == 'PICKED_UP' ||
                order.status == 'IN_TRANSIT' ||
                order.status == 'ARRIVED_AT_BUYER' ||
                order.status == 'BUYER_VERIFICATION' ||
                order.status == 'DELIVERED' ||
                order.status == 'PROCESSING' ||
                order.status == 'SHIPPED') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (order.status == 'CREATED')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmOrder(order),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Confirm Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (order.status == 'PENDING')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateOrderStatus(order, 'COLLECTED'),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark Collected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          side: BorderSide(
                            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (order.status == 'COLLECTED' ||
                      (order.status == 'CONFIRMED' && order.deliveryMethod == 'SELF_TRANSPORTATION')) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order, 'COMPLETED'),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateOrderStatus(order, 'CANCELLED'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
        return const Color(0xFF9E9E9E);
      case 'e-waste':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.primaryGreen;
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
          // Fallback
        }
      }
    }
    
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

  Map<String, Color> _getStatusColor(String status) {
    switch (status.trim().toUpperCase()) {
      case 'CREATED':
      case 'PENDING':
        return {
          'background': const Color(0xFFFFF3E0),
          'text': const Color(0xFFF57C00),
        };
      case 'CONFIRMED':
      case 'PROCESSING':
      case 'SHIPPED':
      case 'DELIVERED':
      case 'COLLECTED':
      case 'WAREHOUSE_ASSIGNED':
      case 'WAITING_FOR_DISPATCH':
      case 'COLLECTOR_ASSIGNED':
      case 'COLLECTOR_ACCEPTED':
      case 'TRAVELLING_TO_SELLER':
      case 'ARRIVED_AT_PICKUP':
      case 'MATERIAL_VERIFIED':
      case 'PICKED_UP':
      case 'IN_TRANSIT':
      case 'ARRIVED_AT_BUYER':
      case 'BUYER_VERIFICATION':
        return {
          'background': const Color(0xFFE3F2FD),
          'text': const Color(0xFF1976D2),
        };
      case 'COMPLETED':
        return {
          'background': const Color(0xFFE8F5E9),
          'text': const Color(0xFF388E3C),
        };
      case 'CANCELLED':
      case 'WAREHOUSE_REJECTED':
      case 'COLLECTOR_DECLINED':
      case 'BUYER_CANCELLED':
      case 'SELLER_CANCELLED':
      case 'DELIVERY_FAILED':
      case 'REFUND_INITIATED':
        return {
          'background': const Color(0xFFFFEBEE),
          'text': const Color(0xFFD32F2F),
        };
      default:
        return {
          'background': Colors.grey.shade100,
          'text': Colors.grey.shade700,
        };
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.trim().toUpperCase()) {
      case 'CREATED':
      case 'PENDING':
        return 'Pending';
      case 'COLLECTED':
        return 'Collected';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
      case 'BUYER_CANCELLED':
      case 'SELLER_CANCELLED':
        return 'Cancelled';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'WAREHOUSE_ASSIGNED':
        return 'Warehouse Assigned';
      case 'WAITING_FOR_DISPATCH':
        return 'Waiting for Dispatch';
      case 'COLLECTOR_ASSIGNED':
        return 'Collector Assigned';
      case 'COLLECTOR_ACCEPTED':
        return 'Collector Accepted';
      case 'TRAVELLING_TO_SELLER':
        return 'Travelling to Seller';
      case 'ARRIVED_AT_PICKUP':
        return 'Arrived at Pickup';
      case 'MATERIAL_VERIFIED':
        return 'Material Verified';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'IN_TRANSIT':
        return 'In Transit';
      case 'ARRIVED_AT_BUYER':
        return 'Arrived at Buyer';
      case 'BUYER_VERIFICATION':
        return 'Buyer Verification';
      case 'DELIVERED':
        return 'Delivered';
      case 'PROCESSING':
        return 'Processing';
      case 'SHIPPED':
        return 'Shipped';
      case 'WAREHOUSE_REJECTED':
        return 'Warehouse Rejected';
      case 'COLLECTOR_DECLINED':
        return 'Collector Declined';
      case 'DELIVERY_FAILED':
        return 'Delivery Failed';
      case 'REFUND_INITIATED':
        return 'Refund Initiated';
      default:
        return status;
    }
  }
}
