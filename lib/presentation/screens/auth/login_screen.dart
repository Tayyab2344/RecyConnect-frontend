import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/recyconnect_logo.dart';
import '../dashboard/dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'role_selection_screen.dart';
import 'forgot_password_screen.dart';

/// Premium Minimalistic Login Screen for RecyConnect
/// Features: Glassmorphism card, holographic world map, soft glowing effects
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;

  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _nodeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    // Pulse animation for glowing effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Node animation for world map data points
    _nodeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _nodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear previous error
    setState(() => _loginError = null);

    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // All logins go through backend API (including admin)
    final success = await authService.login(email, password);

    if (mounted) {
      if (success) {
        final user = authService.currentUser;
        final status = user?['verificationStatus'];
        final role = user?['role'];

        // Check if user is admin and navigate to admin dashboard
        if (role == 'admin') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Welcome Admin! Login successful',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).primaryColor,
              behavior: SnackBarBehavior.floating,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen()),
          );
          return;
        }

        if (status == 'PENDING' && role != 'individual') {
          _showStatusDialog(
            title: 'Account Pending',
            content: 'Your account is under review. You will be notified once verified.',
            icon: Icons.hourglass_top_rounded,
            color: AppColors.warning,
            authService: authService,
          );
        } else if (status == 'REJECTED') {
          _showStatusDialog(
            title: 'Account Rejected',
            content: 'Reason: ${user?['rejectionReason'] ?? 'Verification failed.'}',
            icon: Icons.cancel_rounded,
            color: AppColors.error,
            authService: authService,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Welcome back! Login successful'),
              backgroundColor: AppColors.neonTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        // Show inline error card instead of SnackBar
        setState(() {
          final rawError = authService.error ?? 'Login failed';
          // Map network errors to user-friendly messages
          final errorLower = rawError.toLowerCase();
          if (errorLower.contains('network') || errorLower.contains('socket') || errorLower.contains('connection')) {
            _loginError = 'No internet connection. Please check your network and try again.';
          } else if (errorLower.contains('timeout')) {
            _loginError = 'Connection timed out. Please try again.';
          } else {
            _loginError = rawError;
          }
        });
      }
    }
  }

  void _showStatusDialog({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required AuthService authService,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF1A2A3A),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00D9A5)),
            ),
          ),
        ],
      ),
    );
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
          // Theme-aware gradient background
          gradient: isDark
              ? const LinearGradient(
                  // Dark Mode: Deep navy-to-teal gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.loginNavyDeep, // Deep navy
                    AppColors.loginNavyDark, // Dark teal-navy
                    AppColors.loginNavyMedium, // Medium navy
                    AppColors.loginNavyLight, // Back to deep navy
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                )
              : const LinearGradient(
                  // Light Mode: White and soft-teal gradient
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.white, // Pure white
                    AppColors.loginWhiteSoft, // Soft white-teal
                    AppColors.loginTealLight, // Light teal
                    AppColors.loginTealSoft, // Soft teal
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
        ),
        child: Stack(
          children: [
            // Holographic world map background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _nodeController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: HolographicWorldMapPainter(
                      animationValue: _nodeController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // Subtle radial glow overlay (theme-aware)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 1.2,
                    colors: isDark
                        ? [
                            AppColors.neonTeal.withValues(alpha: 0.05),
                            Colors.transparent,
                            AppColors.neonBlue.withValues(alpha: 0.03),
                          ]
                        : [
                            const Color(0xFF1A8F3A).withValues(alpha: 0.03),
                            Colors.transparent,
                            const Color(0xFF2AAE97).withValues(alpha: 0.02),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Data particles for dark mode
            if (isDark)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _nodeController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: DataParticlesPainter(
                        animationValue: _nodeController.value,
                      ),
                    );
                  },
                ),
              ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // RecyConnect Logo
                          _buildLogo(isDark),
                          const SizedBox(height: 40),

                          // Glass Card
                          _buildGlassCard(size, isDark),

                          const SizedBox(height: 32),

                          // Sign up link
                          _buildSignUpLink(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    final glowColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                glowColor.withValues(alpha: (isDark ? 0.15 : 0.1) * _pulseAnimation.value),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: (isDark ? 0.2 : 0.15) * _pulseAnimation.value),
                blurRadius: isDark ? 25 : 20,
                spreadRadius: isDark ? 3 : 2,
              ),
            ],
          ),
          child: const RecyConnectLogo(
            size: 100,
            showText: false,
          ),
        );
      },
    );
  }

  Widget _buildGlassCard(Size screenSize, bool isDark) {
    final glowColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtextColor = isDark 
        ? Colors.white.withValues(alpha: 0.6)
        : AppColors.darkGrey;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: math.min(400, screenSize.width - 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // Theme-aware glowing edges
            boxShadow: isDark
                ? [
                    // Dark mode: Cyan glowing edges
                    BoxShadow(
                      color: const Color(0xFF00D9A5).withValues(alpha: 0.15 * _pulseAnimation.value),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.neonBlue.withValues(alpha: 0.08 * _pulseAnimation.value),
                      blurRadius: 40,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    // Light mode: Subtle white glowing edges
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.08 * _pulseAnimation.value),
                      blurRadius: 30,
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  // Theme-aware glass effect
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.65),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15 + 0.1 * _pulseAnimation.value)
                        : Colors.white.withValues(alpha: 0.6 + 0.1 * _pulseAnimation.value),
                    width: 1.5,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your eco journey',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtextColor,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => Validators.required(value, 'Email'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (value) => Validators.required(value, 'Password'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : AppColors.darkGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Inline Error Card
                      if (_loginError != null)
                        _buildErrorCard(isDark),

                      // Login Button
                      Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return _buildLoginButton(authService.isLoading, isDark);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    final labelColor = isDark 
        ? Colors.white.withValues(alpha: 0.8)
        : AppColors.textDarkGrey;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = isDark 
        ? Colors.white.withValues(alpha: 0.3)
        : const Color(0xFF999999);
    final iconColor = isDark 
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.darkGrey;
    final fillColor = isDark 
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.softGreyBg;
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.lightGrey;
    final focusColor = isDark 
        ? AppColors.neonTeal
        : AppColors.primaryGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? _obscurePassword : false,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: iconColor,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: focusColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.error.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            errorStyle: TextStyle(
              color: AppColors.error.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading, bool isDark) {
    final buttonColor = isDark ? AppColors.neonTeal : AppColors.primaryGreen;
    final buttonTextColor = isDark ? AppColors.loginNavyDeep : Colors.white;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: (isDark ? 0.4 : 0.3) * _pulseAnimation.value),
                blurRadius: isDark ? 20 : 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: buttonTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20, color: buttonTextColor),
                    ],
                  ),
          ),
        );
      },
    );
  }

  
  Widget _buildErrorCard(bool isDark) {
    final isNetworkError = _loginError != null &&
        (_loginError!.toLowerCase().contains('internet') ||
         _loginError!.toLowerCase().contains('network') ||
         _loginError!.toLowerCase().contains('connection') ||
         _loginError!.toLowerCase().contains('timeout'));

    final errorIcon = isNetworkError
        ? Icons.wifi_off_rounded
        : Icons.error_outline_rounded;

    final errorBgColor = isDark
        ? (isNetworkError ? const Color(0xFF2A1A00) : const Color(0xFF2A0A0A))
        : (isNetworkError ? const Color(0xFFFFF8E1) : const Color(0xFFFFF0F0));

    final errorBorderColor = isDark
        ? (isNetworkError
            ? Colors.orange.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3))
        : (isNetworkError
            ? Colors.orange.withValues(alpha: 0.4)
            : Colors.red.withValues(alpha: 0.3));

    final errorIconColor = isNetworkError
        ? (isDark ? Colors.orange.shade300 : Colors.orange.shade700)
        : (isDark ? Colors.red.shade300 : Colors.red.shade600);

    final errorTextColor = isDark
        ? (isNetworkError ? Colors.orange.shade200 : Colors.red.shade200)
        : (isNetworkError ? Colors.orange.shade800 : Colors.red.shade700);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: errorBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: errorBorderColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(errorIcon, color: errorIconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _loginError!,
                style: TextStyle(
                  color: errorTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _loginError = null),
              child: Icon(
                Icons.close_rounded,
                color: errorIconColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSignUpLink(bool isDark) {
    final textColor = isDark 
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.darkGrey;
    final linkColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const RoleSelectionScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: linkColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for holographic world map with data nodes
class HolographicWorldMapPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  HolographicWorldMapPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw simplified world map curves (stylized continents)
    _drawWorldMapOutlines(canvas, size, paint);

    // Draw data nodes
    _drawDataNodes(canvas, size);

    // Draw connection lines between nodes
    _drawConnectionLines(canvas, size);
  }

  void _drawWorldMapOutlines(Canvas canvas, Size size, Paint paint) {
    final mapColor = isDark 
        ? const Color(0xFF00D9A5).withValues(alpha: 0.08)
        : const Color(0xFF1A8F3A).withValues(alpha: 0.06);
    
    paint.color = mapColor;
    paint.strokeWidth = 1;

    // Create stylized curved paths representing continents
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.35;

    // Draw latitude lines (horizontal curves)
    for (int i = -2; i <= 2; i++) {
      final y = centerY + (i * radius * 0.3);
      final path = Path();
      path.moveTo(centerX - radius * 0.8, y);
      path.quadraticBezierTo(
        centerX,
        y + (i == 0 ? 0 : math.sin(animationValue * math.pi * 2) * 5),
        centerX + radius * 0.8,
        y,
      );
      canvas.drawPath(path, paint);
    }

    // Draw longitude lines (vertical curves)
    for (int i = -3; i <= 3; i++) {
      final x = centerX + (i * radius * 0.25);
      final path = Path();
      path.moveTo(x, centerY - radius * 0.6);
      path.quadraticBezierTo(
        x + math.sin(animationValue * math.pi * 2 + i) * 3,
        centerY,
        x,
        centerY + radius * 0.6,
      );
      paint.color = mapColor.withValues(alpha: isDark ? 0.06 : 0.04);
      canvas.drawPath(path, paint);
    }

    // Draw ellipse for globe outline
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radius * 1.8,
      height: radius * 1.2,
    );
    paint.color = mapColor.withValues(alpha: isDark ? 0.1 : 0.08);
    canvas.drawOval(rect, paint);
  }

  void _drawDataNodes(Canvas canvas, Size size) {
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final nodeColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);

    // Define node positions (scattered across the map)
    final nodes = [
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.25),
      Offset(size.width * 0.65, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.65),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.6, size.height * 0.8),
    ];

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final pulseOffset = (animationValue + i / nodes.length) % 1.0;
      final pulseSize = 2 + math.sin(pulseOffset * math.pi * 2) * 1;

      // Outer glow
      nodePaint.color = nodeColor.withValues(alpha: (isDark ? 0.15 : 0.12) + pulseOffset * 0.1);
      canvas.drawCircle(node, pulseSize + 4, nodePaint);

      // Inner node
      nodePaint.color = nodeColor.withValues(alpha: isDark ? 0.6 : 0.5);
      canvas.drawCircle(node, pulseSize, nodePaint);

      // Core
      nodePaint.color = (isDark ? Colors.white : nodeColor).withValues(alpha: 0.8);
      canvas.drawCircle(node, pulseSize * 0.4, nodePaint);
    }
  }

  void _drawConnectionLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final lineColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);

    // Connection pairs (indices into nodes array)
    final connections = [
      [0, 2],
      [2, 3],
      [3, 4],
      [4, 6],
      [6, 7],
      [3, 5],
      [5, 8],
      [1, 9],
      [9, 10],
      [8, 11],
    ];

    final nodes = [
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.25),
      Offset(size.width * 0.65, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.65),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.6, size.height * 0.8),
    ];

    for (int i = 0; i < connections.length; i++) {
      final start = nodes[connections[i][0]];
      final end = nodes[connections[i][1]];

      // Animated gradient along the line
      final progress = (animationValue + i / connections.length) % 1.0;

      linePaint.shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.05),
          lineColor.withValues(alpha: (isDark ? 0.3 : 0.25) * progress),
          lineColor.withValues(alpha: 0.05),
        ],
        stops: [
          math.max(0, progress - 0.2),
          progress,
          math.min(1, progress + 0.2),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromPoints(start, end));

      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant HolographicWorldMapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isDark != isDark;
  }
}

/// Custom painter for subtle data particles (dark mode only)
class DataParticlesPainter extends CustomPainter {
  final double animationValue;

  DataParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create subtle floating particles
    final random = math.Random(42); // Fixed seed for consistent positions
    for (int i = 0; i < 30; i++) {
      final x = size.width * random.nextDouble();
      final baseY = size.height * random.nextDouble();
      
      // Animate particles floating up and down
      final floatOffset = math.sin((animationValue * 2 + i * 0.1) * math.pi * 2) * 10;
      final y = baseY + floatOffset;
      
      final opacity = (0.1 + random.nextDouble() * 0.15) * 
                      (0.5 + 0.5 * math.sin((animationValue + i * 0.05) * math.pi * 2));
      
      paint.color = const Color(0xFF00D9A5).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble() * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DataParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
