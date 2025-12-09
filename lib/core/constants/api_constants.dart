class ApiConstants {
  // Localhost for emulator/web development
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5000/api');
  
  // Ngrok URL for running APK on physical device (backend on laptop)
  // static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://perkish-unpigmented-nadia.ngrok-free.dev/api');

  static const String checkEmail = '$baseUrl/auth/check-email';
}
