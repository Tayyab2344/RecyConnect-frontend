import 'package:flutter/material.dart';

/// Design tokens - Single source of truth for all design values
/// SRP: Only responsible for storing design constants
/// Used across the entire app for consistent spacing, radius, and timing
abstract class DesignTokens {
  // ============================================
  // SPACING SYSTEM (8px grid)
  // ============================================
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // ============================================
  // BORDER RADIUS (Curvy Design System)
  // ============================================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusCircle = 999.0;

  // Specific component radii
  static const double cardRadius = 16.0;
  static const double buttonRadius = 20.0;
  static const double inputRadius = 16.0;
  static const double bottomNavRadius = 24.0;
  static const double dialogRadius = 24.0;
  static const double chipRadius = 20.0;

  // ============================================
  // ELEVATION & SHADOWS
  // ============================================
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXL = 16.0;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 800);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // ============================================
  // ANIMATION CURVES
  // ============================================
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSmooth = Curves.easeOut;

  // ============================================
  // WAVE & CURVE CONSTANTS (Organic Design)
  // ============================================
  static const double waveHeight = 80.0;
  static const double waveCurvature = 0.3;
  static const double headerWaveHeight = 60.0;
  static const double bottomNavWaveHeight = 20.0;

  // ============================================
  // GLASSMORPHISM SETTINGS
  // ============================================
  static const double glassBlurLight = 10.0;
  static const double glassBlurMedium = 15.0;
  static const double glassBlurHeavy = 20.0;
  static const double glassOpacity = 0.1;
  static const double glassBorderOpacity = 0.2;

  // ============================================
  // ICON SIZES
  // ============================================
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // ============================================
  // COMPONENT HEIGHTS
  // ============================================
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 70.0;
  static const double cardMinHeight = 80.0;
  static const double listItemHeight = 72.0;

  // ============================================
  // BREAKPOINTS (Responsive)
  // ============================================
  static const double breakpointMobile = 360.0;
  static const double breakpointTablet = 600.0;
  static const double breakpointDesktop = 1024.0;

  // ============================================
  // OPACITY VALUES
  // ============================================
  static const double opacityDisabled = 0.38;
  static const double opacityLight = 0.5;
  static const double opacityMedium = 0.7;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // ============================================
  // BORDER WIDTHS
  // ============================================
  static const double borderThin = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;
  static const double borderXThick = 3.0;
}
