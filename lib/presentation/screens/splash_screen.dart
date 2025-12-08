import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import 'dashboard_screen.dart';
import 'welcome_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
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
      ),
    );
  }

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
                      ],
                    ),
                  ),
                ),

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
      ],
    );
  }
}



