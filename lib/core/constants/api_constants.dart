import 'app_config.dart';

class ApiConstants {
  static const String baseUrl = AppConfig.apiBaseUrl;

  static const String checkEmail = '$baseUrl/auth/check-email';

  // Transaction, Reservation, and Payment Endpoints
  static const String transactions = '$baseUrl/transactions';
  static const String reservations = '$baseUrl/reservations';
  static const String payments = '$baseUrl/payments';
}
