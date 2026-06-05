import 'package:flutter/foundation.dart';
import 'api_service.dart';

class EcoAssistService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sends a query message to the EcoAssist AI companion on the backend
  /// and returns the structured JSON response containing:
  /// - `reply`: String text in English, Urdu or Roman Urdu
  /// - `intent`: { `action`: String, `params`: Map }
  /// - `suggestions`: List<String>
  Future<Map<String, dynamic>> sendQuery(String message, {Map<String, dynamic>? location}) async {
    _setLoading(true);
    try {
      final payload = {
        'message': message,
        if (location != null) 'location': location,
      };

      final res = await _apiService.post('/app/eco-assist/chat', payload);

      if (res['success'] == true) {
        return {
          'success': true,
          'data': res['data'], // This holds the ecoassist json result
        };
      }
      return {
        'success': false,
        'message': res['message'] ?? 'Failed to receive reply from EcoAssist',
      };
    } catch (e) {
      if (kDebugMode) print('EcoAssist API query error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }
}
