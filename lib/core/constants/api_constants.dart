class ApiConstants {
  // Production URL (Default)
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://recy-connect-backend-6smb.vercel.app/api');

  static const String checkEmail = '$baseUrl/auth/check-email';

  // Transaction, Reservation, and Payment Endpoints
  static const String transactions = '$baseUrl/transactions';
  static const String reservations = '$baseUrl/reservations';
  static const String payments = '$baseUrl/payments';
}
