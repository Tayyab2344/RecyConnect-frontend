import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class ListingService {
  final ApiService _apiService = ApiService();

  // Create a new listing
  Future<Listing> createListing(Listing listing) async {
    try {
      final jsonData = listing.toCreateJson();
      if (kDebugMode) print('DEBUG: Creating listing with data: $jsonData');
      if (kDebugMode) print('DEBUG: Images count: ${jsonData['images']?.length ?? 0}');
      
      final response = await _apiService.post(
        '/listings',
        jsonData,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return Listing.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create listing');
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error creating listing: $e');
      throw Exception('Error creating listing: $e');
    }
  }

  // Get user's listings with optional filters
  Future<Map<String, dynamic>> getListings({
    String? material,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 10,
    bool isMarketplace = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (material != null) queryParams['materialType'] = material;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (search != null) queryParams['search'] = search;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      if (isMarketplace) queryParams['view'] = 'marketplace';

      // Advanced Delta Sync Logic (DISABLED: Needs local caching database to merge deltas)
      /*
      final prefs = await SharedPreferences.getInstance();
      final lastUpdatedKey = isMarketplace ? 'delta_sync_marketplace' : 'delta_sync_own';
      
      // If we are on page 1 and no search filters, attempt a Delta Sync
      if (page == 1 && search == null && material == null && status == null) {
         final lastUpdated = prefs.getString(lastUpdatedKey);
         if (lastUpdated != null) {
           queryParams['lastUpdated'] = lastUpdated;
         }
      }
      */

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/listings?$queryString');

      if (response['success'] == true) {
        // Update Delta Sync timestamp on success (DISABLED)
        /*
        if (page == 1 && search == null && material == null && status == null) {
           await prefs.setString(lastUpdatedKey, DateTime.now().toUtc().toIso8601String());
        }
        */

        final listings = (response['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();
        
        return {
          'listings': listings,
          'pagination': response['pagination'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch listings');
      }
    } catch (e) {
      throw Exception('Error fetching listings: $e');
    }
  }

  // Get listing statistics
  Future<Map<String, dynamic>> getListingStats() async {
    try {
      final response = await _apiService.get('/listings/stats');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  // Update listing status
  Future<Listing> updateListingStatus(int id, String status, {String? buyerInfo}) async {
    try {
      final data = {'status': status};
      if (buyerInfo != null) {
        data['buyerInfo'] = buyerInfo;
      }

      final response = await _apiService.put('/listings/$id', data);
      
      if (response['success'] == true && response['data'] != null) {
        return Listing.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to update listing');
      }
    } catch (e) {
      throw Exception('Error updating listing: $e');
    }
  }

  // Delete a listing
  Future<void> deleteListing(int id) async {
    try {
      final response = await _apiService.delete('/listings/$id');
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete listing');
      }
    } catch (e) {
      throw Exception('Error deleting listing: $e');
    }
  }

  // Fetch dynamic material rates from backend
  Future<Map<String, double>> fetchMaterialRates() async {
    try {
      final response = await _apiService.get('/app/rates');
      
      if (response['success'] == true && response['data'] != null) {
        final ratesList = response['data'] as List;
        final Map<String, double> ratesMap = {};
        for (var rateObj in ratesList) {
          final category = rateObj['category'] as String;
          final price = (rateObj['pricePerUnit'] as num).toDouble();
          ratesMap[category] = price;
        }
        return ratesMap;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch rates');
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error fetching rates: $e');
      throw Exception('Error fetching rates: $e');
    }
  }

  // Get export URL for CSV download (returns URL, actual download handled by UI)
  String getExportUrl({
    String? material,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    final queryParams = <String, String>{};
    if (material != null) queryParams['material'] = material;
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${ApiConstants.baseUrl}/listings/export${queryString.isNotEmpty ? "?$queryString" : ""}';
  }
}
