import 'package:flutter/foundation.dart';
import '../../../../core/services/secure_storage_service.dart';

/// Local data source for authentication.
/// Handles all persistent storage operations (secure storage for tokens/user data).
class AuthLocalDataSource {
  Future<void> saveToken(String token) async {
    try {
      await SecureStorageService.saveToken(token);
    } catch (e) {
      if (kDebugMode) print('Error saving token: $e');
    }
  }

  Future<String?> readToken() async {
    return SecureStorageService.readToken();
  }

  Future<void> deleteToken() async {
    await SecureStorageService.deleteToken();
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await SecureStorageService.saveUserData(userData);
    } catch (e) {
      if (kDebugMode) print('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>?> readUserData() async {
    return SecureStorageService.readUserData();
  }

  Future<void> deleteUserData() async {
    await SecureStorageService.deleteUserData();
  }
}
