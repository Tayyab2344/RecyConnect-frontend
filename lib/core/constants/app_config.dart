class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://recyconnect-backend.onrender.com/api',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51TIrmdRoUZN6nt4Cr39P7xQbKlfFVBdSNxnCEnliaJueZcUiKUw1QxuXkUj2VJR9KsiQCUxSXJI58DewZDyoHSUS00k7tJCsi0',
  );

  static bool get hasStripePublishableKey =>
      stripePublishableKey.trim().isNotEmpty;
}
