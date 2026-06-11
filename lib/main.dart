import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/services/auth_service.dart'; // Bridge: AuthService = AuthProvider
import 'core/services/admin_service.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/observability_service.dart';
import 'core/services/sync_manager.dart';
import 'core/services/complaint_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/rewards_service.dart';
import 'core/services/eco_assist_service.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/onboarding/splash_screen.dart';
import 'presentation/widgets/skeleton_loader.dart';
import 'features/notification/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  await Hive.initFlutter();

  // Initialize Dependency Injection (Clean Architecture)
  await initDependencies();

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
        // AuthService is now a typedef for AuthProvider (Clean Architecture)
        // Created via get_it service locator instead of direct instantiation
        ChangeNotifierProvider<AuthService>(create: (_) => sl<AuthService>()),
        ChangeNotifierProvider(create: (_) => AdminService()),
        ChangeNotifierProxyProvider<AuthService, ObservabilityService>(
          create: (context) => ObservabilityService(Provider.of<AuthService>(context, listen: false)),
          update: (context, auth, previous) => previous ?? ObservabilityService(auth),
        ),
        ChangeNotifierProvider(create: (_) => SyncManager()),
        ChangeNotifierProxyProvider<AuthService, ComplaintService>(
          create: (context) => ComplaintService(Provider.of<AuthService>(context, listen: false)),
          update: (context, auth, previous) => previous ?? ComplaintService(auth),
        ),
        ChangeNotifierProvider(create: (_) => sl<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => sl<RewardsService>()),
        ChangeNotifierProvider(create: (_) => EcoAssistService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'RecyConnect',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final bool? preloadedHasSeenOnboarding;
  final bool? preloadedNetworkError;

  const AuthWrapper({
    super.key,
    this.preloadedHasSeenOnboarding,
    this.preloadedNetworkError,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _hasSeenOnboarding;
  bool _isCheckingAuth = true;
  bool _networkError = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedHasSeenOnboarding != null) {
      _hasSeenOnboarding = widget.preloadedHasSeenOnboarding;
      _networkError = widget.preloadedNetworkError ?? false;
      _isCheckingAuth = false;
    } else {
      _initializeApp();
    }

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile);
      if (hasConnection) {
        if (_networkError) {
          setState(() {
            _networkError = false;
          });
          _initializeApp();
        } else {
          final authService = Provider.of<AuthService>(context, listen: false);
          if (authService.isAuthenticated) {
            NotificationService.registerDeviceToken();
            NotificationService.checkAndShowPendingNotifications();
            Provider.of<SyncManager>(context, listen: false).processQueue();
          }
        }
      } else {
        setState(() {
          _networkError = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
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
        final result = await authService.fetchProfile().timeout(const Duration(seconds: 2));
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
        } else {
          await NotificationService.registerDeviceToken();
          NotificationService.checkAndShowPendingNotifications();
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
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                SkeletonLoader.card(),
                const SizedBox(height: 20),
                SkeletonLoader.card(),
              ],
            ),
          ),
        ),
      );
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
          return const LoginScreen();
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
