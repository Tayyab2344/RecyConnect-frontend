import 'package:flutter/material.dart';

/// Extension for easy access to theme colors
///
/// Usage:
/// ```dart
/// Container(
///   color: context.surfaceColor,
///   child: Text('Hello', style: TextStyle(color: context.textPrimary)),
/// )
/// ```
extension ThemeColors on BuildContext {
  // Quick access to theme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // Theme mode check
  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isLightMode => theme.brightness == Brightness.light;

  // Primary colors
  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;

  // Background colors
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get surfaceColor => colorScheme.surface;
  Color get cardColor => theme.cardTheme.color ?? (isDarkMode ? const Color(0xFF2D2D2D) : Colors.white);

  // Text colors
  Color get textPrimary => colorScheme.onSurface;
  Color get textSecondary => textTheme.bodyMedium?.color ?? (isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280));
  Color get textLight => textTheme.bodySmall?.color ?? (isDarkMode ? const Color(0xFF808080) : const Color(0xFF9CA3AF));

  // Border colors
  Color get borderColor => theme.dividerTheme.color ?? (isDarkMode ? const Color(0xFF404040) : const Color(0xFFE5E7EB));
  Color get dividerColor => theme.dividerTheme.color ?? (isDarkMode ? const Color(0xFF505050) : const Color(0xFFD1D5DB));

  // Icon color
  Color get iconColor => theme.iconTheme.color ?? textSecondary;

  // AppBar colors
  Color get appBarBackgroundColor => theme.appBarTheme.backgroundColor ?? (isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF10B981));
  Color get appBarForegroundColor => theme.appBarTheme.foregroundColor ?? Colors.white;
}
