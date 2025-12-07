  import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'design_tokens.dart';
import 'theme_factory.dart';

/// AppTheme - Single source of theme access
/// SRP: Only responsible for providing theme access
/// Maintains backward compatibility while using new ThemeFactory
class AppTheme {
  // ============================================
  // THEME DATA ACCESS (Use ThemeFactory)
  // ============================================

  /// Light theme - Use this for ThemeData.light
  static ThemeData get lightTheme => ThemeFactory.createLight();

  /// Dark theme - Use this for ThemeData.dark
  static ThemeData get darkTheme => ThemeFactory.createDark();

  // ============================================
  // BACKWARD COMPATIBILITY - COLOR ALIASES
  // Maps old color names to new AppColors system
  // TODO: Migrate screens to use AppColors directly
  // ============================================

  // Primary Colors
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color secondaryGreen = AppColors.accentLimeLight;
  static const Color accentGreen = AppColors.primaryGreenLight;
  static const Color lightGreen = AppColors.accentLimeLight;

  // Background Colors
  static const Color backgroundLight = AppColors.softGreyBg;
  static const Color surfaceWhite = AppColors.white;

  // Text Colors
  static const Color textDark = AppColors.darkText;
  static const Color textLight = AppColors.mediumGrey;
  static const Color lightGray = AppColors.lightGrey;

  // Semantic Colors
  static const Color errorRed = AppColors.error;
  static const Color warningOrange = AppColors.warning;
  static const Color infoBlue = AppColors.info;

  // Role Colors
  static const Color skyBlue = AppColors.roleWarehouse;
  static const Color accentBlue = AppColors.info;
  static const Color primaryBlue = AppColors.infoDark;
  static const Color earthBrown = Color(0xFF795548);
  static const Color accentPurple = AppColors.roleCollector;

  // Dark Theme Colors
  static const Color darkBackground = AppColors.darkBackground;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkCardSurface = AppColors.darkCard;
  static const Color darkPrimaryGreen = AppColors.darkPrimaryGreen;
  static const Color darkSecondaryGreen = AppColors.darkSecondaryGreen;
  static const Color darkAccentGreen = AppColors.darkAccentGreen;
  static const Color darkTextPrimary = AppColors.darkTextPrimary;
  static const Color darkTextSecondary = AppColors.darkTextSecondary;
  static const Color darkBorderGreen = AppColors.darkBorder;

  // ============================================
  // BACKWARD COMPATIBILITY - TEXT STYLES
  // TODO: Migrate screens to use AppTypography
  // ============================================

  static TextStyle get headingStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      );

  static TextStyle get subHeadingStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      );

  static TextStyle get bodyStyle => GoogleFonts.lato(
        fontSize: 16,
        color: textDark,
      );

  static TextStyle get captionStyle => GoogleFonts.lato(
        fontSize: 14,
        color: textLight,
      );

  // ============================================
  // DESIGN TOKEN ACCESSORS
  // For components that need direct access to tokens
  // ============================================

  /// Card border radius
  static double get cardRadius => DesignTokens.cardRadius;

  /// Button border radius
  static double get buttonRadius => DesignTokens.buttonRadius;

  /// Input border radius
  static double get inputRadius => DesignTokens.inputRadius;

  /// Standard button height
  static double get buttonHeight => DesignTokens.buttonHeight;

  /// Standard spacing
  static double get spacing16 => DesignTokens.spacing16;
  static double get spacing24 => DesignTokens.spacing24;

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get gradient for eco backgrounds
  static LinearGradient get ecoGradient => AppColors.lightBackgroundGradient;

  /// Get primary gradient
  static LinearGradient get primaryGradient => AppColors.primaryGradient;

  /// Get shadow based on theme
  static List<BoxShadow> getCardShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Get role-specific color
  static Color getRoleColor(String role) => AppColors.getRoleColor(role);

  /// Get role-specific light color
  static Color getRoleLightColor(String role) => AppColors.getRoleLightColor(role);
}
