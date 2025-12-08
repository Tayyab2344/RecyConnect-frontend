import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Widget extensions for cleaner, more readable code
/// DRY: Common operations as chainable methods
/// Usage: Text('Hello').padded().centered()
extension WidgetExtensions on Widget {
  /// Add padding around widget
  Widget padded([EdgeInsets padding = const EdgeInsets.all(DesignTokens.spacing16)]) {
    return Padding(padding: padding, child: this);
  }

  /// Add horizontal padding
  Widget paddedH([double value = DesignTokens.spacing16]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Add vertical padding
  Widget paddedV([double value = DesignTokens.spacing16]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  /// Center the widget
  Widget centered() => Center(child: this);

  /// Expand the widget
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Make flexible
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  /// Apply opacity
  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Wrap in a card with radius
  Widget card({
    double radius = DesignTokens.cardRadius,
    Color? color,
    EdgeInsets? padding,
  }) {
    Widget result = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: this,
    );
    if (padding != null) {
      result = Padding(padding: padding, child: result);
    }
    return result;
  }

  /// Apply glassmorphism effect
  Widget glassmorphism({
    double blur = DesignTokens.glassBlurLight,
    double radius = DesignTokens.radiusMedium,
    Color? tint,
    double opacity = DesignTokens.glassOpacity,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (tint ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(DesignTokens.glassBorderOpacity),
              width: 1,
            ),
          ),
          child: this,
        ),
      ),
    );
  }

  /// Add shadow
  Widget withShadow({
    Color color = Colors.black,
    double blurRadius = 10,
    Offset offset = const Offset(0, 4),
    double opacity = 0.1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Align widget
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);

  /// Safe area wrapper
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: this,
    );
  }

  /// Make widget tappable with ripple
  Widget onTap(VoidCallback? onTap, {double radius = DesignTokens.radiusMedium}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: this,
      ),
    );
  }

  /// Add hero animation tag
  Widget hero(String tag) => Hero(tag: tag, child: this);

  /// Constrain width
  Widget constrainedWidth({double? min, double? max}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: min ?? 0,
        maxWidth: max ?? double.infinity,
      ),
      child: this,
    );
  }

  /// Constrain height
  Widget constrainedHeight({double? min, double? max}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: min ?? 0,
        maxHeight: max ?? double.infinity,
      ),
      child: this,
    );
  }
}

/// Spacing extensions for cleaner code
/// Usage: 16.h for SizedBox with height 16
extension SpacingExtensions on num {
  /// Vertical spacing
  SizedBox get h => SizedBox(height: toDouble());

  /// Horizontal spacing
  SizedBox get w => SizedBox(width: toDouble());

  /// Square box
  SizedBox get box => SizedBox(width: toDouble(), height: toDouble());
}

/// Duration extensions
extension DurationExtensions on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
}

/// Border radius extensions
extension BorderRadiusExtensions on double {
  BorderRadius get circular => BorderRadius.circular(this);
  BorderRadius get topOnly => BorderRadius.only(
        topLeft: Radius.circular(this),
        topRight: Radius.circular(this),
      );
  BorderRadius get bottomOnly => BorderRadius.only(
        bottomLeft: Radius.circular(this),
        bottomRight: Radius.circular(this),
      );
}

/// EdgeInsets extensions
extension EdgeInsetsExtensions on double {
  EdgeInsets get all => EdgeInsets.all(this);
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: this);
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: this);
  EdgeInsets get left => EdgeInsets.only(left: this);
  EdgeInsets get right => EdgeInsets.only(right: this);
  EdgeInsets get top => EdgeInsets.only(top: this);
  EdgeInsets get bottom => EdgeInsets.only(bottom: this);
}

/// Color extensions
extension ColorExtensions on Color {
  /// Darken color by percentage (0-100)
  Color darken([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final factor = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * factor).round(),
      (green * factor).round(),
      (blue * factor).round(),
    );
  }

  /// Lighten color by percentage (0-100)
  Color lighten([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final factor = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * factor).round(),
      green + ((255 - green) * factor).round(),
      blue + ((255 - blue) * factor).round(),
    );
  }
}

/// String extensions for validation
extension StringExtensions on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPhone => RegExp(r'^\d{10,}$').hasMatch(this);

  bool get isValidPassword => length >= 8;

  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase =>
      split(' ').map((word) => word.capitalize).join(' ');
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Separate items with a widget
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) return [];
    final List<Widget> result = [];
    for (int i = 0; i < length; i++) {
      result.add(this[i] as Widget);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
