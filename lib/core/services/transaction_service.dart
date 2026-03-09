import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  // Create a new transaction record
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse(ApiConstants.transactions),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create transaction: ${response.body}');
    }
  }

  // Get user's transaction history
  Future<List<dynamic>> getTransactions() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.get(
      Uri.parse(ApiConstants.transactions),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      // Depending on backend structure, might need to parse `data` or `transactions` key
      return decodedData['data'] ?? decodedData['transactions'] ?? decodedData;
    } else {
      throw Exception('Failed to load transactions: ${response.body}');
    }
  }

  // Update transaction status
  Future<Map<String, dynamic>> updateTransactionStatus(String id, String status) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.put(
      Uri.parse('${ApiConstants.transactions}/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update transaction status: ${response.body}');
    }
  }
}
