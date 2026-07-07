import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class LocationService {
  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Get current GPS location
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      if (kDebugMode) print('Error getting location: $e');
      return null;
    }
  }

  // Get location with timeout
  Future<Map<String, double>?> getCurrentLocationWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await getCurrentLocation().timeout(
        timeout,
        onTimeout: () => null,
      );
    } catch (e) {
      if (kDebugMode) print('Location timeout: $e');
      return null;
    }
  }

  Future<Map<String, String>?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        final displayName = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        return {
          'displayName': displayName,
          'street': place.street ?? '',
          'subLocality': place.subLocality ?? '',
          'locality': place.locality ?? '', // City
          'subAdministrativeArea': place.subAdministrativeArea ?? '',
          'administrativeArea': place.administrativeArea ?? '', // Province
          'country': place.country ?? '',
          'postalCode': place.postalCode ?? '',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Native geocoding failed: $e. Using Nominatim fallback...');
    }

    try {
      final fallback = await reverseGeocodeNominatim(latitude, longitude);
      if (fallback != null) {
        return {
          'displayName': fallback['displayName'] ?? '',
          'street': fallback['street'] ?? '',
          'subLocality': fallback['subLocality'] ?? '',
          'locality': fallback['locality'] ?? '',
          'subAdministrativeArea': '',
          'administrativeArea': fallback['administrativeArea'] ?? '',
          'country': fallback['country'] ?? '',
          'postalCode': fallback['postalCode'] ?? '',
        };
      }
    } catch (err) {
      if (kDebugMode) print('Nominatim reverse geocoding fallback failed: $err');
    }
    return null;
  }

  /// NEW: Smart city matcher - Find best matching city from our list
  String? matchCityFromAddress(
    Map<String, String> address,
    List<String> availableCities,
  ) {
    // Try exact match with locality (city name from GPS)
    String? gpsCity = address['locality'];
    if (gpsCity != null && gpsCity.isNotEmpty) {
      // Direct match
      if (availableCities.contains(gpsCity)) {
        return gpsCity;
      }

      // Case-insensitive match
      String gpsCityLower = gpsCity.toLowerCase();
      for (String city in availableCities) {
        if (city.toLowerCase() == gpsCityLower) {
          return city;
        }
      }

      // Partial match (e.g., "Karachi City" matches "Karachi")
      for (String city in availableCities) {
        if (gpsCityLower.contains(city.toLowerCase()) ||
            city.toLowerCase().contains(gpsCityLower)) {
          return city;
        }
      }
    }

    // Fallback: try subAdministrativeArea
    String? district = address['subAdministrativeArea'];
    if (district != null && district.isNotEmpty) {
      String districtLower = district.toLowerCase();
      for (String city in availableCities) {
        if (city.toLowerCase() == districtLower) {
          return city;
        }
      }
    }

    return null;
  }

  /// NEW: Smart area matcher - Find best matching area from list
  String? matchAreaFromAddress(
    Map<String, String> address,
    List<String> availableAreas,
  ) {
    // Try subLocality (neighborhood)
    String? gpsArea = address['subLocality'];
    if (gpsArea != null && gpsArea.isNotEmpty) {
      // Direct match
      if (availableAreas.contains(gpsArea)) {
        return gpsArea;
      }

      // Case-insensitive match
      String gpsAreaLower = gpsArea.toLowerCase();
      for (String area in availableAreas) {
        if (area.toLowerCase() == gpsAreaLower) {
          return area;
        }
      }

      // Partial match
      for (String area in availableAreas) {
        if (gpsAreaLower.contains(area.toLowerCase()) ||
            area.toLowerCase().contains(gpsAreaLower)) {
          return area;
        }
      }
    }

    // Fallback: try street name
    String? street = address['street'];
    if (street != null && street.isNotEmpty) {
      String streetLower = street.toLowerCase();
      for (String area in availableAreas) {
        if (streetLower.contains(area.toLowerCase()) ||
            area.toLowerCase().contains(streetLower)) {
          return area;
        }
      }
    }

    return null;
  }

  /// NEW: Full location detection with smart matching
  Future<Map<String, dynamic>?> detectLocationAndMatch(
    List<String> availableCities,
    Function(String) getAreasForCity,
  ) async {
    // Get GPS position
    Map<String, double>? position = await getCurrentLocationWithTimeout();
    if (position == null) {
      return null;
    }

    double latitude = position['latitude']!;
    double longitude = position['longitude']!;

    // Reverse geocode to get address
    Map<String, String>? address = await getAddressFromCoordinates(
      latitude,
      longitude,
    );

    if (address == null) {
      // Return just coordinates if reverse geocoding fails
      return {
        'latitude': latitude,
        'longitude': longitude,
        'city': null,
        'area': null,
        'fullAddress': null,
      };
    }

    // Match city
    String? matchedCity = matchCityFromAddress(address, availableCities);

    // Match area (only if city found)
    String? matchedArea;
    if (matchedCity != null) {
      List<String> areas = getAreasForCity(matchedCity);
      matchedArea = matchAreaFromAddress(address, areas);
    }

    // Build full address string
    String fullAddress = [
      address['street'],
      address['subLocality'],
      address['locality'],
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': matchedCity,
      'area': matchedArea,
      'fullAddress': fullAddress,
      'rawAddress': address,
    };
  }

  // Calculate distance between two coordinates (in kilometers, scaled to approximate road/driving distance)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final straightLineKm = Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
    // Scale straight line to road distance using standard 1.8x multiplier
    return straightLineKm * 1.8;
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings (for permission)
  Future<void> openAppSettings() async {
    await Permission.location.request();
    if (await Permission.location.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  /// Nominatim-based forward geocoding (search coordinates by address query)
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'RecyConnectApp/1.0 (contact: attock.dev@gmail.com)',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      if (kDebugMode) print('Nominatim search error: $e');
    }
    return [];
  }

  /// Forward-geocode an address string to lat/lng via Nominatim.
  /// Returns the first result's coordinates, or null if nothing found.
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final results = await searchLocation(address);
      if (results.isNotEmpty) {
        final first = results.first;
        final lat = double.tryParse('${first['lat']}');
        final lng = double.tryParse('${first['lon']}');
        if (lat != null && lng != null) {
          return {'latitude': lat, 'longitude': lng};
        }
      }
    } catch (e) {
      if (kDebugMode) print('geocodeAddress error: $e');
    }
    return null;
  }

  /// Nominatim-based reverse geocoding fallback
  Future<Map<String, dynamic>?> reverseGeocodeNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'RecyConnectApp/1.0 (contact: attock.dev@gmail.com)',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        
        final street = address['road']?.toString() ?? address['suburb']?.toString() ?? '';
        final subLocality = address['suburb']?.toString() ?? address['neighbourhood']?.toString() ?? '';
        final locality = address['city']?.toString() ?? address['town']?.toString() ?? address['village']?.toString() ?? address['county']?.toString() ?? '';
        final province = address['state']?.toString() ?? '';
        final country = address['country']?.toString() ?? '';
        final postalCode = address['postcode']?.toString() ?? '';
        
        final displayName = data['display_name']?.toString() ?? '';
        
        return {
          'displayName': displayName,
          'street': street,
          'subLocality': subLocality,
          'locality': locality,
          'administrativeArea': province,
          'country': country,
          'postalCode': postalCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Nominatim reverse geocoding error: $e');
    }
    return null;
  }
}
