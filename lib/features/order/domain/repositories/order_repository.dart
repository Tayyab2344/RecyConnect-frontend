import '../../../../core/network/api_result.dart';

/// Abstract repository for order operations.
abstract class OrderRepository {
  Future<ApiResult<Map<String, dynamic>>> createOrder(
      int listingId, double weight, {String paymentMethod = 'cod', String? deliveryMethod, double? buyerLatitude, double? buyerLongitude, int? chosenWarehouseId});

  Future<ApiResult<Map<String, dynamic>>> getOrders({
    String? role,
    String? material,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<ApiResult<Map<String, dynamic>>> getOrderStats({String role = 'buyer'});

  Future<ApiResult<Map<String, dynamic>>> updateOrderStatus(int id, String status);

  Future<void> cancelOrder(int orderId, {String reason = 'Payment cancelled by user'});

  Future<ApiResult<Map<String, dynamic>>> getOrderById(int id);

  Future<ApiResult<Map<String, dynamic>>> confirmOrder(int id);

  Future<ApiResult<Map<String, dynamic>>> submitOrderReview(
      int orderId, double rating, String feedback, {
      int? productQuality,
      int? materialAccuracy,
      int? communication,
      int? deliveryExperience,
      int? overallSatisfaction,
  });

  Future<ApiResult<Map<String, dynamic>>> editOrderReview(
      int orderId, double rating, String feedback, {
      int? productQuality,
      int? materialAccuracy,
      int? communication,
      int? deliveryExperience,
      int? overallSatisfaction,
  });

  Future<ApiResult<Map<String, dynamic>>> reportOrderReview(
      int orderId, String reason);

  String getExportUrl({
    String? role,
    String? material,
    String? status,
    String? startDate,
    String? endDate,
  });
}
