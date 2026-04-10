import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
=======
import '../../../core/theme/app_colors.dart';
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/recyconnect_logo.dart';
import '../dashboard/dashboard_screen.dart';
<<<<<<< HEAD
import '../seller/seller_dashboard.dart';
import '../admin/admin_dashboard_screen.dart';
import '../marketplace/buyer_dashboard.dart';
=======
import '../admin/admin_dashboard_screen.dart';
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
import 'role_selection_screen.dart';
import 'forgot_password_screen.dart';

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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

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
            color: AppTheme.warningOrange,
            authService: authService,
          );
        } else if (status == 'REJECTED') {
          _showStatusDialog(
            title: 'Account Rejected',
            content: 'Reason: ${user?['rejectionReason'] ?? 'Verification failed.'}',
            icon: Icons.cancel_rounded,
            color: AppTheme.errorRed,
            authService: authService,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
            const SnackBar(
              content: Text('Welcome back! Login successful'),
              backgroundColor: AppTheme.primaryGreen,
=======
            SnackBar(
              content: const Text('Welcome back! Login successful'),
              backgroundColor: AppColors.neonTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error ?? 'Login failed'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(title, style: AppTheme.subHeadingStyle.copyWith(fontSize: 18)),
          ],
        ),
        content: Text(content, style: AppTheme.bodyStyle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Force light theme
    const isDark = false;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
<<<<<<< HEAD
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              Colors.white,
              AppTheme.primaryGreen.withOpacity(0.05),
            ],
          ),
=======
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
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      _buildLogoSection(),
                      const SizedBox(height: 48),

<<<<<<< HEAD
                      // Login Card
                      _buildLoginCard(),

                      const SizedBox(height: 24),

                      // Footer
                      _buildFooter(),
                    ],
=======
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
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
          ),
=======

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
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildLogoSection() {
    final theme = Theme.of(context);
    // Force light theme
    const isDark = false;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
=======
  Widget _buildLogo(bool isDark) {
    final glowColor = isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
<<<<<<< HEAD
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withOpacity(0.8),
=======
                glowColor.withValues(alpha: (isDark ? 0.15 : 0.1) * _pulseAnimation.value),
                Colors.transparent,
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
<<<<<<< HEAD
                color: isDark
                    ? AppTheme.darkPrimaryGreen.withOpacity(0.3)
                    : AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.recycling_rounded,
            size: 56,
            color: isDark ? AppTheme.darkBackground : Colors.white,
          ),
        ),
        const SizedBox(height: 24),
=======
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
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
        Text(
          'Welcome Back!',
          style: isDark
              ? theme.textTheme.displayLarge?.copyWith(fontSize: 32)
              : AppTheme.headingStyle.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your eco journey',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildLoginCard() {
    final theme = Theme.of(context);
    // Force light theme
    const isDark = false;
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildLoginForm(),
    );
  }
=======
  Widget _buildLoginButton(bool isLoading, bool isDark) {
    final buttonColor = isDark ? AppColors.neonTeal : AppColors.primaryGreen;
    final buttonTextColor = isDark ? AppColors.loginNavyDeep : Colors.white;
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066

  Widget _buildLoginForm() {
    final theme = Theme.of(context);
    // Force light theme
    const isDark = false;
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Email or Collector ID',
              hintText: 'Enter your email or ID',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: isDark ? AppTheme.darkSecondaryGreen : AppTheme.primaryGreen,
              ),
              filled: true,
              fillColor: isDark ? AppTheme.darkSurface : AppTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkBorderGreen : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.errorRed, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
              ),
              labelStyle: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
              hintStyle: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.5) : AppTheme.textLight.withOpacity(0.5),
              ),
            ),
            validator: (value) => Validators.required(value, 'Email or ID'),
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: isDark ? AppTheme.darkSecondaryGreen : AppTheme.primaryGreen,
              ),
              filled: true,
              fillColor: isDark ? AppTheme.darkSurface : AppTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkBorderGreen : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.errorRed, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
              ),
              labelStyle: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
              hintStyle: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.5) : AppTheme.textLight.withOpacity(0.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: isDark ? AppTheme.darkSecondaryGreen : AppTheme.textLight,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) => Validators.required(value, 'Password'),
          ),
          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Login Button
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authService.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.6),
                  ),
                  child: authService.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final theme = Theme.of(context);
    // Force light theme
    const isDark = false;

    return Column(
      children: [
        // Sign Up Prompt
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textLight,
                fontSize: 15,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                );
              },
              child: Text(
                'Sign Up',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Environmental Message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppTheme.darkCardSurface,
                      AppTheme.darkSurface,
                    ]
                  : [
                      AppTheme.primaryGreen.withOpacity(0.1),
                      AppTheme.primaryGreen.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.darkBorderGreen
                  : AppTheme.primaryGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Join 10,000+ users making an impact',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
<<<<<<< HEAD
=======
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
>>>>>>> 49b837f06550d44f1e6ff8b751c414976b29c066
        ),
      ],
    );
  }
}
