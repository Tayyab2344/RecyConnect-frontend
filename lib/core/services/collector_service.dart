import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../di/service_locator.dart';
import 'auth_service.dart';

class CollectorService {
  final AuthService _authService = sl<AuthService>();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, String>> _authOnlyHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw Exception(body['message'] ?? 'Collector request failed');
  }

  // Get all collectors for the warehouse
  Future<List<dynamic>> getCollectors() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/warehouse/collectors'),
      headers: await _headers(),
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

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/collector/dashboard'),
      headers: await _headers(),
    );
    return _decode(response)['data'] ?? {};
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/collector/me'),
      headers: await _headers(),
    );
    return _decode(response)['data'] ?? {};
  }

  Future<List<dynamic>> getTasks({String? status, bool history = false}) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (history) query['history'] = 'true';

    final uri = Uri.parse('${ApiConstants.baseUrl}/collector/tasks')
        .replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.get(uri, headers: await _headers());
    final decoded = _decode(response);
    return decoded['data'] ?? [];
  }

  Future<Map<String, dynamic>> updateAvailability({
    required String availabilityStatus,
    String? dutyStatus,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/collector/availability'),
      headers: await _headers(),
      body: jsonEncode({
        'availabilityStatus': availabilityStatus,
        if (dutyStatus != null) 'dutyStatus': dutyStatus,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      }),
    );
    return _decode(response)['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/collector/tasks/$taskId/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );
    return _decode(response)['data'] ?? {};
  }

  Future<Map<String, dynamic>> acceptTask(int taskId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/collector/tasks/$taskId/accept'),
      headers: await _headers(),
    );
    return _decode(response)['data'] ?? {};
  }

  Future<Map<String, dynamic>> recordLocation({
    int? taskId,
    required double latitude,
    required double longitude,
    double? accuracy,
    String? status,
  }) async {
    final path = taskId == null
        ? '${ApiConstants.baseUrl}/collector/location'
        : '${ApiConstants.baseUrl}/collector/tasks/$taskId/location';
    final response = await http.post(
      Uri.parse(path),
      headers: await _headers(),
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (status != null) 'status': status,
      }),
    );
    return _decode(response)['data'] ?? {};
  }

  /// Verify waste with optional proof photo uploads
  Future<Map<String, dynamic>> verifyWaste({
    required int taskId,
    required double verifiedWeight,
    required String verifiedCategory,
    String? verifiedMaterial,
    String? notes,
    List<String> proofImages = const [],
    List<XFile> proofFiles = const [],
  }) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/collector/tasks/$taskId/verify'),
    );

    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields['verifiedWeight'] = verifiedWeight.toString();
    request.fields['verifiedCategory'] = verifiedCategory;
    if (verifiedMaterial != null && verifiedMaterial.isNotEmpty) {
      request.fields['verifiedMaterial'] = verifiedMaterial;
    }
    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }

    // Attach photo files from camera/gallery
    for (final file in proofFiles) {
      request.files.add(await http.MultipartFile.fromPath('proofImages', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response)['data'] ?? {};
  }

  /// Confirm delivery with optional proof photos and OTP verification
  Future<Map<String, dynamic>> confirmDelivery({
    required int taskId,
    String? receiverName,
    String? receiverContact,
    String? receiverConfirmation,
    double? receivedWeight,
    String? packageCondition,
    String? notes,
    String? otpCode,
    double? distance,
    List<String> proofImages = const [],
    List<XFile> proofFiles = const [],
  }) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/collector/tasks/$taskId/delivery'),
    );

    request.headers.addAll({'Authorization': 'Bearer $token'});
    if (receiverName != null && receiverName.isNotEmpty) request.fields['receiverName'] = receiverName;
    if (receiverContact != null && receiverContact.isNotEmpty) request.fields['receiverContact'] = receiverContact;
    if (receiverConfirmation != null && receiverConfirmation.isNotEmpty) request.fields['receiverConfirmation'] = receiverConfirmation;
    if (receivedWeight != null) request.fields['receivedWeight'] = receivedWeight.toString();
    if (packageCondition != null && packageCondition.isNotEmpty) request.fields['packageCondition'] = packageCondition;
    if (notes != null && notes.isNotEmpty) request.fields['notes'] = notes;
    if (otpCode != null && otpCode.isNotEmpty) request.fields['otpCode'] = otpCode;
    if (distance != null) request.fields['distance'] = distance.toString();

    // Attach photo files from camera/gallery
    for (final file in proofFiles) {
      request.files.add(await http.MultipartFile.fromPath('proofImages', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response)['data'] ?? {};
  }

  /// Report a safety/field incident with optional proof photo
  Future<Map<String, dynamic>> reportIncident({
    int? taskId,
    required String type,
    required String description,
    XFile? proofImage,
  }) async {
    final token = await _authService.getToken();
    final idSegment = taskId?.toString() ?? '0';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/collector/tasks/$idSegment/incident'),
    );

    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields['type'] = type;
    request.fields['description'] = description;

    if (proofImage != null) {
      request.files.add(await http.MultipartFile.fromPath('proofImages', proofImage.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response)['data'] ?? {};
  }

  /// Get collector earnings wallet and transaction log
  Future<Map<String, dynamic>> getEarnings({String? status}) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) query['status'] = status;

    final uri = Uri.parse('${ApiConstants.baseUrl}/collector/earnings')
        .replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.get(uri, headers: await _headers());
    return _decode(response)['data'] ?? {};
  }

  /// Assign a collector task (Warehouse dashboard only)
  Future<Map<String, dynamic>> assignTask({
    required int collectorId,
    required String taskType,
    required String sourceType,
    required String sourceAddress,
    String? sourceName,
    String? sourceContact,
    required String destinationType,
    required String destinationAddress,
    String? destinationName,
    String? destinationContact,
    required String materialCategory,
    required double estimatedWeight,
    String? materialType,
    double? pricePerUnit,
    double? deliveryFee,
    String? notes,
    String? instructions,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/warehouse/collector-tasks'),
      headers: await _headers(),
      body: jsonEncode({
        'collectorId': collectorId,
        'taskType': taskType,
        'sourceType': sourceType,
        'sourceAddress': sourceAddress,
        if (sourceName != null) 'sourceName': sourceName,
        if (sourceContact != null) 'sourceContact': sourceContact,
        'destinationType': destinationType,
        'destinationAddress': destinationAddress,
        if (destinationName != null) 'destinationName': destinationName,
        if (destinationContact != null) 'destinationContact': destinationContact,
        'materialCategory': materialCategory,
        'estimatedWeight': estimatedWeight,
        if (materialType != null) 'materialType': materialType,
        if (pricePerUnit != null) 'pricePerUnit': pricePerUnit,
        if (deliveryFee != null) 'deliveryFee': deliveryFee,
        if (notes != null) 'notes': notes,
        if (instructions != null) 'instructions': instructions,
      }),
    );
    return _decode(response);
  }
}
