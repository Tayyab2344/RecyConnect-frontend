import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/admin_service.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'presentation/screens/onboarding/welcome_story_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.hasStripePublishableKey) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'RecyConnect',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _hasSeenOnboarding;
  bool _isCheckingAuth = true;
  bool _networkError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (mounted) {
      setState(() {
        _networkError = false;
        _isCheckingAuth = true;
      });
    }

    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Try to restore saved authentication
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loadToken();

    // If we have a saved token, try to fetch the user profile
    if (authService.isAuthenticated) {
      try {
        final result = await authService.fetchProfile();
        if (!result['success']) {
          final msg = (result['message'] ?? '').toString().toLowerCase();
          final isNetworkError = msg.contains('network') ||
              msg.contains('socket') ||
              msg.contains('timeout') ||
              msg.contains('connection') ||
              msg.contains('failed host');

          if (isNetworkError) {
            // Keep the session alive — user can still use cached data
            if (mounted) setState(() => _networkError = true);
          } else {
            // Auth error (401, token expired) — force re-login
            await authService.logout();
          }
        }
      } catch (e) {
        // Network exception — keep session alive
        if (mounted) setState(() => _networkError = true);
      }
    }

    if (mounted) {
      setState(() {
        _hasSeenOnboarding = hasSeenOnboarding;
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth || _hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          if (_networkError) {
            return Stack(
              children: [
                const DashboardScreen(),
                _buildConnectivityBanner(context),
              ],
            );
          }
          return const DashboardScreen();
        } else if (!_hasSeenOnboarding!) {
          return const OnboardingScreen();
        } else {
          return const AnimatedStoryWelcomeScreen();
        }
      },
    );
  }

  Widget _buildConnectivityBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A1A00) : const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.orange.withValues(alpha: 0.3)
                  : Colors.orange.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded,
                  color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                  size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No internet connection. Some features may be limited.',
                  style: TextStyle(
                    color: isDark ? Colors.orange.shade200 : Colors.orange.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _initializeApp,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
