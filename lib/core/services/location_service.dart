import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

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

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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

  /// NEW: Reverse geocode - Convert coordinates to address
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

        return {
          'street': place.street ?? '',
          'subLocality': place.subLocality ?? '',
          'locality': place.locality ?? '', // City
          'subAdministrativeArea': place.subAdministrativeArea ?? '',
          'administrativeArea': place.administrativeArea ?? '', // Province
          'country': place.country ?? '',
          'postalCode': place.postalCode ?? '',
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error reverse geocoding: $e');
      return null;
    }
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

  // Calculate distance between two coordinates (in kilometers)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
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
}
