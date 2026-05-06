import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Request a password reset email.
class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<ApiResult<String>> execute(String email) {
    return _repository.forgotPassword(email);
  }
}

/// UseCase: Reset password with OTP code.
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<ApiResult<String>> execute(
      String email, String otp, String newPassword) {
    return _repository.resetPassword(email, otp, newPassword);
  }
}

/// UseCase: Change password for authenticated user.
class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<ApiResult<String>> execute(
      String currentPassword, String newPassword) {
    return _repository.changePassword(currentPassword, newPassword);
  }
}
