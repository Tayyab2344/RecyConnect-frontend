import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/auth_service.dart';
import 'core/services/admin_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/intro_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
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
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
