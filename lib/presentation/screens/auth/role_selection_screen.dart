import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../widgets/curved/wave_painter.dart';
import '../../widgets/curved/curved_card.dart';
import '../../widgets/curved/organic_button.dart';
import 'collector_registration_screen.dart';
import 'registration_screen.dart';
import 'individual_registration_screen.dart';

/// RoleSelectionScreen - Premium role selection with curvy design
/// Features: Wave background, selectable frosted cards, organic animations
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedRole;

  // Role data
  final List<_RoleData> _roles = [
    _RoleData(
      id: 'individual',
      title: 'Individual / Household',
      description: 'For households and personal recycling needs',
      icon: Icons.home_rounded,
      color: AppColors.primaryGreen,
      lightColor: AppColors.roleIndividualLight,
      tooltip: 'Perfect for individuals and households who want to sell recyclable materials.',
    ),
    _RoleData(
      id: 'warehouse',
      title: 'Warehouse',
      description: 'For recycling facilities and warehouses',
      icon: Icons.warehouse_rounded,
      color: AppColors.roleWarehouse,
      lightColor: AppColors.roleWarehouseLight,
      tooltip: 'Ideal for recycling facilities managing bulk operations and inventory.',
    ),
    _RoleData(
      id: 'company',
      title: 'Company / Business',
      description: 'For businesses and corporate recycling',
      icon: Icons.business_rounded,
      color: AppColors.roleCompany,
      lightColor: AppColors.roleCompanyLight,
      tooltip: 'Designed for businesses seeking comprehensive recycling solutions.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softGreyBg,
      body: Stack(
        children: [
          // Wave background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 260),
              painter: WavePainter(
                gradient: AppColors.heroGradient,
                color: AppColors.primaryGreen,
                waveHeight: 70,
                isTop: true,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Back Button
                    _buildBackButton(isDark),

                    // Header Section
                    _buildHeader(),

                    const SizedBox(height: DesignTokens.spacing24),

                    // Role Cards
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing24,
                        ),
                        child: Column(
                          children: [
                            ..._roles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final role = entry.value;
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 400 + (index * 100)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
                                  child: _buildRoleCard(role, isDark),
                                ),
                              );
                            }),
                            const SizedBox(height: 80), // Space for button
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
      bottomNavigationBar: _buildContinueButton(isDark),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall + 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.people_rounded,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select how you want to use RecyConnect',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(_RoleData role, bool isDark) {
    final isSelected = _selectedRole == role.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role.id),
      child: AnimatedContainer(
        duration: DesignTokens.animationNormal,
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
        child: CurvedCard(
          radius: DesignTokens.radiusLarge,
          padding: const EdgeInsets.all(DesignTokens.spacing20),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          border: isSelected
              ? Border.all(color: role.color, width: 2.5)
              : Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
          shadows: [
            BoxShadow(
              color: isSelected
                  ? role.color.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: isSelected ? 20 : 15,
              offset: const Offset(0, 6),
              spreadRadius: isSelected ? 1 : 0,
            ),
          ],
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      role.color,
                      role.color.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: role.color.withValues(alpha: 0.3),
                      blurRadius: 10,
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
              const SizedBox(width: DesignTokens.spacing16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.mediumGrey,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: DesignTokens.spacing8),

              // Info button
              IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey,
                ),
                onPressed: () => _showRoleInfoDialog(role),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),

              // Selection indicator
              AnimatedContainer(
                duration: DesignTokens.animationNormal,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? role.color : (isDark ? AppColors.darkSurface : AppColors.lightGrey),
                  shape: BoxShape.circle,
                  border: !isSelected
                      ? Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
                          width: 2,
                        )
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final isEnabled = _selectedRole != null;
    final roleText = _selectedRole != null
        ? _selectedRole![0].toUpperCase() + _selectedRole!.substring(1)
        : '';

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusLarge),
          topRight: Radius.circular(DesignTokens.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: OrganicButton(
          text: isEnabled ? 'Continue as $roleText' : 'Select a role to continue',
          icon: isEnabled ? Icons.arrow_forward_rounded : null,
          iconTrailing: true,
          style: OrganicButtonStyle.gradient,
          isDisabled: !isEnabled,
          onPressed: isEnabled ? _handleContinue : null,
        ),
      ),
    );
  }

  void _showRoleInfoDialog(_RoleData role) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.dialogRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: role.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(role.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                role.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          role.tooltip,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: role.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
        transitionDuration: DesignTokens.pageTransition,
      ),
    );
  }
}

/// Role data model
class _RoleData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final String tooltip;

  const _RoleData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.tooltip,
  });
}
