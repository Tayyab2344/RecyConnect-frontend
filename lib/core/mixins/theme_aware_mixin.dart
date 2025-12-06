import 'package:flutter/material.dart';

/// Mixin providing theme-aware utilities
/// DRY: Eliminates repeated Theme.of(context) calls
/// Usage: class MyWidget extends StatefulWidget with ThemeAwareMixin
mixin ThemeAwareMixin<T extends StatefulWidget> on State<T> {
  /// Get current theme
  ThemeData get theme => Theme.of(context);

  /// Get color scheme
  ColorScheme get colors => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Primary color
  Color get primaryColor => colors.primary;

  /// Secondary color
  Color get secondaryColor => colors.secondary;

  /// Background color
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  /// Surface color
  Color get surfaceColor => colors.surface;

  /// Card color
  Color get cardColor => theme.cardColor;

  /// Primary text color
  Color get textColor => textTheme.bodyLarge?.color ?? Colors.black;

  /// Secondary text color
  Color get textSecondaryColor =>
      textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey;

  /// Error color
  Color get errorColor => colors.error;

  /// Divider color
  Color get dividerColor => theme.dividerColor;

  /// Get contrast color (white for dark colors, black for light colors)
  Color contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Get themed shadow
  List<BoxShadow> get themedShadow => [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Get themed border
  Border get themedBorder => Border.all(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        width: 1,
      );
}

/// StatelessWidget version of theme mixin
/// Usage: Build with context and call these helper methods
class ThemeHelper {
  final BuildContext context;

  ThemeHelper(this.context);

  ThemeData get theme => Theme.of(context);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  Color get primaryColor => colors.primary;
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get cardColor => theme.cardColor;
  Color get textColor => textTheme.bodyLarge?.color ?? Colors.black;

  List<BoxShadow> get shadow => [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
