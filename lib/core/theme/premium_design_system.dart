import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Design System for RecyConnect Admin
/// Features: Glassmorphism, 3D effects, Neon highlights, Modern gradients
class PremiumDesignSystem {
  // ═══════════════════════════════════════════════════════════
  // 🎨 PREMIUM COLOR PALETTE
  // ═══════════════════════════════════════════════════════════

  // Primary Colors (Vibrant Green with depth)
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryNeon = Color(0xFF6EE7B7);

  // Accent Colors (Multiple vibrant accents)
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentBlueDark = Color(0xFF2563EB);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleDark = Color(0xFF7C3AED);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentOrangeDark = Color(0xFFD97706);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentTeal = Color(0xFF14B8A6);

  // Status Colors with glow
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0xFF6EE7B7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningGlow = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoGlow = Color(0xFF60A5FA);

  // Neutral Colors (Light Mode)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Dark Mode Colors (Deep & Rich)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkSurfaceElevated = Color(0xFF475569);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // ═══════════════════════════════════════════════════════════
  // 🌈 PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════

  // Primary Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Accent Gradients
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777), Color(0xFFBE185D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Gradients
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Special Gradients
  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
      Color(0xFF047857),
      Color(0xFF065F46),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism Gradients
  static LinearGradient glassGradient({Color? color}) {
    final baseColor = color ?? primary;
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0.1),
        baseColor.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✨ PREMIUM SHADOWS & EFFECTS
  // ═══════════════════════════════════════════════════════════

  // Soft Shadows (subtle elevation)
  static List<BoxShadow> get softShadowSmall => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get softShadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get softShadowLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  // Elevated Shadows (strong depth)
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 12),
          blurRadius: 32,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  // Hover Shadows (interactive feedback)
  static List<BoxShadow> hoverShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: color.withOpacity(0.15),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // Glow Effects (neon highlights)
  static List<BoxShadow> glowEffect(Color color, {double intensity = 0.4}) => [
        BoxShadow(
          color: color.withOpacity(intensity),
          offset: const Offset(0, 0),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: color.withOpacity(intensity * 0.5),
          offset: const Offset(0, 0),
          blurRadius: 40,
          spreadRadius: 0,
        ),
      ];

  // Inner Shadow (depth effect)
  static List<BoxShadow> get innerShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: -2,
        ),
      ];

  // Glassmorphism Shadow
  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          offset: const Offset(-4, -4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(4, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  // ═══════════════════════════════════════════════════════════
  // 📝 PREMIUM TYPOGRAPHY
  // ═══════════════════════════════════════════════════════════

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
      );

  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
      );

  static TextStyle get subtitle1 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get subtitle2 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get body1 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get body2 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  // ═══════════════════════════════════════════════════════════
  // 📏 SPACING SYSTEM
  // ═══════════════════════════════════════════════════════════

  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing28 = 28;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing56 = 56;
  static const double spacing64 = 64;

  // ═══════════════════════════════════════════════════════════
  // 🔲 BORDER RADIUS
  // ═══════════════════════════════════════════════════════════

  static const double radiusXSmall = 6;
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;
  static const double radiusXXLarge = 24;
  static const double radiusRound = 100;

  static BorderRadius get borderRadiusXSmall =>
      BorderRadius.circular(radiusXSmall);
  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXLarge =>
      BorderRadius.circular(radiusXLarge);
  static BorderRadius get borderRadiusXXLarge =>
      BorderRadius.circular(radiusXXLarge);

  // ═══════════════════════════════════════════════════════════
  // ⏱️ ANIMATION DURATIONS & CURVES
  // ═══════════════════════════════════════════════════════════

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  static const Curve animationCurve = Curves.easeInOutCubic;
  static const Curve animationCurveIn = Curves.easeInCubic;
  static const Curve animationCurveOut = Curves.easeOutCubic;
  static const Curve animationCurveElastic = Curves.elasticOut;
  static const Curve animationCurveSpring = Curves.easeOutBack;

  // ═══════════════════════════════════════════════════════════
  // 🎭 GLASSMORPHISM EFFECTS
  // ═══════════════════════════════════════════════════════════

  static BoxDecoration glassDecoration({
    Color? color,
    double opacity = 0.1,
    double borderOpacity = 0.2,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: borderRadius ?? borderRadiusLarge,
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.5,
      ),
      boxShadow: boxShadow ?? glassShadow,
    );
  }

  static BoxDecoration glassDecorationDark({
    Color? color,
    double opacity = 0.1,
    double borderOpacity = 0.1,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: borderRadius ?? borderRadiusLarge,
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1,
      ),
      boxShadow: boxShadow ?? glassShadow,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 💎 3D EFFECTS
  // ═══════════════════════════════════════════════════════════

  static BoxDecoration threeDDecoration({
    required Gradient gradient,
    BorderRadius? borderRadius,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius ?? borderRadiusLarge,
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? Colors.black).withOpacity(0.2),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          offset: const Offset(-2, -2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🎨 UTILITY FUNCTIONS
  // ═══════════════════════════════════════════════════════════

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color addOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
