import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/repositories/listing_repository.dart';

/// Concrete implementation of ListingRepository using ApiService.
class ListingRepositoryImpl implements ListingRepository {
  final ApiService _apiService;

  ListingRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<ApiResult<Map<String, dynamic>>> createListing(
      Map<String, dynamic> listingData) async {
    try {
      if (kDebugMode) print('DEBUG: Creating listing with data: $listingData');
      if (kDebugMode) print('DEBUG: Images count: ${listingData['images']?.length ?? 0}');

      final response = await _apiService.post('/listings', listingData);

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to create listing');
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error creating listing: $e');
      return ApiResult.failure('Error creating listing: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getListings({
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

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/listings?$queryString');

      if (response['success'] == true) {
        return ApiResult.success(data: {
          'data': response['data'],
          'pagination': response['pagination'],
        });
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to fetch listings');
      }
    } catch (e) {
      return ApiResult.failure('Error fetching listings: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getListingStats() async {
    try {
      final response = await _apiService.get('/listings/stats');

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      return ApiResult.failure('Error fetching stats: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> updateListing(
      int id, Map<String, dynamic> updateData) async {
    try {
      if (kDebugMode) print('DEBUG: Updating listing $id with data: $updateData');

      final response = await _apiService.put('/listings/$id', updateData);

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to update listing');
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error updating listing: $e');
      return ApiResult.failure('Error updating listing: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> updateListingStatus(
      int id, String status, {String? buyerInfo}) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (buyerInfo != null) data['buyerInfo'] = buyerInfo;

      final response = await _apiService.put('/listings/$id', data);

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to update listing');
      }
    } catch (e) {
      return ApiResult.failure('Error updating listing: $e');
    }
  }

  @override
  Future<ApiResult<void>> deleteListing(int id) async {
    try {
      final response = await _apiService.delete('/listings/$id');

      if (response['success'] == true) {
        return ApiResult.success();
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to delete listing');
      }
    } catch (e) {
      return ApiResult.failure('Error deleting listing: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, double>>> fetchMaterialRates() async {
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
        return ApiResult.success(data: ratesMap);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to fetch rates');
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error fetching rates: $e');
      return ApiResult.failure('Error fetching rates: $e');
    }
  }

  @override
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

  @override
  Future<ApiResult<Map<String, dynamic>>> classifyImage({
    String? imageUrl,
    String? imageBase64,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (imageBase64 != null) body['imageBase64'] = imageBase64;

      final response = await _apiService.post('/listings/classify', body);

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Cloud classification unavailable');
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Cloud classify error: $e');
      return ApiResult.failure('Cloud classification unavailable: $e');
    }
  }
}
