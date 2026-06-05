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
                                  'Recy',
                                  style: GoogleFonts.outfit(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF4CAF50), // Premium green
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Connect',
                                  style: GoogleFonts.outfit(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2196F3), // Accent blue
                                    letterSpacing: -0.5,
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
                            'RECYCLE SMARTER. BUILD A GREENER FUTURE.',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF7F5F0).withOpacity(0.7),
                              letterSpacing: 1.5,
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

    // Drifting Particle 1 (Left): Blue Technology Node (circuit node)
    final leftCenter = Offset(leftX, center.dy);
    final Paint linePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.8 * (1.0 - progress * 0.5))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawLine(leftCenter, Offset(leftCenter.dx - 15, leftCenter.dy - 10), linePaint);
    canvas.drawLine(leftCenter, Offset(leftCenter.dx - 12, leftCenter.dy + 15), linePaint);
    
    particlePaint.color = const Color(0xFF2196F3).withOpacity(0.9 * (1.0 - progress * 0.5));
    canvas.drawCircle(leftCenter, 6, particlePaint);
    canvas.drawCircle(Offset(leftCenter.dx - 15, leftCenter.dy - 10), 4, particlePaint);
    canvas.drawCircle(Offset(leftCenter.dx - 12, leftCenter.dy + 15), 4, particlePaint);

    // Drifting Particle 2 (Right): Green Leaf
    final rightCenter = Offset(rightX, center.dy);
    final Path leafPath = Path();
    final double leafRadius = 15.0 * (1.0 - progress * 0.3);
    
    final leafStart = Offset(rightCenter.dx - leafRadius, rightCenter.dy + leafRadius * 0.5);
    final leafEnd = Offset(rightCenter.dx + leafRadius, rightCenter.dy - leafRadius * 0.5);
    leafPath.moveTo(leafStart.dx, leafStart.dy);
    leafPath.quadraticBezierTo(rightCenter.dx + leafRadius * 0.8, rightCenter.dy + leafRadius * 0.5, leafEnd.dx, leafEnd.dy);
    leafPath.quadraticBezierTo(rightCenter.dx - leafRadius * 0.8, rightCenter.dy - leafRadius * 0.5, leafStart.dx, leafStart.dy);
    leafPath.close();
    
    particlePaint.color = const Color(0xFF8BC34A).withOpacity(0.9 * (1.0 - progress * 0.5));
    canvas.drawPath(leafPath, particlePaint);
  }

  void _drawSpark(Canvas canvas, Offset center, double baseRadius, double progress) {
    final double sparkRadius = baseRadius * 1.5 * progress;
    final double opacity = 1.0 - progress;

    // Glowing spark core (teal/green mix)
    final glowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.6 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 * progress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, sparkRadius * 0.5, glowPaint);

    // Radiating burst particles
    final sparkPaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(opacity)
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

    // Draw the stylized R logo matching the brand identity
    final loopCenter = Offset(center.dx + baseRadius * 0.05, center.dy - baseRadius * 0.25);
    final loopRadiusOuter = baseRadius * 0.75;
    final loopRadiusInner = baseRadius * 0.45;

    // 1. Main R Loop Path (Green Gradient)
    final Path rPath = Path();
    rPath.moveTo(loopCenter.dx - loopRadiusOuter, loopCenter.dy + baseRadius * 0.1);
    rPath.quadraticBezierTo(
      loopCenter.dx - loopRadiusOuter * 0.9, loopCenter.dy - loopRadiusOuter * 0.9,
      loopCenter.dx, loopCenter.dy - loopRadiusOuter
    );
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusOuter * 1.0, loopCenter.dy - loopRadiusOuter * 0.9,
      loopCenter.dx + loopRadiusOuter * 0.95, loopCenter.dy + baseRadius * 0.05
    );
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusOuter * 0.8, loopCenter.dy + loopRadiusOuter * 0.7,
      center.dx + baseRadius * 0.65, center.dy + baseRadius * 0.85 // leg outer
    );
    rPath.lineTo(center.dx + baseRadius * 0.35, center.dy + baseRadius * 0.85); // leg bottom
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusInner * 0.8, loopCenter.dy + loopRadiusInner * 0.9,
      loopCenter.dx + loopRadiusInner * 0.7, loopCenter.dy + baseRadius * 0.1 // leg inner
    );
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusInner * 0.8, loopCenter.dy - loopRadiusInner * 0.8,
      loopCenter.dx, loopCenter.dy - loopRadiusInner
    );
    rPath.quadraticBezierTo(
      loopCenter.dx - loopRadiusInner * 0.8, loopCenter.dy - loopRadiusInner * 0.6,
      loopCenter.dx - loopRadiusInner * 0.9, loopCenter.dy + baseRadius * 0.2
    );
    rPath.quadraticBezierTo(
      loopCenter.dx - loopRadiusOuter * 0.95, loopCenter.dy + baseRadius * 0.35,
      loopCenter.dx - loopRadiusOuter, loopCenter.dy + baseRadius * 0.1
    );
    rPath.close();

    final Paint rPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8BC34A).withOpacity(fade), // Light Green
          const Color(0xFF4CAF50).withOpacity(fade), // Green
          const Color(0xFF2E7D32).withOpacity(fade), // Dark Green
        ],
      ).createShader(Rect.fromCircle(center: loopCenter, radius: loopRadiusOuter))
      ..style = PaintingStyle.fill;
    canvas.drawPath(rPath, rPaint);

    // 2. Green Leaf inside loop
    final Path leafPath = Path();
    final leafStart = Offset(loopCenter.dx - loopRadiusInner * 0.2, loopCenter.dy + loopRadiusInner * 0.4);
    final leafEnd = Offset(loopCenter.dx + loopRadiusInner * 0.5, loopCenter.dy - loopRadiusInner * 0.5);
    final leafControl1 = Offset(loopCenter.dx + loopRadiusInner * 0.6, loopCenter.dy + loopRadiusInner * 0.1);
    final leafControl2 = Offset(loopCenter.dx - loopRadiusInner * 0.4, loopCenter.dy - loopRadiusInner * 0.3);

    leafPath.moveTo(leafStart.dx, leafStart.dy);
    leafPath.quadraticBezierTo(leafControl1.dx, leafControl1.dy, leafEnd.dx, leafEnd.dy);
    leafPath.quadraticBezierTo(leafControl2.dx, leafControl2.dy, leafStart.dx, leafStart.dy);
    leafPath.close();

    final Paint leafPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          const Color(0xFF4CAF50).withOpacity(fade),
          const Color(0xFF8BC34A).withOpacity(fade),
        ],
      ).createShader(Rect.fromPoints(leafStart, leafEnd))
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafPaint);

    // 3. Blue Circuit Nodes on the left
    final Paint tracePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final Paint nodePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(fade)
      ..style = PaintingStyle.fill;

    final startNode = Offset(loopCenter.dx - loopRadiusOuter * 0.6, loopCenter.dy + baseRadius * 0.25);

    // Trace 1: Top-left
    final Path path1 = Path();
    path1.moveTo(startNode.dx, startNode.dy);
    final node1 = Offset(loopCenter.dx - baseRadius * 0.95, loopCenter.dy - baseRadius * 0.15);
    path1.cubicTo(
      startNode.dx - baseRadius * 0.2, startNode.dy - baseRadius * 0.1,
      node1.dx + baseRadius * 0.1, node1.dy + baseRadius * 0.2,
      node1.dx, node1.dy
    );
    canvas.drawPath(path1, tracePaint);
    canvas.drawCircle(node1, 4.5, nodePaint);

    // Trace 2: Middle-left
    final Path path2 = Path();
    path2.moveTo(startNode.dx + baseRadius * 0.05, startNode.dy + baseRadius * 0.05);
    final node2 = Offset(loopCenter.dx - baseRadius * 1.0, loopCenter.dy + baseRadius * 0.15);
    path2.quadraticBezierTo(
      startNode.dx - baseRadius * 0.25, startNode.dy + baseRadius * 0.05,
      node2.dx, node2.dy
    );
    canvas.drawPath(path2, tracePaint);
    canvas.drawCircle(node2, 4.5, nodePaint);

    // Trace 3: Bottom-left
    final Path path3 = Path();
    path3.moveTo(startNode.dx + baseRadius * 0.1, startNode.dy + baseRadius * 0.1);
    final node3 = Offset(loopCenter.dx - baseRadius * 0.8, loopCenter.dy + baseRadius * 0.45);
    path3.quadraticBezierTo(
      startNode.dx - baseRadius * 0.1, startNode.dy + baseRadius * 0.2,
      node3.dx, node3.dy
    );
    canvas.drawPath(path3, tracePaint);
    canvas.drawCircle(node3, 4.5, nodePaint);

    canvas.restore();
  }

  void _buildLeafShape(Path path, Offset center, double radius, {required bool isLeft}) {
    // Left empty since leaves are drawn inside _drawLogo
  }

  @override
  bool shouldRepaint(covariant RecyConnectSplashPainter oldDelegate) {
    return driftProgress != oldDelegate.driftProgress ||
           sparkProgress != oldDelegate.sparkProgress ||
           logoProgress != oldDelegate.logoProgress;
  }
}
