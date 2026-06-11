import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recyconnect/core/theme/marketplace_theme.dart';
import 'package:recyconnect/core/services/location_service.dart';
import 'package:recyconnect/core/services/auth_service.dart';
import 'package:recyconnect/presentation/widgets/marketplace/glass_card.dart';
import 'package:recyconnect/presentation/widgets/marketplace/neon_button.dart';
import 'dart:async';

class LocationSelectionScreen extends StatefulWidget {
  final LatLng initialLocation;
  final String? initialAddress;

  const LocationSelectionScreen({
    Key? key,
    required this.initialLocation,
    this.initialAddress,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLatLng = const LatLng(33.7687, 72.3618);
  String _selectedAddress = 'Attock, Punjab, Pakistan';
  String? _selectedCity;
  String? _selectedArea;

  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounceTimer;

  // Mock branches for Warehouses/Companies
  final List<Map<String, dynamic>> _mockBranches = [
    {
      'name': 'Main Branch Attock',
      'address': 'Main City Center Road, Attock',
      'lat': 33.7687,
      'lng': 72.3618
    },
    {
      'name': 'Kamra Collection Hub',
      'address': 'Kamra Road Depot, Attock',
      'lat': 33.8547,
      'lng': 72.3993
    },
    {
      'name': 'Attock Cantt Depot',
      'address': 'Cantt Industrial Zone, Attock',
      'lat': 33.7844,
      'lng': 72.3564
    },
    {
      'name': 'Bypass Recycling Center',
      'address': 'Attock Bypass Hub, Punjab',
      'lat': 33.7505,
      'lng': 72.3256
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialLocation;
    _selectedAddress = widget.initialAddress ?? 'Attock, Punjab, Pakistan';
    
    // Automatically reverse geocode if no address provided
    if (widget.initialAddress == null || widget.initialAddress!.isEmpty) {
      _reverseGeocode(_selectedLatLng);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Handle address searches via Nominatim
  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = [];
        });
        return;
      }

      setState(() => _isSearching = true);
      try {
        final results = await _locationService.searchLocation(query);
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        setState(() => _isSearching = false);
      }
    });
  }

  // Move pin and reverse geocode
  Future<void> _updateLocation(LatLng position) async {
    setState(() {
      _selectedLatLng = position;
      _isReverseGeocoding = true;
    });
    _mapController.move(position, _mapController.camera.zoom);
    await _reverseGeocode(position);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final addressData = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (addressData != null) {
        final street = addressData['street'] ?? '';
        final subLocality = addressData['subLocality'] ?? '';
        final locality = addressData['locality'] ?? '';
        final province = addressData['administrativeArea'] ?? '';

        final List<String> parts = [
          if (street.isNotEmpty) street,
          if (subLocality.isNotEmpty) subLocality,
          if (locality.isNotEmpty) locality,
          if (province.isNotEmpty) province,
        ];

        setState(() {
          _selectedAddress = parts.isNotEmpty ? parts.join(', ') : 'Selected Point Location';
          _selectedCity = locality.isNotEmpty ? locality : null;
          _selectedArea = subLocality.isNotEmpty ? subLocality : null;
          _isReverseGeocoding = false;
        });
      } else {
        setState(() {
          _selectedAddress = 'Selected Coordinates: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _isReverseGeocoding = false;
        });
      }
    } catch (_) {
      setState(() => _isReverseGeocoding = false);
    }
  }

  // Snap to current GPS position
  Future<void> _useCurrentGPSLocation() async {
    setState(() => _isReverseGeocoding = true);
    final gpsData = await _locationService.getCurrentLocation();
    if (gpsData != null) {
      final pos = LatLng(gpsData['latitude']!, gpsData['longitude']!);
      await _updateLocation(pos);
    } else {
      setState(() => _isReverseGeocoding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch GPS coordinates. Ensure location is enabled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context, listen: false);
    final userRole = authService.userRole;
    final isWarehouseOrCompany = userRole == 'warehouse' || userRole == 'company';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Select Location',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. The OSM Map Background
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 14.0,
              maxZoom: 18,
              minZoom: 5,
              onTap: (tapPosition, point) => _updateLocation(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.recyconnect.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng,
                    width: 60,
                    height: 60,
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 28),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isDark ? MarketplaceTheme.darkAccentCyan.withOpacity(0.5) : MarketplaceTheme.lightAccent.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Search & Results Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Search location by address...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: isDark ? Colors.white70 : Colors.black54),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Search Results Dropdown
                if (_searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final displayName = result['display_name'] ?? 'Unknown Location';
                            final double lat = double.parse(result['lat']);
                            final double lon = double.parse(result['lon']);
                            
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined, color: MarketplaceTheme.lightAccent),
                              title: Text(
                                displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                                _updateLocation(LatLng(lat, lon));
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),

          // 3. Floating Action buttons (GPS Snap & Zoom)
          Positioned(
            right: 16,
            bottom: isWarehouseOrCompany ? 280 : 220,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'gps_snap',
                  backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  foregroundColor: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                  mini: true,
                  onPressed: _useCurrentGPSLocation,
                  child: const Icon(Icons.gps_fixed),
                ),
              ],
            ),
          ),

          // 4. Predefined Branch Selection Carousel for Warehouse/Company roles
          if (isWarehouseOrCompany)
            Positioned(
              left: 0,
              right: 0,
              bottom: 155,
              child: Container(
                height: 55,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _mockBranches.length,
                  itemBuilder: (context, index) {
                    final branch = _mockBranches[index];
                    final double bLat = branch['lat'];
                    final double bLng = branch['lng'];
                    final isSelected = (bLat - _selectedLatLng.latitude).abs() < 0.0001 &&
                                       (bLng - _selectedLatLng.longitude).abs() < 0.0001;

                    return GestureDetector(
                      onTap: () {
                        _updateLocation(LatLng(bLat, bLng));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent)
                            : (isDark ? Colors.black54 : Colors.white70),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white24 : Colors.black12)
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storefront, 
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), 
                              size: 16
                            ),
                            const SizedBox(width: 8),
                            Text(
                              branch['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 5. Bottom Location Detail Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECTED ADDRESS',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isReverseGeocoding
                            ? const LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                color: MarketplaceTheme.lightAccent,
                              )
                            : Text(
                                _selectedAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      text: 'CONFIRM LOCATION',
                      onPressed: _isReverseGeocoding
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'latitude': _selectedLatLng.latitude,
                                'longitude': _selectedLatLng.longitude,
                                'address': _selectedAddress,
                                'city': _selectedCity,
                                'area': _selectedArea,
                              });
                            },
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
}
