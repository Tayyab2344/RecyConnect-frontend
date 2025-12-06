import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/admin_colors.dart';
import '../../../core/constants/modern_colors.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_collector_details_screen.dart';

// CollectorData Model
class CollectorData {
  final String id;
  final String name;
  final String contact;
  final String warehouseName;
  final String area;
  final double rating; // 1.0 to 5.0
  final int totalPickups;
  final int performancePercent; // 0 to 100
  final String status; // 'active', 'inactive', 'on_leave'
  final DateTime joinedDate;

  CollectorData({
    required this.id,
    required this.name,
    required this.contact,
    required this.warehouseName,
    required this.area,
    required this.rating,
    required this.totalPickups,
    required this.performancePercent,
    required this.status,
    required this.joinedDate,
  });

  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class AdminCollectorsScreen extends StatefulWidget {
  const AdminCollectorsScreen({super.key});

  @override
  State<AdminCollectorsScreen> createState() => _AdminCollectorsScreenState();
}

class _AdminCollectorsScreenState extends State<AdminCollectorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';
  String? _selectedSortOption;
  List<CollectorData> _allCollectors = [];
  List<CollectorData> _filteredCollectors = [];

  @override
  void initState() {
    super.initState();
    _generateDummyCollectors();
    _filteredCollectors = List.from(_allCollectors);
  }

