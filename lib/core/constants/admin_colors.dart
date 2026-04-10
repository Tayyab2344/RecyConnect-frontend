import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium Admin Colors - Aligned with main app glassmorphism theme
/// Supports both light and dark modes with consistent design language
class AdminColors {
  // ============================================
  // PRIMARY COLORS (From AppColors for consistency)
  // ============================================
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color primaryGreenDark = AppColors.primaryGreenDark;
  static const Color primaryGreenLight = AppColors.primaryGreenLight;

  // ============================================
  // NEON COLORS (Dark Mode Accents)
  // ============================================
  static const Color neonCyan = AppColors.neonCyan;
  static const Color neonGreen = AppColors.neonGreen;
  static const Color neonPurple = AppColors.neonPurple;

  // ============ LIGHT MODE COLORS ============
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundAlt = Color(0xFFF0F9F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFE8F5F2);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFD1D5DB);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // ============ DARK MODE COLORS ============
  // Matching main app's dark theme
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkBackgroundAlt = Color(0xFF0D2137);
  static const Color darkSurface = Color(0xFF0F2847);
  static const Color darkCardBackground = Color(0xFF1A2A3A);
  static const Color darkSurfaceLight = Color(0xFF1E3A4E);

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0C4DE);
  static const Color darkTextLight = Color(0xFF6B8299);

  // Dark Border & Divider
  static const Color darkBorder = Color(0xFF2D4A5C);
  static const Color darkDivider = Color(0xFF3A5A6D);

  // Dark Shadow
  static const Color darkShadow = Color(0x60000000);

  // ============ ACCENT COLORS ============
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFFBBF24);

  // Status Colors
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;

  // ============================================
  // GRADIENTS
  // ============================================
  
  // Light mode background gradient (matching login screen)
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F9F7),
      Color(0xFFE8F5F2),
      Color(0xFFDFF2ED),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Dark mode background gradient (matching login screen)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1628),
      Color(0xFF0D2137),
      Color(0xFF0F2847),
      Color(0xFF0A1E35),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neon gradient (dark mode)
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonGreen, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card gradients
  static LinearGradient get lightCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.85),
      Colors.white.withValues(alpha: 0.65),
    ],
  );

  static LinearGradient get darkCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.12),
      Colors.white.withValues(alpha: 0.05),
    ],
  );

  // Accent gradients
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get background gradient based on theme
  static LinearGradient getBackgroundGradient(bool isDark) {
    return isDark ? darkBackgroundGradient : lightBackgroundGradient;
  }

  /// Get card gradient based on theme
  static LinearGradient getCardGradient(bool isDark) {
    return isDark ? darkCardGradient : lightCardGradient;
  }

  /// Get text primary color based on theme
  static Color getTextPrimary(bool isDark) {
    return isDark ? darkTextPrimary : textPrimary;
  }

  /// Get text secondary color based on theme
  static Color getTextSecondary(bool isDark) {
    return isDark ? darkTextSecondary : textSecondary;
  }

  /// Get card background color based on theme
  static Color getCardBackground(bool isDark) {
    return isDark ? darkCardBackground : cardBackground;
  }

  /// Get accent color (neon for dark, primary for light)
  static Color getAccentColor(bool isDark) {
    return isDark ? neonCyan : primaryGreen;
  }

  /// Get glow shadows for dark mode
  static List<BoxShadow> getGlowShadow(Color color, {double intensity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }

  /// Get standard card shadow
  static List<BoxShadow> getCardShadow(bool isDark) {
    return isDark
        ? [
            BoxShadow(
              color: neonCyan.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ];
  }

  /// Get border color based on theme
  static Color getBorderColor(bool isDark, {double pulseValue = 1.0}) {
    return isDark
        ? neonCyan.withValues(alpha: 0.15 + 0.1 * pulseValue)
        : Colors.white.withValues(alpha: 0.6);
  }
}

/// Premium Glass Card for Admin Screens
class AdminGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double blurAmount;
  final Color? glowColor;

  const AdminGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurAmount = 15,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);
    
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: AdminColors.getCardGradient(isDark),
            border: Border.all(
              color: isDark
                  ? (glowColor ?? AdminColors.neonCyan).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: AdminColors.getCardShadow(isDark),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Admin Stat Card with glassmorphism
class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? trend;
  final bool isPositive;
  final Color color;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trend,
    this.isPositive = true,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdminGlassCard(
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: isDark
                      ? Border.all(color: color.withValues(alpha: 0.3))
                      : null,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? AdminColors.success : AdminColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isPositive ? AdminColors.success : AdminColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? AdminColors.success : AdminColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AdminColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AdminColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
