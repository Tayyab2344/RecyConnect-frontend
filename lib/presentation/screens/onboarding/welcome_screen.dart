import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/mixins/animation_mixin.dart';
import '../../widgets/curved/wave_painter.dart';
import '../../widgets/curved/organic_button.dart';
import '../auth/login_screen.dart';

/// WelcomeScreen - Premium curvy eco-tech onboarding
/// Features: Wave background, organic animations, glassmorphism accents
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin, ScreenAnimationMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize entrance animation from mixin
    initEntranceAnimation(
      duration: const Duration(milliseconds: 1200),
    );

    // Pulse animation for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    disposeEntranceAnimation();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        AppColors.darkSurface,
                      ]
                    : [
                        AppColors.gradientLightTop,
                        AppColors.white,
                      ],
              ),
            ),
          ),

          // Top wave decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 280),
              painter: WavePainter(
                color: isDark
                    ? AppColors.darkPrimaryGreen.withValues(alpha: 0.15)
                    : AppColors.primaryGreen.withValues(alpha: 0.08),
                waveHeight: 60,
                isTop: true,
              ),
            ),
          ),

          // Second wave layer (lighter)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 220),
              painter: WavePainter(
                color: isDark
                    ? AppColors.ecoTeal.withValues(alpha: 0.1)
                    : AppColors.ecoTeal.withValues(alpha: 0.05),
                waveHeight: 50,
                isTop: true,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.12),

                          // Animated Hero Icon
                          withEntranceAnimation(
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: _buildHeroIcon(isDark),
                            ),
                          ),

                          const SizedBox(height: DesignTokens.spacing32),


                  // App Name with gradient
                  withEntranceAnimation(
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.ecoTeal,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'RecyConnect',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: DesignTokens.spacing16),

                  // Tagline
                  withFadeAnimation(
                    Text(
                      'Transform Waste into Worth',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.primaryGreen.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: DesignTokens.spacing12),

                  // Description
                  withFadeAnimation(
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing16,
                      ),
                      child: Text(
                        'Connect with recycling centers, sell recyclables, and contribute to a sustainable future',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                              : AppColors.mediumGrey,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                          const SizedBox(height: DesignTokens.spacing32),

                  // Feature highlights
                  withEntranceAnimation(_buildFeatureHighlights(isDark)),

                  const SizedBox(height: DesignTokens.spacing32),

                  // Get Started Button
                  withEntranceAnimation(
                    OrganicButton(
                      text: 'Get Started',
                      icon: Icons.arrow_forward_rounded,
                      iconTrailing: true,
                      style: OrganicButtonStyle.gradient,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const LoginScreen(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: DesignTokens.pageTransition,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: DesignTokens.spacing24),

                  // Footer
                  withFadeAnimation(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkPrimaryGreen
                              : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Join the sustainable revolution',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                                : AppColors.mediumGrey.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                          const SizedBox(height: DesignTokens.spacing32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(bool isDark) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.ecoTeal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          // Icon
          Icon(
            Icons.recycling_rounded,
            size: 80,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(bool isDark) {
    final features = [
      {'icon': Icons.sell_rounded, 'text': 'Sell'},
      {'icon': Icons.shopping_cart_rounded, 'text': 'Buy'},
      {'icon': Icons.emoji_events_rounded, 'text': 'Earn'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((feature) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing12,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                feature['icon'] as IconData,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                feature['text'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.darkText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
