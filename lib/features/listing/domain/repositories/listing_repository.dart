import '../../../../core/network/api_result.dart';

/// Abstract repository for listing operations.
abstract class ListingRepository {
  Future<ApiResult<Map<String, dynamic>>> createListing(Map<String, dynamic> listingData);

  Future<ApiResult<Map<String, dynamic>>> getListings({
    String? material,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 10,
    bool isMarketplace = false,
  });

  Future<ApiResult<Map<String, dynamic>>> getListingStats();

  Future<ApiResult<Map<String, dynamic>>> updateListingStatus(
      int id, String status, {String? buyerInfo});

  Future<ApiResult<Map<String, dynamic>>> updateListing(
      int id, Map<String, dynamic> updateData);

  Future<ApiResult<void>> deleteListing(int id);

  Future<ApiResult<Map<String, double>>> fetchMaterialRates();

  String getExportUrl({
    String? material,
    String? status,
    String? startDate,
    String? endDate,
  });
}
