import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Eco-Friendly Color Palette
  static const Color primaryGreen = Color(0xFF1B5E20); // Deep Forest Green
  static const Color secondaryGreen = Color(0xFF81C784); // Sage Green
  static const Color accentGreen = Color(0xFF4CAF50); // Vibrant Green
  static const Color lightGreen = Color(0xFFA5D6A7); // Light Green (for gradients)
  
  static const Color backgroundLight = Color(0xFFFAFAFA); // Clean Off-White
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure White
  
  static const Color textDark = Color(0xFF263238); // Dark Blue-Grey (Softer than black)
  static const Color textLight = Color(0xFF757575); // Medium Grey
  static const Color lightGray = Color(0xFFE0E0E0); // Light Gray
  
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFFA000);
  static const Color infoBlue = Color(0xFF1976D2);
  
  // Additional accent colors for different roles/features
  static const Color skyBlue = Color(0xFF42A5F5); // Sky Blue
  static const Color accentBlue = Color(0xFF2196F3); // Accent Blue
  static const Color primaryBlue = Color(0xFF1565C0); // Primary Blue
  static const Color earthBrown = Color(0xFF795548); // Earth Brown
  static const Color accentPurple = Color(0xFF9C27B0); // Accent Purple

  // Dark Theme Colors - Deep Greenish Theme
  static const Color darkBackground = Color(0xFF0A1F0C); // Richer Dark Green-Black
  static const Color darkSurface = Color(0xFF152D17); // Forest Green Surface
  static const Color darkCardSurface = Color(0xFF1E3A21); // Deep Green Card
  static const Color darkPrimaryGreen = Color(0xFF66BB6A); // Vibrant Medium Green
  static const Color darkSecondaryGreen = Color(0xFF81C784); // Light Green accent
  static const Color darkAccentGreen = Color(0xFF4CAF50); // Bright accent green
  static const Color darkTextPrimary = Color(0xFFE8F5E9); // Very Light Green-White
  static const Color darkTextSecondary = Color(0xFFA5D6A7); // Muted Light Green
  static const Color darkBorderGreen = Color(0xFF2E5930); // Subtle border green

  // Text Styles
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

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: surfaceWhite,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: textDark,
      onSurface: textDark,
      onError: Colors.white,
    ),
    
    // Typography
    textTheme: TextTheme(
      displayLarge: headingStyle,
      displayMedium: subHeadingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle.copyWith(fontSize: 14),
      labelSmall: captionStyle,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      labelStyle: GoogleFonts.lato(color: textLight),
      hintStyle: GoogleFonts.lato(color: textLight.withOpacity(0.5)),
    ),
    
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    primaryColor: darkPrimaryGreen,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryGreen,
      secondary: darkSecondaryGreen,
      surface: darkSurface,
      error: errorRed,
      onPrimary: darkBackground,
      onSecondary: darkBackground,
      onSurface: darkTextPrimary,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    
    // Typography for dark theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: darkTextPrimary,
      ),
      labelSmall: GoogleFonts.lato(
        fontSize: 14,
        color: darkTextSecondary,
      ),
    ),

    // AppBar Theme for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
    ),

    // Button Themes for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryGreen,
        foregroundColor: darkBackground,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPrimaryGreen,
        side: const BorderSide(color: darkPrimaryGreen, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme for dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: darkSecondaryGreen.withOpacity(0.3), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkPrimaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      labelStyle: GoogleFonts.lato(color: darkTextSecondary),
      hintStyle: GoogleFonts.lato(color: darkTextSecondary.withOpacity(0.5)),
    ),

    // Card Theme for dark mode
    cardTheme: CardTheme(
      color: darkCardSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
