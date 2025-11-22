import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:5000/api';

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
  Map<String, dynamic>? get currentUser => _user;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final responseData = data['data'];
        _token = responseData['accessToken'] as String?;
        _user = {
          'role': responseData['role'],
          'name': responseData['name'],
          'collectorId': responseData['collectorId'],
        };

        if (_token != null) {
          await _saveToken(_token!);
        }

        _setLoading(false);
        return true;
      } else {
        _setError(data['error']?['message'] as String? ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData, {
    File? profileImage,
    File? cnicImage,
    File? utilityImage,
    File? ntnImage,
    List<File>? extraDocs,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/register'),
      );

      // Add text fields from userData
      userData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add profile image if provided
      if (profileImage != null) {
        try {
          final bytes = await profileImage.readAsBytes();
          final filename = profileImage.path.split(Platform.pathSeparator).last;
          request.files.add(
            http.MultipartFile.fromBytes(
              'profileImage',
              bytes,
              filename: filename,
            ),
          );
        } catch (e) {
          _setError('Error reading profile image: ${e.toString()}');
          _setLoading(false);
          return {
            'success': false,
            'message': 'Error reading profile image: ${e.toString()}'
          };
        }
      }

      // Add CNIC image if provided
      if (cnicImage != null) {
        try {
          final bytes = await cnicImage.readAsBytes();
          final filename = cnicImage.path.split(Platform.pathSeparator).last;
          request.files.add(
            http.MultipartFile.fromBytes(
              'cnic',
              bytes,
              filename: filename,
            ),
          );
        } catch (e) {
          _setError('Error reading CNIC image: ${e.toString()}');
          _setLoading(false);
          return {
            'success': false,
            'message': 'Error reading CNIC image: ${e.toString()}'
          };
        }
      }

      // Add utility bill image if provided
      if (utilityImage != null) {
        try {
          final bytes = await utilityImage.readAsBytes();
          final filename = utilityImage.path.split(Platform.pathSeparator).last;
          request.files.add(
            http.MultipartFile.fromBytes(
              'utility',
              bytes,
              filename: filename,
            ),
          );
        } catch (e) {
          _setError('Error reading utility bill: ${e.toString()}');
          _setLoading(false);
          return {
            'success': false,
            'message': 'Error reading utility bill: ${e.toString()}'
          };
        }
      }

      // Add NTN document if provided
      if (ntnImage != null) {
        try {
          final bytes = await ntnImage.readAsBytes();
          final filename = ntnImage.path.split(Platform.pathSeparator).last;
          request.files.add(
            http.MultipartFile.fromBytes(
              'ntn',
              bytes,
              filename: filename,
            ),
          );
        } catch (e) {
          _setError('Error reading NTN document: ${e.toString()}');
          _setLoading(false);
          return {
            'success': false,
            'message': 'Error reading NTN document: ${e.toString()}'
          };
        }
      }

      // Add extra documents if provided
      if (extraDocs != null && extraDocs.isNotEmpty) {
        for (var doc in extraDocs) {
          try {
            final bytes = await doc.readAsBytes();
            final filename = doc.path.split(Platform.pathSeparator).last;
            request.files.add(
              http.MultipartFile.fromBytes(
                'extraDocs',
                bytes,
                filename: filename,
              ),
            );
          } catch (e) {
            _setError('Error reading extra document: ${e.toString()}');
            _setLoading(false);
            return {
              'success': false,
              'message': 'Error reading extra document: ${e.toString()}'
            };
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        _setError(data['error']?['message'] ??
            data['message'] ??
            'Registration failed');
        _setLoading(false);
        return {
          'success': false,
          'message': data['error']?['message'] ?? data['message']
        };
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'] as String?;
        _user = data['user'] as Map<String, dynamic>?;

        if (_token != null) {
          await _saveToken(_token!);
        }

        _setLoading(false);
        return {'success': true, 'data': data};
      } else {
        _setError(data['message'] as String? ?? 'OTP verification failed');
        _setLoading(false);
        return {'success': false, 'message': data['message']};
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
        Uri.parse('$baseUrl/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'data': data};
      } else {
        _setError(data['message'] as String? ?? 'Failed to resend OTP');
        _setLoading(false);
        return {'success': false, 'message': data['message']};
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
    }
  }

  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
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
      Map<String, dynamic> updateData, File? profileImage) async {
    try {
      _setLoading(true);
      _setError(null);

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/me'),
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
          final filename = profileImage.path.split('/').last;
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
        _setError(
            data['error']?['message'] as String? ?? 'Profile update failed');
        _setLoading(false);
        return {'success': false, 'message': data['error']?['message']};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _user = data['data'] as Map<String, dynamic>?;
        notifyListeners();

        _setLoading(false);
        return {'success': true, 'data': data};
      } else {
        _setError(
            data['error']?['message'] as String? ?? 'Failed to fetch profile');
        _setLoading(false);
        return {'success': false, 'message': data['error']?['message']};
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        _setError(data['error']?['message'] ?? 'Failed to send reset email');
        _setLoading(false);
        return {'success': false, 'message': data['error']?['message']};
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
        Uri.parse('$baseUrl/auth/reset-password'),
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
        _setError(data['error']?['message'] ?? 'Password reset failed');
        _setLoading(false);
        return {'success': false, 'message': data['error']?['message']};
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
        Uri.parse('$baseUrl/auth/change-password'),
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
        _setError(data['error']?['message'] ?? 'Password change failed');
        _setLoading(false);
        return {'success': false, 'message': data['error']?['message']};
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
          Uri.parse('$baseUrl/auth/logout'),
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
        Uri.parse('$baseUrl/auth/register-collector'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(collectorData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        _setError(data['error']?['message'] ??
            data['message'] ??
            'Collector registration failed');
        _setLoading(false);
        return {
          'success': false,
          'message': data['error']?['message'] ?? data['message']
        };
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }
}
