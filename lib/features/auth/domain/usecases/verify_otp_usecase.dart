import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Verify OTP code during registration.
class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<ApiResult<String>> execute(String email, String otp) {
    return _repository.verifyOtp(email, otp);
  }
}

/// UseCase: Resend OTP code.
class ResendOtpUseCase {
  final AuthRepository _repository;

  ResendOtpUseCase(this._repository);

  Future<ApiResult<Map<String, dynamic>>> execute(String email) {
    return _repository.resendOtp(email);
  }
}
