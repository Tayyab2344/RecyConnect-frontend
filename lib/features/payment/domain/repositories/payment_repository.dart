import '../../../../core/network/api_result.dart';

/// Abstract repository for payment operations.
abstract class PaymentRepository {
  Future<ApiResult<Map<String, dynamic>>> createPaymentIntent(int orderId);
  Future<ApiResult<Map<String, dynamic>>> createCodPayment(int orderId);
  Future<ApiResult<Map<String, dynamic>>> getPaymentMethods(int orderId);
  Future<ApiResult<Map<String, dynamic>>> confirmCodPayment(int id);
  Future<ApiResult<Map<String, dynamic>>> getPaymentStatus(int orderId);
  Future<ApiResult<Map<String, dynamic>>> getPaymentById(int id);
  Future<ApiResult<Map<String, dynamic>>> authorizePayment(int id);
  Future<ApiResult<Map<String, dynamic>>> capturePayment(int id);
  Future<ApiResult<Map<String, dynamic>>> releasePayment(int id);
  Future<ApiResult<Map<String, dynamic>>> refundPayment(int id,
      {String reason = 'requested_by_customer'});
}
