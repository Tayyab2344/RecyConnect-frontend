import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class AuthService extends ChangeNotifier {
  // IMPORTANT: Choose the correct URL based on your testing environment:
  // - For Android Emulator: use 'http://10.0.2.2:5000/api'
  // - For iOS Simulator or Web: use 'http://localhost:5000/api' or 'http://127.0.0.1:5000/api'
  // - For Physical Device: use your computer's WiFi IP (e.g., 'http://192.168.1.31:5000/api')
  //   To find your IP: Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) in terminal
  // Update the baseUrl in lib/core/constants/api_constants.dart

  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get userName => _user?['name'] as String?;
  String? get userRole => _user?['role'];
  int? get userId => (_user?['id'] as num?)?.toInt();
  Map<String, dynamic>? get currentUser => _user;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  String _extractErrorMessage(dynamic body) {
    try {
      if (kDebugMode) {
        print('Full API Response Error Body: $body');
      }

      if (body is Map<String, dynamic>) {
        // PRIORITY 1: Check for "errors" array (detailed validation errors) - Express Validator style
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

        // PRIORITY 2: Check for "error" key which might be a List (found in user logs)
        if (body.containsKey('error')) {
          final error = body['error'];
          
          // Case A: "error" is a List of errors
          if (error is List && error.isNotEmpty) {
             return error.take(2).map((e) {
              if (e is Map) {
                return e['msg'] ?? e['message'] ?? e.toString();
              }
              return e.toString();
            }).join('. ');
          }

          // Case B: "error" is a simple String
          if (error is String) return error;

          // Case C: "error" is an Object with message
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
      if (kDebugMode) {
        print('Error parsing response exception: $e');
      }
      return 'Error parsing response: $e';
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': email, // Changed from 'email' to 'identifier' to match backend
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final responseData = data['data'];
        
        // Check if this is a pending verification response (no tokens)
        if (responseData['verificationStatus'] == 'PENDING' || 
            responseData['verificationStatus'] == 'REJECTED') {
          _setError('Account ${responseData['verificationStatus'].toString().toLowerCase()}. ${responseData['rejectionReason'] ?? 'Please wait for admin approval.'}');
          _setLoading(false);
          return false;
        }
        
        // Normal login with tokens
        if (responseData['accessToken'] == null || responseData['user'] == null) {
          _setError('Invalid response from server');
          _setLoading(false);
          return false;
        }
        
        _token = responseData['accessToken'] as String?;
        
        // Extract user data from nested 'user' object
        final userData = responseData['user'];
        _user = {
          'id': userData['id'],
          'role': userData['role'],
          'name': userData['name'] ?? userData['businessName'] ?? userData['companyName'],
          'collectorId': userData['collectorId'],
          'verificationStatus': responseData['verificationStatus'],
          'kycStage': responseData['kycStage'],
          'rejectionReason': responseData['rejectionReason'],
        };

        if (_token != null) {
          await _saveToken(_token!);
          await _saveUserData(_user!);
        }

        _setLoading(false);
        return true;
      } else {
        _setError(_extractErrorMessage(data));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.checkEmail),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': _extractErrorMessage(data)};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData, Map<String, XFile> files) async {
    try {
      _setLoading(true);
      _setError(null);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
      );

      // Add text fields
      userData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add files
      for (var entry in files.entries) {
        final file = entry.value;
        final bytes = await file.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          entry.key,
          bytes,
          filename: file.name,
          contentType: MediaType('image', 'jpeg'), // Explicitly set content type
        );
        request.files.add(multipartFile);
      }

      print('Sending registration request...'); 
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Connection timed out. Please check your internet or try a smaller image.';
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _setLoading(false);
        return {'success': true, 'message': data['message'], 'userId': data['userId']};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> analyzeDocument(XFile file) async {
    try {
      _setLoading(true);
      
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
      final data = jsonDecode(response.body);

      _setLoading(false);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': _extractErrorMessage(data)};
      }
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'data': data};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _error = null;

    await SecureStorageService.deleteToken();
    await SecureStorageService.deleteUserData();

    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    try {
      await SecureStorageService.saveToken(token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      await SecureStorageService.saveUserData(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<void> loadToken() async {
    try {
      _token = await SecureStorageService.readToken();
      _user = await SecureStorageService.readUserData();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading token: $e');
      }
    }
  }

  Future<bool> checkAuthStatus() async {
    await loadToken();
    return isAuthenticated;
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updateData, XFile? profileImage) async {
    try {
      _setLoading(true);
      _setError(null);

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}/auth/me'),
      );

      // Add authorization header
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add text fields
      updateData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add profile image if selected
      if (profileImage != null) {
        try {
          final bytes = await profileImage.readAsBytes();
          final filename = profileImage.name;
          request.files.add(
            http.MultipartFile.fromBytes(
              'profileImage',
              bytes,
              filename: filename,
            ),
          );
        } catch (e) {
          _setError('Error reading image file: ${e.toString()}');
          _setLoading(false);
          return {
            'success': false,
            'message': 'Error reading image file: ${e.toString()}'
          };
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update local user data
        _user = data['data'] as Map<String, dynamic>?;
        notifyListeners();

        _setLoading(false);
        return {'success': true, 'data': data};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      // Set loading without notifying to prevent setState during build
      _isLoading = true;
      _error = null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _user = data['data'] as Map<String, dynamic>?;
        
        // Save user data to persistent storage
        if (_user != null) {
          await _saveUserData(_user!);
        }
        
        _isLoading = false;
        notifyListeners();  // Notify once at the end
        return {'success': true, 'data': data};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _error = errorMessage;
        _isLoading = false;
        notifyListeners();  // Notify once at the end
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();  // Notify once at the end
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
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
    } catch (e) {
      // Continue with local logout even if server logout fails
    } finally {
      await logout(); // Call existing local logout
    }
  }

  Future<Map<String, dynamic>> registerCollector(
      Map<String, dynamic> collectorData) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register-collector'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(collectorData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {
          'success': false,
          'message': errorMessage
        };
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  // Helper method to get token for API calls
  Future<String?> getToken() async {
    if (_token != null) return _token;
    await loadToken();
    return _token;
  }

  // Helper method to get user data
  Future<Map<String, dynamic>?> getUser() async {
    if (_user != null) return _user;
    await fetchProfile();
    return _user;
  }

  /// Delete user account permanently
  Future<Map<String, dynamic>> deleteAccount(String password, {String? reason}) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/user/account'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'password': password,
          if (reason != null) 'reason': reason,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Clear local data after successful deletion
        await logout();
        _setLoading(false);
        return {'success': true, 'message': data['message'] ?? 'Account deleted successfully'};
      } else {
        final errorMessage = _extractErrorMessage(data);
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }
}
