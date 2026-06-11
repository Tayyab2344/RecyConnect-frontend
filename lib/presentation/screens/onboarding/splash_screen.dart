import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _glowOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;
  late Animation<double> _pulse;

  // Preloading states
  bool _hasSeenOnboarding = false;
  bool _networkError = false;
  bool _isInitFinished = false;

  @override
  void initState() {
    super.initState();

    // Main timeline: 0.9s (fast start)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Pulse loop for the glow ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Particle floating animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Logo entrance: 0.0 → 0.35 (scale from 0 + rotation + fade in)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Glow ring: 0.15 → 0.5
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text "RecyConnect": 0.35 → 0.6
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );

    // Tagline: 0.5 → 0.7
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
      ),
    );

    // Exit: 0.85 → 1.0
    _exitScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    _mainController.forward();
    _initializeApp();

    // Fallback timer (snappy fallback at 1.2s)
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted && !_isInitFinished) {
        debugPrint('Splash initialization fallback timer triggered.');
        setState(() => _isInitFinished = true);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.loadToken();

      if (authService.isAuthenticated) {
        try {
          final result = await authService.fetchProfile().timeout(const Duration(milliseconds: 800));
          if (!result['success']) {
            final msg = (result['message'] ?? '').toString().toLowerCase();
            final isNetworkError = msg.contains('network') ||
                msg.contains('socket') ||
                msg.contains('timeout') ||
                msg.contains('connection');

            if (isNetworkError) {
              _networkError = true;
            } else {
              await authService.logout();
            }
          } else {
            NotificationService.registerDeviceToken().catchError((e) {
              debugPrint('Error registering FCM token in splash: $e');
            });
          }
        } catch (e) {
          _networkError = true;
        }
      }
    } catch (e) {
      debugPrint('Error during splash initialization: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitFinished = true);
      }
    }
  }

  void _navigateToNextScreen() {
    if (!_isInitFinished) {
      Future.delayed(const Duration(milliseconds: 200), _navigateToNextScreen);
      return;
    }

    final nextScreen = AuthWrapper(
      preloadedHasSeenOnboarding: _hasSeenOnboarding,
      preloadedNetworkError: _networkError,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF071410),
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _pulseController, _particleController]),
        builder: (context, child) {
          return Opacity(
            opacity: _exitOpacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _exitScale.value,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  _buildBackground(size),

                  // Floating particles
                  _buildParticles(size),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glow ring + Logo
                        _buildLogoSection(size),

                        SizedBox(height: size.height * 0.04),

                        // App name
                        _buildAppName(),

                        const SizedBox(height: 12),

                        // Tagline
                        _buildTagline(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            const Color(0xFF0D2818).withOpacity(0.8),
            const Color(0xFF071410),
            const Color(0xFF030A07),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildParticles(Size size) {
    return CustomPaint(
      painter: _ParticlePainter(
        progress: _particleController.value,
        mainProgress: _mainController.value,
      ),
      size: size,
    );
  }

  Widget _buildLogoSection(Size size) {
    final logoSize = size.width * 0.35;

    return Opacity(
      opacity: _logoOpacity.value.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: _logoScale.value.clamp(0.0, 2.0),
        child: Transform.rotate(
          angle: _logoRotation.value * math.pi,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring (pulsing)
              if (_glowOpacity.value > 0)
                Opacity(
                  opacity: (_glowOpacity.value * 0.5).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: logoSize + 60,
                      height: logoSize + 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Inner glow
              if (_glowOpacity.value > 0)
                Opacity(
                  opacity: (_glowOpacity.value * 0.3).clamp(0.0, 1.0),
                  child: Container(
                    width: logoSize + 30,
                    height: logoSize + 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF4CAF50).withOpacity(0.1),
                          const Color(0xFF2196F3).withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // The actual app_icon.png
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(logoSize * 0.22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3 * _glowOpacity.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.15 * _glowOpacity.value),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(logoSize * 0.22),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return Opacity(
      opacity: _textOpacity.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, _textSlide.value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recy',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4CAF50),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Connect',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2196F3),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Opacity(
      opacity: _taglineOpacity.value.clamp(0.0, 1.0),
      child: Text(
        'RECYCLE SMARTER. BUILD A GREENER FUTURE.',
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.5),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

/// Floating particle painter for ambient background effect
class _ParticlePainter extends CustomPainter {
  final double progress;
  final double mainProgress;

  _ParticlePainter({required this.progress, required this.mainProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (mainProgress < 0.1) return; // Don't draw particles at very start

    final opacity = (mainProgress < 0.85)
        ? mainProgress.clamp(0.0, 1.0)
        : ((1.0 - mainProgress) / 0.15).clamp(0.0, 1.0);

    final random = math.Random(42); // fixed seed for consistency

    for (int i = 0; i < 30; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final radius = 1.5 + random.nextDouble() * 2.5;

      // Gentle floating motion
      final dx = math.sin((progress * 2 * math.pi * speed) + i) * 15;
      final dy = math.cos((progress * 2 * math.pi * speed * 0.7) + i) * 20;

      final isGreen = i % 3 != 0;
      final color = isGreen
          ? const Color(0xFF4CAF50).withOpacity(0.2 * opacity)
          : const Color(0xFF2196F3).withOpacity(0.15 * opacity);

      canvas.drawCircle(
        Offset(baseX + dx, baseY + dy),
        radius,
        Paint()..color = color,
      );
    }

    // A few larger glowing orbs
    for (int i = 0; i < 5; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.2 + random.nextDouble() * 0.3;

      final dx = math.sin((progress * 2 * math.pi * speed) + i * 2) * 25;
      final dy = math.cos((progress * 2 * math.pi * speed * 0.5) + i * 2) * 30;

      final color = i % 2 == 0
          ? const Color(0xFF4CAF50).withOpacity(0.06 * opacity)
          : const Color(0xFF2196F3).withOpacity(0.04 * opacity);

      canvas.drawCircle(
        Offset(baseX + dx, baseY + dy),
        8 + random.nextDouble() * 12,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return progress != oldDelegate.progress || mainProgress != oldDelegate.mainProgress;
  }
}
