import 'package:flutter/material.dart';

class MarketplaceTheme {
  // Light Theme Colors (Glassmorphism / Pastel)
  static const Color lightBackgroundStart = Color(0xFFF0F4F2); // Soft White-Green
  static const Color lightBackgroundEnd = Color(0xFFE0F2F1); // Pastel Mint
  static const Color lightGlassColor =
      Color(0x99FFFFFF); // High alpha white for glass
  static const Color lightGlassBorder = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightAccent = Color(0xFF00B894); // Mint Green
  static const Color lightCardShadow = Color(0x1A000000); // Soft shadow
  static const Color lightSidebarBg = Color(0xFFF6FBF9);

  // Dark Theme Colors (Neon / Futuristic)
  static const Color darkBackgroundStart = Color(0xFF0F172A); // Deep Navy
  static const Color darkBackgroundEnd = Color(0xFF1E293B); // Charcoal
  static const Color darkGlassColor =
      Color(0xCC1E293B); // High alpha dark for glass
  static const Color darkGlassBorder = Color(0xFF00E5FF); // Cyan Border
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB2BEC3);
  static const Color darkAccentCyan = Color(0xFF00E5FF); // Neon Cyan
  static const Color darkAccentGreen = Color(0xFF00FF9D); // Neon Green
  static const Color darkCardShadow = Color(0x8000E5FF); // Neon Glow
  static const Color darkSidebarBg = Color(0xFF111827);

  /// Get background gradient based on theme
  static LinearGradient getBackgroundGradient(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [darkBackgroundStart, darkBackgroundEnd],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightBackgroundStart, lightBackgroundEnd],
      );
    }
  }

  /// Get glass decoration
  static BoxDecoration getGlassDecoration({
    required bool isDark,
    double radius = 20,
    double opacity = 0.7,
  }) {
    return BoxDecoration(
      color: isDark
          ? darkGlassColor.withOpacity(opacity)
          : lightGlassColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? darkGlassBorder.withOpacity(0.5)
            : lightGlassBorder.withOpacity(0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? darkCardShadow.withOpacity(0.15) // Subtle neon glow
              : lightCardShadow,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Get neon shadow for buttons
  static List<BoxShadow> getNeonShadow({required bool isDark, Color? color}) {
    if (!isDark) return []; // No neon in light mode

    final shadowColor = color ?? darkAccentCyan;
    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.6),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.3),
        blurRadius: 24,
        spreadRadius: 2,
        offset: const Offset(0, 0),
      ),
    ];
  }

  static LinearGradient getKPIGradient(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF172033), Color(0xFF0F172A)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F8F5)],
          );
  }
}
