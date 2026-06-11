import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/utils/static_data.dart';
import '../../widgets/skeleton_loader.dart';
import 'marketplace/item_detail_screen.dart';
import 'create_listing_screen.dart';

class BrowseMarketplaceScreen extends StatefulWidget {
  final String? initialMaterial;
  final String? initialRadius;
  final String? initialSort;
  final bool initialMapView;

  const BrowseMarketplaceScreen({
    Key? key,
    this.initialMaterial,
    this.initialRadius,
    this.initialSort,
    this.initialMapView = false,
  }) : super(key: key);

  @override
  State<BrowseMarketplaceScreen> createState() => _BrowseMarketplaceScreenState();
}

class _BrowseMarketplaceScreenState extends State<BrowseMarketplaceScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  @override
  bool get wantKeepAlive => true;

  final ListingService _listingService = ListingService();
  final LocationService _locationService = LocationService();
  List<Listing> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Real GPS location
  LatLng? _userLocation;
  bool _locationLoading = true;
  String _currentCity = 'Detecting...';
  String _currentArea = '';

  // Filters
  String _selectedRadius = 'Within 10 km';
  String _selectedSort = 'Nearest First';
  String? _filterMaterial;
  String _searchQuery = '';
  bool _isMapView = false;

  // Map
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _activeMapCardIndex = 0;

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    'Recently Listed',
  ];

  // Material type gradients for modern card styling
  static const Map<String, List<Color>> _materialGradients = {
    'plastic': [Color(0xFF43A047), Color(0xFF66BB6A)],
    'paper': [Color(0xFFEF6C00), Color(0xFFFFA726)],
    'metal': [Color(0xFF546E7A), Color(0xFF78909C)],
    'e-waste': [Color(0xFF1565C0), Color(0xFF42A5F5)],
  };

  static const List<Color> _defaultGradient = [Color(0xFF2E7D32), Color(0xFF4CAF50)];

  @override
  void initState() {
    super.initState();
    if (widget.initialMaterial != null) _filterMaterial = widget.initialMaterial;
    if (widget.initialRadius != null) _selectedRadius = widget.initialRadius!;
    if (widget.initialSort != null) _selectedSort = widget.initialSort!;
    _isMapView = widget.initialMapView;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initLocation();
    _loadItems();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Fetch real GPS location and reverse geocode city/area
  Future<void> _initLocation() async {
    try {
      // Explicitly request location permission
      await _locationService.requestLocationPermission();

      final pos = await _locationService.getCurrentLocationWithTimeout(
        timeout: const Duration(seconds: 8),
      );
      if (pos != null && mounted) {
        final lat = pos['latitude']!;
        final lng = pos['longitude']!;
        setState(() {
          _userLocation = LatLng(lat, lng);
        });

        // Reverse geocode for city/area display
        final address = await _locationService.getAddressFromCoordinates(lat, lng);
        if (address != null && mounted) {
          setState(() {
            _currentCity = address['locality']?.isNotEmpty == true
                ? address['locality']!
                : (address['subAdministrativeArea'] ?? 'Your Area');
            _currentArea = address['subLocality']?.isNotEmpty == true
                ? address['subLocality']!
                : (address['street'] ?? '');
            _locationLoading = false;
          });
        } else if (mounted) {
          setState(() => _locationLoading = false);
        }
      } else if (mounted) {
        _useProfileLocationFallback();
      }
    } catch (e) {
      if (mounted) {
        _useProfileLocationFallback();
      }
    }
  }

  void _useProfileLocationFallback() {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        final city = user['city'] as String?;
        final area = (user['area'] ?? user['address']) as String?;
        
        if (city != null && city.isNotEmpty) {
          setState(() {
            _currentCity = city;
            _currentArea = area ?? '';
            _userLocation = _getFallbackCoordinates(city, area ?? '');
            _locationLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error getting profile location fallback: $e');
    }

    // Default ultimate fallback to Abbottabad
    setState(() {
      _userLocation = const LatLng(34.1688, 73.2215);
      _currentCity = 'Abbottabad';
      _currentArea = 'Jinnahabad';
      _locationLoading = false;
    });
  }

  LatLng _getFallbackCoordinates(String city, String area) {
    final combined = '$area, $city'.toLowerCase();
    if (combined.contains('attock') || combined.contains('kamra')) {
      return const LatLng(33.7686, 72.3614);
    } else if (combined.contains('abbottabad') || combined.contains('jinnahabad')) {
      return const LatLng(34.1688, 73.2215);
    } else if (combined.contains('haripur')) {
      return const LatLng(33.9998, 72.9344);
    } else if (combined.contains('mansehra')) {
      return const LatLng(34.3313, 73.2038);
    } else if (combined.contains('islamabad')) {
      return const LatLng(33.6844, 73.0479);
    } else if (combined.contains('rawalpindi')) {
      return const LatLng(33.5651, 73.0169);
    } else if (combined.contains('lahore')) {
      return const LatLng(31.5204, 74.3587);
    } else if (combined.contains('karachi')) {
      return const LatLng(24.8607, 67.0011);
    } else if (combined.contains('peshawar')) {
      return const LatLng(34.0151, 71.5249);
    }
    return const LatLng(34.1688, 73.2215); // Default to Abbottabad
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

  /// Calculate real distance using LocationService (Geolocator)
  double _calculateDistance(double lat, double lng) {
    if (_userLocation == null) return 0.0;
    return _locationService.calculateDistance(
      _userLocation!.latitude,
      _userLocation!.longitude,
      lat,
      lng,
    );
  }

  /// Assign fallback coordinates to API listings missing lat/lng
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
          final seed = item.id;
          lat = (_userLocation?.latitude ?? 34.1688) + (math.sin(seed * 0.5) * 0.03);
          lng = (_userLocation?.longitude ?? 73.2215) + (math.cos(seed * 0.5) * 0.03);
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

  /// Filtered & sorted items — only real API data, no mocks
  List<Listing> get _filteredAndSortedItems {
    final processedItems = _processListings(_items);

    // 1. Search filter
    var filtered = processedItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final title = (item.title ?? '').toLowerCase();
      final type = item.materialType.toLowerCase();
      final address = item.pickupAddress.toLowerCase();
      return title.contains(q) || type.contains(q) || address.contains(q);
    }).toList();

    // 2. Material filter
    if (_filterMaterial != null && _filterMaterial != 'All') {
      filtered = filtered.where((item) {
        return item.materialType.toLowerCase() == _filterMaterial!.toLowerCase();
      }).toList();
    }

    // 3. Radius filter (only if GPS is available)
    if (_userLocation != null) {
      filtered = filtered.where((item) {
        final double distance = _calculateDistance(
          item.latitude ?? _userLocation!.latitude,
          item.longitude ?? _userLocation!.longitude,
        );
        switch (_selectedRadius) {
          case 'Within 5 km': return distance <= 5.0;
          case 'Within 10 km': return distance <= 10.0;
          case 'Within 25 km': return distance <= 25.0;
          case 'Entire City': return distance <= 15.0 || item.pickupAddress.toLowerCase().contains(_currentCity.toLowerCase());
          case 'Nearby Cities': return distance <= 50.0;
          default: return true;
        }
      }).toList();
    }

    // 4. Sort
    if (_selectedSort == 'Nearest First' && _userLocation != null) {
      filtered.sort((a, b) {
        final addressA = a.pickupAddress.toLowerCase();
        final addressB = b.pickupAddress.toLowerCase();
        
        int scoreA = 0;
        int scoreB = 0;

        if (_currentArea.isNotEmpty && _currentArea != 'Detecting...') {
          if (addressA.contains(_currentArea.toLowerCase())) scoreA = 2;
          if (addressB.contains(_currentArea.toLowerCase())) scoreB = 2;
        }

        if (scoreA == 0 && _currentCity.isNotEmpty && _currentCity != 'Detecting...') {
          if (addressA.contains(_currentCity.toLowerCase())) scoreA = 1;
        }
        if (scoreB == 0 && _currentCity.isNotEmpty && _currentCity != 'Detecting...') {
          if (addressB.contains(_currentCity.toLowerCase())) scoreB = 1;
        }

        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA); // Higher score (closer match) comes first
        }

        final distA = _calculateDistance(a.latitude ?? _userLocation!.latitude, a.longitude ?? _userLocation!.longitude);
        final distB = _calculateDistance(b.latitude ?? _userLocation!.latitude, b.longitude ?? _userLocation!.longitude);
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
    if (result == true) _loadItems();
  }

  List<Color> _getGradient(String materialType) {
    return _materialGradients[materialType.toLowerCase()] ?? _defaultGradient;
  }

  IconData _getIconForMaterial(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Icons.local_drink_rounded;
      case 'metal': return Icons.build_rounded;
      case 'paper': return Icons.description_rounded;
      case 'e-waste': return Icons.computer_rounded;
      default: return Icons.recycling_rounded;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  // ─── BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsToShow = _filteredAndSortedItems;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildFilterChips(isDark),
            _buildSortBar(isDark, itemsToShow.length),
            Expanded(
              child: _isLoading
                  ? SkeletonLoader.grid()
                  : _errorMessage != null
                      ? _buildErrorState(isDark)
                      : itemsToShow.isEmpty
                          ? _buildEmptyState(isDark)
                          : _isMapView
                              ? _buildMapView(isDark, itemsToShow)
                              : _buildListView(isDark, itemsToShow),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              // Location indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_locationLoading)
                          _buildPulsingDot()
                        else
                          const SizedBox.shrink(),
                        Text(
                          _locationLoading ? 'Detecting location...' : _currentCity,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    if (_currentArea.isNotEmpty && !_locationLoading)
                      Text(
                        _currentArea,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                  ],
                ),
              ),
              // Refresh button
              _buildIconBtn(
                Icons.refresh_rounded,
                isDark,
                onTap: () {
                  _initLocation();
                  _loadItems();
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark ? const Color(0xFF1A2035) : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE8ECF0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search recyclables near you...',
                hintStyle: GoogleFonts.outfit(
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? const Color(0xFF66BB6A) : const Color(0xFF43A047),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withOpacity(_pulseAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildIconBtn(IconData icon, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isDark ? Colors.white60 : Colors.black54, size: 20),
      ),
    );
  }

  // ─── FILTER CHIPS ───────────────────────────────────────

  Widget _buildFilterChips(bool isDark) {
    return Column(
      children: [
        // Radius chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _radiusOptions.length,
            itemBuilder: (context, index) {
              final opt = _radiusOptions[index];
              final isSelected = _selectedRadius == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRadius = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)])
                          : null,
                      color: isSelected ? null : (isDark ? const Color(0xFF1A2035) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0E4E8)),
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Text(
                      opt,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Material category chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'Plastic', 'Paper', 'Metal', 'E-Waste']
                .map((label) => _buildMaterialChip(label, isDark))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialChip(String label, bool isDark) {
    final isSelected = _filterMaterial == label || (_filterMaterial == null && label == 'All');
    final gradient = label == 'All'
        ? _defaultGradient
        : (_materialGradients[label.toLowerCase()] ?? _defaultGradient);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterMaterial = label == 'All' ? null : label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: gradient) : null,
            color: isSelected ? null : (isDark ? const Color(0xFF1A2035) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0E4E8)),
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != 'All') ...[
                Icon(
                  _getIconForMaterial(label),
                  size: 14,
                  color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SORT BAR ───────────────────────────────────────────

  Widget _buildSortBar(bool isDark, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2035) : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count found',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    dropdownColor: isDark ? const Color(0xFF1A2035) : Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 18),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF43A047),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSort = val);
                    },
                    items: _sortOptions.map((opt) {
                      return DropdownMenuItem(value: opt, child: Text(opt));
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // View toggle
          Container(
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2035) : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _viewToggle(Icons.grid_view_rounded, !_isMapView, isDark, () => setState(() => _isMapView = false)),
                _viewToggle(Icons.map_rounded, _isMapView, isDark, () => setState(() => _isMapView = true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewToggle(IconData icon, bool active, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? const Color(0xFF263040) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
              : [],
        ),
        child: Center(
          child: Icon(icon, color: active ? const Color(0xFF43A047) : Colors.grey, size: 18),
        ),
      ),
    );
  }

  // ─── LIST VIEW ──────────────────────────────────────────

  Widget _buildListView(bool isDark, List<Listing> items) {
    return RefreshIndicator(
      onRefresh: _loadItems,
      color: const Color(0xFF43A047),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildCard(items[index], isDark),
      ),
    );
  }

  // ─── MODERN CARD ────────────────────────────────────────

  Widget _buildCard(Listing item, bool isDark) {
    final gradient = _getGradient(item.materialType);
    final double distance = _calculateDistance(
      item.latitude ?? (_userLocation?.latitude ?? 34.1688),
      item.longitude ?? (_userLocation?.longitude ?? 73.2215),
    );
    final double rate = MaterialData.materialRates[item.materialType.toLowerCase()] ?? 40.0;
    final double price = item.estimatedWeight * rate;
    final bool hasImages = item.hasNetworkImages;

    return GestureDetector(
      onTap: () => _onItemTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141B2D) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE8ECF0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / Placeholder Area ──
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: hasImages
                        ? Image.network(
                            item.imageUrls.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return _buildGradientPlaceholder(item.materialType, gradient);
                            },
                            errorBuilder: (_, __, ___) => _buildGradientPlaceholder(item.materialType, gradient),
                          )
                        : _buildGradientPlaceholder(item.materialType, gradient),
                  ),
                  // Material type pill
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: gradient[0].withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        item.materialTypeDisplay,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Distance pill
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            _userLocation != null
                                ? '${distance.toStringAsFixed(1)} km'
                                : '...',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card Details ──
            Expanded(
              flex: 12,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title & metadata
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 12, color: isDark ? Colors.white30 : Colors.black38),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                item.pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: isDark ? Colors.white30 : Colors.black38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Weight & time
                        Row(
                          children: [
                            _buildMetaPill(
                              '${item.estimatedWeight} kg',
                              isDark,
                              icon: Icons.scale_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildMetaPill(
                              _timeAgo(item.createdAt),
                              isDark,
                              icon: Icons.access_time_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Price & seller
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Seller
                        Flexible(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: gradient[0].withOpacity(0.2),
                                child: Icon(Icons.person, size: 12, color: gradient[0]),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  item.user?.name ?? 'Seller',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Text(
                          'Rs ${price.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientPlaceholder(String materialType, List<Color> gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient[0].withOpacity(0.15), gradient[1].withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getIconForMaterial(materialType),
          size: 48,
          color: gradient[0].withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildMetaPill(String text, bool isDark, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: isDark ? Colors.white30 : Colors.black38),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MAP VIEW ───────────────────────────────────────────

  Widget _buildMapView(bool isDark, List<Listing> items) {
    final center = _userLocation ?? const LatLng(34.1688, 73.2215);

    final markers = items.map((item) {
      final gradient = _getGradient(item.materialType);
      final index = items.indexOf(item);
      final isSelected = _activeMapCardIndex == index;

      return Marker(
        point: LatLng(item.latitude ?? center.latitude, item.longitude ?? center.longitude),
        width: isSelected ? 48 : 36,
        height: isSelected ? 48 : 36,
        child: GestureDetector(
          onTap: () {
            setState(() => _activeMapCardIndex = index);
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            _mapController.move(
              LatLng(item.latitude ?? center.latitude, item.longitude ?? center.longitude), 13.5);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
              boxShadow: [
                BoxShadow(color: gradient[0].withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
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

    // User location marker with pulse
    markers.add(
      Marker(
        point: center,
        width: 44,
        height: 44,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36 * _pulseAnimation.value,
                  height: 36 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: center, initialZoom: 13.0),
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
        // Bottom carousel
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
                setState(() => _activeMapCardIndex = index);
                final item = items[index];
                _mapController.move(
                  LatLng(item.latitude ?? center.latitude, item.longitude ?? center.longitude), 13.5);
              },
              itemBuilder: (context, index) => _buildMapCard(items[index], isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(Listing item, bool isDark) {
    final gradient = _getGradient(item.materialType);
    final double distance = _calculateDistance(
      item.latitude ?? (_userLocation?.latitude ?? 34.1688),
      item.longitude ?? (_userLocation?.longitude ?? 73.2215),
    );
    final double rate = MaterialData.materialRates[item.materialType.toLowerCase()] ?? 40.0;
    final double price = item.estimatedWeight * rate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141B2D).withOpacity(0.95) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
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
                // Thumbnail
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [gradient[0].withOpacity(0.15), gradient[1].withOpacity(0.08)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: item.hasNetworkImages
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(item.imageUrls.first, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                    child: Icon(_getIconForMaterial(item.materialType),
                                        size: 32, color: gradient[0]),
                                  )),
                        )
                      : Center(
                          child: Icon(_getIconForMaterial(item.materialType),
                              size: 32, color: gradient[0]),
                        ),
                ),
                const SizedBox(width: 14),
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
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.pickupAddress} · ${distance.toStringAsFixed(1)} km',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.estimatedWeight} kg',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          Text(
                            'Rs ${price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF43A047),
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

  // ─── EMPTY STATE ────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF43A047).withOpacity(0.12),
                    const Color(0xFF66BB6A).withOpacity(0.06),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.storefront_rounded, color: Color(0xFF43A047), size: 40),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No listings found nearby',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try expanding your search radius\nor create a new listing.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white38 : Colors.black45,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Expand radius button
            SizedBox(
              width: 220,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _selectedRadius = 'Nearby Cities'),
                icon: const Icon(Icons.radar_rounded, size: 18),
                label: Text('Expand Radius', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Create listing button
            SizedBox(
              width: 220,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListingScreen()));
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Create Listing', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF43A047),
                  side: const BorderSide(color: Color(0xFF43A047)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ERROR STATE ─────────────────────────────────────────

  Widget _buildErrorState(bool isDark) {
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
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 36),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to load listings',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white38 : Colors.black45,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _loadItems,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Retry', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FAB ────────────────────────────────────────────────

  Widget _buildFAB() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListingScreen()));
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
