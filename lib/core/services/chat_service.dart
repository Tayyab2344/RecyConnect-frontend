import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../di/service_locator.dart';
import 'auth_service.dart';

class ChatService {
  final AuthService _authService = sl<AuthService>();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw Exception(body['message'] ?? 'Chat request failed');
  }

  // Get conversations for the current authenticated user
  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/chat/conversations'),
      headers: await _headers(),
    );
    final decoded = _decode(response);
    return decoded['data'] ?? [];
  }

  // Get total unread message count across all conversations
  Future<int> getTotalUnreadCount() async {
    try {
      final conversations = await getConversations();
      int total = 0;
      for (final c in conversations) {
        total += (c['unreadCount'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  // Get messages for a specific conversation with pagination
  Future<List<dynamic>> getMessages(int conversationId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/chat/conversations/$conversationId/messages'),
      headers: await _headers(),
    );
    final decoded = _decode(response);
    return decoded['data'] ?? [];
  }

  // Send a message via REST API
  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String content,
    String? imageUrl,
    String? voiceUrl,
    String messageType = 'TEXT',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/chat/messages'),
      headers: await _headers(),
      body: jsonEncode({
        'conversationId': conversationId,
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (voiceUrl != null) 'voiceUrl': voiceUrl,
        'messageType': messageType,
      }),
    );
    final decoded = _decode(response);
    return decoded['data'] ?? {};
  }

  // Get conversations linked to a specific order
  Future<List<dynamic>> getOrderChats(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/chat/order/$orderId'),
      headers: await _headers(),
    );
    final decoded = _decode(response);
    return decoded['data'] ?? [];
  }

  // Upload a voice note recording
  Future<Map<String, dynamic>> uploadVoiceNote(String filePath) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/chat/voice-message/upload'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('voice', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = _decode(response);
    return decoded['data'] ?? {};
  }
}
