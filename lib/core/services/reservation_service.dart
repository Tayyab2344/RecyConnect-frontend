import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../di/service_locator.dart';
import 'auth_service.dart';

class ReservationService {
  final AuthService _authService = sl<AuthService>();

  // Reserve a specific quantity of a listing
  Future<Map<String, dynamic>> reserveListing(int listingId, double quantity) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse(ApiConstants.reservations),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'listingId': listingId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  // Manually release an active reservation
  Future<Map<String, dynamic>> releaseReservation(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No auth token available');

    final response = await http.post(
      Uri.parse('${ApiConstants.reservations}/$id/release'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to release reservation: ${response.body}');
    }
  }
}
