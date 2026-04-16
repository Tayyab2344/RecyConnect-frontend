import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/utils/static_data.dart';
import '../../widgets/marketplace/glass_card.dart';
import '../../widgets/recycle_loader.dart';
import '../../../core/theme/marketplace_theme.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final ListingService _listingService = ListingService();

  List<Listing> _listings = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  
  String? _filterMaterial;
  String? _filterStatus;
  String _searchQuery = '';
  
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _listingService.getListings(
        material: _filterMaterial,
        status: _filterStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      final stats = await _listingService.getListingStats();

      setState(() {
        _listings = result['listings'];
        _stats = stats;
        _totalPages = result['pagination']['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading listings: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteListing(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _listingService.deleteListing(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted successfully')),
          );
        }
        _loadListings();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'My Listings',
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
        leading: Navigator.canPop(context) ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ) : null,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
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
            child: RefreshIndicator(
              onRefresh: _loadListings,
              child: _isLoading
                  ? RecycleLoader.centered()
                  : Column(
                      children: [
                        _buildStatsCard(isDark),
                        _buildSearchBar(isDark),
                        if (_filterMaterial != null || _filterStatus != null)
                          _buildActiveFilters(isDark),
                        Expanded(
                          child: _listings.isEmpty
                              ? _buildEmptyState(isDark)
                              : _buildListingsGrid(isDark),
                        ),
                        if (_totalPages > 1) _buildPagination(isDark),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateListingScreen()),
          );
          if (result == true) {
            _loadListings();
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Listing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    if (_stats == null) return const SizedBox.shrink();

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Total', '${_stats!['totalListings'] ?? 0}', Icons.inventory_2_outlined, isDark),
          Container(width: 1, height: 40, color: isDark ? Colors.white24 : Colors.black12),
          _buildStatItem('Pending', '${_stats!['pendingCount'] ?? 0}', Icons.hourglass_empty, isDark),
          Container(width: 1, height: 40, color: isDark ? Colors.white24 : Colors.black12),
          _buildStatItem('Sold (kg)', '${(_stats!['totalWeight'] ?? 0).toStringAsFixed(1)}', Icons.scale_outlined, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Search your listings...',
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
            icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black38),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
          onSubmitted: (_) => _loadListings(),
        ),
      ),
    );
  }

  Widget _buildActiveFilters(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_filterMaterial != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                label: Text(
                  'Material: ${_filterMaterial!.toUpperCase()}', 
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2E7D32)),
                ),
                deleteIcon: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : const Color(0xFF2E7D32)),
                onDeleted: () {
                  setState(() => _filterMaterial = null);
                  _loadListings();
                },
              ),
            ),
          if (_filterStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                backgroundColor: Colors.blue.withOpacity(0.2),
                label: Text(
                  'Status: $_filterStatus', 
                  style: TextStyle(color: isDark ? Colors.white : Colors.blue[800]),
                ),
                deleteIcon: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.blue[800]),
                onDeleted: () {
                  setState(() => _filterStatus = null);
                  _loadListings();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListingsGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return _buildListingCard(listing, isDark);
      },
    );
  }

  Widget _buildListingCard(Listing listing, bool isDark) {
    return GestureDetector(
      onTap: () => _showListingDetails(listing),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Badge
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(listing.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(listing.status).withOpacity(0.5)),
                    ),
                    child: Text(
                      listing.statusDisplay,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(listing.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Image or Icon
            Expanded(
              child: listing.hasNetworkImages
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        listing.imageUrls.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _getMaterialColor(listing.materialType),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getMaterialColor(listing.materialType).withOpacity(0.15),
                            ),
                            child: Text(
                              StaticDataHelper.getMaterialIcon(listing.materialType),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                    )
                  : listing.decodedImages.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.memory(
                            listing.decodedImages.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _getMaterialColor(listing.materialType).withOpacity(0.3),
                                  _getMaterialColor(listing.materialType).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Text(
                              StaticDataHelper.getMaterialIcon(listing.materialType),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.materialTypeDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getMaterialColor(listing.materialType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.scale, size: 14, color: isDark ? Colors.white60 : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.estimatedWeight} kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today, size: 12, color: isDark ? Colors.white60 : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd').format(listing.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey[600],
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
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined, 
            size: 80, 
            color: isDark ? Colors.white24 : Colors.black12
          ),
          const SizedBox(height: 16),
          Text(
            'No listings found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first item to start selling!',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 16, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: _currentPage > 1 ? () => setState(() { _currentPage--; _loadListings(); }) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: _currentPage < _totalPages ? () => setState(() { _currentPage++; _loadListings(); }) : null,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Keep existing implementation but styled better if needed
    // For brevity, reusing standard dialog but could be GlassDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Filter Listings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Material'),
              value: _filterMaterial,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...MaterialData.materialTypes.map((m) =>
                    DropdownMenuItem(value: m, child: Text(m.toUpperCase()))),
              ],
              onChanged: (value) => setState(() => _filterMaterial = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status'),
              value: _filterStatus,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...StatusData.listingStatuses.map((s) =>
                    DropdownMenuItem(value: s, child: Text(s))),
              ],
              onChanged: (value) => setState(() => _filterStatus = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterMaterial = null;
                _filterStatus = null;
              });
              Navigator.pop(context);
              _loadListings();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _loadListings();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(Listing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(
          listing: listing,
          onDelete: () {
            Navigator.pop(context);
            _deleteListing(listing.id);
          },
        ),
      ),
    );
  }

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
}
