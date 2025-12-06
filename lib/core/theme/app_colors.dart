import 'package:flutter/material.dart';

/// App color palette - Single responsibility for color management
/// SRP: Only handles color definitions
/// Used: Import AppColors.primaryGreen instead of hardcoding hex values
abstract class AppColors {
  // ============================================
  // PRIMARY PALETTE (Eco-Tech Green)
  // ============================================
  static const Color primaryGreen = Color(0xFF1A8F3A);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  // ============================================
  // SECONDARY PALETTE (Eco Teal)
  // ============================================
  static const Color ecoTeal = Color(0xFF2AAE97);
  static const Color ecoTealLight = Color(0xFF4DB6AC);
  static const Color ecoTealDark = Color(0xFF00897B);

  // ============================================
  // ACCENT PALETTE (Lime)
  // ============================================
  static const Color accentLime = Color(0xFF89E470);
  static const Color accentLimeLight = Color(0xFFA5D6A7);
  static const Color accentLimeDark = Color(0xFF66BB6A);

  // ============================================
  // NEUTRAL PALETTE
  // ============================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color softGreyBg = Color(0xFFF4F6F5);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF616161);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color black = Color(0xFF000000);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  static const Color error = Color(0xFFEA5455);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color errorDark = Color(0xFFC62828);

  static const Color warning = Color(0xFFFF9F43);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color warningDark = Color(0xFFE65100);

  static const Color success = Color(0xFF28C76F);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color successDark = Color(0xFF2E7D32);

  static const Color info = Color(0xFF00CFE8);
  static const Color infoLight = Color(0xFFB3E5FC);
  static const Color infoDark = Color(0xFF0288D1);

  // ============================================
  // DARK MODE PALETTE
  // ============================================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBackgroundAlt = Color(0xFF161616);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkCardElevated = Color(0xFF2D2D2D);
  static const Color darkBorder = Color(0xFF2E5930);
  static const Color darkTextPrimary = Color(0xFFE8F5E9);
  static const Color darkTextSecondary = Color(0xFFA5D6A7);

  // Dark mode greens
  static const Color darkPrimaryGreen = Color(0xFF66BB6A);
  static const Color darkSecondaryGreen = Color(0xFF81C784);
  static const Color darkAccentGreen = Color(0xFF4CAF50);

  // ============================================
  // LIGHT MODE GRADIENT BACKGROUNDS
  // ============================================
  static const Color gradientLightTop = Color(0xFFEEF9F1);
  static const Color gradientLightBottom = Color(0xFFFFFFFF);

  // ============================================
  // ROLE-SPECIFIC COLORS
  // ============================================
  // Individual
  static const Color roleIndividual = Color(0xFF4CAF50);
  static const Color roleIndividualLight = Color(0xFFE8F5E9);

  // Warehouse
  static const Color roleWarehouse = Color(0xFF42A5F5);
  static const Color roleWarehouseLight = Color(0xFFE3F2FD);

  // Company
  static const Color roleCompany = Color(0xFFFFA726);
  static const Color roleCompanyLight = Color(0xFFFFF3E0);

  // Collector
  static const Color roleCollector = Color(0xFF9C27B0);
  static const Color roleCollectorLight = Color(0xFFF3E5F5);

  // ============================================
  // MATERIAL CATEGORY COLORS
  // ============================================
  static const Color categoryPlastic = Color(0xFF2196F3);
  static const Color categoryMetal = Color(0xFF607D8B);
  static const Color categoryPaper = Color(0xFFFFA726);
  static const Color categoryGlass = Color(0xFF26A69A);
  static const Color categoryEwaste = Color(0xFF9C27B0);
  static const Color categoryOrganic = Color(0xFF8BC34A);

  // ============================================
  // MARKETPLACE SPECIAL PALETTE
  // ============================================
  // Dark Mode Neon
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonPurple = Color(0xFFD500F9);
  static const Color darkGlassBorder = Color(0xFF00E5FF); // Cyan outline

  // Light Mode Pastel
  static const Color pastelMint = Color(0xFFE0F2F1);
  static const Color pastelGreen = Color(0xFFE8F5E9);
  static const Color pastelTeal = Color(0xFFB2DFDB);
  static const Color lightGlassBorder = Color(0xFFE0F2F1);


  /// Get gradient for light mode backgrounds
  static LinearGradient get lightBackgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientLightTop, gradientLightBottom],
      );

  /// Get gradient for primary button
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryGreen, ecoTeal],
      );

  /// Get gradient for hero sections
  static LinearGradient get heroGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryGreen, primaryGreenLight],
      );

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get shadow color based on theme
  static Color shadowColor(bool isDark) {
    return isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.08);
  }

  /// Get border color based on theme
  static Color borderColor(bool isDark) {
    return isDark
        ? darkBorder.withValues(alpha: 0.3)
        : lightGrey.withValues(alpha: 0.5);
  }

  /// Get role color by role name
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'individual':
        return roleIndividual;
      case 'warehouse':
        return roleWarehouse;
      case 'company':
        return roleCompany;
      case 'collector':
        return roleCollector;
      default:
        return primaryGreen;
    }
  }

  /// Get role light color by role name
  static Color getRoleLightColor(String role) {
    switch (role.toLowerCase()) {
      case 'individual':
        return roleIndividualLight;
      case 'warehouse':
        return roleWarehouseLight;
      case 'company':
        return roleCompanyLight;
      case 'collector':
        return roleCollectorLight;
      default:
        return accentLimeLight;
    }
  }
}
