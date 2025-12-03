import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class CollectorService {
  final AuthService _authService = AuthService();

  // Get all collectors for the warehouse
  Future<List<dynamic>> getCollectors() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/warehouse/collectors'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch collectors');
    }
  }

  // Add a new collector
  Future<Map<String, dynamic>> addCollector({
    required String name,
    required String address,
    required String contactNo,
    required XFile? profileImage,
    required XFile? cnicImage,
  }) async {
    final token = await _authService.getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/warehouse/add-collector'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    request.fields['address'] = address;
    request.fields['contactNo'] = contactNo;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        profileImage.path,
      ));
    }

    if (cnicImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'cnic',
        cnicImage.path,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to add collector');
    }
  }
}
