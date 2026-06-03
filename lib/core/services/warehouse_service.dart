import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class WarehouseService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Helper to generate common headers containing authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Add a new collector with full details and files (Existing method)
  Future<Map<String, dynamic>> addCollector({
    required String name,
    required String address,
    required String contactNo,
    required String token,
    File? profileImage,
    File? cnic,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/warehouse/add-collector'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['address'] = address;
      request.fields['contactNo'] = contactNo;

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
        ));
      }

      if (cnic != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cnic',
          cnic.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (streamedResponse.statusCode == 201) {
        _setLoading(false);
        return {
          'success': true,
          'collectorId': data['data']['collectorId'],
          'password': data['data']['password'],
          'name': data['data']['name'],
        };
      } else {
        _setError(data['error']?['message'] ?? 'Failed to add collector');
        _setLoading(false);
        return {
          'success': false,
          'message': data['error']?['message'] ?? 'Failed to add collector',
        };
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // ERP: INVENTORY MANAGEMENT
  // ==========================================

  /// Fetch all inventory list from warehouse
  Future<List<dynamic>> getInventory({String? search, String? status, String? materialType}) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (materialType != null && materialType.isNotEmpty) queryParams['materialType'] = materialType;

      final uri = Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/inventory')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      _setLoading(false);
      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        _setError(data['error']?['message'] ?? 'Failed to fetch inventory');
        return [];
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Add new inventory item, supports file upload for AI classification
  Future<Map<String, dynamic>> addInventoryItem({
    required String materialType,
    required String category,
    required double quantity,
    required double reorderLevel,
    required double purchasePrice,
    required double sellingPrice,
    String? location,
    String? notes,
    int? supplierId,
    File? image,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await SecureStorageService.readToken();
      final url = Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/inventory');

      http.Response response;

      if (image != null) {
        // Multipart upload
        final request = http.MultipartRequest('POST', url);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        request.fields['materialType'] = materialType;
        request.fields['category'] = category;
        request.fields['quantityInStock'] = quantity.toString();
        request.fields['reorderLevel'] = reorderLevel.toString();
        request.fields['purchasePrice'] = purchasePrice.toString();
        request.fields['sellingPrice'] = sellingPrice.toString();
        if (location != null) request.fields['location'] = location;
        if (notes != null) request.fields['notes'] = notes;
        if (supplierId != null) request.fields['supplierId'] = supplierId.toString();

        request.files.add(await http.MultipartFile.fromPath('image', image.path));

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        // Standard JSON post
        final headers = await _getHeaders();
        final body = {
          'materialType': materialType,
          'category': category,
          'quantityInStock': quantity,
          'reorderLevel': reorderLevel,
          'purchasePrice': purchasePrice,
          'sellingPrice': sellingPrice,
          'location': location,
          'notes': notes,
          'supplierId': supplierId,
        };

        response = await http.post(url, headers: headers, body: jsonEncode(body));
      }

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        _setError(data['error']?['message'] ?? 'Failed to add inventory item');
        return {'success': false, 'message': data['error']?['message']};
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update stock quantities or locations
  Future<Map<String, dynamic>> updateInventoryItem(
    int id, {
    double? quantity,
    double? reorderLevel,
    double? purchasePrice,
    double? sellingPrice,
    String? location,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final body = {
        if (quantity != null) 'quantityInStock': quantity,
        if (reorderLevel != null) 'reorderLevel': reorderLevel,
        if (purchasePrice != null) 'purchasePrice': purchasePrice,
        if (sellingPrice != null) 'sellingPrice': sellingPrice,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/inventory/$id'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        _setError(data['error']?['message'] ?? 'Failed to update inventory item');
        return {'success': false, 'message': data['error']?['message']};
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Hard delete inventory stock from list
  Future<bool> deleteInventoryItem(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/inventory/$id'),
        headers: headers,
      );

      _setLoading(false);
      return response.statusCode == 200;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // ERP: EXPENSE MANAGEMENT
  // ==========================================

  /// Fetch logged warehouse operating expenses
  Future<List<dynamic>> getExpenses({String? category, String? startDate, String? endDate}) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;

      final uri = Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/expenses')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      _setLoading(false);
      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        _setError(data['error']?['message'] ?? 'Failed to fetch expenses');
        return [];
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Create new expense log sheet entry
  Future<Map<String, dynamic>> addExpense({
    required String category,
    required double amount,
    String? description,
    String? date,
    File? receipt,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await SecureStorageService.readToken();
      final url = Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/expenses');

      http.Response response;

      if (receipt != null) {
        final request = http.MultipartRequest('POST', url);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        request.fields['category'] = category;
        request.fields['amount'] = amount.toString();
        if (description != null) request.fields['description'] = description;
        if (date != null) request.fields['date'] = date;

        request.files.add(await http.MultipartFile.fromPath('receipt', receipt.path));

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        final headers = await _getHeaders();
        final body = {
          'category': category,
          'amount': amount,
          'description': description,
          'date': date,
        };

        response = await http.post(url, headers: headers, body: jsonEncode(body));
      }

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        _setError(data['error']?['message'] ?? 'Failed to add expense');
        return {'success': false, 'message': data['error']?['message']};
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Delete logged operational expense sheet
  Future<bool> deleteExpense(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/expenses/$id'),
        headers: headers,
      );

      _setLoading(false);
      return response.statusCode == 200;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // ERP: PROFIT & LOSS CALCULATOR
  // ==========================================

  /// Calculate revenues, purchases, expenses totals
  Future<Map<String, dynamic>> getFinancialSummary() async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/financial-summary'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200) {
        return data['data'] ?? {};
      } else {
        _setError(data['error']?['message'] ?? 'Failed to load financial statistics');
        return {};
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {};
    }
  }

  // ==========================================
  // ERP: CUSTOMER MANAGEMENT
  // ==========================================

  /// Fetch customer client database list
  Future<List<dynamic>> getCustomers() async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/customers'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        _setError(data['error']?['message'] ?? 'Failed to load customers list');
        return [];
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  // ==========================================
  // ERP: REPORT GENERATION & PRINT
  // ==========================================

  /// Generate report summary matching specific filters
  Future<Map<String, dynamic>> getReport({required String type, String? startDate, String? endDate}) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final queryParams = {
        'type': type,
        if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/reports')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200) {
        return data['data'] ?? {};
      } else {
        _setError(data['error']?['message'] ?? 'Failed to generate report');
        return {};
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {};
    }
  }

  // ==========================================
  // ERP: SMART AI BUSINESS INSIGHTS & CHAT
  // ==========================================

  /// Fetch smart AI operational recommendations list
  Future<List<dynamic>> getAIInsights() async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/ai-insights'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        _setError(data['error']?['message'] ?? 'Failed to load AI insights');
        return [];
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Communicate with AI Business assistant
  Future<String> askAIAssistant(String message) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/warehouse/erp/ai-assistant'),
        headers: headers,
        body: jsonEncode({'message': message}),
      );

      final data = jsonDecode(response.body);
      _setLoading(false);

      if (response.statusCode == 200) {
        return data['data']?['reply'] ?? 'No response received.';
      } else {
        _setError(data['error']?['message'] ?? 'Failed to reach AI assistant');
        return 'Sorry, I failed to reach the assistant: ${data['error']?['message']}';
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return 'Sorry, a connection error occurred: $e';
    }
  }
}
