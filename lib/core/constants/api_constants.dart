class ApiConstants {
  // Production URL (Default)
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://recy-connect-six.vercel.app/api');

  static const String checkEmail = '$baseUrl/auth/check-email';
}
