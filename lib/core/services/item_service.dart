import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../di/service_locator.dart';
import 'auth_service.dart';

class ItemService {
  final AuthService _authService = sl<AuthService>();

  Future<Map<String, dynamic>> createItem({
    required String title,
    required String description,
    required double price,
    required double quantity,
    required String category,
    required String unit,
    required List<File> images,
  }) async {
    final token = await _authService.getToken();
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.baseUrl}/items'));
    
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['quantity'] = quantity.toString();
    request.fields['category'] = category;
    request.fields['unit'] = unit;

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: MediaType('image', 'jpeg'), // Adjust based on file type if needed
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create item: ${response.body}');
    }
  }

  Future<List<dynamic>> getItems({String? sellerId, String? category, String? search}) async {
    final token = await _authService.getToken();
    String query = '';
    if (sellerId != null) query += 'sellerId=$sellerId&';
    if (category != null) query += 'category=$category&';
    if (search != null) query += 'search=$search&';

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/items?$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch items');
    }
  }

  Future<void> deleteItem(int id) async {
    final token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/items/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }
}
