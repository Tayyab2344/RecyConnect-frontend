class ApiConstants {
  // Production URL - Vercel Backend
  static const String baseUrl = 'http://localhost:5000/api';

  static const String checkEmail = '$baseUrl/auth/check-email';

  // Transaction, Reservation, and Payment Endpoints
  static const String transactions = '$baseUrl/transactions';
  static const String reservations = '$baseUrl/reservations';
  static const String payments = '$baseUrl/payments';
}
