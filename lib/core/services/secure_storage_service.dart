import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> readToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      return token;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_tokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await _storage.write(key: _tokenKey, value: legacyToken);
      await prefs.remove(_tokenKey);
      return legacyToken;
    }

    return null;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> readUserData() async {
    final data = await _storage.read(key: _userKey);
    if (data != null && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyData = prefs.getString(_userKey);
    if (legacyData != null && legacyData.isNotEmpty) {
      await _storage.write(key: _userKey, value: legacyData);
      await prefs.remove(_userKey);
      return jsonDecode(legacyData) as Map<String, dynamic>;
    }

    return null;
  }

  static Future<void> deleteUserData() async {
    await _storage.delete(key: _userKey);
  }
}
