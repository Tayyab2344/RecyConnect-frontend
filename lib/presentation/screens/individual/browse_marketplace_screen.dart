import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/marketplace_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/utils/static_data.dart';
import '../../widgets/marketplace/glass_card.dart';
import '../../widgets/marketplace/neon_button.dart';
import '../../widgets/skeleton_loader.dart';
import 'marketplace/item_detail_screen.dart';
import 'create_listing_screen.dart';

class BrowseMarketplaceScreen extends StatefulWidget {
  const BrowseMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BrowseMarketplaceScreen> createState() => _BrowseMarketplaceScreenState();
}

class _BrowseMarketplaceScreenState extends State<BrowseMarketplaceScreen> 
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  final ListingService _listingService = ListingService();
  List<Listing> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Hyperlocal filters
  String _selectedRadius = 'Within 10 km';
  String _selectedSort = 'Nearest First';
  String? _filterMaterial;
  String _searchQuery = '';
  bool _isMapView = false;
  String _currentCity = 'Abbottabad';
  String _currentArea = 'Jinnahabad';
  
  // Coordinates (User location: Abbottabad center)
  final LatLng _userLocation = const LatLng(34.1688, 73.2215);
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _activeMapCardIndex = 0;

  final List<String> _radiusOptions = [
    'Within 5 km',
    'Within 10 km',
    'Within 25 km',
    'Entire City',
    'Nearby Cities'
  ];

  final List<String> _sortOptions = [
    'Nearest First',
    'Best Price',
    'Most Trusted Seller',
    'Recently Listed',
    'AI Recommended'
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _listingService.getListings(
        material: _filterMaterial == 'All' ? null : _filterMaterial,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        isMarketplace: true,
      );

      if (mounted) {
        setState(() {
          _items = (result['listings'] as List<Listing>);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = ErrorMessageHelper.getUserFriendlyError(e);
        });
      }
    }
  }

  // Pre-configured mock local listings to ensure the screen is rich and populated
  List<Listing> _getMockListings() {
    return [
      Listing(
        id: 901,
        userId: 301,
        materialType: 'plastic',
        estimatedWeight: 15.0,
        pickupAddress: 'Jinnahabad, Abbottabad',
        latitude: 34.1725,
        longitude: 73.2185,
        title: 'Sorted HDPE Plastic Bottles',
        notes: 'Dry, cleaned water bottles, stored in boxes.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 301, name: 'Asif Mehmood'),
      ),
      Listing(
        id: 902,
        userId: 302,
        materialType: 'paper',
        estimatedWeight: 45.0,
        pickupAddress: 'Mandian, Abbottabad',
        latitude: 34.1950,
        longitude: 73.2420,
        title: 'Corrugated Cardboard Boxes',
        notes: 'Flattened carton boxes, excellent for recycling.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 302, name: 'Bilal Malik'),
      ),
      Listing(
        id: 903,
        userId: 303,
        materialType: 'metal',
        estimatedWeight: 12.5,
        pickupAddress: 'Cantonment, Abbottabad',
        latitude: 34.1620,
        longitude: 73.2260,
        title: 'Iron Scrap and Rods',
        notes: 'Construction waste, steel and iron rods.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 303, name: 'Sajid Ali'),
      ),
      Listing(
        id: 904,
        userId: 304,
        materialType: 'e-waste',
        estimatedWeight: 6.8,
        pickupAddress: 'Supply Area, Abbottabad',
        latitude: 34.1800,
        longitude: 73.2180,
        title: 'Computer Scrap (RAM, Motherboards)',
        notes: 'Assorted computer boards from workshop.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 304, name: 'Kashif Nazir'),
      ),
      Listing(
        id: 905,
        userId: 305,
        materialType: 'plastic',
        estimatedWeight: 32.0,
        pickupAddress: 'Kakul Road, Abbottabad',
        latitude: 34.1850,
        longitude: 73.2550,
        title: 'Crushed Plastic Cans',
        notes: 'HDPE food cans washed clean.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 305, name: 'Col. Tariq'),
      ),
      Listing(
        id: 906,
        userId: 306,
        materialType: 'paper',
        estimatedWeight: 22.0,
        pickupAddress: 'Haripur, KPK',
        latitude: 33.9998,
        longitude: 72.9344,
        title: 'Old Newspaper Bundles',
        notes: 'Stored in dry location, tied with ropes.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 306, name: 'Zia-ur-Rehman'),
      ),
      Listing(
        id: 907,
        userId: 307,
        materialType: 'metal',
        estimatedWeight: 5.5,
        pickupAddress: 'Mansehra, KPK',
        latitude: 34.3313,
        longitude: 73.2038,
        title: 'Aluminum Scrap Cans',
        notes: 'Crushed and bagged soda cans.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 307, name: 'Haris Khan'),
      ),
      Listing(
        id: 908,
        userId: 308,
        materialType: 'e-waste',
        estimatedWeight: 14.0,
        pickupAddress: 'G-11, Islamabad',
        latitude: 33.6844,
        longitude: 73.0479,
        title: 'Dead Laptop Batteries and Chargers',
        notes: 'Office clearance, bulk collection.',
        status: 'AVAILABLE',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        images: [],
        user: ListingUser(id: 308, name: 'Waseem Shah'),
      ),
    ];
  }

  // Calculate distance in km between user location and listing coordinates using Haversine formula
  double _calculateDistance(double lat, double lng) {
    const double userLat = 34.1688;
    const double userLng = 73.2215;
    
    var p = 0.017453292519943295;
    var a = 0.5 - math.cos((lat - userLat) * p)/2 + 
          math.cos(userLat * p) * math.cos(lat * p) * 
          (1 - math.cos((lng - userLng) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }

  // Assign coordinate positions dynamically to API listings if they are missing
  List<Listing> _processListings(List<Listing> rawListings) {
    return rawListings.map((item) {
      double? lat = item.latitude;
      double? lng = item.longitude;
      String address = item.pickupAddress.toLowerCase();
      
      if (lat == null || lng == null) {
        if (address.contains('jinnahabad')) {
          lat = 34.1725; lng = 73.2185;
        } else if (address.contains('cantonment') || address.contains('cantt')) {
          lat = 34.1620; lng = 73.2260;
        } else if (address.contains('supply')) {
          lat = 34.1800; lng = 73.2180;
        } else if (address.contains('mandian')) {
          lat = 34.1950; lng = 73.2420;
        } else if (address.contains('kakul')) {
          lat = 34.1850; lng = 73.2550;
        } else if (address.contains('haripur')) {
          lat = 33.9998; lng = 72.9344;
        } else if (address.contains('mansehra')) {
          lat = 34.3313; lng = 73.2038;
        } else if (address.contains('islamabad') || address.contains('g-11') || address.contains('f-7')) {
          lat = 33.6844; lng = 73.0479;
        } else {
          // Semi-random offset close to user to mock hyperlocal coordinates
          final seed = item.id;
          lat = 34.1688 + (math.sin(seed * 0.5) * 0.05);
          lng = 73.2215 + (math.cos(seed * 0.5) * 0.05);
        }
      }
      
      return Listing(
        id: item.id,
        userId: item.userId,
        materialType: item.materialType,
        estimatedWeight: item.estimatedWeight,
        pickupAddress: item.pickupAddress,
        latitude: lat,
        longitude: lng,
        locationMethod: item.locationMethod,
        title: item.title,
        notes: item.notes,
        status: item.status,
        buyerInfo: item.buyerInfo,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        user: item.user,
        images: item.images,
        quantity: item.quantity,
        orderItems: item.orderItems,
      );
    }).toList();
  }

  // Core hyperlocal sorting and filtering logic
  List<Listing> get _filteredAndSortedItems {
    final List<Listing> allItems = [];
    allItems.addAll(_items);
    
    final existingIds = _items.map((i) => i.id).toSet();
    for (var mock in _getMockListings()) {
      if (!existingIds.contains(mock.id)) {
        allItems.add(mock);
      }
    }

    final processedItems = _processListings(allItems);

    // 1. Filter by search query
    var filtered = processedItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final title = (item.title ?? '').toLowerCase();
      final type = item.materialType.toLowerCase();
      final address = item.pickupAddress.toLowerCase();
      return title.contains(q) || type.contains(q) || address.contains(q);
    }).toList();

    // 2. Filter by material type
    if (_filterMaterial != null && _filterMaterial != 'All') {
      filtered = filtered.where((item) {
        return item.materialType.toLowerCase() == _filterMaterial!.toLowerCase();
      }).toList();
    }

    // 3. Filter by radius
    filtered = filtered.where((item) {
      final double distance = _calculateDistance(item.latitude ?? 34.1688, item.longitude ?? 73.2215);
      if (_selectedRadius == 'Within 5 km') {
        return distance <= 5.0;
      } else if (_selectedRadius == 'Within 10 km') {
        return distance <= 10.0;
      } else if (_selectedRadius == 'Within 25 km') {
        return distance <= 25.0;
      } else if (_selectedRadius == 'Entire City') {
        return distance <= 15.0 || item.pickupAddress.toLowerCase().contains(_currentCity.toLowerCase());
      } else if (_selectedRadius == 'Nearby Cities') {
        return distance <= 50.0; // haripur, mansehra
      }
      return true; // entire province/all
    }).toList();

    // 4. Sort items (Nearby First Logic as priority)
    if (_selectedSort == 'Nearest First' || _selectedSort == 'AI Recommended') {
      filtered.sort((a, b) {
        final distA = _calculateDistance(a.latitude ?? 34.1688, a.longitude ?? 73.2215);
        final distB = _calculateDistance(b.latitude ?? 34.1688, b.longitude ?? 73.2215);
        return distA.compareTo(distB);
      });
    } else if (_selectedSort == 'Best Price') {
      filtered.sort((a, b) {
        final priceA = a.estimatedWeight * (MaterialData.materialRates[a.materialType.toLowerCase()] ?? 40.0);
        final priceB = b.estimatedWeight * (MaterialData.materialRates[b.materialType.toLowerCase()] ?? 40.0);
        return priceB.compareTo(priceA);
      });
    } else if (_selectedSort == 'Recently Listed') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Most Trusted Seller') {
      filtered.sort((a, b) {
        final ratingA = 4.0 + (a.id % 10) * 0.1;
        final ratingB = 4.0 + (b.id % 10) * 0.1;
        return ratingB.compareTo(ratingA);
      });
    }

    return filtered;
  }

  void _onItemTap(Listing item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );
    if (result == true) {
      _loadItems();
    }
  }

  // Opens simulated GPS switcher dialog
  void _showLocationSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final cities = ['Abbottabad', 'Haripur', 'Mansehra', 'Islamabad', 'Peshawar'];
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: Text(
            'Simulate GPS Location',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities.map((city) {
              return ListTile(
                title: Text(city, style: GoogleFonts.outfit(color: Colors.white70)),
                leading: const Icon(Icons.location_city_rounded, color: Color(0xFF2196F3)),
                onTap: () {
                  setState(() {
                    _currentCity = city;
                    _currentArea = city == 'Abbottabad' ? 'Jinnahabad' : 'Central';
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Displays the EcoBot AI Assistant Bottom Sheet
  void _openAIAssistantSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0F1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final commands = [
          'Show cardboard near me',
          'Find highest paying plastic nearby',
          'Show e-waste within 5 km',
          'Request collector to Abbottabad',
          'Sell my plastic bottles'
        ];

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Icon(Icons.psychology_outlined, color: Color(0xFF4CAF50), size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EcoBot AI Assistant',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hyperlocal smart commander',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Try asking EcoBot to filter and sort automatically:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Column(
                children: commands.map((cmd) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _executeAICommand(cmd);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cmd,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF2196F3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper that parses command and updates state dynamically
  void _executeAICommand(String cmd) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'EcoBot: Applying filters for "$cmd"',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );

    setState(() {
      if (cmd.contains('cardboard')) {
        _filterMaterial = 'Paper';
        _searchQuery = 'cardboard';
        _selectedRadius = 'Within 10 km';
      } else if (cmd.contains('highest paying')) {
        _filterMaterial = 'Plastic';
        _selectedSort = 'Best Price';
      } else if (cmd.contains('e-waste within 5 km')) {
        _filterMaterial = 'E-Waste';
        _selectedRadius = 'Within 5 km';
        _selectedSort = 'Nearest First';
      } else if (cmd.contains('Request collector')) {
        _selectedRadius = 'Entire City';
        _showCollectorRequestAlert();
      } else if (cmd.contains('plastic bottles')) {
        _filterMaterial = 'Plastic';
        _searchQuery = 'bottles';
        _selectedRadius = 'Within 10 km';
      }
    });
  }

  void _showCollectorRequestAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: Text('Request Dispatch', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'EcoBot is preparing a collector pickup request in $_currentArea, $_currentCity. Verify details and dispatch?',
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF2E7D32),
                    content: Text('Collector dispatch request created successfully in $_currentArea!', style: GoogleFonts.outfit()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
              child: Text('Confirm Dispatch', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsToShow = _filteredAndSortedItems;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Section
            _buildHyperlocalHeader(isDark),

            // 2. Filter Chips Rows
            _buildFilterRow(isDark),

            // 3. View Toggle & Sort Controls
            _buildSortAndToggleControls(isDark, itemsToShow.length),

            // 4. Main Body Content (List View or Map View)
            Expanded(
              child: _isLoading
                  ? SkeletonLoader.grid()
                  : itemsToShow.isEmpty
                      ? _buildEmptyState(isDark)
                      : _isMapView
                          ? _buildMapView(isDark, itemsToShow)
                          : _buildListView(isDark, itemsToShow),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAIAssistantSheet,
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 6,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.psychology_outlined, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildHyperlocalHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Row: Location Picker, Title & Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _showLocationSelectorDialog,
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF4CAF50), size: 22),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$_currentCity, Pakistan',
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50), size: 20),
                          ],
                        ),
                        Text(
                          '$_currentArea (Hyperlocal Focus)',
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white38 : Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, 
                        color: isDark ? Colors.white70 : Colors.black87),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.voice_chat, color: Color(0xFF2196F3)),
                    onPressed: _openAIAssistantSheet,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Box with Glass/Neomorphism Design
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search recyclable items near you',
                hintStyle: GoogleFonts.outfit(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Column(
      children: [
        // 1. Distance Radius Filter Chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _radiusOptions.length,
            itemBuilder: (context, index) {
              final opt = _radiusOptions[index];
              final isSelected = _selectedRadius == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(opt, style: GoogleFonts.outfit(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2196F3).withOpacity(0.25),
                  backgroundColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                  textColor: isSelected ? const Color(0xFF2196F3) : (isDark ? Colors.white60 : Colors.black54),
                  selectedShadowColor: Colors.transparent,
                  checkmarkColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedRadius = opt);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // 2. Categories chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('All', isDark),
              _buildCategoryChip('Plastic', isDark),
              _buildCategoryChip('Paper', isDark),
              _buildCategoryChip('Metal', isDark),
              _buildCategoryChip('E-Waste', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isDark) {
    final isSelected = _filterMaterial == label || (_filterMaterial == null && label == 'All');
    final activeColor = const Color(0xFF4CAF50);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.outfit(fontSize: 12)),
        selected: isSelected,
        selectedColor: activeColor.withOpacity(0.2),
        backgroundColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        textColor: isSelected ? activeColor : (isDark ? Colors.white60 : Colors.black54),
        selectedShadowColor: Colors.transparent,
        checkmarkColor: activeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ),
        onSelected: (val) {
          if (val) {
            setState(() => _filterMaterial = label == 'All' ? null : label);
          }
        },
      ),
    );
  }

  Widget _buildSortAndToggleControls(bool isDark, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '$count items found nearby',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown selector
              DropdownButton<String>(
                value: _selectedSort,
                dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4CAF50), size: 18),
                underline: const SizedBox(),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSort = val);
                },
                items: _sortOptions.map((opt) {
                  return DropdownMenuItem(value: opt, child: Text(opt));
                }).toList(),
              ),
            ],
          ),
          // Toggle View Controls (List / Map)
          Container(
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isMapView = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: !_isMapView
                          ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Icon(Icons.view_list_rounded, 
                         color: !_isMapView ? const Color(0xFF4CAF50) : Colors.grey, size: 18),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isMapView = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _isMapView
                          ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Icon(Icons.map_rounded, 
                         color: _isMapView ? const Color(0xFF4CAF50) : Colors.grey, size: 18),
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

  Widget _buildListView(bool isDark, List<Listing> items) {
    return RefreshIndicator(
      onRefresh: _loadItems,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.61, // taller aspect ratio to fit all metadata nicely
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildMarketplaceCard(items[index], isDark);
        },
      ),
    );
  }

  Widget _buildMarketplaceCard(Listing item, bool isDark) {
    final double distance = _calculateDistance(item.latitude ?? 34.1688, item.longitude ?? 73.2215);
    final double rate = MaterialData.materialRates[item.materialType.toLowerCase()] ?? 40.0;
    final double price = item.estimatedWeight * rate;
    
    // Simulate seller rating based on ID seed
    final double rating = 4.2 + (item.id % 8) * 0.1;
    final bool isAIClassified = item.id % 2 == 1; // Odd ids are AI classified
    
    // Color mapping by category
    Color badgeColor = const Color(0xFF4CAF50);
    if (item.materialType.toLowerCase() == 'paper') badgeColor = const Color(0xFFFF9800);
    if (item.materialType.toLowerCase() == 'metal') badgeColor = const Color(0xFF757575);
    if (item.materialType.toLowerCase() == 'e-waste') badgeColor = const Color(0xFF2196F3);

    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => _onItemTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 12,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: isDark ? Colors.black12 : Colors.grey.shade100,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Center(
                      child: Icon(
                        _getIconForMaterial(item.materialType),
                        size: 50,
                        color: badgeColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                // Material Category Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.materialTypeDisplay,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Distance badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${distance.toStringAsFixed(1)} km away',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Card Details
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name & Area
                      Text(
                        item.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.pickupAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Weight & Price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.estimatedWeight} kg Available',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            'Rs. ${price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Rating & Badges
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (isAIClassified)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(color: Color(0xFF2196F3), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Pickup',
                              style: TextStyle(color: Color(0xFF4CAF50), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Buy Button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: NeonButton(
                      text: 'BUY',
                      height: 32,
                      onPressed: () => _onItemTap(item),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(bool isDark, List<Listing> items) {
    // Generate map markers based on item locations
    final markers = items.map((item) {
      Color pinColor = const Color(0xFF4CAF50);
      if (item.materialType.toLowerCase() == 'paper') pinColor = const Color(0xFFFF9800);
      if (item.materialType.toLowerCase() == 'metal') pinColor = const Color(0xFF757575);
      if (item.materialType.toLowerCase() == 'e-waste') pinColor = const Color(0xFF2196F3);

      final index = items.indexOf(item);
      final isSelected = _activeMapCardIndex == index;

      return Marker(
        point: LatLng(item.latitude ?? 34.1688, item.longitude ?? 73.2215),
        width: isSelected ? 48 : 36,
        height: isSelected ? 48 : 36,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _activeMapCardIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _mapController.move(
              LatLng(item.latitude ?? 34.1688, item.longitude ?? 73.2215),
              13.5,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: pinColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Icon(
              _getIconForMaterial(item.materialType),
              color: Colors.white,
              size: isSelected ? 22 : 16,
            ),
          ),
        ),
      );
    }).toList();

    // Pulser User Location Marker
    markers.add(
      Marker(
        point: _userLocation,
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        // 1. Flutter Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _userLocation,
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: isDark
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                  : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.recyconnect.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        
        // 2. Carousel overlay at the bottom
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) {
                setState(() {
                  _activeMapCardIndex = index;
                });
                final item = items[index];
                _mapController.move(
                  LatLng(item.latitude ?? 34.1688, item.longitude ?? 73.2215),
                  13.5,
                );
              },
              itemBuilder: (context, index) {
                return _buildMapCarouselCard(items[index], isDark);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCarouselCard(Listing item, bool isDark) {
    final double distance = _calculateDistance(item.latitude ?? 34.1688, item.longitude ?? 73.2215);
    final double rate = MaterialData.materialRates[item.materialType.toLowerCase()] ?? 40.0;
    final double price = item.estimatedWeight * rate;

    Color badgeColor = const Color(0xFF4CAF50);
    if (item.materialType.toLowerCase() == 'paper') badgeColor = const Color(0xFFFF9800);
    if (item.materialType.toLowerCase() == 'metal') badgeColor = const Color(0xFF757575);
    if (item.materialType.toLowerCase() == 'e-waste') badgeColor = const Color(0xFF2196F3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTap(item),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon Thumbnail
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForMaterial(item.materialType),
                      size: 36,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Card Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${item.pickupAddress} · ${distance.toStringAsFixed(1)} km away',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.estimatedWeight} kg Available',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            'Rs. ${price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.location_off_rounded, color: Colors.redAccent, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No recyclable items found nearby.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try expanding your search radius to find listings in nearby areas or cities.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            Column(
              children: [
                SizedBox(
                  width: 220,
                  child: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ).build(
                    context,
                    onPressed: () {
                      setState(() {
                        _selectedRadius = 'Nearby Cities';
                      });
                    },
                    child: Text('Expand search radius', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 220,
                  child: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ).build(
                    context,
                    onPressed: _showCollectorRequestAlert,
                    child: Text('Request collector', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 220,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateListingScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Create listing', style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMaterial(String type) {
    switch (type.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink_rounded;
      case 'metal':
        return Icons.build_rounded;
      case 'paper':
        return Icons.description_rounded;
      case 'e-waste':
        return Icons.computer_rounded;
      default:
        return Icons.recycling_rounded;
    }
  }
}

// Extension to build generic buttons cleanly
extension on ButtonStyle {
  Widget build(BuildContext context, {required VoidCallback onPressed, required Widget child}) {
    return ElevatedButton(
      style: this,
      onPressed: onPressed,
      child: child,
    );
  }
}
