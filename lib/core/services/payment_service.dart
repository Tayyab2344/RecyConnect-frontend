import '../di/service_locator.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../core/network/api_result.dart';

/// PaymentService now delegates to the clean architecture PaymentRepository.
/// All existing screens continue to work with no changes.
class PaymentService {
  final PaymentRepository _repository = sl<PaymentRepository>();

  /// Unwraps an ApiResult into a Map or throws on failure.
  /// Eliminates the repeated if/else/throw pattern.
  Map<String, dynamic> _unwrap(ApiResult<Map<String, dynamic>> result, String fallback) {
    if (result.isSuccess && result.data != null) return result.data!;
    throw Exception(result.message ?? fallback);
  }

  Future<Map<String, dynamic>> createPaymentIntent(int orderId) async =>
      _unwrap(await _repository.createPaymentIntent(orderId), 'Failed to create payment intent');

  Future<Map<String, dynamic>> createCodPayment(int orderId) async =>
      _unwrap(await _repository.createCodPayment(orderId), 'Failed to create COD payment');

  Future<Map<String, dynamic>> getPaymentMethods(int orderId) async =>
      _unwrap(await _repository.getPaymentMethods(orderId), 'Failed to load payment methods');

  Future<Map<String, dynamic>> confirmCodPayment(int id) async =>
      _unwrap(await _repository.confirmCodPayment(id), 'Failed to confirm COD payment');

  Future<Map<String, dynamic>> getPaymentStatus(int orderId) async =>
      _unwrap(await _repository.getPaymentStatus(orderId), 'Failed to get payment status');

  Future<Map<String, dynamic>> getPaymentById(int id) async =>
      _unwrap(await _repository.getPaymentById(id), 'Failed to get payment');

  Future<Map<String, dynamic>> authorizePayment(int id) async =>
      _unwrap(await _repository.authorizePayment(id), 'Failed to authorize payment');

  Future<Map<String, dynamic>> capturePayment(int id) async =>
      _unwrap(await _repository.capturePayment(id), 'Failed to capture payment');

  Future<Map<String, dynamic>> releasePayment(int id) async =>
      _unwrap(await _repository.releasePayment(id), 'Failed to release payment');

  Future<Map<String, dynamic>> refundPayment(int id,
      {String reason = 'requested_by_customer'}) async =>
      _unwrap(await _repository.refundPayment(id, reason: reason), 'Failed to refund payment');
}
