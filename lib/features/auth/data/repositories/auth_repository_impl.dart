import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Concrete implementation of AuthRepository.
/// This is the ONLY class that coordinates between remote and local data sources.
/// It translates raw API responses into domain-level ApiResult objects.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<ApiResult<({UserEntity user, String token})>> login(
      String identifier, String password) async {
    try {
      final response = await _remoteDataSource.login(identifier, password);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200 && body['success'] == true) {
        final responseData = body['data'];

        // Check for pending verification
        if (responseData['verificationStatus'] == 'PENDING' ||
            responseData['verificationStatus'] == 'REJECTED') {
          final status = responseData['verificationStatus'].toString().toLowerCase();
          final reason = responseData['rejectionReason'] ?? 'Please wait for admin approval.';
          return ApiResult.failure('Account $status. $reason');
        }

        // Validate response
        if (responseData['accessToken'] == null || responseData['user'] == null) {
          return ApiResult.failure('Invalid response from server');
        }

        final token = responseData['accessToken'] as String;
        final userData = responseData['user'] as Map<String, dynamic>;

        // Build storage map (backward compatible with old AuthService format)
        final storageMap = UserModel.toStorageMap(
          userData,
          verificationStatus: responseData['verificationStatus'],
          kycStage: responseData['kycStage'],
          rejectionReason: responseData['rejectionReason'],
        );

        // Save session
        await saveSession(token, storageMap);

        // Set token on remote data source for future authenticated calls
        _remoteDataSource.setToken(token);

        final user = UserModel.fromJson(storageMap);

        return ApiResult.success(data: (user: user as UserEntity, token: token));
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<({String message, int? userId})>> register(
      Map<String, dynamic> userData, Map<String, XFile> files) async {
    try {
      final response = await _remoteDataSource.register(userData, files);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 201) {
        return ApiResult.success(
          data: (
            message: body['message'] as String? ?? 'Registration successful',
            userId: (body['userId'] as num?)?.toInt(),
          ),
        );
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<String>> registerCollector(
      Map<String, dynamic> collectorData) async {
    try {
      final response = await _remoteDataSource.registerCollector(collectorData);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(
            data: body['message'] as String? ?? 'Registration successful');
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> analyzeDocument(XFile file) async {
    try {
      final response = await _remoteDataSource.analyzeDocument(file);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200 && body['success'] == true) {
        return ApiResult.success(data: body['data'] as Map<String, dynamic>);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> checkEmail(String email) async {
    try {
      final response = await _remoteDataSource.checkEmail(email);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(data: body['data'] as Map<String, dynamic>?);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<String>> verifyOtp(String email, String otp) async {
    try {
      final response = await _remoteDataSource.verifyOtp(email, otp);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(data: body['message'] as String?);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> resendOtp(String email) async {
    try {
      final response = await _remoteDataSource.resendOtp(email);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(data: body);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<String>> forgotPassword(String email) async {
    try {
      final response = await _remoteDataSource.forgotPassword(email);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(data: body['message'] as String?);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<String>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response =
          await _remoteDataSource.resetPassword(email, otp, newPassword);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(data: body['message'] as String?);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<String>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final response =
          await _remoteDataSource.changePassword(currentPassword, newPassword);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        return ApiResult.success(data: body['message'] as String?);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<UserEntity>> fetchProfile() async {
    try {
      final response = await _remoteDataSource.fetchProfile();
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        final userData = body['data'] as Map<String, dynamic>;

        // Save to local storage
        await _localDataSource.saveUserData(userData);

        final user = UserModel.fromJson(userData);
        return ApiResult.success(data: user);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<UserEntity>> updateProfile(
      Map<String, dynamic> updateData, XFile? profileImage) async {
    try {
      final response =
          await _remoteDataSource.updateProfile(updateData, profileImage);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        final userData = body['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        return ApiResult.success(data: user);
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<String>> deleteAccount(String password,
      {String? reason}) async {
    try {
      final response =
          await _remoteDataSource.deleteAccount(password, reason: reason);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (statusCode == 200 && body['success'] == true) {
        await clearSession();
        return ApiResult.success(
            data: body['message'] as String? ?? 'Account deleted successfully');
      } else {
        return ApiResult.failure(_remoteDataSource.extractErrorMessage(body));
      }
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> logoutFromServer() async {
    await _remoteDataSource.logoutFromServer();
  }

  @override
  Future<void> saveSession(String token, Map<String, dynamic> userData) async {
    await _localDataSource.saveToken(token);
    await _localDataSource.saveUserData(userData);
    _remoteDataSource.setToken(token);
  }

  @override
  Future<({String? token, Map<String, dynamic>? userData})>
      loadSession() async {
    final token = await _localDataSource.readToken();
    final userData = await _localDataSource.readUserData();
    if (token != null) {
      _remoteDataSource.setToken(token);
    }
    return (token: token, userData: userData);
  }

  @override
  Future<void> clearSession() async {
    await _localDataSource.deleteToken();
    await _localDataSource.deleteUserData();
    _remoteDataSource.setToken(null);
  }
}