  void _generateDummyCollectors() {
    _allCollectors = [
      CollectorData(
        id: 'COL001',
        name: 'Ahmed Khan',
        contact: '+92-300-1234567',
        warehouseName: 'Green Warehouse',
        area: 'Downtown',
        rating: 4.8,
        totalPickups: 245,
        performancePercent: 95,
        status: 'active',
        joinedDate: DateTime(2023, 3, 15),
      ),
      CollectorData(
        id: 'COL002',
        name: 'Fatima Ali',
        contact: '+92-301-2345678',
        warehouseName: 'EcoHub',
        area: 'Uptown',
        rating: 4.5,
        totalPickups: 189,
        performancePercent: 88,
        status: 'active',
        joinedDate: DateTime(2023, 6, 20),
      ),
      CollectorData(
        id: 'COL003',
        name: 'Hassan Raza',
        contact: '+92-302-3456789',
        warehouseName: 'RecyclePoint',
        area: 'Westside',
        rating: 3.2,
        totalPickups: 67,
        performancePercent: 65,
        status: 'inactive',
        joinedDate: DateTime(2024, 1, 10),
      ),
      CollectorData(
        id: 'COL004',
        name: 'Zara Sheikh',
        contact: '+92-303-4567890',
        warehouseName: 'ABC Warehouse',
        area: 'Eastend',
        rating: 4.9,
        totalPickups: 312,
        performancePercent: 98,
        status: 'active',
        joinedDate: DateTime(2023, 2, 5),
      ),
      CollectorData(
        id: 'COL005',
        name: 'Bilal Ahmed',
        contact: '+92-304-5678901',
        warehouseName: 'CleanCity Hub',
        area: 'Northgate',
        rating: 4.2,
        totalPickups: 156,
        performancePercent: 82,
        status: 'active',
        joinedDate: DateTime(2023, 8, 12),
      ),
      CollectorData(
        id: 'COL006',
        name: 'Ayesha Malik',
        contact: '+92-305-6789012',
        warehouseName: 'Green Warehouse',
        area: 'Southside',
        rating: 4.6,
        totalPickups: 203,
        performancePercent: 91,
        status: 'active',
        joinedDate: DateTime(2023, 5, 18),
      ),
      CollectorData(
        id: 'COL007',
        name: 'Usman Tariq',
        contact: '+92-306-7890123',
        warehouseName: 'EcoHub',
        area: 'Downtown',
        rating: 3.8,
        totalPickups: 98,
        performancePercent: 72,
        status: 'active',
        joinedDate: DateTime(2024, 2, 28),
      ),
      CollectorData(
        id: 'COL008',
        name: 'Sara Qureshi',
        contact: '+92-307-8901234',
        warehouseName: 'WasteWise Center',
        area: 'Uptown',
        rating: 4.4,
        totalPickups: 178,
        performancePercent: 86,
        status: 'active',
        joinedDate: DateTime(2023, 9, 7),
      ),
      CollectorData(
        id: 'COL009',
        name: 'Imran Hussain',
        contact: '+92-308-9012345',
        warehouseName: 'RecyclePoint',
        area: 'Westside',
        rating: 2.9,
        totalPickups: 45,
        performancePercent: 55,
        status: 'inactive',
        joinedDate: DateTime(2024, 4, 15),
      ),
      CollectorData(
        id: 'COL010',
        name: 'Nadia Hassan',
        contact: '+92-309-0123456',
        warehouseName: 'GreenEarth Depot',
        area: 'Eastend',
        rating: 4.7,
        totalPickups: 225,
        performancePercent: 93,
        status: 'active',
        joinedDate: DateTime(2023, 4, 22),
      ),
      CollectorData(
        id: 'COL011',
        name: 'Ali Raza',
        contact: '+92-310-1234567',
        warehouseName: 'ABC Warehouse',
        area: 'Northgate',
        rating: 3.5,
        totalPickups: 89,
        performancePercent: 68,
        status: 'on_leave',
        joinedDate: DateTime(2024, 3, 8),
      ),
      CollectorData(
        id: 'COL012',
        name: 'Hina Butt',
        contact: '+92-311-2345678',
        warehouseName: 'CleanCity Hub',
        area: 'Southside',
        rating: 4.3,
        totalPickups: 167,
        performancePercent: 84,
        status: 'active',
        joinedDate: DateTime(2023, 7, 30),
      ),
      CollectorData(
        id: 'COL013',
        name: 'Kamran Shah',
        contact: '+92-312-3456789',
        warehouseName: 'Green Warehouse',
        area: 'Downtown',
        rating: 5.0,
        totalPickups: 350,
        performancePercent: 99,
        status: 'active',
        joinedDate: DateTime(2023, 1, 5),
      ),
      CollectorData(
        id: 'COL014',
        name: 'Rabia Noor',
        contact: '+92-313-4567890',
        warehouseName: 'EcoHub',
        area: 'Uptown',
        rating: 4.1,
        totalPickups: 134,
        performancePercent: 79,
        status: 'active',
        joinedDate: DateTime(2023, 10, 14),
      ),
      CollectorData(
        id: 'COL015',
        name: 'Farhan Iqbal',
        contact: '+92-314-5678901',
        warehouseName: 'WasteWise Center',
        area: 'Westside',
        rating: 2.5,
        totalPickups: 32,
        performancePercent: 50,
        status: 'inactive',
        joinedDate: DateTime(2024, 5, 20),
      ),
      CollectorData(
        id: 'COL016',
        name: 'Sana Riaz',
        contact: '+92-315-6789012',
        warehouseName: 'GreenEarth Depot',
        area: 'Eastend',
        rating: 4.0,
        totalPickups: 145,
        performancePercent: 77,
        status: 'active',
        joinedDate: DateTime(2023, 11, 3),
      ),
      CollectorData(
        id: 'COL017',
        name: 'Waqas Ali',
        contact: '+92-316-7890123',
        warehouseName: 'RecyclePoint',
        area: 'Northgate',
        rating: 3.9,
        totalPickups: 112,
        performancePercent: 74,
        status: 'active',
        joinedDate: DateTime(2024, 1, 25),
      ),
      CollectorData(
        id: 'COL018',
        name: 'Maria Khan',
        contact: '+92-317-8901234',
        warehouseName: 'ABC Warehouse',
        area: 'Southside',
        rating: 4.8,
        totalPickups: 267,
        performancePercent: 96,
        status: 'active',
        joinedDate: DateTime(2023, 3, 28),
      ),
      CollectorData(
        id: 'COL019',
        name: 'Junaid Aslam',
        contact: '+92-318-9012345',
        warehouseName: 'CleanCity Hub',
        area: 'Downtown',
        rating: 2.1,
        totalPickups: 25,
        performancePercent: 52,
        status: 'inactive',
        joinedDate: DateTime(2024, 6, 10),
      ),
      CollectorData(
        id: 'COL020',
        name: 'Amna Yousaf',
        contact: '+92-319-0123456',
        warehouseName: 'Green Warehouse',
        area: 'Uptown',
        rating: 4.5,
        totalPickups: 198,
        performancePercent: 89,
        status: 'active',
        joinedDate: DateTime(2023, 6, 15),
      ),
      CollectorData(
        id: 'COL021',
        name: 'Tahir Mehmood',
        contact: '+92-320-1234567',
        warehouseName: 'EcoHub',
        area: 'Westside',
        rating: 3.6,
        totalPickups: 87,
        performancePercent: 70,
        status: 'on_leave',
        joinedDate: DateTime(2024, 2, 14),
      ),
      CollectorData(
        id: 'COL022',
        name: 'Zainab Fatima',
        contact: '+92-321-2345678',
        warehouseName: 'WasteWise Center',
        area: 'Eastend',
        rating: 4.6,
        totalPickups: 210,
        performancePercent: 90,
        status: 'active',
        joinedDate: DateTime(2023, 8, 5),
      ),
      CollectorData(
        id: 'COL023',
        name: 'Asad Rafiq',
        contact: '+92-322-3456789',
        warehouseName: 'GreenEarth Depot',
        area: 'Northgate',
        rating: 3.3,
        totalPickups: 76,
        performancePercent: 62,
        status: 'inactive',
        joinedDate: DateTime(2024, 4, 2),
      ),
      CollectorData(
        id: 'COL024',
        name: 'Mehwish Hayat',
        contact: '+92-323-4567890',
        warehouseName: 'RecyclePoint',
        area: 'Southside',
        rating: 4.4,
        totalPickups: 183,
        performancePercent: 85,
        status: 'active',
        joinedDate: DateTime(2023, 9, 20),
      ),
      CollectorData(
        id: 'COL025',
        name: 'Danish Taimoor',
        contact: '+92-324-5678901',
        warehouseName: 'ABC Warehouse',
        area: 'Downtown',
        rating: 4.9,
        totalPickups: 298,
        performancePercent: 97,
        status: 'active',
        joinedDate: DateTime(2023, 2, 18),
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<CollectorData> result = List.from(_allCollectors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((collector) {
        return collector.name.toLowerCase().contains(query) ||
            collector.contact.toLowerCase().contains(query) ||
            collector.warehouseName.toLowerCase().contains(query) ||
            collector.area.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    if (_selectedSortOption != null) {
      switch (_selectedSortOption!) {
        case 'rating_high':
          result.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'rating_low':
          result.sort((a, b) => a.rating.compareTo(b.rating));
          break;
        case 'newest':
          result.sort((a, b) => b.joinedDate.compareTo(a.joinedDate));
          break;
        case 'oldest':
          result.sort((a, b) => a.joinedDate.compareTo(b.joinedDate));
          break;
      }
    }

    setState(() {
      _filteredCollectors = result;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
        _applyFilters();
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _applyFilters();
  }

  String _getFilterLabel(String? option) {
    switch (option) {
      case 'rating_high':
        return 'High Rating';
      case 'rating_low':
        return 'Low Rating';
      case 'newest':
        return 'Newest Collector';
      case 'oldest':
        return 'Oldest Collector';
      default:
        return 'None';
    }
  }

  void _applySort(String sortBy) {
    setState(() {
      _selectedSortOption = sortBy;
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sorted by: ${_getFilterLabel(sortBy)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetSort() {
    setState(() {
      _selectedSortOption = null;
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Filter cleared', style: TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: AdminColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _generateDummyCollectors();
      _applyFilters();
    });
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) {
      return const Color(0xFFFBBF24); // Gold/Yellow
    } else if (rating >= 3.5) {
      return AdminColors.success; // Green
    } else if (rating >= 2.5) {
      return AdminColors.accentOrange; // Orange
    } else {
      return AdminColors.error; // Red
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AdminColors.success;
      case 'inactive':
        return AdminColors.error;
      case 'on_leave':
        return AdminColors.accentOrange;
      default:
        return AdminColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'on_leave':
        return 'On Leave';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.cancel;
      case 'on_leave':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Collectors Management',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: theme.appBarTheme.foregroundColor),
            tooltip: 'Filter Collectors',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: theme.cardColor,
            onSelected: (value) {
              if (value == 'reset') {
                _resetSort();
              } else {
                _applySort(value);
              }
            },
            itemBuilder: (BuildContext context) => [
              // Header
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              const PopupMenuDivider(),

              // RATING Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                    SizedBox(width: 8),
                    Text('Rating',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'rating_high',
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('High Rating')),
                    if (_selectedSortOption == 'rating_high')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'rating_low',
                child: Row(
                  children: [
                    const Icon(Icons.star_border, color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Low Rating')),
                    if (_selectedSortOption == 'rating_low')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // JOIN DATE Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AdminColors.accentPurple),
                    SizedBox(width: 8),
                    Text('Join Date',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'newest',
                child: Row(
                  children: [
                    const Icon(Icons.new_releases, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Newest Collector')),
                    if (_selectedSortOption == 'newest')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'oldest',
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Oldest Collector')),
                    if (_selectedSortOption == 'oldest')
                      const Icon(Icons.check, color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // RESET Option
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AdminColors.error, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Clear Filter',
                      style: TextStyle(
                        color: AdminColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: 'collectors'),
      body: Column(
        children: [
          // Search Bar (toggleable)
          if (_isSearchVisible)
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by name, contact, or warehouse...',
                  hintStyle: const TextStyle(
                    color: AdminColors.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AdminColors.primaryGreen,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AdminColors.textLight,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AdminColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

          // Collector Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AdminColors.surfaceLight,
            child: Text(
              '${_filteredCollectors.length} ${_filteredCollectors.length == 1 ? 'Collector' : 'Collectors'} Found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.textSecondary,
              ),
            ),
          ),

          // Filter Indicator Banner
          if (_selectedSortOption != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withOpacity(0.1),
                border: const Border(
                  bottom: BorderSide(color: AdminColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt,
                      size: 18, color: AdminColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sorted by: ${_getFilterLabel(_selectedSortOption)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AdminColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetSort,
                    icon: const Icon(Icons.close, size: 16, color: AdminColors.error),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: AdminColors.error, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

          // Collector Cards List
          Expanded(
            child: _filteredCollectors.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AdminColors.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCollectors.length,
                      itemBuilder: (context, index) {
                        final collector = _filteredCollectors[index];
                        return _buildCollectorCard(collector);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorCard(CollectorData collector) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: ModernColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: Avatar, Name, Rating Badge
            Row(
              children: [
                // Modern Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    gradient: ModernColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping,
                        color: AdminColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collector.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(collector.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(collector.status),
                            size: 12,
                            color: _getStatusColor(collector.status),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(collector.status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(collector.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRatingColor(collector.rating).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: _getRatingColor(collector.rating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      collector.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(collector.rating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // MIDDLE SECTION: Contact Info
          _buildInfoRow(Icons.phone, 'Contact', collector.contact),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.warehouse, 'Warehouse', collector.warehouseName),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Area', collector.area),

          const SizedBox(height: 16),

          // BOTTOM SECTION: Stats Row (3 boxes)
          Row(
            children: [
              // Total Pickups
              Expanded(
                child: _buildStatBox(
                  icon: Icons.inventory_2,
                  iconColor: AdminColors.success,
                  value: collector.totalPickups.toString(),
                  label: 'Pickups',
                ),
              ),
              const SizedBox(width: 8),
              // Performance
              Expanded(
                child: _buildStatBox(
                  icon: Icons.analytics,
                  iconColor: AdminColors.accentBlue,
                  value: '${collector.performancePercent}%',
                  label: 'Performance',
                ),
              ),
              const SizedBox(width: 8),
              // Joined Date
              Expanded(
                child: _buildStatBox(
                  icon: Icons.calendar_today,
                  iconColor: AdminColors.accentPurple,
                  value: DateFormat('MMM yy').format(collector.joinedDate),
                  label: 'Joined',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminCollectorDetailsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminColors.textLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AdminColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AdminColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80,
            color: AdminColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No collectors found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
                                                                              