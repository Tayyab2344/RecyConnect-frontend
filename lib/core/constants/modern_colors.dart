import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern Design System Colors
/// Features: Gradients, Glassmorphism, Neumorphism, Soft Shadows
class ModernColors {
  // ============ PRIMARY GRADIENTS ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF047857)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradientExtended = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ ACCENT GRADIENTS ============
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ SPECIAL GRADIENTS ============
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // ============ GLASSMORPHISM ============
  static Color glassBackground = Colors.white.withOpacity(0.7);
  static Color glassBackgroundDark = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color glassBorderLight = Colors.white.withOpacity(0.5);

  /// Glass decoration for light mode
  static BoxDecoration glassDecoration({
    double borderRadius = 20,
    Color? color,
    double opacity = 0.7,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 8),
          blurRadius: 32,
        ),
      ],
    );
  }

  /// Glass decoration for colored backgrounds
  static BoxDecoration glassDecorationColored({
    required Color color,
    double borderRadius = 20,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1.5,
      ),
    );
  }

  // ============ NEUMORPHISM ============
  static List<BoxShadow> neumorphicShadow = [
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      offset: const Offset(-4, -4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.grey.withOpacity(0.3),
      offset: const Offset(4, 4),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> neumorphicShadowInset = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.3),
      offset: const Offset(-2, -2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      offset: const Offset(2, 2),
      blurRadius: 4,
    ),
  ];

  // ============ MODERN SOFT SHADOWS ============
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> softShadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> softShadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 12),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Colored shadow for hover effects
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: const Offset(0, 8),
        blurRadius: 24,
        spreadRadius: 0,
      ),
    ];
  }

  /// Elevated colored shadow
  static List<BoxShadow> elevatedColoredShadow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        offset: const Offset(0, 12),
        blurRadius: 28,
        spreadRadius: 0,
      ),
    ];
  }

  // ============ HOVER EFFECTS ============
  static Color hoverColor = const Color(0xFF10B981).withOpacity(0.1);
  static Color hoverColorLight = const Color(0xFF10B981).withOpacity(0.05);

  // ============ CARD DECORATIONS ============
  static BoxDecoration modernCardDecoration({
    Color? color,
    double borderRadius = 16,
    bool isHovered = false,
    Color? hoverColor,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isHovered
          ? coloredShadow(hoverColor ?? const Color(0xFF10B981))
          : softShadow,
      border: Border.all(
        color: isHovered
            ? (hoverColor ?? const Color(0xFF10B981)).withOpacity(0.5)
            : Colors.transparent,
        width: 2,
      ),
    );
  }

  /// Gradient card decoration
  static BoxDecoration gradientCardDecoration({
    required LinearGradient gradient,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: softShadowMedium,
    );
  }

  // ============ ICON CONTAINER DECORATIONS ============
  static BoxDecoration iconContainerDecoration({
    required Color color,
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color, color.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ]
          : null,
    );
  }

  // ============ ANIMATION DURATIONS ============
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);

  // ============ ANIMATION CURVES ============
  static const Curve smoothCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve snappyCurve = Curves.easeOutBack;

  // ============ GRADIENT BORDERS ============
  static BoxDecoration gradientBorderDecoration({
    required LinearGradient gradient,
    double borderWidth = 2,
    double borderRadius = 16,
    Color? fillColor,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // ============ UTILITY METHODS ============

  /// Get gradient for specific color
  static LinearGradient getGradientForColor(Color color) {
    return LinearGradient(
      colors: [color, color.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Get light version of color
  static Color getLightColor(Color color, {double opacity = 0.1}) {
    return color.withOpacity(opacity);
  }

  /// Create blur filter for glassmorphism
  static ImageFilter glassBlur({double sigma = 10}) {
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }
}

/// Extension for easy gradient application
extension GradientExtension on Color {
  LinearGradient toGradient({double endOpacity = 0.7}) {
    return LinearGradient(
      colors: [this, withOpacity(endOpacity)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
