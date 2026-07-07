import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class InAppMapScreen extends StatefulWidget {
  final LatLng destination;
  final String destinationName;
  final String destinationAddress;
  final LatLng? initialSource;

  const InAppMapScreen({
    super.key,
    required this.destination,
    required this.destinationName,
    required this.destinationAddress,
    this.initialSource,
  });

  @override
  State<InAppMapScreen> createState() => _InAppMapScreenState();
}

class _InAppMapScreenState extends State<InAppMapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  double _routeDistanceKm = 0.0;
  double _routeDurationMins = 0.0;
  bool _isFollowingUser = true;
  StreamSubscription<Position>? _positionStreamSub;
  
  // Simulated navigation mode
  bool _isSimulating = false;
  Timer? _simulationTimer;
  int _simulationIndex = 0;
  double _bearing = 0.0;
  double _currentSpeedKmh = 0.0;

  // Animation for user location pulse
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialSource ?? const LatLng(34.1504, 73.2078);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initLocationAndRouting();
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _simulationTimer?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * pi / 180.0;
    final double lon1 = start.longitude * pi / 180.0;
    final double lat2 = end.latitude * pi / 180.0;
    final double lon2 = end.longitude * pi / 180.0;

    final double dLon = lon2 - lon1;

    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    return atan2(y, x);
  }

  Future<void> _initLocationAndRouting() async {
    // 1. Get initial current position if not provided
    if (widget.initialSource == null) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          await Geolocator.requestPermission();
        }
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      } catch (e) {
        debugPrint('Error getting initial location: $e');
      }
    }

    // 2. Fetch initial route
    await _fetchRoute();

    // 3. Listen to live location updates
    _startLiveLocationUpdates();
  }

  void _startLiveLocationUpdates() {
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );
      _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
        if (_isSimulating) return; // Skip live GPS updates during simulation
        
        final newLatLng = LatLng(position.latitude, position.longitude);
        
        double newBearing = _bearing;
        if (_currentPosition != null) {
          newBearing = _calculateBearing(_currentPosition!, newLatLng);
        }

        setState(() {
          _currentPosition = newLatLng;
          _bearing = newBearing;
        });

        if (_isFollowingUser) {
          _mapController.move(newLatLng, _mapController.camera.zoom);
        }

        // Periodically refresh route points as user moves
        _fetchRoute(silent: true);
      });
    } catch (e) {
      debugPrint('Error starting location stream: $e');
    }
  }

  Future<void> _fetchRoute({bool silent = false}) async {
    if (_currentPosition == null) return;
    
    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      final String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${_currentPosition!.longitude},${_currentPosition!.latitude};'
          '${widget.destination.longitude},${widget.destination.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          final List<LatLng> points = coordinates
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          final distanceMeters = data['routes'][0]['distance'] as num? ?? 0;
          final durationSeconds = data['routes'][0]['duration'] as num? ?? 0;

          if (mounted) {
            setState(() {
              _routePoints = points;
              // Use the actual OSRM driving distance directly (real road path)
              _routeDistanceKm = distanceMeters / 1000.0;
              _routeDurationMins = durationSeconds / 60.0;
              _isLoading = false;
              if (points.length > 1) {
                _bearing = _calculateBearing(points[0], points[1]);
              }
            });
          }
        }
      } else {
        _setDirectFallbackRoute();
      }
    } catch (e) {
      debugPrint('Error fetching navigation route: $e');
      _setDirectFallbackRoute();
    }
  }

  void _setDirectFallbackRoute() {
    if (mounted) {
      setState(() {
        _routePoints = [_currentPosition!, widget.destination];
        // Scale fallback distance using realistic city road circuitry factor (1.35x)
        _routeDistanceKm = (Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          widget.destination.latitude,
          widget.destination.longitude,
        ) / 1000.0) * 1.35;
        _routeDurationMins = _routeDistanceKm * 2.0; // Assume 30km/h average
        _isLoading = false;
        _bearing = _calculateBearing(_currentPosition!, widget.destination);
      });
    }
  }

  void _toggleSimulation() {
    if (_isSimulating) {
      _simulationTimer?.cancel();
      setState(() {
        _isSimulating = false;
        _currentSpeedKmh = 0.0;
      });
      _initLocationAndRouting(); // Reset to live GPS
    } else {
      if (_routePoints.isEmpty) return;
      setState(() {
        _isSimulating = true;
        _simulationIndex = 0;
        _currentPosition = _routePoints.first;
        _currentSpeedKmh = 45.0; // Starting speed in km/h
      });

      if (_routePoints.length > 1) {
        _bearing = _calculateBearing(_routePoints[0], _routePoints[1]);
      }

      _mapController.move(_currentPosition!, 16.5);

      // Start simulated drive along route points
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (_simulationIndex >= _routePoints.length - 1) {
          timer.cancel();
          setState(() {
            _isSimulating = false;
            _currentPosition = widget.destination;
            _routeDistanceKm = 0.0;
            _routeDurationMins = 0.0;
            _currentSpeedKmh = 0.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have arrived at your destination!')),
          );
          return;
        }

        _simulationIndex++;
        final nextPos = _routePoints[_simulationIndex];
        
        // Calculate bearing towards next coordinate node
        double newBearing = _bearing;
        if (_simulationIndex < _routePoints.length - 1) {
          newBearing = _calculateBearing(nextPos, _routePoints[_simulationIndex + 1]);
        }

        // Simulate natural speed variations around the 50 km/h average
        final double speedVariance = -4.0 + (Random().nextDouble() * 8.0);
        double speed = _currentSpeedKmh + speedVariance;
        if (speed < 30.0) speed = 30.0;
        if (speed > 60.0) speed = 60.0;

        setState(() {
          _currentPosition = nextPos;
          _bearing = newBearing;
          _currentSpeedKmh = speed;
          // Dynamically reduce remaining distance/duration as we drive
          final ratio = 1.0 - (_simulationIndex / _routePoints.length);
          _routeDistanceKm = _routeDistanceKm * ratio;
          _routeDurationMins = _routeDurationMins * ratio;
        });

        if (_isFollowingUser) {
          _mapController.move(nextPos, 16.5);
        }
      });
    }
  }

  String _getNavigationInstruction() {
    if (_routeDistanceKm < 0.1) {
      return "Arrived at ${widget.destinationName}!";
    }
    if (_isSimulating) {
      if (_simulationIndex == 0) return "Head toward the highlighted route";
      if (_simulationIndex > _routePoints.length - 5) return "In 100m, your destination will be on the left";
      
      // Generate some dummy directions to feel like a GPS
      final hash = _simulationIndex % 4;
      switch (hash) {
        case 0: return "Keep straight on the highway";
        case 1: return "In 300m, turn left at the intersection";
        case 2: return "Continue straight toward your destination";
        default: return "Turn right on the next street";
      }
    }
    return "Follow the highlighted path to ${widget.destinationName}";
  }

  IconData _getNavigationIcon() {
    if (_routeDistanceKm < 0.1) return Icons.check_circle_outline;
    if (_isSimulating) {
      final hash = _simulationIndex % 4;
      switch (hash) {
        case 1: return Icons.turn_left;
        case 3: return Icons.turn_right;
        default: return Icons.arrow_upward;
      }
    }
    return Icons.navigation;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryGreen;
    
    // Calculate ETA
    final etaTime = DateTime.now().add(Duration(seconds: (_routeDurationMins * 60).round()));
    final etaString = DateFormat('h:mm a').format(etaTime);

    return Scaffold(
      body: Stack(
        children: [
          // 1. The Map View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition!,
              initialZoom: 15.5,
              maxZoom: 18,
              minZoom: 10,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && _isFollowingUser) {
                  setState(() {
                    _isFollowingUser = false;
                  });
                }
              },
            ),
            children: [
              // Tile map layer (standard dark/light)
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.recyconnect.app',
              ),

              // Route path Polyline
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Shadow line for a premium glow effect
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFF1A73E8).withValues(alpha: 0.25),
                      strokeWidth: 11.0,
                    ),
                    // Core line
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFF1A73E8),
                      strokeWidth: 7.0,
                    ),
                  ],
                ),

              // Pin Markers Layer
              MarkerLayer(
                markers: [
                  // Starting position or current user marker
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 25 + (_pulseController.value * 25),
                                height: 25 + (_pulseController.value * 25),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8).withValues(alpha: 0.3 * (1.0 - _pulseController.value)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ]
                                ),
                              ),
                              Transform.rotate(
                                angle: _bearing,
                                child: const Icon(
                                  Icons.navigation,
                                  color: Color(0xFF1A73E8),
                                  size: 20,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  // Destination Flag Pin Marker
                  Marker(
                    point: widget.destination,
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 44,
                        ),
                        Positioned(
                          top: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.flag,
                                color: Colors.redAccent,
                                size: 9,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Google Maps style GREEN HEADER BAR
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F7D52), // Classic Google Maps dark green
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Transform.rotate(
                      angle: _getNavigationIcon() == Icons.navigation ? -0.7 : 0.0,
                      child: Icon(
                        _getNavigationIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getNavigationInstruction(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _routeDistanceKm > 0
                              ? "Remaining: ${_routeDistanceKm.toStringAsFixed(1)} km"
                              : "Arriving...",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Side Float Buttons (Re-center & Simulation)
          Positioned(
            right: 16,
            bottom: 160,
            child: Column(
              children: [
                // Simulation Toggle Button
                FloatingActionButton.small(
                  heroTag: 'sim_btn',
                  backgroundColor: _isSimulating ? Colors.orangeAccent : Colors.grey[800],
                  foregroundColor: Colors.white,
                  onPressed: _toggleSimulation,
                  tooltip: _isSimulating ? "Stop Simulation" : "Simulate Drive",
                  child: Icon(_isSimulating ? Icons.stop : Icons.play_arrow),
                ),
                const SizedBox(height: 12),
                
                // Recenter location button
                FloatingActionButton.small(
                  heroTag: 'center_btn',
                  backgroundColor: _isFollowingUser ? primaryColor : Colors.grey[800],
                  foregroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isFollowingUser = true;
                    });
                    if (_currentPosition != null) {
                      _mapController.move(_currentPosition!, 16.0);
                    }
                  },
                  tooltip: "Recenter Map",
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // 3.5. Speedometer & Speed Limit HUD (Google Maps style)
          if (_isSimulating)
            Positioned(
              left: 16,
              bottom: 160,
              child: Column(
                children: [
                  // Speed limit indicator (standard round red-bordered sign)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 4.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "60",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Current Speed indicator
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentSpeedKmh.toStringAsFixed(0),
                            style: TextStyle(
                              color: _currentSpeedKmh > 60 ? Colors.red : (isDark ? Colors.white : Colors.black),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "km/h",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 4. Google Maps bottom stats panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _routeDurationMins > 0
                                    ? "${_routeDurationMins.toStringAsFixed(0)} min"
                                    : "Arrived",
                                style: const TextStyle(
                                  color: Color(0xFF0F7D52), // Google Green
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "(${_routeDistanceKm.toStringAsFixed(1)} km)",
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ETA: $etaString",
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: primaryColor, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.destinationAddress,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey[350] : Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "Calculating Navigation Route...",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
