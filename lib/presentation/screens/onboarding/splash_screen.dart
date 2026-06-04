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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Preloading states
  bool _hasSeenOnboarding = false;
  bool _networkError = false;
  bool _isInitFinished = false;

  @override
  void initState() {
    super.initState();

    // 3-second animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Check onboarding status
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // 2. Restore saved authentication
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.loadToken();

      // 3. If authenticated, fetch profile
      if (authService.isAuthenticated) {
        try {
          final result = await authService.fetchProfile();
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
            await NotificationService.registerDeviceToken();
          }
        } catch (e) {
          _networkError = true;
        }
      }
    } catch (e) {
      debugPrint('Error during splash initialization: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitFinished = true;
        });
      }
    }
  }

  void _navigateToNextScreen() {
    // If initialization hasn't finished, wait for it
    if (!_isInitFinished) {
      Future.delayed(const Duration(milliseconds: 200), _navigateToNextScreen);
      return;
    }

    final nextScreen = AuthWrapper(
      preloadedHasSeenOnboarding: _hasSeenOnboarding,
      preloadedNetworkError: _networkError,
    );

    // Scale up and fade transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
          final scale = ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: fade,
          );
          return scale;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071410), // Deep forest dark green background
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          
          // Animate phases based on timeline value
          // 0.0 - 0.33: Drift & transform particles
          // 0.33 (1s): Meet and spark
          // 0.33 - 0.67: Logo reveals, wordmark slides
          // 0.67 - 0.83: Hold
          // 0.83 - 1.0: Transition scale-up & fade-out
          
          double driftProgress = (value / 0.33).clamp(0.0, 1.0);
          double sparkProgress = 0.0;
          if (value > 0.33 && value <= 0.5) {
            sparkProgress = ((value - 0.33) / 0.17).clamp(0.0, 1.0);
          }
          
          double logoRevealProgress = 0.0;
          if (value > 0.33) {
            logoRevealProgress = ((value - 0.33) / 0.34).clamp(0.0, 1.0);
          }

          double exitProgress = 0.0;
          if (value > 0.83) {
            exitProgress = ((value - 0.83) / 0.17).clamp(0.0, 1.0);
          }

          return Opacity(
            opacity: (1.0 - exitProgress).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 1.0 + (exitProgress * 0.08),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Custom painter to draw animated logo, spark, and particles
                  CustomPaint(
                    painter: RecyConnectSplashPainter(
                      driftProgress: driftProgress,
                      sparkProgress: sparkProgress,
                      logoProgress: logoRevealProgress,
                    ),
                    size: MediaQuery.of(context).size,
                  ),

                  // Wordmark text reveal at the bottom center
                  if (logoRevealProgress > 0.1)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.22,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: logoRevealProgress,
                          child: Transform.translate(
                            offset: Offset(0, 15 * (1.0 - logoRevealProgress)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'recy',
                                  style: GoogleFonts.outfit(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00D2C4), // Vivid electric teal
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'connect',
                                  style: GoogleFonts.outfit(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFF7F5F0), // Warm sand
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Minimal optimistic tagline
                  if (logoRevealProgress > 0.4)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.17,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: ((logoRevealProgress - 0.4) / 0.6).clamp(0.0, 1.0),
                          child: Text(
                            'Exchange Waste. Save the Planet.',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFF7F5F0).withOpacity(0.6),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
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
}

class RecyConnectSplashPainter extends CustomPainter {
  final double driftProgress;
  final double sparkProgress;
  final double logoProgress;

  RecyConnectSplashPainter({
    required this.driftProgress,
    required this.sparkProgress,
    required this.logoProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 30);
    final baseRadius = size.width * 0.16;

    // Phase 1: Drifting particles
    if (driftProgress < 1.0) {
      _drawDriftingParticles(canvas, center, size.width, driftProgress);
    }

    // Phase 2: Spark flash
    if (sparkProgress > 0.0 && sparkProgress < 1.0) {
      _drawSpark(canvas, center, baseRadius, sparkProgress);
    }

    // Phase 3: Logo drawing
    if (logoProgress > 0.0) {
      _drawLogo(canvas, center, baseRadius, logoProgress);
    }
  }

  void _drawDriftingParticles(Canvas canvas, Offset center, double screenWidth, double progress) {
    // Physics easing: magnetic pull curves
    final double leftX = (screenWidth * 0.15) + ((center.dx - (screenWidth * 0.15)) * Curves.easeInOutCubic.transform(progress));
    final double rightX = (screenWidth * 0.85) - (((screenWidth * 0.85) - center.dx) * Curves.easeInOutCubic.transform(progress));

    final Paint particlePaint = Paint()..style = PaintingStyle.fill;

    // Drifting rough particle 1 (Left: rough waste shape becoming cleaner)
    final path1 = Path();
    final leftCenter = Offset(leftX, center.dy);
    _buildRoughShape(path1, leftCenter, 22 * (1.0 - progress * 0.4), progress);
    particlePaint.color = const Color(0xFF00D2C4).withOpacity(0.8); // Teal
    canvas.drawPath(path1, particlePaint);

    // Drifting rough particle 2 (Right: rough waste shape becoming cleaner)
    final path2 = Path();
    final rightCenter = Offset(rightX, center.dy);
    _buildRoughShape(path2, rightCenter, 22 * (1.0 - progress * 0.4), progress);
    particlePaint.color = const Color(0xFFB5FF00).withOpacity(0.8); // Lime
    canvas.drawPath(path2, particlePaint);
  }

  void _buildRoughShape(Path path, Offset offsetCenter, double radius, double progress) {
    // Generate an irregular, organic polygon representing waste
    // Irregularity decreases as progress approaches 1.0 (waste becomes valuable/clean logo)
    final int points = 7;
    final double irregularity = 0.4 * (1.0 - progress);
    
    for (int i = 0; i < points; i++) {
      final double angle = (i / points) * 2 * math.pi;
      // Add slight randomness to radius based on index to simulate rough waste edges
      final double randomOffset = math.sin(i * 3.8) * irregularity * radius;
      final double r = radius + randomOffset;
      final double x = offsetCenter.dx + math.cos(angle) * r;
      final double y = offsetCenter.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
  }

  void _drawSpark(Canvas canvas, Offset center, double baseRadius, double progress) {
    final double sparkRadius = baseRadius * 1.5 * progress;
    final double opacity = 1.0 - progress;

    // Glowing spark core
    final glowPaint = Paint()
      ..color = const Color(0xFF00D2C4).withOpacity(0.7 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 * progress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, sparkRadius * 0.5, glowPaint);

    // Radiating burst particles
    final sparkPaint = Paint()
      ..color = const Color(0xFFF7F5F0).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final int rays = 12;
    for (int i = 0; i < rays; i++) {
      final double angle = (i / rays) * 2 * math.pi;
      final double startDist = baseRadius * 0.2 + (baseRadius * 0.4 * progress);
      final double endDist = baseRadius * 0.4 + (baseRadius * 1.2 * progress);

      final start = Offset(center.dx + math.cos(angle) * startDist, center.dy + math.sin(angle) * startDist);
      final end = Offset(center.dx + math.cos(angle) * endDist, center.dy + math.sin(angle) * endDist);

      canvas.drawLine(start, end, sparkPaint);
    }
  }

  void _drawLogo(Canvas canvas, Offset center, double baseRadius, double progress) {
    final double fade = progress.clamp(0.0, 1.0);
    final double scale = 0.8 + (0.2 * Curves.easeOutBack.transform(progress));

    // Dynamic rotation of logo during entry
    final double spin = (1.0 - progress) * 0.5 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.rotate(spin);
    canvas.translate(-center.dx, -center.dy);

    // Draw the two geometric leaf-arrows
    // Arrow 1: Teal leaf (Inflow exchange)
    final Path tealLeaf = Path();
    final Paint tealPaint = Paint()
      ..color = const Color(0xFF00D2C4).withOpacity(fade)
      ..style = PaintingStyle.fill;
    _buildLeafShape(tealLeaf, center, baseRadius, isLeft: true);
    canvas.drawPath(tealLeaf, tealPaint);

    // Arrow 2: Lime leaf (Outflow exchange)
    final Path limeLeaf = Path();
    final Paint limePaint = Paint()
      ..color = const Color(0xFFB5FF00).withOpacity(fade)
      ..style = PaintingStyle.fill;
    _buildLeafShape(limeLeaf, center, baseRadius, isLeft: false);
    canvas.drawPath(limeLeaf, limePaint);

    // Central connection node
    final nodePaint = Paint()
      ..color = const Color(0xFF071410) // Match background to punch hole
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.28, nodePaint);

    final coreGlowPaint = Paint()
      ..color = const Color(0xFFF7F5F0).withOpacity(fade)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.16, coreGlowPaint);

    canvas.restore();
  }

  void _buildLeafShape(Path path, Offset center, double radius, {required bool isLeft}) {
    final double sideMultiplier = isLeft ? -1.0 : 1.0;
    
    // Draw leaf geometry meeting symmetrically at the center exchange point
    final start = Offset(center.dx, center.dy - radius);
    final end = Offset(center.dx, center.dy + radius);
    
    final controlPoint1 = Offset(center.dx + (radius * 1.15 * sideMultiplier), center.dy - (radius * 0.1));
    final controlPoint2 = Offset(center.dx + (radius * 0.3 * sideMultiplier), center.dy + (radius * 0.2));

    path.moveTo(start.dx, start.dy);
    // Outer curve
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, end.dx, end.dy);
    // Inner curve
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, start.dx, start.dy);
    path.close();
  }

  @override
  bool shouldRepaint(covariant RecyConnectSplashPainter oldDelegate) {
    return driftProgress != oldDelegate.driftProgress ||
           sparkProgress != oldDelegate.sparkProgress ||
           logoProgress != oldDelegate.logoProgress;
  }
}
