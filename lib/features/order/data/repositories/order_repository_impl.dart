import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/repositories/order_repository.dart';

/// Concrete implementation of OrderRepository using ApiService.
class OrderRepositoryImpl implements OrderRepository {
  final ApiService _apiService;

  OrderRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<ApiResult<Map<String, dynamic>>> createOrder(
      int listingId, double weight, {String paymentMethod = 'cod'}) async {
    try {
      final response = await _apiService.post('/orders', {
        'listingId': listingId,
        'weight': weight,
        'paymentMethod': paymentMethod,
      });

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to create order');
      }
    } catch (e) {
      return ApiResult.failure('Error creating order: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getOrders({
    String? role,
    String? material,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (material != null) queryParams['material'] = material;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (search != null) queryParams['search'] = search;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/orders?$queryString');

      if (response['success'] == true) {
        return ApiResult.success(data: {
          'data': response['data'],
          'pagination': response['pagination'],
        });
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to fetch orders');
      }
    } catch (e) {
      return ApiResult.failure('Error fetching orders: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getOrderStats(
      {String role = 'buyer'}) async {
    try {
      final response = await _apiService.get('/orders/stats?role=$role');

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
  Future<ApiResult<Map<String, dynamic>>> updateOrderStatus(
      int id, String status) async {
    try {
      final response = await _apiService.put('/orders/$id/status', {'status': status});

      if (response['success'] == true && response['data'] != null) {
        return ApiResult.success(data: response['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to update order');
      }
    } catch (e) {
      return ApiResult.failure('Error updating order: $e');
    }
  }

  @override
  Future<void> cancelOrder(int orderId,
      {String reason = 'Payment cancelled by user'}) async {
    try {
      await _apiService.post('/orders/$orderId/cancel', {'reason': reason});
    } catch (e) {
      debugPrint('Error cancelling order: $e');
    }
  }

  @override
  String getExportUrl({
    String? role,
    String? material,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    final queryParams = <String, String>{};
    if (role != null) queryParams['role'] = role;
    if (material != null) queryParams['material'] = material;
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${ApiConstants.baseUrl}/orders/export${queryString.isNotEmpty ? "?$queryString" : ""}';
  }
}
