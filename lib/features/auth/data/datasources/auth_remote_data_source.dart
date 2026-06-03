import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../../../core/constants/api_constants.dart';

/// Remote data source for authentication API calls.
/// This is the ONLY place in the auth feature that makes HTTP calls.
/// It returns raw Maps — parsing into domain entities happens in the repository.
class AuthRemoteDataSource {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Extract a user-friendly error message from API response body.
  String extractErrorMessage(dynamic body) {
    try {
      if (body is Map<String, dynamic>) {
        // PRIORITY 1: Check for "errors" array (Express Validator style)
        if (body.containsKey('errors') && body['errors'] is List) {
          final errors = body['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.take(2).map((e) {
              if (e is Map) {
                return e['msg'] ?? e['message'] ?? e.toString();
              }
              return e.toString();
            }).join('. ');
          }
        }

        // PRIORITY 2: Check for "error" key
        if (body.containsKey('error')) {
          final error = body['error'];
          if (error is List && error.isNotEmpty) {
            return error.take(2).map((e) {
              if (e is Map) {
                return e['msg'] ?? e['message'] ?? e.toString();
              }
              return e.toString();
            }).join('. ');
          }
          if (error is String) return error;
          if (error is Map && error.containsKey('message')) {
            return error['message'].toString();
          }
        }

        // PRIORITY 3: Check for "message" string
        if (body.containsKey('message') && body['message'] != null) {
          return body['message'].toString();
        }
      }
      return 'An unexpected error occurred';
    } catch (e) {
      return 'Error parsing response: $e';
    }
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData, Map<String, XFile> files) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/auth/register'),
    );

    userData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (var entry in files.entries) {
      final file = entry.value;
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        entry.key,
        bytes,
        filename: file.name,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }

    if (kDebugMode) print('Sending registration request...');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> registerCollector(
      Map<String, dynamic> collectorData) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/register-collector'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(collectorData),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> analyzeDocument(XFile file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/auth/analyze-document'),
    );

    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'document',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> checkEmail(String email) async {
    final response = await http.post(
      Uri.parse(ApiConstants.checkEmail),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/change-password'),
      headers: _authHeaders,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/me'),
      headers: _authHeaders,
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updateData, XFile? profileImage) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConstants.baseUrl}/auth/me'),
    );

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    updateData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (profileImage != null) {
      final bytes = await profileImage.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profileImage',
          bytes,
          filename: profileImage.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> deleteAccount(String password,
      {String? reason}) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/user/account'),
      headers: _authHeaders,
      body: jsonEncode({
        'password': password,
        if (reason != null) 'reason': reason,
      }),
    );
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<void> logoutFromServer() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (_) {
      // Continue with local logout even if server logout fails
    }
  }
}
