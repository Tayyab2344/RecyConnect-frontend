import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class BatchService {
  Future<List<dynamic>> batchGetListings(List<int> ids) async {
    final token = await SecureStorageService.readToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/batch/listings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'ids': ids}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to batch fetch listings');
    }
  }

  Future<List<dynamic>> batchGetOrders(List<int> ids) async {
    final token = await SecureStorageService.readToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/batch/orders'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'ids': ids}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to batch fetch orders');
    }
  }

  Future<List<dynamic>> batchGetUsers(List<int> ids) async {
    final token = await SecureStorageService.readToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/batch/users'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'ids': ids}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to batch fetch users');
    }
  }
}
