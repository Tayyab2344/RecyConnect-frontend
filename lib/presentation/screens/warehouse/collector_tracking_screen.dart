import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/collector_service.dart';
import '../../../core/theme/app_theme.dart';

class CollectorTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> collector;
  const CollectorTrackingScreen({super.key, required this.collector});

  @override
  State<CollectorTrackingScreen> createState() => _CollectorTrackingScreenState();
}

class _CollectorTrackingScreenState extends State<CollectorTrackingScreen> {
  final MapController _mapController = MapController();
  final CollectorService _collectorService = CollectorService();
  Timer? _pollingTimer;

  LatLng? _collectorLocation;
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _activeTrip;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLiveStatus();
    // Poll every 10 seconds for real-time location updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLiveStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLiveStatus({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final userObj = widget.collector['user'] as Map<String, dynamic>? ?? widget.collector;
      final int collectorId = userObj['id'] as int;

      // 1. Get warehouse trips for this collector to find the active trip
      final trips = await _collectorService.getWarehouseTrips(
        collectorId: collectorId,
        status: 'IN_TRANSIT', // Try to get active in-transit trip first
      );

      List<dynamic> activeTrips = trips;
      if (activeTrips.isEmpty) {
        // Fallback to active assigned trips
        activeTrips = await _collectorService.getWarehouseTrips(
          collectorId: collectorId,
          status: 'ASSIGNED',
        );
      }

      if (activeTrips.isNotEmpty) {
        final trip = activeTrips.first;
        _activeTrip = trip;
        _tasks = List<Map<String, dynamic>>.from(trip['tasks'] ?? []);

        // Update collector current location from trip response profile if available
        final collUser = trip['collector'];
        if (collUser != null && collUser['collectorProfile'] != null) {
          final profile = collUser['collectorProfile'];
          if (profile['currentLatitude'] != null && profile['currentLongitude'] != null) {
            _collectorLocation = LatLng(
              double.parse(profile['currentLatitude'].toString()),
              double.parse(profile['currentLongitude'].toString()),
            );
          }
        }
      }

      // If collector location is still null, check the widget data
      if (_collectorLocation == null) {
        final profile = widget.collector['collectorProfile'] ?? {};
        if (profile['currentLatitude'] != null && profile['currentLongitude'] != null) {
          _collectorLocation = LatLng(
            double.parse(profile['currentLatitude'].toString()),
            double.parse(profile['currentLongitude'].toString()),
          );
        }
      }

      // Fetch route points if we have tasks and collector location
      if (_collectorLocation != null && _tasks.isNotEmpty) {
        await _fetchOSRMRoute();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to retrieve tracking data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchOSRMRoute() async {
    if (_collectorLocation == null || _tasks.isEmpty) return;

    // Build the waypoint string starting from collector's current location,
    // then to the source coordinates, and then the destination coordinates.
    // To keep it simple, we construct a route through all pending tasks.
    final List<LatLng> waypoints = [_collectorLocation!];
    for (final task in _tasks) {
      final String taskStatus = task['status'] ?? 'ASSIGNED';
      if (taskStatus == 'COMPLETED' || taskStatus == 'CANCELLED') continue;

      final double? sourceLat = task['sourceLatitude'] != null ? double.tryParse(task['sourceLatitude'].toString()) : null;
      final double? sourceLon = task['sourceLongitude'] != null ? double.tryParse(task['sourceLongitude'].toString()) : null;
      final double? destLat = task['destinationLatitude'] != null ? double.tryParse(task['destinationLatitude'].toString()) : null;
      final double? destLon = task['destinationLongitude'] != null ? double.tryParse(task['destinationLongitude'].toString()) : null;

      if (taskStatus == 'PICKED_UP' || taskStatus == 'IN_TRANSIT') {
        // If picked up, path is from current collector position to the destination
        if (destLat != null && destLon != null) {
          waypoints.add(LatLng(destLat, destLon));
        }
      } else {
        // If not picked up yet, path is from collector -> source -> destination
        if (sourceLat != null && sourceLon != null) {
          waypoints.add(LatLng(sourceLat, sourceLon));
        }
        if (destLat != null && destLon != null) {
          waypoints.add(LatLng(destLat, destLon));
        }
      }
    }

    if (waypoints.length < 2) {
      // No active tasks needing navigation
      return;
    }

    try {
      final String coords = waypoints.map((w) => '${w.longitude},${w.latitude}').join(';');
      final String url = 'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
        
        final List<LatLng> points = coordinates.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        
        if (mounted) {
          setState(() {
            _routePoints = points;
          });
        }
      }
    } catch (e) {
      debugPrint("OSRM routing API error in tracking: $e");
      // Fallback to straight lines connecting waypoints
      if (mounted) {
        setState(() {
          _routePoints = waypoints;
        });
      }
    }
  }

