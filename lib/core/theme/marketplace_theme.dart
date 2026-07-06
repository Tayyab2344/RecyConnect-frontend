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

  // Dark Theme Colors (Flat Black / Green Accent)
  static const Color darkBackgroundStart = Color(0xFF000000); // Pure Black
  static const Color darkBackgroundEnd = Color(0xFF000000); // Pure Black
  static const Color darkGlassColor =
      Color(0xFF121212); // Solid dark grey for cards
  static const Color darkGlassBorder = Color(0xFF00B894); // Mint Green Border
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB2BEC3);
  static const Color darkAccentCyan = Color(0xFF00B894); // Mint Green Accent
  static const Color darkAccentGreen = Color(0xFF00B894); // Mint Green Accent
  static const Color darkCardShadow = Color(0x00000000); // No glow
  static const Color darkSidebarBg = Color(0xFF000000);

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
          ? const Color(0xFF121212)
          : lightGlassColor.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? darkGlassBorder.withValues(alpha: 0.3)
            : lightGlassBorder.withValues(alpha: 0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black54
              : lightCardShadow,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Get neon shadow for buttons
  static List<BoxShadow> getNeonShadow({required bool isDark, Color? color}) {
    return []; // No neon glows
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
