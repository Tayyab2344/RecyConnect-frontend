import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/listing_model.dart';

class ExportHelper {
  /// Builds a stat card widget inside the PDF document layout.
  static pw.Widget _buildPdfStatCard(String title, String value) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F0FCF4'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#E0F5E9')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2E7D32')),
          ),
        ],
      ),
    );
  }

  /// Exports a list of sell listings to a CSV file and opens the share dialog.
  static Future<void> exportListingsToCsv(List<Listing> listings) async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'Listing ID',
      'Title',
      'Material Type',
      'Weight (kg)',
      'Status',
      'Pickup Address',
      'Created Date'
    ]);

    for (final listing in listings) {
      rows.add([
        listing.id,
        listing.displayTitle,
        listing.materialTypeDisplay,
        listing.displayWeight,
        listing.statusDisplay,
        listing.pickupAddress,
        DateFormat('yyyy-MM-dd HH:mm').format(listing.createdAt),
      ]);
    }

    final csvString = Csv().encode(rows);
    final bytes = const Utf8Encoder().convert(csvString);

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'listings_report.csv',
    );
  }

  /// Exports a list of sell listings to a PDF document and opens the print preview dialog.
  static Future<void> exportListingsToPdf(List<Listing> listings) async {
    final pdf = pw.Document();
    final totalWeight = listings.fold<double>(0.0, (sum, item) => sum + item.displayWeight);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RecyConnect',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#4CAF50'),
                      ),
                    ),
                    pw.Text(
                      'Sustainable Recycling Platform',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'SELL ITEMS REPORT',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Stat Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildPdfStatCard('Total Listings', listings.length.toString()),
                _buildPdfStatCard('Total Weight', '${totalWeight.toStringAsFixed(1)} kg'),
                _buildPdfStatCard('Active Listings', listings.where((l) => l.status == 'PUBLISHED').length.toString()),
              ],
            ),
            pw.SizedBox(height: 20),

            // Table of Listings
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Title', 'Material', 'Weight (kg)', 'Status', 'Date'],
              data: listings.map((l) => [
                '#L0${l.id}',
                l.displayTitle,
                l.materialTypeDisplay,
                l.displayWeight.toStringAsFixed(1),
                l.statusDisplay,
                DateFormat('yyyy-MM-dd').format(l.createdAt),
              ]).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#4CAF50')),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 9),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Exports warehouse inventory to a CSV file and opens the share dialog.
  static Future<void> exportInventoryToCsv(List<dynamic> items) async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'Material Type',
      'Category',
      'Stock (kg)',
      'Purchase Price (PKR/kg)',
      'Selling Price (PKR/kg)',
      'Total Value (PKR)',
      'Location',
      'Notes'
    ]);

    for (final item in items) {
      final qty = (item['quantityInStock'] as num).toDouble();
      final sell = (item['sellingPrice'] as num).toDouble();
      rows.add([
        item['materialType'].toString().toUpperCase(),
        item['category'] ?? '',
        qty,
        item['purchasePrice'] ?? 0.0,
        sell,
        qty * sell,
        item['location'] ?? '',
        item['notes'] ?? '',
      ]);
    }

    final csvString = Csv().encode(rows);
    final bytes = const Utf8Encoder().convert(csvString);

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'inventory_report.csv',
    );
  }

  /// Exports warehouse inventory to a PDF document and opens the print preview dialog.
  static Future<void> exportInventoryToPdf(List<dynamic> items) async {
    final pdf = pw.Document();

    final totalItems = items.length;
    final totalValue = items.fold<double>(0.0, (sum, item) {
      final qty = (item['quantityInStock'] as num).toDouble();
      final sell = (item['sellingPrice'] as num).toDouble();
      return sum + (qty * sell);
    });
    final lowStockItems = items.where((item) {
      final qty = (item['quantityInStock'] as num).toDouble();
      final reorder = (item['reorderLevel'] ?? 0.0).toDouble();
      return qty <= reorder;
    }).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RecyConnect ERP',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#4CAF50'),
                      ),
                    ),
                    pw.Text(
                      'Warehouse Management System',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'INVENTORY STATUS REPORT',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Stat Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildPdfStatCard('Total Items', totalItems.toString()),
                _buildPdfStatCard('Low Stock Alert', lowStockItems.toString()),
                _buildPdfStatCard('Inventory Value', 'PKR ${totalValue.toStringAsFixed(0)}'),
              ],
            ),
            pw.SizedBox(height: 20),

            // Table of Inventory
            pw.TableHelper.fromTextArray(
              headers: ['Material', 'Category', 'Stock (kg)', 'Buy (PKR)', 'Sell (PKR)', 'Value (PKR)', 'Location'],
              data: items.map((item) {
                final qty = (item['quantityInStock'] as num).toDouble();
                final buy = (item['purchasePrice'] as num).toDouble();
                final sell = (item['sellingPrice'] as num).toDouble();
                final val = qty * sell;
                return [
                  item['materialType'].toString().toUpperCase(),
                  item['category'] ?? '',
                  qty.toStringAsFixed(1),
                  buy.toStringAsFixed(0),
                  sell.toStringAsFixed(0),
                  val.toStringAsFixed(0),
                  item['location'] ?? 'N/A',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#4CAF50')),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 9),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
