import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/utils/static_data.dart';
import 'create_listing_screen.dart';

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
      // Load listings with filters
      final result = await _listingService.getListings(
        material: _filterMaterial,
        status: _filterStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      // Load stats
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings (DEBUG MODE)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadListings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildStatsCard(),
                  _buildSearchBar(),
                  if (_filterMaterial != null || _filterStatus != null)
                    _buildActiveFilters(),
                  Expanded(
                    child: _listings.isEmpty
                        ? _buildEmptyState()
                        : _buildListingsList(),
                  ),
                  if (_totalPages > 1) _buildPagination(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateListingScreen()),
          );
          // Refresh listings if a new listing was created
          if (result == true) {
            _loadListings();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total',
              '${_stats!['totalListings'] ?? 0}',
              Icons.list_alt,
            ),
            _buildStatItem(
              'Pending',
              '${_stats!['pendingCount'] ?? 0}',
              Icons.pending,
            ),
            _buildStatItem(
              'Weight Sold',
              '${(_stats!['totalWeight'] ?? 0).toStringAsFixed(1)} kg',
              Icons.scale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.green),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search listings...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        onSubmitted: (_) => _loadListings(),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterMaterial != null)
            Chip(
              label: Text('Material: ${_filterMaterial!.toUpperCase()}'),
              onDeleted: () {
                setState(() => _filterMaterial = null);
                _loadListings();
              },
            ),
          if (_filterStatus != null)
            Chip(
              label: Text('Status: $_filterStatus'),
              onDeleted: () {
                setState(() => _filterStatus = null);
                _loadListings();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildListingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return _buildListingCard(listing);
      },
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMaterialColor(listing.materialType),
          child: Text(StaticDataHelper.getMaterialIcon(listing.materialType)),
        ),
        title: Text(
          '${listing.materialTypeDisplay} - ${listing.estimatedWeight} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(listing.pickupAddress),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(listing.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(
                listing.statusDisplay,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: _getStatusColor(listing.status),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
        onTap: () => _showListingDetails(listing),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first listing to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadListings();
                  }
                : null,
          ),
          Text('Page $_currentPage of $_totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadListings();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          TextButton(
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

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export to CSV'),
        content: const Text('Export your listings to a CSV file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final url = _listingService.getExportUrl(
                material: _filterMaterial,
                status: _filterStatus,
              );
              // In a real app, use url_launcher or download package
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature: use url_launcher package')),
              );
              Navigator.pop(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(Listing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${listing.materialTypeDisplay} Listing'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Weight', '${listing.estimatedWeight} kg'),
              _buildDetailRow('Status', listing.statusDisplay),
              _buildDetailRow('Address', listing.pickupAddress),
              if (listing.latitude != null)
                _buildDetailRow('Location', '${listing.latitude!.toStringAsFixed(4)}, ${listing.longitude!.toStringAsFixed(4)}'),
              _buildDetailRow('Created', DateFormat('MMM dd, yyyy').format(listing.createdAt)),
              if (listing.notes != null && listing.notes!.isNotEmpty)
                _buildDetailRow('Notes', listing.notes!),
            ],
          ),
        ),
        actions: [
          if (listing.status == 'PENDING')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteListing(listing.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getMaterialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Colors.green.shade100;
      case 'paper':
        return Colors.orange.shade100;
      case 'metal':
        return Colors.grey.shade200;
      case 'e-waste':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange.shade100;
      case 'COLLECTED':
        return Colors.blue.shade100;
      case 'COMPLETED':
        return Colors.green.shade100;
      case 'CANCELLED':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
