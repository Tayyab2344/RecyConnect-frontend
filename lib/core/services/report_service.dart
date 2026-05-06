import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class ReportService {
  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await SecureStorageService.readToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reports/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load dashboard statistics');
    }
  }

  Future<List<dynamic>> getActivity({int limit = 10}) async {
    final token = await SecureStorageService.readToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reports/activity?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load recent activity');
    }
  }

  Future<Map<String, dynamic>> getTrends({int months = 6}) async {
    final token = await SecureStorageService.readToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reports/trends?months=$months'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load trends');
    }
  }
}
