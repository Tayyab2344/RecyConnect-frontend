import 'package:flutter/foundation.dart';
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

  if (!kIsWeb && AppConfig.hasStripePublishableKey) {
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    // Try to restore saved authentication
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loadToken();
    
    // If we have a saved token, try to fetch the user profile
    if (authService.isAuthenticated) {
      final result = await authService.fetchProfile();
      // If fetching profile fails (e.g., token expired), logout
      if (!result['success']) {
        await authService.logout();
      }
    }
    
    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loader while checking auth and prefs
    if (_isCheckingAuth || _hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const DashboardScreen();
        } else if (!_hasSeenOnboarding!) {
          return const OnboardingScreen();
        } else {
          return const AnimatedStoryWelcomeScreen();
        }
      },
    );
  }
}






