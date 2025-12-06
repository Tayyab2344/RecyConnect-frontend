import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../dashboard/dashboard_screen.dart';
import '../seller/seller_dashboard.dart';
import '../admin/admin_dashboard_screen.dart';
import '../marketplace/buyer_dashboard.dart';
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

    // Check for admin credentials FIRST (before API call)
    if (email == 'panel.quantix@gmail.com' && password == 'RecyAdmin@786') {
      // Admin login - navigate directly to Admin Dashboard
      if (mounted) {
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
            backgroundColor: AppTheme.primaryGreen,
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
      }
      return;
    }

    // Regular user login - proceed with API call
    final success = await authService.login(email, password);

    if (mounted) {
      if (success) {
        final user = authService.currentUser;
        final status = user?['verificationStatus'];
        final role = user?['role'];

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
            const SnackBar(
              content: Text('Welcome back! Login successful'),
              backgroundColor: AppTheme.primaryGreen,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              Colors.white,
              AppTheme.primaryGreen.withOpacity(0.05),
            ],
          ),
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

                      // Login Card
                      _buildLoginCard(),

                      const SizedBox(height: 24),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    final theme = Theme.of(context);
    // Force light theme
    const isDark = false;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
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
        ),
      ],
    );
  }
}
