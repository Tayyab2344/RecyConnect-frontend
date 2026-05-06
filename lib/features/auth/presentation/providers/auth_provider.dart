import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/password_usecases.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/notification_service.dart';

/// AuthProvider manages authentication state for the UI.
///
/// This replaces the old AuthService. Instead of making HTTP calls directly,
/// it delegates to UseCases which go through the Repository pattern.
///
/// All existing screens that use `Provider.of<AuthService>(context)` will
/// instead use `Provider.of<AuthProvider>(context)` — the API surface
/// (property names, method signatures) is kept identical for easy migration.
class AuthProvider extends ChangeNotifier {
  // Use Cases
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final FetchProfileUseCase _fetchProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final AuthRepository _repository;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required FetchProfileUseCase fetchProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required AuthRepository repository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _fetchProfileUseCase = fetchProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _repository = repository;

  // ─── State ───────────────────────────────────────────────
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;
  String? _error;

  // ─── Getters (backward compatible with old AuthService) ──
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get userName => _user?['name'] as String?;
  String? get userRole => _user?['role'];
  int? get userId => (_user?['id'] as num?)?.toInt();
  Map<String, dynamic>? get currentUser => _user;

  // ─── Private Helpers ─────────────────────────────────────
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Converts a UserEntity into the Map format expected by existing screens.
  /// Centralizes the entity→map conversion that was previously duplicated
  /// across login(), fetchProfile(), and updateProfile().
  Map<String, dynamic> _userToMap(UserEntity user, {bool full = false}) {
    final map = <String, dynamic>{
      'id': user.id,
      'role': user.role,
      'name': user.displayName,
      'collectorId': user.collectorId,
      'verificationStatus': user.verificationStatus,
      'kycStage': user.kycStage,
      'rejectionReason': user.rejectionReason,
    };
    if (full) {
      map.addAll({
        'email': user.email,
        'phone': user.phone,
        'address': user.address,
        'city': user.city,
        'area': user.area,
        'profileImage': user.profileImage,
        'businessName': user.businessName,
        'companyName': user.companyName,
        'businessType': user.businessType,
        'registrationNumber': user.registrationNumber,
      });
    }
    return map;
  }

  /// Generic wrapper that handles loading state, error handling, and
  /// return-map construction for simple ApiResult<T> operations.
  /// Eliminates the repeated try/setLoading/setError/catch boilerplate
  /// across verifyOtp, resendOtp, forgotPassword, resetPassword, etc.
  Future<Map<String, dynamic>> _runWithLoading<T>(
    Future<ApiResult<T>> Function() action, {
    String successKey = 'message',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await action();

      _setLoading(false);
      if (result.isSuccess) {
        return {'success': true, successKey: result.data};
      } else {
        _setError(result.message);
        return {'success': false, 'message': result.message};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Login ───────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _loginUseCase.execute(email, password);

      if (result.isSuccess && result.data != null) {
        _token = result.data!.token;
        _user = _userToMap(result.data!.user);
        await NotificationService.registerDeviceToken();
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ─── Check Email ─────────────────────────────────────────
  Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final result = await _repository.checkEmail(email);
      if (result.isSuccess) {
        return {'success': true, 'data': result.data};
      } else {
        return {'success': false, 'message': result.message};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Register ────────────────────────────────────────────
  Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData, Map<String, XFile> files) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _registerUseCase.execute(userData, files);

      if (result.isSuccess && result.data != null) {
        _setLoading(false);
        return {
          'success': true,
          'message': result.data!.message,
          'userId': result.data!.userId,
        };
      } else {
        _setError(result.message);
        _setLoading(false);
        return {'success': false, 'message': result.message};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Register Collector ──────────────────────────────────
  Future<Map<String, dynamic>> registerCollector(
      Map<String, dynamic> collectorData) =>
      _runWithLoading(() => _repository.registerCollector(collectorData));

  // ─── Analyze Document ────────────────────────────────────
  Future<Map<String, dynamic>> analyzeDocument(XFile file) =>
      _runWithLoading(() => _repository.analyzeDocument(file), successKey: 'data');

  // ─── Verify OTP ──────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) =>
      _runWithLoading(() => _verifyOtpUseCase.execute(email, otp));

  // ─── Resend OTP ──────────────────────────────────────────
  Future<Map<String, dynamic>> resendOtp(String email) =>
      _runWithLoading(() => _resendOtpUseCase.execute(email), successKey: 'data');

  // ─── Forgot Password ────────────────────────────────────
  Future<Map<String, dynamic>> forgotPassword(String email) =>
      _runWithLoading(() => _forgotPasswordUseCase.execute(email));

  // ─── Reset Password ─────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) =>
      _runWithLoading(() => _resetPasswordUseCase.execute(email, otp, newPassword));

  // ─── Change Password ────────────────────────────────────
  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) =>
      _runWithLoading(() => _changePasswordUseCase.execute(currentPassword, newPassword));

  // ─── Fetch Profile ──────────────────────────────────────
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      _isLoading = true;
      _error = null;

      final result = await _fetchProfileUseCase.execute();

      if (result.isSuccess && result.data != null) {
        _user = _userToMap(result.data!, full: true);
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'data': _user};
      } else {
        _error = result.message;
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': result.message};
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Update Profile ─────────────────────────────────────
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updateData, XFile? profileImage) async {
    try {
      _setLoading(true);
      _setError(null);

      final result =
          await _updateProfileUseCase.execute(updateData, profileImage);

      if (result.isSuccess && result.data != null) {
        _user = _userToMap(result.data!, full: true);
        notifyListeners();
        _setLoading(false);
        return {'success': true, 'data': _user};
      } else {
        _setError(result.message);
        _setLoading(false);
        return {'success': false, 'message': result.message};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Delete Account ─────────────────────────────────────
  Future<Map<String, dynamic>> deleteAccount(String password,
      {String? reason}) async {
    try {
      _setLoading(true);
      _setError(null);

      final result =
          await _deleteAccountUseCase.execute(password, reason: reason);

      if (result.isSuccess) {
        _token = null;
        _user = null;
        _error = null;
        _setLoading(false);
        return {'success': true, 'message': result.data};
      } else {
        _setError(result.message);
        _setLoading(false);
        return {'success': false, 'message': result.message};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Logout ──────────────────────────────────────────────
  Future<void> logout() async {
    _token = null;
    _user = null;
    _error = null;
    await _logoutUseCase.executeLocal();
    notifyListeners();
  }

  Future<void> logoutFromServer() async {
    try {
      await _logoutUseCase.execute();
    } finally {
      _token = null;
      _user = null;
      _error = null;
      notifyListeners();
    }
  }

  // ─── Load Token (Startup) ───────────────────────────────
  Future<void> loadToken() async {
    try {
      final session = await _repository.loadSession();
      _token = session.token;
      _user = session.userData;
      if (_token != null && _token!.isNotEmpty) {
        await NotificationService.registerDeviceToken();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading token: $e');
    }
  }

  Future<bool> checkAuthStatus() async {
    await loadToken();
    return isAuthenticated;
  }

  // ─── Helper: Get token for other services ────────────────
  Future<String?> getToken() async {
    if (_token != null) return _token;
    await loadToken();
    return _token;
  }

  Future<Map<String, dynamic>?> getUser() async {
    if (_user != null) return _user;
    await fetchProfile();
    return _user;
  }
}
