import '../models/listing_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class ListingService {
  final ApiService _apiService = ApiService();

  // Create a new listing
  Future<Listing> createListing(Listing listing) async {
    try {
      final jsonData = listing.toCreateJson();
      print('DEBUG: Creating listing with data: $jsonData');
      print('DEBUG: Images count: ${jsonData['images']?.length ?? 0}');
      
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
      print('DEBUG: Error creating listing: $e');
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
      if (material != null) queryParams['material'] = material;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (search != null) queryParams['search'] = search;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      if (isMarketplace) queryParams['view'] = 'marketplace';

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/listings?$queryString');

      if (response['success'] == true) {
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
