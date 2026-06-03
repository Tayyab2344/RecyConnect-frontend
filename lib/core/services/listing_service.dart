import '../models/listing_model.dart';
import '../../core/di/service_locator.dart';
import '../../features/listing/domain/repositories/listing_repository.dart';
import '../../core/network/api_result.dart';

/// ListingService now delegates to the clean architecture ListingRepository.
/// All existing screens continue to work with no changes.
class ListingService {
  final ListingRepository _repository = sl<ListingRepository>();

  /// Unwraps an ApiResult into a Map or throws on failure.
  Map<String, dynamic> _unwrapMap(ApiResult<Map<String, dynamic>> result, String fallback) {
    if (result.isSuccess && result.data != null) return result.data!;
    throw Exception(result.message ?? fallback);
  }

  // Create a new listing
  Future<Listing> createListing(Listing listing) async {
    final data = _unwrapMap(await _repository.createListing(listing.toCreateJson()), 'Failed to create listing');
    return Listing.fromJson(data);
  }

  // Update an existing listing
  Future<Listing> updateListing(int id, Listing listing) async {
    final data = _unwrapMap(await _repository.updateListing(id, listing.toCreateJson()), 'Failed to update listing');
    return Listing.fromJson(data);
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
    final data = _unwrapMap(await _repository.getListings(
      material: material,
      status: status,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
      isMarketplace: isMarketplace,
    ), 'Failed to fetch listings');

    final listings = (data['data'] as List)
        .map((json) => Listing.fromJson(json))
        .toList();
    return {
      'listings': listings,
      'pagination': data['pagination'],
    };
  }

  // Get listing statistics
  Future<Map<String, dynamic>> getListingStats() async {
    return _unwrapMap(await _repository.getListingStats(), 'Failed to fetch statistics');
  }

  // Update listing status
  Future<Listing> updateListingStatus(int id, String status,
      {String? buyerInfo}) async {
    final data = _unwrapMap(await _repository.updateListingStatus(id, status, buyerInfo: buyerInfo), 'Failed to update listing');
    return Listing.fromJson(data);
  }

  // Delete a listing
  Future<void> deleteListing(int id) async {
    final result = await _repository.deleteListing(id);
    if (result.isFailure) {
      throw Exception(result.message ?? 'Failed to delete listing');
    }
  }

  // Fetch dynamic material rates from backend
  Future<Map<String, double>> fetchMaterialRates() async {
    final result = await _repository.fetchMaterialRates();
    if (result.isSuccess && result.data != null) return result.data!;
    throw Exception(result.message ?? 'Failed to fetch rates');
  }

  // Get export URL for CSV download
  String getExportUrl({
    String? material,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    return _repository.getExportUrl(
      material: material,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
