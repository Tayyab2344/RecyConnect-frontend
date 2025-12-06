import '../models/order_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      final response = await _apiService.post(
        '/orders',
        order.toCreateJson(),
      );
      
      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Get user's orders with optional filters
  Future<Map<String, dynamic>> getOrders({
    String? role, // 'buyer' or 'seller'
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
        final orders = (response['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
        
        return {
          'orders': orders,
          'pagination': response['pagination'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStats({String role = 'buyer'}) async {
    try {
      final response = await _apiService.get('/orders/stats?role=$role');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  // Update order status
  Future<Order> updateOrderStatus(int id, String status) async {
    try {
      final response = await _apiService.put(
        '/orders/$id/status',
        {'status': status},
      );
      
      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to update order');
      }
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }

  // Get export URL for CSV download
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
