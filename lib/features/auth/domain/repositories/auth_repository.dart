import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';

/// Abstract repository interface for authentication.
/// This lives in the DOMAIN layer and defines WHAT the auth system can do,
/// without specifying HOW it does it (no HTTP, no storage details).
///
/// The Data layer provides the concrete implementation.
abstract class AuthRepository {
  /// Login with email/identifier and password.
  /// Returns the user entity and token on success.
  Future<ApiResult<({UserEntity user, String token})>> login(
      String identifier, String password);

  /// Register a new user with form data and optional document files.
  Future<ApiResult<({String message, int? userId})>> register(
      Map<String, dynamic> userData, Map<String, XFile> files);

  /// Register a collector account.
  Future<ApiResult<String>> registerCollector(
      Map<String, dynamic> collectorData);

  /// Analyze a document image (e.g. for KYC).
  Future<ApiResult<Map<String, dynamic>>> analyzeDocument(XFile file);

  /// Check if an email already exists.
  Future<ApiResult<Map<String, dynamic>>> checkEmail(String email);

  /// Verify OTP code.
  Future<ApiResult<String>> verifyOtp(String email, String otp);

  /// Resend OTP code.
  Future<ApiResult<Map<String, dynamic>>> resendOtp(String email);

  /// Request a password reset.
  Future<ApiResult<String>> forgotPassword(String email);

  /// Reset password with OTP.
  Future<ApiResult<String>> resetPassword(
      String email, String otp, String newPassword);

  /// Change password for authenticated user.
  Future<ApiResult<String>> changePassword(
      String currentPassword, String newPassword);

  /// Fetch the current user's profile from the server.
  Future<ApiResult<UserEntity>> fetchProfile();

  /// Update the current user's profile.
  Future<ApiResult<UserEntity>> updateProfile(
      Map<String, dynamic> updateData, XFile? profileImage);

  /// Delete the current user's account.
  Future<ApiResult<String>> deleteAccount(String password, {String? reason});

  /// Logout from server.
  Future<void> logoutFromServer();

  /// Save token and user data locally.
  Future<void> saveSession(String token, Map<String, dynamic> userData);

  /// Load saved token and user data.
  Future<({String? token, Map<String, dynamic>? userData})> loadSession();

  /// Clear saved session data.
  Future<void> clearSession();
}
