import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  // Create a Stripe PaymentIntent for a confirmed order
  Future<Map<String, dynamic>> createPaymentIntent(int orderId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/create-intent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Log the full error for debugging
      if (kDebugMode) print('[PaymentService] createPaymentIntent FAILED: status=${response.statusCode}, body=${response.body}');
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? 'Failed to create payment intent';
      throw Exception(message);
    }
  }

  // Create a COD (Cash on Delivery) payment
  Future<Map<String, dynamic>> createCodPayment(int orderId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/create-cod'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create COD payment: ${response.body}');
    }
  }

  // Get available payment methods for an order
  Future<Map<String, dynamic>> getPaymentMethods(int orderId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.get(
      Uri.parse('${ApiConstants.payments}/methods/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load payment methods: ${response.body}');
    }
  }

  // Confirm COD payment received (seller action)
  Future<Map<String, dynamic>> confirmCodPayment(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/$id/confirm-cod'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to confirm COD payment: ${response.body}');
    }
  }

  // Get payment status by order ID
  Future<Map<String, dynamic>> getPaymentStatus(int orderId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.get(
      Uri.parse('${ApiConstants.payments}/order/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment status: ${response.body}');
    }
  }

  // Get payment by ID
  Future<Map<String, dynamic>> getPaymentById(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.get(
      Uri.parse('${ApiConstants.payments}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment by ID: ${response.body}');
    }
  }

  // Authorize a payment
  Future<Map<String, dynamic>> authorizePayment(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/$id/authorize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to authorize payment: ${response.body}');
    }
  }

  // Capture an authorized payment
  Future<Map<String, dynamic>> capturePayment(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/$id/capture'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to capture payment: ${response.body}');
    }
  }

  // Release a captured payment
  Future<Map<String, dynamic>> releasePayment(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/$id/release'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to release payment: ${response.body}');
    }
  }

  // Refund a payment
  Future<Map<String, dynamic>> refundPayment(int id, {String reason = 'requested_by_customer'}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.payments}/$id/refund'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to refund payment: ${response.body}');
    }
  }
}
