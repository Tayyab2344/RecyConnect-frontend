import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {

  // Get stored JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET request with authentication
  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      
      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request with authentication
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      
      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request with authentication
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      
      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request with authentication
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      
      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? errorBody['error']?['message'] ?? 'Unknown error';
      throw Exception('HTTP ${response.statusCode}: $message');
    }
  }
}
