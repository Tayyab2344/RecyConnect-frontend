import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'design_tokens.dart';

/// Theme factory - Creates themed configurations
/// Pattern: Factory
/// SRP: Only responsible for theme assembly from component files
class ThemeFactory {
  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData createLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.softGreyBg,
      colorScheme: _buildLightColorScheme(),
      textTheme: AppTypography.buildTextTheme(isDark: false),
      appBarTheme: _buildAppBarTheme(isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark: false),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      textButtonTheme: _buildTextButtonTheme(isDark: false),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: false),
      bottomNavigationBarTheme: _buildBottomNavTheme(isDark: false),
      floatingActionButtonTheme: _buildFabTheme(isDark: false),
      chipTheme: _buildChipTheme(isDark: false),
      dialogTheme: _buildDialogTheme(isDark: false),
      snackBarTheme: _buildSnackBarTheme(isDark: false),
      bottomSheetTheme: _buildBottomSheetTheme(isDark: false),
      dividerTheme: _buildDividerTheme(isDark: false),
      iconTheme: const IconThemeData(color: AppColors.darkGrey, size: 24),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData createDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimaryGreen,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: _buildDarkColorScheme(),
      textTheme: AppTypography.buildTextTheme(isDark: true),
      appBarTheme: _buildAppBarTheme(isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark: true),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      textButtonTheme: _buildTextButtonTheme(isDark: true),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: true),
      bottomNavigationBarTheme: _buildBottomNavTheme(isDark: true),
      floatingActionButtonTheme: _buildFabTheme(isDark: true),
      chipTheme: _buildChipTheme(isDark: true),
      dialogTheme: _buildDialogTheme(isDark: true),
      snackBarTheme: _buildSnackBarTheme(isDark: true),
      bottomSheetTheme: _buildBottomSheetTheme(isDark: true),
      dividerTheme: _buildDividerTheme(isDark: true),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary, size: 24),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ============================================
  // COLOR SCHEMES
  // ============================================

  static ColorScheme _buildLightColorScheme() {
    return const ColorScheme.light(
      primary: AppColors.primaryGreen,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.accentLimeLight,
      onPrimaryContainer: AppColors.primaryGreenDark,
      secondary: AppColors.ecoTeal,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.ecoTealLight,
      onSecondaryContainer: AppColors.ecoTealDark,
      tertiary: AppColors.accentLime,
      onTertiary: AppColors.darkText,
      tertiaryContainer: AppColors.accentLimeLight,
      surface: AppColors.white,
      onSurface: AppColors.darkText,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,
      outline: AppColors.lightGrey,
      shadow: Colors.black12,
    );
  }

  static ColorScheme _buildDarkColorScheme() {
    return const ColorScheme.dark(
      primary: AppColors.darkPrimaryGreen,
      onPrimary: AppColors.darkBackground,
      primaryContainer: AppColors.primaryGreenDark,
      onPrimaryContainer: AppColors.accentLimeLight,
      secondary: AppColors.darkSecondaryGreen,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.ecoTealDark,
      onSecondaryContainer: AppColors.ecoTealLight,
      tertiary: AppColors.accentLime,
      onTertiary: AppColors.darkBackground,
      tertiaryContainer: AppColors.accentLimeDark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.errorLight,
      outline: AppColors.darkBorder,
      shadow: Colors.black45,
    );
  }

  // ============================================
  // APP BAR THEME
  // ============================================

  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryGreen,
      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.white,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.darkTextPrimary : AppColors.white,
      ),
    );
  }

  // ============================================
  // CARD THEME (Curvy Design)
  // ============================================

  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? AppColors.darkCard : AppColors.white,
      elevation: DesignTokens.elevationLow,
      shadowColor: isDark ? Colors.black45 : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      margin: const EdgeInsets.all(DesignTokens.spacing8),
    );
  }

  // ============================================
  // BUTTON THEMES (Curvy Design)
  // ============================================

  static ElevatedButtonThemeData _buildElevatedButtonTheme({required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen,
        foregroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: DesignTokens.elevationLow,
        shadowColor: (isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen)
            .withOpacity(0.4),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing24,
          vertical: DesignTokens.spacing16,
        ),
        minimumSize: const Size(double.infinity, DesignTokens.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    final primaryColor = isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen;
    
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: DesignTokens.borderThick),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing24,
          vertical: DesignTokens.spacing16,
        ),
        minimumSize: const Size(double.infinity, DesignTokens.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme({required bool isDark}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================
  // INPUT DECORATION THEME (Curvy Design)
  // ============================================

  static InputDecorationTheme _buildInputDecorationTheme({required bool isDark}) {
    final borderColor = isDark
        ? AppColors.darkSecondaryGreen.withOpacity(0.3)
        : AppColors.lightGrey;
    final focusColor = isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen;
    final fillColor = isDark ? AppColors.darkCard : AppColors.white;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing20,
        vertical: DesignTokens.spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: borderColor, width: DesignTokens.borderMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: focusColor, width: DesignTokens.borderThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: AppColors.error, width: DesignTokens.borderMedium),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: AppColors.error, width: DesignTokens.borderThick),
      ),
      labelStyle: GoogleFonts.lato(
        color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey,
      ),
      hintStyle: GoogleFonts.lato(
        color: (isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey)
            .withOpacity(0.5),
      ),
      errorStyle: GoogleFonts.lato(
        color: AppColors.error,
        fontSize: 12,
      ),
    );
  }

  // ============================================
  // BOTTOM NAVIGATION THEME
  // ============================================

  static BottomNavigationBarThemeData _buildBottomNavTheme({required bool isDark}) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      selectedItemColor: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen,
      unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  // ============================================
  // FAB THEME
  // ============================================

  static FloatingActionButtonThemeData _buildFabTheme({required bool isDark}) {
    return FloatingActionButtonThemeData(
      backgroundColor: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen,
      foregroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      elevation: DesignTokens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
    );
  }

  // ============================================
  // CHIP THEME
  // ============================================

  static ChipThemeData _buildChipTheme({required bool isDark}) {
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.softGreyBg,
      selectedColor: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing12,
        vertical: DesignTokens.spacing8,
      ),
    );
  }

  // ============================================
  // DIALOG THEME
  // ============================================

  static DialogThemeData _buildDialogTheme({required bool isDark}) {
    return DialogThemeData(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      elevation: DesignTokens.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.dialogRadius),
      ),
    );
  }

  // ============================================
  // SNACKBAR THEME
  // ============================================

  static SnackBarThemeData _buildSnackBarTheme({required bool isDark}) {
    return SnackBarThemeData(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.darkText,
      contentTextStyle: GoogleFonts.lato(
        color: isDark ? AppColors.darkTextPrimary : AppColors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // ============================================
  // BOTTOM SHEET THEME
  // ============================================

  static BottomSheetThemeData _buildBottomSheetTheme({required bool isDark}) {
    return BottomSheetThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      elevation: DesignTokens.elevationHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusLarge),
          topRight: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
    );
  }

  // ============================================
  // DIVIDER THEME
  // ============================================

  static DividerThemeData _buildDividerTheme({required bool isDark}) {
    return DividerThemeData(
      color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
      thickness: 1,
      space: DesignTokens.spacing16,
    );
  }
}
