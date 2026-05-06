import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class AppService {
  Future<Map<String, dynamic>> getBootstrapData() async {
    final token = await SecureStorageService.readToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/app/bootstrap'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load app bootstrap data');
    }
  }

  Future<List<dynamic>> getPublicRates() async {
    final token = await SecureStorageService.readToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/app/rates'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load market rates');
    }
  }
}
