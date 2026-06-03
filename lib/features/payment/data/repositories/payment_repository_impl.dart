import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/payment_repository.dart';

/// Concrete implementation of PaymentRepository.
class PaymentRepositoryImpl implements PaymentRepository {
  final AuthService _authService = sl<AuthService>();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generic helper that handles the repeated pattern:
  /// get auth headers → make HTTP call → decode → wrap in ApiResult.
  Future<ApiResult<Map<String, dynamic>>> _request({
    required Future<http.Response> Function(Map<String, String> headers) call,
    required String errorMessage,
    int expectedStatus = 200,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await call(headers);

      if (response.statusCode == expectedStatus) {
        return ApiResult.success(
            data: jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        if (kDebugMode) {
          debugPrint('[PaymentRepo] $errorMessage: status=${response.statusCode}');
        }
        final body = jsonDecode(response.body);
        return ApiResult.failure(
            body['message'] as String? ?? errorMessage);
      }
    } catch (e) {
      return ApiResult.failure('Error: $e');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> createPaymentIntent(int orderId) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/create-intent'),
          headers: h,
          body: jsonEncode({'orderId': orderId}),
        ),
        errorMessage: 'Failed to create payment intent',
        expectedStatus: 201,
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> createCodPayment(int orderId) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/create-cod'),
          headers: h,
          body: jsonEncode({'orderId': orderId}),
        ),
        errorMessage: 'Failed to create COD payment',
        expectedStatus: 201,
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> getPaymentMethods(int orderId) =>
      _request(
        call: (h) => http.get(
          Uri.parse('${ApiConstants.payments}/methods/$orderId'),
          headers: h,
        ),
        errorMessage: 'Failed to load payment methods',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> confirmCodPayment(int id) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/$id/confirm-cod'),
          headers: h,
        ),
        errorMessage: 'Failed to confirm COD payment',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> getPaymentStatus(int orderId) =>
      _request(
        call: (h) => http.get(
          Uri.parse('${ApiConstants.payments}/order/$orderId'),
          headers: h,
        ),
        errorMessage: 'Failed to get payment status',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> getPaymentById(int id) =>
      _request(
        call: (h) => http.get(
          Uri.parse('${ApiConstants.payments}/$id'),
          headers: h,
        ),
        errorMessage: 'Failed to get payment',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> authorizePayment(int id) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/$id/authorize'),
          headers: h,
        ),
        errorMessage: 'Failed to authorize payment',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> capturePayment(int id) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/$id/capture'),
          headers: h,
        ),
        errorMessage: 'Failed to capture payment',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> releasePayment(int id) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/$id/release'),
          headers: h,
        ),
        errorMessage: 'Failed to release payment',
      );

  @override
  Future<ApiResult<Map<String, dynamic>>> refundPayment(int id,
      {String reason = 'requested_by_customer'}) =>
      _request(
        call: (h) => http.post(
          Uri.parse('${ApiConstants.payments}/$id/refund'),
          headers: h,
          body: jsonEncode({'reason': reason}),
        ),
        errorMessage: 'Failed to refund payment',
      );
}