  LatLng _getCenterCoordinate() {
    if (_collectorLocation != null) return _collectorLocation!;
    if (_tasks.isNotEmpty) {
      final double? sourceLat = _tasks.first['sourceLatitude'] != null ? double.tryParse(_tasks.first['sourceLatitude'].toString()) : null;
      final double? sourceLon = _tasks.first['sourceLongitude'] != null ? double.tryParse(_tasks.first['sourceLongitude'].toString()) : null;
      if (sourceLat != null && sourceLon != null) {
        return LatLng(sourceLat, sourceLon);
      }
    }
    return const LatLng(31.4015, 74.2405); // Default Lahore / Islamabad coordinates
  }

  @override
  Widget build(BuildContext context) {
    final LatLng centerLatLng = _getCenterCoordinate();
    final bool hasNoLocation = _collectorLocation == null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking: ${widget.collector['name']}'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchLiveStatus(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchLiveStatus(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // The OSM Map
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: centerLatLng,
                        initialZoom: 13.5,
                        maxZoom: 18,
                        minZoom: 8,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.recyconnect.app',
                        ),

                        // Route Polyline
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: AppTheme.primaryGreen.withOpacity(0.8),
                                strokeWidth: 5.0,
                                borderColor: Colors.black.withOpacity(0.3),
                                borderStrokeWidth: 1.0,
                              ),
                            ],
                          ),

                        // Pin Markers
                        MarkerLayer(
                          markers: [
                            // 1. Collector Vehicle Pin
                            if (_collectorLocation != null)
                              Marker(
                                point: _collectorLocation!,
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                                ),
                              ),

                            // 2. Task Pins
                            ..._tasks.expand((task) {
                              final String status = task['status'] ?? 'ASSIGNED';
                              if (status == 'COMPLETED' || status == 'CANCELLED') return [];

                              final List<Marker> markers = [];
                              final double? sourceLat = task['sourceLatitude'] != null ? double.tryParse(task['sourceLatitude'].toString()) : null;
                              final double? sourceLon = task['sourceLongitude'] != null ? double.tryParse(task['sourceLongitude'].toString()) : null;
                              final double? destLat = task['destinationLatitude'] != null ? double.tryParse(task['destinationLatitude'].toString()) : null;
                              final double? destLon = task['destinationLongitude'] != null ? double.tryParse(task['destinationLongitude'].toString()) : null;

                              // Pickup location
                              if (sourceLat != null && sourceLon != null && status != 'PICKED_UP' && status != 'IN_TRANSIT') {
                                markers.add(
                                  Marker(
                                    point: LatLng(sourceLat, sourceLon),
                                    width: 45,
                                    height: 45,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: Text(
                                            '${task['sequenceIndex'] != null ? task['sequenceIndex'] + 1 : 'P'}',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                                          child: const Text('PICKUP', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Dropoff location
                              if (destLat != null && destLon != null) {
                                markers.add(
                                  Marker(
                                    point: LatLng(destLat, destLon),
                                    width: 45,
                                    height: 45,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Icon(Icons.warehouse, color: Colors.white, size: 14),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                                          child: const Text('DROPOFF', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return markers;
                            }),
                          ],
                        ),
                      ],
                    ),

                    // No location warning overlay
                    if (hasNoLocation)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Card(
                          margin: const EdgeInsets.all(32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_off_rounded, size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                const Text(
                                  'GPS Signal Offline',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'The collector has not broadcasted their current coordinates yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _fetchLiveStatus(),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                                  child: const Text('Retry Refresh'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Recenter button
                    if (!hasNoLocation)
                      Positioned(
                        right: 16,
                        bottom: 230,
                        child: FloatingActionButton.small(
                          heroTag: 'recenter_tracker',
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryGreen,
                          onPressed: () {
                            if (_collectorLocation != null) {
                              _mapController.move(_collectorLocation!, 14.5);
                            }
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ),

                    // Status and tasks bottom panel
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.collector['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(
                                      'ID: ${widget.collector['collectorId']}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (_activeTrip?['status'] == 'IN_TRANSIT' ? Colors.green : Colors.blue).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _activeTrip?['status'] ?? 'ON ASSIGNMENT',
                                    style: TextStyle(
                                      color: _activeTrip?['status'] == 'IN_TRANSIT' ? Colors.green[800] : Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text(
                              'Assigned Tasks Sequence:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 90,
                              child: _tasks.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No active tasks found in this trip.',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _tasks.length,
                                      itemBuilder: (context, i) {
                                        final t = _tasks[i];
                                        final status = t['status'] ?? 'ASSIGNED';
                                        final isCompleted = status == 'COMPLETED';
                                        final isPickedUp = status == 'PICKED_UP' || status == 'IN_TRANSIT';

                                        Color statusColor = Colors.orange;
                                        if (isCompleted) {
                                          statusColor = Colors.green;
                                        } else if (isPickedUp) {
                                          statusColor = Colors.blue;
                                        }

                                        return Container(
                                          width: 160,
                                          margin: const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Stop #${i + 1}: Order #${t['orderId']}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${t['materialCategory']} (${t['estimatedWeight']} kg)',
                                                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    status.toString().replaceAll('_', ' '),
                                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
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
