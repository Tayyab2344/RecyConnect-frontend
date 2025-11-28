import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';

class AppTheme {
  // Primary Colors (kept for backward compatibility)
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

  // ============ LIGHT THEME ============
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        primaryColor: AdminColors.primaryGreen,
        scaffoldBackgroundColor: AdminColors.background,
        colorScheme: const ColorScheme.light(
          primary: AdminColors.primaryGreen,
          secondary: AdminColors.primaryGreenDark,
          surface: AdminColors.cardBackground,
          error: AdminColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AdminColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: AdminColors.cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AdminColors.cardBackground,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: AdminColors.textPrimary,
          iconColor: AdminColors.textSecondary,
        ),
        dividerTheme: const DividerThemeData(
          color: AdminColors.border,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AdminColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.primaryGreen, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: AdminColors.textSecondary),
          bodyLarge: TextStyle(color: AdminColors.textPrimary),
          bodyMedium: TextStyle(color: AdminColors.textSecondary),
          bodySmall: TextStyle(color: AdminColors.textLight),
        ),
        iconTheme: const IconThemeData(color: AdminColors.textSecondary),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AdminColors.primaryGreen;
            }
            return AdminColors.textLight;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AdminColors.primaryGreenLight;
            }
            return AdminColors.border;
          }),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );

  // ============ DARK THEME ============
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        primaryColor: AdminColors.primaryGreen,
        scaffoldBackgroundColor: AdminColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AdminColors.primaryGreen,
          secondary: AdminColors.primaryGreenDark,
          surface: AdminColors.darkSurface,
          error: AdminColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AdminColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: AdminColors.darkCardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AdminColors.darkSurface,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: AdminColors.darkTextPrimary,
          iconColor: AdminColors.darkTextSecondary,
        ),
        dividerTheme: const DividerThemeData(
          color: AdminColors.darkBorder,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AdminColors.darkSurfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.primaryGreen, width: 2),
          ),
          labelStyle: const TextStyle(color: AdminColors.darkTextSecondary),
          hintStyle: const TextStyle(color: AdminColors.darkTextLight),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AdminColors.darkTextPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AdminColors.darkTextPrimary, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: AdminColors.darkTextPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: AdminColors.darkTextPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AdminColors.darkTextPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: AdminColors.darkTextSecondary),
          bodyLarge: TextStyle(color: AdminColors.darkTextPrimary),
          bodyMedium: TextStyle(color: AdminColors.darkTextSecondary),
          bodySmall: TextStyle(color: AdminColors.darkTextLight),
        ),
        iconTheme: const IconThemeData(color: AdminColors.darkTextSecondary),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AdminColors.primaryGreen;
            }
            return AdminColors.darkTextLight;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AdminColors.primaryGreenLight;
            }
            return AdminColors.darkBorder;
          }),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
