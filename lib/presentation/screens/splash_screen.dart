import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'dart:math' as math;
=======
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
import '../../core/services/auth_service.dart';
import 'dashboard_screen.dart';
import 'welcome_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

<<<<<<< HEAD
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _leafController;
  late AnimationController _particleController;
=======
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoggedIn = false;
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD

    // Pulse animation for button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Leaf sway animation
    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Particle float animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _leafController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    final authService = context.read<AuthService>();
    final isLoggedIn = await authService.checkAuthStatus();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const DashboardScreen() : const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9), // Soft white background
      body: SafeArea(
        child: Stack(
          children: [
            // Floating particles background
            ..._buildFloatingParticles(),

            // Main content
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top section - Logo and title
                      _buildTopSection(),

                      // Spacer to push content apart
                      const Spacer(),

                      // Bottom section - Continue button
                      _buildBottomSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
=======
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Simulate minimum splash duration and check auth in parallel
    final authService = context.read<AuthService>();
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)), // Minimum display time
      authService.checkAuthStatus(),
    ]);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = results[1] as bool;
      });
    }
  }

  void _handleContinue() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          _isLoggedIn ? const DashboardScreen() : const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
      ),
    );
  }

<<<<<<< HEAD
  // Top section with recycling icon and app name
  Widget _buildTopSection() {
    return Column(
      children: [
        // Recycling symbol with bounce animation
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.recycling_rounded,
            color: Colors.white,
            size: 45,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              duration: 2.seconds,
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: 2.seconds,
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
              curve: Curves.easeInOut,
            ),

        const SizedBox(height: 20),

        // App name
        const Text(
          'RecyConnect',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .slideY(begin: -0.3, end: 0),

        const SizedBox(height: 8),

        const Text(
          'Connecting Communities for a Greener Tomorrow',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.4,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  // Floating particles
  List<Widget> _buildFloatingParticles() {
    return List.generate(8, (index) {
      return Positioned(
        top: 100.0 + (index * 60),
        left: 30.0 + (index * 45) % MediaQuery.of(context).size.width,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_particleController.value * 2 * math.pi + index) * 10,
                math.cos(_particleController.value * 2 * math.pi + index) * 20,
              ),
              child: Opacity(
                opacity: 0.3 + (math.sin(_particleController.value * 2 * math.pi + index) * 0.2),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // Bottom section with animated button
  Widget _buildBottomSection() {
    return Column(
      children: [
        // Animated "Tap to Continue" button
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.05);
            final glowOpacity = 0.3 + (_pulseController.value * 0.3);

            return Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTap: _navigateToNextScreen,
                child: Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: glowOpacity),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tap to Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Elements
          const _BackgroundDecorations(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.recycling,
                      size: 32,
                      color: AppTheme.primaryGreen,
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                    const SizedBox(width: 12),
                    const Text(
                      'RecyConnect',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),

                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow behind image
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryGreen.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                         .scale(duration: 3000.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),

                        // Main Illustration
                        Image.asset(
                          'assets/images/splash_illustration.png',
                          width: 320,
                          fit: BoxFit.contain,
                        ).animate()
                         .fadeIn(duration: 1000.ms, curve: Curves.easeOut)
                         .scale(duration: 1000.ms, begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
                      ],
                    ),
                  ),
                ),
<<<<<<< HEAD
              ),
            );
          },
        )
            .animate()
            .fadeIn(duration: 1.seconds, delay: 1.2.seconds)
            .slideY(begin: 0.5, end: 0),

        const SizedBox(height: 20),

        const Text(
          'Join the green revolution today!',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 1.4.seconds),
=======

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 60, left: 24, right: 24),
                  child: AnimatedOpacity(
                    opacity: _isLoading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: GestureDetector(
                      onTap: _isLoading ? null : _handleContinue,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tap to Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                      target: _isLoading ? 0 : 1,
                    )
                    .shimmer(duration: 2000.ms, color: AppTheme.primaryGreen.withOpacity(0.2))
                    .boxShadow(
                      begin: BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.1), blurRadius: 10),
                      end: BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                      duration: 1500.ms,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right leaf
        Positioned(
          top: -50,
          right: -50,
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Icon(
              Icons.eco,
              size: 200,
              color: AppTheme.primaryGreen.withOpacity(0.03),
            ),
          ),
        ).animate().slide(duration: 2000.ms, begin: const Offset(0.1, -0.1), end: Offset.zero, curve: Curves.easeOut),

        // Bottom left leaf
        Positioned(
          bottom: -30,
          left: -30,
          child: Transform.rotate(
            angle: math.pi / 3,
            child: Icon(
              Icons.eco,
              size: 150,
              color: AppTheme.primaryGreen.withOpacity(0.05),
            ),
          ),
        ).animate().slide(duration: 2000.ms, begin: const Offset(-0.1, 0.1), end: Offset.zero, curve: Curves.easeOut),

        // Floating particles
        ...List.generate(5, (index) {
          final random = math.Random(index);
          return Positioned(
            left: random.nextDouble() * 300,
            top: random.nextDouble() * 600,
            child: Container(
              width: 8 + random.nextDouble() * 8,
              height: 8 + random.nextDouble() * 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1 + random.nextDouble() * 0.1),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(duration: (2000 + random.nextInt(2000)).ms, begin: 0, end: -30)
             .fadeIn(duration: 1000.ms),
          );
        }),
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
      ],
    );
  }
}
<<<<<<< HEAD
=======



>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
