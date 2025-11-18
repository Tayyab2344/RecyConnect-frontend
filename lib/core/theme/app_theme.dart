import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF66BB6A);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  // Status Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color skyBlue = Color(0xFF2196F3);
  static const Color earthBrown = Color(0xFF8D6E63);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color accentPurple = Color(0xFF9C27B0);

  static const Color primaryBlue = Color(0xFF1976D2);

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.green,
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
