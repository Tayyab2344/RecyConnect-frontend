import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/auth_service.dart';
import 'core/services/admin_service.dart';
<<<<<<< HEAD
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/intro_screen.dart';
=======
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'presentation/screens/onboarding/welcome_story_screen.dart';
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  
=======

  // Initialize Stripe with the publishable key
  Stripe.publishableKey =
      'pk_test_51TIrmdRoUZN6nt4Cr39P7xQbKlfFVBdSNxnCEnliaJueZcUiKUw1QxuXkUj2VJR9KsiQCUxSXJI58DewZDyoHSUS00k7tJCsi0';
  await Stripe.instance.applySettings();

>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
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
            home: const SplashRouter(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

<<<<<<< HEAD
/// SplashRouter - Determines which screen to show first based on first launch status
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  bool _isLoading = true;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;
    
    if (!hasSeenIntro) {
      // Mark intro as seen for future launches
      await prefs.setBool('has_seen_intro', true);
    }
    
    if (mounted) {
      setState(() {
        _showIntro = !hasSeenIntro;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show minimal loading state while checking preferences
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_showIntro) {
      return const IntroScreen();
    }

    return const AuthWrapper();
  }
}

/// AuthWrapper - Routes authenticated users to Dashboard, others to WelcomeScreen
class AuthWrapper extends StatelessWidget {
=======

class AuthWrapper extends StatefulWidget {
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
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
          return const WelcomeScreen();
        }
      },
    );
  }
}
