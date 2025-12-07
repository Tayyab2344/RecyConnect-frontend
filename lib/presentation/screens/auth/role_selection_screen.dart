import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import 'collector_registration_screen.dart';
import 'registration_screen.dart';
import 'individual_registration_screen.dart';

/// RoleSelectionScreen - Premium glassmorphism design matching login screen
/// Features: Holographic background, glass cards, glowing effects
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _nodeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  String? _selectedRole;

  // Role data
  final List<_RoleData> _roles = [
    _RoleData(
      id: 'individual',
      title: 'Individual / Household',
      description: 'For households and personal recycling needs',
      icon: Icons.home_rounded,
      color: AppColors.primaryGreen,
      tooltip: 'Perfect for individuals who want to sell recyclable materials.',
    ),
    _RoleData(
      id: 'warehouse',
      title: 'Warehouse',
      description: 'For recycling facilities and warehouses',
      icon: Icons.warehouse_rounded,
      color: const Color(0xFF5B9BD5),
      tooltip: 'Ideal for recycling facilities managing bulk operations.',
    ),
    _RoleData(
      id: 'company',
      title: 'Company / Business',
      description: 'For businesses and corporate recycling',
      icon: Icons.business_rounded,
      color: const Color(0xFFFF8A65),
      tooltip: 'Designed for businesses seeking recycling solutions.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _nodeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _nodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1628),
                    Color(0xFF0D2137),
                    Color(0xFF0F2847),
                    Color(0xFF0A1E35),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F9F7),
                    Color(0xFFE8F5F2),
                    Color(0xFFDFF2ED),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
        ),
        child: Stack(
          children: [
            // Holographic background pattern
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _nodeController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RoleSelectionBackgroundPainter(
                      animationValue: _nodeController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // Radial glow
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: 1.2,
                    colors: isDark
                        ? [
                            const Color(0xFF00D9A5).withOpacity(0.05),
                            Colors.transparent,
                            const Color(0xFF0066FF).withOpacity(0.03),
                          ]
                        : [
                            const Color(0xFF1A8F3A).withOpacity(0.03),
                            Colors.transparent,
                            const Color(0xFF2AAE97).withOpacity(0.02),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Back button
                      _buildBackButton(isDark),
                      
                      // Header
                      _buildHeader(isDark),

                      const SizedBox(height: 32),

                      // Role Cards
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              ..._roles.asMap().entries.map((entry) {
                                final index = entry.key;
                                final role = entry.value;
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(milliseconds: 500 + (index * 150)),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 30 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildRoleCard(role, isDark),
                                  ),
                                );
                              }),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildContinueButton(isDark),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final glowColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtextColor = isDark
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF666666);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Icon with glow
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.9),
                  border: Border.all(
                    color: glowColor.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.2 * _pulseAnimation.value),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  size: 36,
                  color: glowColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to use RecyConnect',
                style: TextStyle(
                  fontSize: 15,
                  color: subtextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleCard(_RoleData role, bool isDark) {
    final isSelected = _selectedRole == role.id;
    final glowColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role.id),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? role.color.withOpacity(0.25 * _pulseAnimation.value)
                      : Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: isSelected ? 25 : 15,
                  offset: const Offset(0, 6),
                  spreadRadius: isSelected ? 2 : 0,
                ),
                if (isDark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.03),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.05),
                            ]
                          : [
                              Colors.white.withOpacity(0.85),
                              Colors.white.withOpacity(0.65),
                            ],
                    ),
                    border: Border.all(
                      color: isSelected
                          ? role.color.withOpacity(0.7)
                          : isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.white.withOpacity(0.6),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon container
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              role.color,
                              role.color.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: role.color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          role.icon,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : const Color(0xFF666666),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Selection indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isSelected ? role.color : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? role.color
                                : isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final isEnabled = _selectedRole != null;
    final buttonColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);
    final buttonTextColor = isDark ? const Color(0xFF0A1628) : Colors.white;
    final roleText = _selectedRole != null
        ? _selectedRole![0].toUpperCase() + _selectedRole!.substring(1)
        : '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A1628).withOpacity(0.9)
            : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.35 * _pulseAnimation.value),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: isEnabled ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  disabledBackgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade200,
                  disabledForegroundColor: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.shade500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEnabled ? 'Continue as $roleText' : 'Select a role to continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (isEnabled) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedRole == null) return;

    final Widget targetScreen = _selectedRole == 'individual'
        ? const IndividualRegistrationScreen()
        : RegistrationScreen(role: _selectedRole!);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

/// Background painter with subtle grid pattern
class _RoleSelectionBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  _RoleSelectionBackgroundPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Grid pattern
    final gridColor = isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.black.withOpacity(0.02);
    paint.color = gridColor;

    const gridSpacing = 60.0;
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Floating dots
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      final offset = math.sin(animationValue * 2 * math.pi + i * 0.5) * 8;
      final opacity = 0.3 + 0.2 * math.sin(animationValue * 2 * math.pi + i);
      
      dotPaint.color = isDark
          ? const Color(0xFF00D9A5).withOpacity(opacity * 0.3)
          : const Color(0xFF1A8F3A).withOpacity(opacity * 0.15);
      
      canvas.drawCircle(
        Offset(x, y + offset),
        3 + random.nextDouble() * 2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoleSelectionBackgroundPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

/// Role data model
class _RoleData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String tooltip;

  const _RoleData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tooltip,
  });
}
