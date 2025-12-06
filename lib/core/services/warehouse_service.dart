import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../constants/api_constants.dart';

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

  /// Add a new collector with full details and files
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

      if (response.statusCode == 201) {
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
}
