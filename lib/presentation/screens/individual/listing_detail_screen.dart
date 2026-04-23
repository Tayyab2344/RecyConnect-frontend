import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/theme/marketplace_theme.dart';
import '../../../core/utils/static_data.dart';
import '../../widgets/marketplace/glass_card.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  final VoidCallback onDelete;

  const ListingDetailScreen({
    Key? key,
    required this.listing,
    required this.onDelete,
  }) : super(key: key);

  Color _getMaterialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plastic': return Colors.orange;
      case 'paper': return Colors.blue;
      case 'metal': return Colors.grey;
      case 'e-waste': return Colors.purple;
      case 'glass': return Colors.cyan;
      default: return Colors.green;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'COLLECTED': return Colors.blue;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Listing Details',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (listing.status == 'PENDING')
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: onDelete,
              tooltip: 'Delete Listing',
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F1F19), const Color(0xFF1B3A2F)]
                    : [const Color(0xFFF0FCF4), const Color(0xFFE0F5E9)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageHeader(context, isDark),
                    const SizedBox(height: 24),
                    _buildMainInfoCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildDetailsCard(context, isDark),
                    if (listing.notes != null && listing.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildNotesCard(context, isDark),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 250,
          width: double.infinity,
          color: _getMaterialColor(listing.materialType).withOpacity(0.1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (listing.hasNetworkImages)
                Image.network(
                  listing.imageUrls.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, p) => p == null 
                      ? child 
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                )
              else if (listing.decodedImages.isNotEmpty)
                Image.memory(
                  listing.decodedImages.first,
                  fit: BoxFit.cover,
                )
              else
                _buildFallbackIcon(),
              
              // Gradient overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              
              // Status Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(listing.status).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    listing.statusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              
              // Title on image
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Text(
                        StaticDataHelper.getMaterialIcon(listing.materialType),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        listing.displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Text(
        StaticDataHelper.getMaterialIcon(listing.materialType),
        style: const TextStyle(fontSize: 80),
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (listing.title != null && listing.title!.trim().isNotEmpty) ...[
            Text(
              'TITLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              listing.title!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 12),
          ],
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.category_outlined, 'Material', listing.materialTypeDisplay, isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.white24 : Colors.black12),
              _buildInfoItem(Icons.scale, 'Weight', '${listing.estimatedWeight} kg', isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.white24 : Colors.black12),
              _buildInfoItem(Icons.calendar_today, 'Date', DateFormat('MMM dd, yyyy').format(listing.createdAt), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LISTING DETAILS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on_outlined, 'Pickup Location', listing.pickupAddress, isDark),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.info_outline, 
            'Status', 
            listing.statusDisplay, 
            isDark,
            valueColor: _getStatusColor(listing.status),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.update, 
            'Last Updated', 
            DateFormat('MMM dd, yyyy – hh:mm a').format(listing.updatedAt), 
            isDark,
          ),
          if (listing.latitude != null && listing.longitude != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.pin_drop_outlined, 
              'Coordinates', 
              '${listing.latitude!.toStringAsFixed(4)}, ${listing.longitude!.toStringAsFixed(4)}', 
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            listing.notes!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
