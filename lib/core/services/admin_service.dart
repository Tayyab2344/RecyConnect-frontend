import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:5000/api';
  
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _totalLogs = 0;

  List<Map<String, dynamic>> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get totalLogs => _totalLogs;

  String? _token;

  AdminService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> getLogs({
    int page = 1,
    int limit = 20,
    String? query,
    String? action,
    String? role,
    int? userId,
    String? resourceType,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      if (page == 1) {
        _setLoading(true);
        _logs.clear();
      }
      _setError(null);

      if (_token == null) {
        await _loadToken();
        if (_token == null) {
          throw Exception('No authentication token found');
        }
      }

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (action != null) queryParams['action'] = action;
      if (role != null) queryParams['role'] = role;
      if (userId != null) queryParams['userId'] = userId.toString();
      if (resourceType != null) queryParams['resourceType'] = resourceType;
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();

      final uri = Uri.parse('$baseUrl/admin/logs').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final newLogs = List<Map<String, dynamic>>.from(data['data']['items']);
        _totalLogs = data['data']['total'];
        
        if (page == 1) {
          _logs = newLogs;
        } else {
          _logs.addAll(newLogs);
        }
        
        _hasMore = _logs.length < _totalLogs;
        _setLoading(false);
      } else {
        throw Exception(data['error']?['message'] ?? 'Failed to fetch logs');
      }
    } catch (e) {
      _setError('Error fetching logs: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getLogById(int id) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_token == null) {
        await _loadToken();
        if (_token == null) {
          throw Exception('No authentication token found');
        }
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/logs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _setLoading(false);
        return data['data'];
      } else if (response.statusCode == 404) {
        throw Exception('Log not found');
      } else {
        throw Exception(data['error']?['message'] ?? 'Failed to fetch log');
      }
    } catch (e) {
      _setError('Error fetching log: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  void clearLogs() {
    _logs.clear();
    _hasMore = true;
    _totalLogs = 0;
    _error = null;
    notifyListeners();
  }
}