import '../models/order_model.dart';
import '../../core/di/service_locator.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../core/network/api_result.dart';

/// OrderService now delegates to the clean architecture OrderRepository.
/// All existing screens continue to work with no changes.
class OrderService {
  final OrderRepository _repository = sl<OrderRepository>();

  /// Unwraps an ApiResult into a Map or throws on failure.
  Map<String, dynamic> _unwrapMap(ApiResult<Map<String, dynamic>> result, String fallback) {
    if (result.isSuccess && result.data != null) return result.data!;
    throw Exception(result.message ?? fallback);
  }

  // Create a new order from a listing
  Future<Order> createOrder(int listingId, double weight,
      {String paymentMethod = 'cod'}) async {
    final data = _unwrapMap(
      await _repository.createOrder(listingId, weight, paymentMethod: paymentMethod),
      'Failed to create order'
    );
    return Order.fromJson(data);
  }

  // Get user's orders with optional filters
  Future<Map<String, dynamic>> getOrders({
    String? role,
    String? material,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final data = _unwrapMap(
      await _repository.getOrders(
        role: role,
        material: material,
        status: status,
        startDate: startDate,
        endDate: endDate,
        search: search,
        page: page,
        limit: limit,
      ),
      'Failed to fetch orders'
    );

    final orders = (data['data'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
    return {
      'orders': orders,
      'pagination': data['pagination'],
    };
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStats({String role = 'buyer'}) async {
    return _unwrapMap(await _repository.getOrderStats(role: role), 'Failed to fetch statistics');
  }

  // Update order status
  Future<Order> updateOrderStatus(int id, String status) async {
    final data = _unwrapMap(await _repository.updateOrderStatus(id, status), 'Failed to update order');
    return Order.fromJson(data);
  }

  // Cancel an order
  Future<void> cancelOrder(int orderId,
      {String reason = 'Payment cancelled by user'}) async {
    await _repository.cancelOrder(orderId, reason: reason);
  }

  // Get a single order by ID
  Future<Order> getOrderById(int id) async {
    final data = _unwrapMap(
      await _repository.getOrderById(id),
      'Failed to fetch order details'
    );
    return Order.fromJson(data);
  }

  // Confirm an order
  Future<Order> confirmOrder(int id) async {
    final data = _unwrapMap(
      await _repository.confirmOrder(id),
      'Failed to confirm order'
    );
    return Order.fromJson(data);
  }

  // Submit review for an order
  Future<Map<String, dynamic>> submitOrderReview(
      int orderId, double rating, String feedback, {
      int? productQuality,
      int? materialAccuracy,
      int? communication,
      int? deliveryExperience,
      int? overallSatisfaction,
  }) async {
    return _unwrapMap(
      await _repository.submitOrderReview(
        orderId,
        rating,
        feedback,
        productQuality: productQuality,
        materialAccuracy: materialAccuracy,
        communication: communication,
        deliveryExperience: deliveryExperience,
        overallSatisfaction: overallSatisfaction,
      ),
      'Failed to submit review'
    );
  }

  // Edit review for an order
  Future<Map<String, dynamic>> editOrderReview(
      int orderId, double rating, String feedback, {
      int? productQuality,
      int? materialAccuracy,
      int? communication,
      int? deliveryExperience,
      int? overallSatisfaction,
  }) async {
    return _unwrapMap(
      await _repository.editOrderReview(
        orderId,
        rating,
        feedback,
        productQuality: productQuality,
        materialAccuracy: materialAccuracy,
        communication: communication,
        deliveryExperience: deliveryExperience,
        overallSatisfaction: overallSatisfaction,
      ),
      'Failed to edit review'
    );
  }

  // Report review for an order
  Future<Map<String, dynamic>> reportOrderReview(
      int orderId, String reason) async {
    return _unwrapMap(
      await _repository.reportOrderReview(orderId, reason),
      'Failed to report review'
    );
  }

  // Get export URL for CSV download
  String getExportUrl({
    String? role,
    String? material,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    return _repository.getExportUrl(
      role: role,
      material: material,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
