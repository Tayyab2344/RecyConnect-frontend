import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/collector_service.dart';
import '../../widgets/skeleton_loader.dart';

class CollectorMapScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onBack;
  final VoidCallback? onTaskUpdated;

  const CollectorMapScreen({
    super.key,
    required this.task,
    this.onBack,
    this.onTaskUpdated,
  });

  @override
  State<CollectorMapScreen> createState() => _CollectorMapScreenState();
}

class _CollectorMapScreenState extends State<CollectorMapScreen> {
  final MapController _mapController = MapController();
  final CollectorService _collectorService = CollectorService();
  StreamSubscription<Position>? _positionSubscription;
  
  late Map<String, dynamic> _task;
  DateTime? _lastLocationUpdate;
  
  LatLng? _currentPosition;
  LatLng? _pickupPosition;
  LatLng? _warehousePosition;
  
  List<LatLng> _routePoints = [];
  List<LatLng> _routePointsToPickup = [];
  List<LatLng> _routePointsToDestination = [];
  double _totalDistanceKm = 0.0;
  double _totalDurationMinutes = 0.0;
  bool _isLoadingRoute = true;
  String _navigationMode = "pickup"; // "pickup" or "warehouse"

  @override
  void initState() {
    super.initState();
    _task = Map<String, dynamic>.from(widget.task);
    _initializePoints();
    _startLocationTracking();
    _fetchRoute();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  LatLng _getCoordinatesFallback(String? address, LatLng defaultFallback) {
    if (address == null) return defaultFallback;
    final lower = address.toLowerCase();
    
    // Check specific sub-locations first to provide realistic local routing
    if (lower.contains('jinnahabad') || lower.contains('jinnah abad')) {
      return const LatLng(34.1680, 73.2230);
    }
    if (lower.contains('supply bazar') || lower.contains('supply')) {
      return const LatLng(34.1504, 73.2078);
    }
    
    if (lower.contains('abbottabad')) {
      return const LatLng(34.1504, 73.2078);
    }
    if (lower.contains('islamabad')) {
      return const LatLng(33.6844, 73.0479);
    }
    if (lower.contains('lahore')) {
      return const LatLng(31.5204, 74.3587);
    }
    return defaultFallback;
  }

  void _initializePoints() {
    final task = _task;
    
    // Parse source coordinates
    final double? sourceLat = task['sourceLatitude'] != null ? double.tryParse(task['sourceLatitude'].toString()) : null;
    final double? sourceLon = task['sourceLongitude'] != null ? double.tryParse(task['sourceLongitude'].toString()) : null;
    if (sourceLat != null && sourceLon != null && sourceLat != 0.0) {
      _pickupPosition = LatLng(sourceLat, sourceLon);
    } else {
      // Default fallback based on address
      _pickupPosition = _getCoordinatesFallback(task['sourceAddress']?.toString(), const LatLng(33.6844, 73.0479));
    }

    // Parse destination coordinates
    final double? destLat = task['destinationLatitude'] != null ? double.tryParse(task['destinationLatitude'].toString()) : null;
    final double? destLon = task['destinationLongitude'] != null ? double.tryParse(task['destinationLongitude'].toString()) : null;
    if (destLat != null && destLon != null && destLat != 0.0) {
      _warehousePosition = LatLng(destLat, destLon);
    } else {
      // Fallback based on address
      _warehousePosition = _getCoordinatesFallback(task['destinationAddress']?.toString(), const LatLng(33.7294, 73.0931));
    }

    // Determine current navigation mode based on task status
    final String status = task['status'] ?? 'ASSIGNED';
    if (status == 'PICKED_UP' || status == 'IN_TRANSIT' || status == 'ARRIVED_AT_DESTINATION') {
      _navigationMode = "warehouse";
    } else {
      _navigationMode = "pickup";
    }
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get initial position
    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    
    // Log initial location
    _recordLocation(position);

    // Subscribe to continuous location updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
        });
        
