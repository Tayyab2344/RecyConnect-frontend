import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system - Single responsibility for text styles
/// SRP: Only handles text style definitions
/// Usage: AppTypography.heading1(context) for theme-aware styles
class AppTypography {
  // ============================================
  // FONT FAMILIES
  // ============================================
  static String get fontFamilyHeading => GoogleFonts.poppins().fontFamily!;
  static String get fontFamilyBody => GoogleFonts.lato().fontFamily!;

  // ============================================
  // HEADING STYLES (Poppins)
  // ============================================

  /// Display Large - Hero titles, splash screens
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: Theme.of(context).textTheme.displayLarge?.color,
      );

  /// Display Medium - Page titles
  static TextStyle displayMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
        color: Theme.of(context).textTheme.displayMedium?.color,
      );

  /// Heading 1 - Section headers
  static TextStyle heading1(BuildContext context) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.headlineLarge?.color,
      );

  /// Heading 2 - Card titles, subsection headers
  static TextStyle heading2(BuildContext context) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.headlineMedium?.color,
      );

  /// Heading 3 - Component headers
  static TextStyle heading3(BuildContext context) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.headlineSmall?.color,
      );

  /// Heading 4 - List item titles
  static TextStyle heading4(BuildContext context) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleLarge?.color,
      );

  // ============================================
  // BODY STYLES (Lato)
  // ============================================

  /// Body Large - Primary body text
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  /// Body Medium - Secondary body text
  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  /// Body Small - Tertiary body text
  static TextStyle bodySmall(BuildContext context) => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );

  // ============================================
  // LABEL STYLES
  // ============================================

  /// Label Large - Button text, input labels
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Theme.of(context).textTheme.labelLarge?.color,
      );

  /// Label Medium - Chips, badges
  static TextStyle labelMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: Theme.of(context).textTheme.labelMedium?.color,
      );

  /// Label Small - Captions, hints
  static TextStyle labelSmall(BuildContext context) => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        color: Theme.of(context).textTheme.labelSmall?.color,
      );

  // ============================================
  // SPECIAL STYLES
  // ============================================

  /// Caption - Image captions, timestamps
  static TextStyle caption(BuildContext context) => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
      );

  /// Overline - Category labels, section dividers
  static TextStyle overline(BuildContext context) => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: Theme.of(context).textTheme.labelSmall?.color,
      );

  /// Button text
  static TextStyle button(BuildContext context) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// Link text
  static TextStyle link(BuildContext context) => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
      );

  /// Error text
  static TextStyle error(BuildContext context) => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).colorScheme.error,
      );

  // ============================================
  // STAT/METRIC STYLES
  // ============================================

  /// Stat value - Large numbers on dashboards
  static TextStyle statValue(BuildContext context) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.displayLarge?.color,
      );

  /// Stat label - Labels under stat values
  static TextStyle statLabel(BuildContext context) => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      );

  /// Price - Currency display
  static TextStyle price(BuildContext context) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      );

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Build TextTheme for ThemeData
  static TextTheme buildTextTheme({required bool isDark}) {
    final Color textColor = isDark ? const Color(0xFFE8F5E9) : const Color(0xFF1A1A1A);
    final Color textSecondary = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF757575);

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
    );
  }
}
