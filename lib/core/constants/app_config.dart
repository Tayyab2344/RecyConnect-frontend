class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://recy-connect-backend-8aer.vercel.app/api',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static bool get hasStripePublishableKey =>
      stripePublishableKey.trim().isNotEmpty;
}
