import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  double _totalDistanceKm = 0.0;
  double _totalDurationMinutes = 0.0;
  bool _isLoadingRoute = true;
  DateTime? _lastRouteFetchTime;

  @override
  void initState() {
    super.initState();
    _task = Map<String, dynamic>.from(widget.task);
    _initializePoints();
    _startLocationTracking();
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
    
    // Parse source coordinates (seller)
    final double? sourceLat = task['seller']?['lat'] != null 
        ? double.tryParse(task['seller']['lat'].toString()) 
        : (task['sourceLatitude'] != null ? double.tryParse(task['sourceLatitude'].toString()) : null);
    final double? sourceLon = task['seller']?['lng'] != null 
        ? double.tryParse(task['seller']['lng'].toString()) 
        : (task['sourceLongitude'] != null ? double.tryParse(task['sourceLongitude'].toString()) : null);
    
    if (sourceLat != null && sourceLon != null && sourceLat != 0.0) {
      _pickupPosition = LatLng(sourceLat, sourceLon);
    } else {
      // Default fallback based on address
      _pickupPosition = _getCoordinatesFallback(task['sourceAddress']?.toString(), const LatLng(33.6844, 73.0479));
    }

    // Parse destination coordinates (buyer)
    final double? destLat = task['buyer']?['lat'] != null 
        ? double.tryParse(task['buyer']['lat'].toString()) 
        : (task['destinationLatitude'] != null ? double.tryParse(task['destinationLatitude'].toString()) : null);
    final double? destLon = task['buyer']?['lng'] != null 
        ? double.tryParse(task['buyer']['lng'].toString()) 
        : (task['destinationLongitude'] != null ? double.tryParse(task['destinationLongitude'].toString()) : null);
        
    if (destLat != null && destLon != null && destLat != 0.0) {
      _warehousePosition = LatLng(destLat, destLon);
    } else {
      _warehousePosition = _getCoordinatesFallback(task['destinationAddress']?.toString(), const LatLng(33.7294, 73.0931));
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

    // Fetch initial route
    _fetchRoute();

    // Subscribe to continuous location updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((Position pos) {
      if (mounted) {
        final now = DateTime.now();
        if (_lastLocationUpdate == null || now.difference(_lastLocationUpdate!).inSeconds >= 3) {
          _lastLocationUpdate = now;
          
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
          });
          
          // Auto-pan: pan the map to current location
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, _mapController.camera.zoom);
          }
          
          // Only refresh route at most once every 30 seconds to prevent OSRM rate-limiting
          if (_lastRouteFetchTime == null || now.difference(_lastRouteFetchTime!).inSeconds > 30) {
            _lastRouteFetchTime = now;
            _fetchRoute();
          }

          // Log location to server
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

  String _getStageDescription(String taskType, bool isPickedUp) {
    if (isPickedUp) {
      if (taskType == 'SELLER_TO_WAREHOUSE') {
        return "Delivering to Warehouse";
      }
      return "Delivering to Buyer";
    } else {
      if (taskType == 'WAREHOUSE_TO_BUYER') {
        return "Picking up from Warehouse";
      }
      return "Picking up from Seller";
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = true;
        });
      }
      return;
    }

    final LatLng pickup = _pickupPosition ?? const LatLng(34.1504, 73.2078);
    final LatLng dest = _warehousePosition ?? const LatLng(34.1504, 73.2078);
    final String status = _task['status']?.toString() ?? 'ASSIGNED';

    final bool isPickedUp = ['PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'COMPLETED', 'DELIVERED'].contains(status);
    final LatLng target = isPickedUp ? dest : pickup;
    final LatLng start = _currentPosition!;

    try {
      final String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${target.longitude},${target.latitude}'
          '?overview=full&geometries=geojson';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
        final List<LatLng> points = coordinates.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
        final distanceMeters = data['routes'][0]['distance'] as num? ?? 0;
        final durationSeconds = data['routes'][0]['duration'] as num? ?? 0;

        if (mounted) {
          setState(() {
            _routePoints = points;
            _totalDistanceKm = distanceMeters / 1000.0;
            _totalDurationMinutes = durationSeconds / 60.0;
            _isLoadingRoute = false;
          });
        }
      } else {
        // Fallback to straight line & direct distance calculation
        final directDistanceMeters = Geolocator.distanceBetween(
          start.latitude, start.longitude, target.latitude, target.longitude
        );
        if (mounted) {
          setState(() {
            _routePoints = [start, target];
            _totalDistanceKm = directDistanceMeters / 1000.0;
            _totalDurationMinutes = (directDistanceMeters / 1000.0) * 2.0; // Estimate 2 mins per km
            _isLoadingRoute = false;
          });
        }
      }
    } catch (e) {
      debugPrint("OSRM routing API error: $e");
      final directDistanceMeters = Geolocator.distanceBetween(
        start.latitude, start.longitude, target.latitude, target.longitude
      );
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _routePoints = [start, target];
          _totalDistanceKm = directDistanceMeters / 1000.0;
          _totalDurationMinutes = (directDistanceMeters / 1000.0) * 2.0;
        });
      }
    }
  }

  Future<void> _startNativeNavigation() async {
    final LatLng pickup = _pickupPosition ?? const LatLng(34.1504, 73.2078);
    final LatLng dest = _warehousePosition ?? const LatLng(34.1504, 73.2078);
    final String status = _task['status']?.toString() ?? 'ASSIGNED';
    final bool isPickedUp = ['PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'COMPLETED', 'DELIVERED'].contains(status);
    final LatLng target = isPickedUp ? dest : pickup;
    
    final double lat = target.latitude;
    final double lng = target.longitude;
    
    final uri = Uri.parse('google.navigation:q=$lat,$lng');
    final appleUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri);
      } else {
        final fallbackUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          _showMessage("Could not open navigation app", isError: true);
        }
      }
    } catch (e) {
      _showMessage("Error opening maps: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng pickup = _pickupPosition ?? const LatLng(34.1504, 73.2078);
    final LatLng dest = _warehousePosition ?? const LatLng(34.1504, 73.2078);
    final String status = _task['status']?.toString() ?? 'ASSIGNED';
    


    final bool isPickedUp = ['PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'COMPLETED', 'DELIVERED'].contains(status);
    final LatLng target = isPickedUp ? dest : pickup;

    final LatLng center = _currentPosition ?? target;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Flutter OpenStreetMap Widget
          FlutterMap(
            key: ValueKey('${_routePoints.length},${_currentPosition?.latitude}'),
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

              // Road Route path
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFF1D9E75),
                      strokeWidth: 5.0,
                    ),
                  ],
                ),

              // Custom Pin Markers Layer
              MarkerLayer(
                markers: [
                  // Collector Vehicle Marker
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 60,
                      height: 60,
                      child: const PulsingCollectorMarker(),
                    ),

                  // Destination Red Pin Marker
                  Marker(
                    point: target,
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 45,
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
                    color: isDark ? const Color(0xFF1E1E1E).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
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
                
                // Glassmorphic Stage Title Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    _getStageDescription(_task['taskType']?.toString() ?? '', isPickedUp),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isPickedUp ? Colors.blue : Colors.orange,
                    ),
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
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
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
                      Container(width: 1.5, height: 12, color: Colors.grey.withValues(alpha: 0.5)),
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
                color: isDark ? const Color(0xFF121212).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, -5)),
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
                          color: isPickedUp ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStageDescription(_task['taskType']?.toString() ?? '', isPickedUp).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPickedUp ? Colors.blue : Colors.orange,
                          ),
                        ),
                      ),
                      if (_isLoadingRoute)
                        const SizedBox(width: 14, height: 14, child: SkeletonLoader(width: 14, height: 14, borderRadius: 7))
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPickedUp
                        ? (_task['buyer']?['name'] ?? _task['destinationName'] ?? 'Buyer')
                        : (_task['seller']?['name'] ?? _task['sourceName'] ?? 'Seller'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isPickedUp
                              ? "${_task['buyer']?['street'] ?? _task['destinationAddress'] ?? ''}, ${_task['buyer']?['area'] ?? ''}"
                              : "${_task['seller']?['street'] ?? _task['sourceAddress'] ?? ''}, ${_task['seller']?['area'] ?? ''}",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _currentPosition == null
                            ? 'Awaiting location...'
                            : (_isLoadingRoute
                                ? 'Calculating route...'
                                : '${_totalDistanceKm.toStringAsFixed(1)} km (${_totalDurationMinutes.toStringAsFixed(0)} mins away)'),
                        style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
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
                              _mapController.move(center, 15);
                            },
                            icon: const Icon(Icons.my_location),
                            tooltip: "Re-center",
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Navigate Button
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _startNativeNavigation,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.navigation, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Navigate',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          if (hasAction) ...[
                            const SizedBox(width: 8),
                            // Expanded Main Status Action Button
                            Expanded(
                              child: _buildStatusActionButton(),
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
    final bool isPickedUp = ['PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'COMPLETED', 'DELIVERED'].contains(status);
    final bool isCompleted = ['COMPLETED', 'DELIVERED'].contains(status);
    
    int activeStep = 0;
    if (isCompleted) {
      activeStep = 2;
    } else if (isPickedUp) {
      activeStep = 1;
    } else {
      activeStep = 0;
    }

    final steps = ['Pickup', 'Delivery', 'Complete'];
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
                      : (isActive ? accentColor.withValues(alpha: 0.2) : Colors.transparent),
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
    
    final bool isPickedUp = ['PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION'].contains(status);

    String label = isPickedUp ? "Deliver" : "Collect";
    IconData icon = isPickedUp ? Icons.fact_check : Icons.inventory_2;
    VoidCallback onPressed = isPickedUp ? _markAsDelivered : _markAsCollected;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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



  Future<void> _markAsCollected() async {
    try {
      setState(() => _isLoadingRoute = true);
      final updatedTask = await _collectorService.markTaskAsCollected(_task['id'] as int);
      
      // Log location immediately with the new status
      if (_currentPosition != null) {
        await _collectorService.recordLocation(
          taskId: _task['id'] as int,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          status: 'PICKED_UP',
        );
      }
      
      setState(() {
        _task = updatedTask;
        _initializePoints();
        _isLoadingRoute = false;
      });
      widget.onTaskUpdated?.call();
      _showMessage("Task marked as collected");
      // Fetch new route to the buyer's destination
      _fetchRoute();
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _markAsDelivered() async {
    try {
      setState(() => _isLoadingRoute = true);
      // Pass estimated distance if available
      final double distance = _totalDistanceKm > 0 ? _totalDistanceKm : 5.0;
      final response = await _collectorService.markTaskAsDelivered(_task['id'] as int, distance: distance);
      
      Map<String, dynamic> updatedTask = _task;
      if (response['task'] != null) {
        updatedTask = response['task'] as Map<String, dynamic>;
      } else if (response.containsKey('status')) {
        updatedTask = Map<String, dynamic>.from(response);
      } else {
        updatedTask = Map<String, dynamic>.from(_task);
        updatedTask['status'] = 'COMPLETED';
      }
      
      // Log location immediately with the completed status
      if (_currentPosition != null) {
        await _collectorService.recordLocation(
          taskId: _task['id'] as int,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          status: 'COMPLETED',
        );
      }

      setState(() {
        _task = updatedTask;
        _initializePoints();
        _isLoadingRoute = false;
      });
      widget.onTaskUpdated?.call();
      _showMessage("Task marked as delivered");
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      _showMessage(e.toString(), isError: true);
    }
  }
}

class PulsingCollectorMarker extends StatefulWidget {
  const PulsingCollectorMarker({super.key});

  @override
  State<PulsingCollectorMarker> createState() => _PulsingCollectorMarkerState();
}

class _PulsingCollectorMarkerState extends State<PulsingCollectorMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