        // Relocate map focus dynamically only if the driver is near the task area
        if (_currentPosition != null) {
          final double distanceToTask = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            _pickupPosition?.latitude ?? 34.1504,
            _pickupPosition?.longitude ?? 73.2078,
          ) / 1000.0;
          if (distanceToTask <= 30.0) {
            _mapController.move(_currentPosition!, _mapController.camera.zoom);
          }
        }
        
        // Refresh route as location shifts
        _fetchRoute();

        // Throttle location updates to backend: check if _lastLocationUpdate is null or >= 5 seconds
        final now = DateTime.now();
        if (_lastLocationUpdate == null || now.difference(_lastLocationUpdate!).inSeconds >= 5) {
          _lastLocationUpdate = now;
          _recordLocation(pos);
        }
      }
    });
  }

  Future<void> _recordLocation(Position pos) async {
    try {
      final taskId = _task['id'] as int?;
      final status = _task['status']?.toString();
      await _collectorService.recordLocation(
        taskId: taskId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        status: status,
      );
      debugPrint("Logged location: (${pos.latitude}, ${pos.longitude}) for task $taskId status: $status");
    } catch (e) {
      debugPrint("Failed to record location to server: $e");
    }
  }

  Future<void> _fetchRoute() async {
    final LatLng pickup = _pickupPosition ?? const LatLng(34.1504, 73.2078);
    final LatLng dest = _warehousePosition ?? const LatLng(34.1504, 73.2078);
    final String status = _task['status']?.toString() ?? 'ASSIGNED';

    final isPickedUp = ['PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'COMPLETED'].contains(status);

    LatLng start = _currentPosition ?? pickup;
    bool isFarAway = false;
    if (_currentPosition != null) {
      final double distanceToTask = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        pickup.latitude,
        pickup.longitude,
      ) / 1000.0;
      if (distanceToTask > 30.0) {
        isFarAway = true;
        start = pickup;
      }
    }

    try {
      if (isPickedUp || isFarAway) {
        // Only Leg 2 (Pickup/Start -> Dest) is active/shown
        final String leg2Url = 'https://router.project-osrm.org/route/v1/driving/'
            '${start.longitude},${start.latitude};${dest.longitude},${dest.latitude}'
            '?overview=full&geometries=geojson';
        final response = await http.get(Uri.parse(leg2Url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          final List<LatLng> points = coordinates.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          final distanceMeters = data['routes'][0]['distance'] as num? ?? 0;
          final durationSeconds = data['routes'][0]['duration'] as num? ?? 0;

          if (mounted) {
            setState(() {
              _routePointsToPickup = [];
              _routePointsToDestination = points;
              _routePoints = points;
              _totalDistanceKm = distanceMeters / 1000.0;
              _totalDurationMinutes = durationSeconds / 60.0;
              _isLoadingRoute = false;
            });
          }
        }
      } else {
        // Both legs: Leg 1 (Start -> Pickup), Leg 2 (Pickup -> Dest)
        final String leg1Url = 'https://router.project-osrm.org/route/v1/driving/'
            '${start.longitude},${start.latitude};${pickup.longitude},${pickup.latitude}'
            '?overview=full&geometries=geojson';
        final String leg2Url = 'https://router.project-osrm.org/route/v1/driving/'
            '${pickup.longitude},${pickup.latitude};${dest.longitude},${dest.latitude}'
            '?overview=full&geometries=geojson';

        final responses = await Future.wait([
          http.get(Uri.parse(leg1Url)),
          http.get(Uri.parse(leg2Url)),
        ]);

        List<LatLng> points1 = [];
        List<LatLng> points2 = [];
        double distanceKm = 0.0;
        double durationMins = 0.0;

        if (responses[0].statusCode == 200) {
          final data = jsonDecode(responses[0].body);
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          points1 = coordinates.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          distanceKm += (data['routes'][0]['distance'] as num? ?? 0) / 1000.0;
          durationMins += (data['routes'][0]['duration'] as num? ?? 0) / 60.0;
        }

        if (responses[1].statusCode == 200) {
          final data = jsonDecode(responses[1].body);
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          points2 = coordinates.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          distanceKm += (data['routes'][0]['distance'] as num? ?? 0) / 1000.0;
          durationMins += (data['routes'][0]['duration'] as num? ?? 0) / 60.0;
        }

        if (mounted) {
          setState(() {
            _routePointsToPickup = points1;
            _routePointsToDestination = points2;
            _routePoints = [...points1, ...points2];
            _totalDistanceKm = distanceKm;
            _totalDurationMinutes = durationMins;
            _isLoadingRoute = false;
          });
        }
      }
    } catch (e) {
      debugPrint("OSRM routing API error: $e");
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _routePointsToPickup = [start, pickup];
          _routePointsToDestination = [pickup, dest];
          _routePoints = [start, pickup, dest];
          _totalDistanceKm = 0.0;
          _totalDurationMinutes = 0.0;
        });
      }
    }
  }

  Future<void> _startNativeNavigation() async {
    final LatLng centerPos = _currentPosition ?? (_navigationMode == "pickup" ? _pickupPosition! : _warehousePosition!);
    _mapController.move(centerPos, 16.0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("In-App tracking active. Please follow the highlighted route."),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng pickup = _pickupPosition ?? const LatLng(34.1504, 73.2078);
    final LatLng dest = _warehousePosition ?? const LatLng(34.1504, 73.2078);
    
    // Check if the current position is far away from the task area (e.g. > 30 km)
    // to determine if we should fall back to a local route preview
    bool isFarAway = false;
    if (_currentPosition != null) {
      final double distanceToTask = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        pickup.latitude,
        pickup.longitude,
      ) / 1000.0;
      if (distanceToTask > 30.0) {
        isFarAway = true;
      }
    }

    final LatLng center = (isFarAway || _currentPosition == null)
        ? pickup
        : _currentPosition!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String status = _task['status']?.toString() ?? 'ASSIGNED';
    final String taskType = _task['taskType']?.toString() ?? '';
    
    String pickupLabel = "Pickup";
    String destLabel = "Delivery";
    IconData pickupIcon = Icons.hail;
    IconData destIcon = Icons.warehouse;

    if (taskType == 'WAREHOUSE_TO_BUYER') {
      pickupLabel = "Warehouse";
      destLabel = "Buyer";
      pickupIcon = Icons.warehouse;
      destIcon = Icons.person;
    } else if (taskType == 'SELLER_TO_WAREHOUSE') {
      pickupLabel = "Seller";
      destLabel = "Warehouse";
      pickupIcon = Icons.person;
      destIcon = Icons.warehouse;
    } else if (taskType == 'SELLER_TO_BUYER') {
      pickupLabel = "Seller";
      destLabel = "Buyer";
      pickupIcon = Icons.person;
      destIcon = Icons.person;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Flutter OpenStreetMap Widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.5,
              maxZoom: 18,
              minZoom: 10,
            ),
            children: [
              // Premium Dark or Standard map tiles
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.recyconnect.app',
              ),

              // Road Route paths for Leg 1 and Leg 2
              if (_routePointsToPickup.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePointsToPickup,
                      color: AppTheme.primaryGreen.withOpacity(0.85),
                      strokeWidth: 5.5,
                      borderColor: Colors.black.withOpacity(0.3),
                      borderStrokeWidth: 1.0,
                    ),
                  ],
                ),
              if (_routePointsToDestination.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePointsToDestination,
                      color: Colors.amber.withOpacity(0.75),
                      strokeWidth: 5.0,
                      borderColor: Colors.black.withOpacity(0.3),
                      borderStrokeWidth: 1.0,
                    ),
                  ],
                ),

              // Custom Pin Markers Layer
              MarkerLayer(
                markers: [
                  // Collector Vehicle Marker
                  if (_currentPosition != null && !isFarAway)
                    Marker(
                      point: _currentPosition!,
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGreen.withOpacity(0.24),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGreen,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.navigation, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),

                  // Source Pickup Marker
                  Marker(
                    point: _pickupPosition!,
                    width: 65,
                    height: 65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                            ],
                          ),
                          child: const Icon(Icons.hail, color: Colors.white, size: 18),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.orange[800],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Text(
                            'PICKUP',
                            style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Destination Warehouse Marker
                  Marker(
                    point: _warehousePosition!,
                    width: 65,
                    height: 65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                            ],
                          ),
                          child: const Icon(Icons.warehouse, color: Colors.white, size: 18),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Text(
                            'DELIVERY',
                            style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Floating Cohesive Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Glassmorphic Back Button
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.85) : Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Glassmorphic Mode Selector Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.85) : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildModeButton("pickup", pickupLabel, pickupIcon),
                      _buildModeButton("warehouse", destLabel, destIcon),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Premium Travel Estimates Capsule
          if (!_isLoadingRoute && _totalDistanceKm > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_run_outlined, color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Full Ride: ${_totalDistanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1.5, height: 12, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_outlined, color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_totalDurationMinutes.toStringAsFixed(0)} mins',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Info Overlay Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal Premium Progress Stepper
                  _buildPremiumStepper(status, isDark),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _navigationMode == "pickup" ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _navigationMode == "pickup" ? "EN ROUTE TO PICKUP" : "TRANSITING TO DESTINATION",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _navigationMode == "pickup" ? Colors.orange : Colors.blue,
                          ),
                        ),
                      ),
                      if (_isLoadingRoute)
                        const SizedBox(width: 14, height: 14, child: SkeletonLoader(width: 14, height: 14, borderRadius: 7))
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _navigationMode == "pickup" 
                        ? (_task['sourceName'] ?? 'Pickup Customer') 
                        : (_task['destinationName'] ?? 'Warehouse Operations'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _navigationMode == "pickup" 
                              ? _task['sourceAddress'] 
                              : _task['destinationAddress'],
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("MATERIAL CATEGORY", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(_task['materialCategory'] ?? 'Mixed Recycle', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ESTIMATED WEIGHT", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text("${_task['estimatedWeight'] ?? 0} ${_task['unit'] ?? 'kg'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Builder(
                    builder: (context) {
                      final hasAction = !['COMPLETED', 'CANCELLED', 'REJECTED', 'DELIVERED'].contains(status);
                      
                      return Row(
                        children: [
                          // Re-center map button
                          IconButton.filledTonal(
                            onPressed: () {
                              if (center != null) {
                                _mapController.move(center, 15);
                              }
                            },
                            icon: const Icon(Icons.my_location),
                            tooltip: "Re-center",
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          if (hasAction) ...[
                            // Launch native navigation as a compact icon button
                            IconButton.filledTonal(
                              onPressed: _startNativeNavigation,
                              icon: const Icon(Icons.navigation),
                              tooltip: "Start Navigation",
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                foregroundColor: AppTheme.primaryGreen,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Expanded Main Status Action Button
                            Expanded(
                              child: _buildStatusActionButton(),
                            ),
                          ] else ...[
                            // If no status action, expand the Navigation button
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _startNativeNavigation,
                                  icon: const Icon(Icons.navigation),
                                  label: const Text('Start Navigation', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStepper(String status, bool isDark) {
    int activeStep = 0;
    if (status == 'EN_ROUTE_TO_PICKUP') activeStep = 0;
    if (status == 'ARRIVED_AT_SOURCE') activeStep = 1;
    if (['COMPLETED', 'DELIVERED'].contains(status)) activeStep = 2;

    final steps = ['En Route', 'Arrived', 'Complete'];
    final accentColor = AppTheme.primaryGreen;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIdx = index ~/ 2;
          final isDone = activeStep > stepIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone ? accentColor : (isDark ? Colors.white10 : Colors.grey.shade300),
            ),
          );
        } else {
          final stepIdx = index ~/ 2;
          final isDone = activeStep > stepIdx;
          final isActive = activeStep == stepIdx;
          final stepName = steps[stepIdx];

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone 
                      ? accentColor 
                      : (isActive ? accentColor.withOpacity(0.2) : Colors.transparent),
                  border: Border.all(
                    color: (isDone || isActive) ? accentColor : (isDark ? Colors.white24 : Colors.black26),
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : (isActive
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryGreen),
                            ),
                          )
                        : null),
              ),
              const SizedBox(width: 6),
              Text(
                stepName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: (isDone || isActive) ? FontWeight.bold : FontWeight.normal,
                  color: (isDone || isActive) 
                      ? (isDark ? Colors.white : Colors.black87) 
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
            ],
          );
        }
      }),
    );
  }

  Widget _buildStatusActionButton() {
    final status = _task['status']?.toString() ?? 'ASSIGNED';
    
    // Terminal statuses don't need buttons
    if (['COMPLETED', 'CANCELLED', 'REJECTED', 'DELIVERED'].contains(status)) {
      return const SizedBox.shrink();
    }
    
    String label = "";
    IconData icon = Icons.arrow_forward;
    VoidCallback? onPressed;
    Color buttonColor = AppTheme.primaryGreen;

    switch (status) {
      case 'ASSIGNED':
        label = "Start Route";
        icon = Icons.play_arrow;
        onPressed = _acceptAndStartRoute;
        break;
      case 'ACCEPTED':
        label = "Start Route";
        icon = Icons.play_arrow;
        onPressed = () => _updateStatus('EN_ROUTE_TO_PICKUP');
        break;
      case 'EN_ROUTE_TO_PICKUP':
        label = "Mark Arrived";
        icon = Icons.location_on;
        onPressed = () => _updateStatus('ARRIVED_AT_SOURCE');
        break;
      case 'ARRIVED_AT_SOURCE':
        label = "Verify Waste";
        icon = Icons.scale;
        onPressed = _showVerificationDialog;
        buttonColor = AppTheme.earthBrown;
        break;
      case 'VERIFIED':
        label = "Confirm Pickup";
        icon = Icons.inventory_2;
        onPressed = () => _updateStatus('PICKED_UP');
        break;
      case 'PICKED_UP':
        label = "Start Route to Destination";
        icon = Icons.local_shipping;
        onPressed = () => _updateStatus('IN_TRANSIT');
        break;
      case 'IN_TRANSIT':
        label = "Arrived at Destination";
        icon = Icons.warehouse;
        onPressed = () => _updateStatus('ARRIVED_AT_DESTINATION');
        break;
      case 'ARRIVED_AT_DESTINATION':
        label = "Complete Delivery";
        icon = Icons.fact_check;
        onPressed = _showDeliveryDialog;
        break;
      default:
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.primaryGreen,
      ),
    );
  }

  String _statusLabel(String? status) {
    final value = (status ?? '').replaceAll('_', ' ').toLowerCase();
    if (value.isEmpty) return 'Unknown';
    return value.split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      setState(() => _isLoadingRoute = true);
      final updatedTask = await _collectorService.updateTaskStatus(_task['id'] as int, newStatus);
      
      // Log location immediately with the new status
      if (_currentPosition != null) {
        await _collectorService.recordLocation(
          taskId: _task['id'] as int,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          status: newStatus,
        );
      }
      
      setState(() {
        _task = updatedTask;
        _initializePoints();
        _isLoadingRoute = false;
      });
      widget.onTaskUpdated?.call();
      _showMessage("Task updated: ${_statusLabel(newStatus)}");
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _acceptAndStartRoute() async {
    try {
      setState(() => _isLoadingRoute = true);
      // Automatically accept first
      await _collectorService.acceptTask(_task['id'] as int);
      // Then start the route (status EN_ROUTE_TO_PICKUP)
      final updatedTask = await _collectorService.updateTaskStatus(_task['id'] as int, 'EN_ROUTE_TO_PICKUP');
      
      if (_currentPosition != null) {
        await _collectorService.recordLocation(
          taskId: _task['id'] as int,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          status: 'EN_ROUTE_TO_PICKUP',
        );
      }
      
      setState(() {
        _task = updatedTask;
        _initializePoints();
        _isLoadingRoute = false;
      });
      widget.onTaskUpdated?.call();
      _showMessage("Route started");
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _acceptTask() async {
    try {
      setState(() => _isLoadingRoute = true);
      final updatedTask = await _collectorService.acceptTask(_task['id'] as int);
      setState(() {
        _task = updatedTask;
        _initializePoints();
        _isLoadingRoute = false;
      });
      widget.onTaskUpdated?.call();
      _showMessage("Task accepted");
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  void _showVerificationDialog() {
    final weightController = TextEditingController(text: _task['estimatedWeight']?.toString() ?? '');
    final categoryController = TextEditingController(text: _task['materialCategory']?.toString() ?? '');
    final materialController = TextEditingController(text: _task['materialType']?.toString() ?? '');
    final notesController = TextEditingController();
    List<XFile> proofFiles = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Verify Waste'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Verified weight (kg)', prefixIcon: Icon(Icons.scale_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Verified category', prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: materialController,
                  decoration: const InputDecoration(labelText: 'Material type', prefixIcon: Icon(Icons.recycling)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes_outlined)),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Text('Proof Photos (${proofFiles.length})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                              if (image != null) {
                                setDialogState(() => proofFiles.add(image));
                              }
                            },
                            icon: const Icon(Icons.add_a_photo, size: 16),
                            label: const Text('Take Photo', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      if (proofFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: proofFiles.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(File(proofFiles[i].path), width: 60, height: 60, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => proofFiles.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final weight = double.tryParse(weightController.text.trim());
                if (weight == null || weight <= 0) {
                  _showMessage('Enter a valid verified weight', isError: true);
                  return;
                }
                if (proofFiles.isEmpty) {
                  _showMessage('Proof photo is required. Please take a picture of the weighing scale.', isError: true);
                  return;
                }
                Navigator.pop(context);
                try {
                  setState(() => _isLoadingRoute = true);
                  final response = await _collectorService.verifyWaste(
                    taskId: _task['id'] as int,
                    verifiedWeight: weight,
                    verifiedCategory: categoryController.text.trim(),
                    verifiedMaterial: materialController.text.trim(),
                    notes: notesController.text.trim(),
                    proofFiles: proofFiles,
                  );
                  Map<String, dynamic> updatedTask = _task;
                  if (response['task'] != null) {
                    updatedTask = response['task'] as Map<String, dynamic>;
                  } else if (response is Map && response.containsKey('status')) {
                    updatedTask = Map<String, dynamic>.from(response);
                  }
                  setState(() {
                    _task = updatedTask;
                    _initializePoints();
                    _isLoadingRoute = false;
                  });
                  widget.onTaskUpdated?.call();
                  _showMessage('Waste verified');
                } catch (e) {
                  setState(() => _isLoadingRoute = false);
                  _showMessage(e.toString(), isError: true);
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDialog() {
    final receiverController = TextEditingController(text: _task['destinationName']?.toString() ?? '');
    final contactController = TextEditingController(text: _task['destinationContact']?.toString() ?? '');
    final weightController = TextEditingController(
      text: _task['verification']?['verifiedWeight']?.toString() ?? _task['estimatedWeight']?.toString() ?? '',
    );
    final conditionController = TextEditingController(text: 'Good');
    final notesController = TextEditingController();
    final otpController = TextEditingController();
    List<XFile> proofFiles = [];
    final bool hasOtp = false; // Disabled PIN verification per request

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Confirm Delivery'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasOtp) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warningOrange.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.pin_outlined, size: 18, color: AppTheme.warningOrange),
                            SizedBox(width: 8),
                            Text('Delivery PIN Required', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ask the receiver for the 4-digit delivery PIN to confirm handover.',
                          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 12),
                          decoration: const InputDecoration(
                            hintText: '● ● ● ●',
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(controller: receiverController, decoration: const InputDecoration(labelText: 'Receiver name')),
                const SizedBox(height: 10),
                TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Receiver contact')),
                const SizedBox(height: 10),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Received weight (kg)'),
                ),
                const SizedBox(height: 10),
                TextField(controller: conditionController, decoration: const InputDecoration(labelText: 'Package condition')),
                const SizedBox(height: 10),
                TextField(controller: notesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.infoBlue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.infoBlue),
                          const SizedBox(width: 8),
                          Text('Delivery Proof (${proofFiles.length})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                              if (image != null) {
                                setDialogState(() => proofFiles.add(image));
                              }
                            },
                            icon: const Icon(Icons.add_a_photo, size: 16),
                            label: const Text('Take Photo', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      if (proofFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: proofFiles.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(File(proofFiles[i].path), width: 60, height: 60, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => proofFiles.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (hasOtp && otpController.text.trim().length != 4) {
                  _showMessage('Enter the 4-digit delivery PIN', isError: true);
                  return;
                }
                Navigator.pop(context);
                try {
                  setState(() => _isLoadingRoute = true);
                  final response = await _collectorService.confirmDelivery(
                    taskId: _task['id'] as int,
                    receiverName: receiverController.text.trim(),
                    receiverContact: contactController.text.trim(),
                    receivedWeight: double.tryParse(weightController.text.trim()),
                    packageCondition: conditionController.text.trim(),
                    notes: notesController.text.trim(),
                    receiverConfirmation: 'CONFIRMED_BY_COLLECTOR',
                    otpCode: otpController.text.trim(),
                    proofFiles: proofFiles,
                  );
                  Map<String, dynamic> updatedTask = _task;
                  if (response['task'] != null) {
                    updatedTask = response['task'] as Map<String, dynamic>;
                  } else {
                    updatedTask = Map<String, dynamic>.from(_task);
                    updatedTask['status'] = 'COMPLETED';
                  }
                  setState(() {
                    _task = updatedTask;
                    _initializePoints();
                    _isLoadingRoute = false;
                  });
                  widget.onTaskUpdated?.call();
                  _showMessage('Delivery completed');
                } catch (e) {
                  setState(() => _isLoadingRoute = false);
                  _showMessage(e.toString(), isError: true);
                }
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, String label, IconData icon) {
    final isSelected = _navigationMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _navigationMode = mode;
          _isLoadingRoute = true;
        });
        _fetchRoute();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryGreen 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
