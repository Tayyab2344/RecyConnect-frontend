// dart:ui import removed - BackdropFilter no longer used for performance
import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

/// Glassmorphism decorator - Adds frosted glass effect
/// Performance-optimized version without BackdropFilter for low-end devices
/// Pattern: Decorator
/// SRP: Only adds glass effect to child widget
class GlassmorphismDecorator extends StatelessWidget {
  final Widget child;
  final double blur; // Kept for API compatibility but ignored for performance
  final double radius;
  final Color? tintColor;
  final double tintOpacity;
  final double borderOpacity;
  final bool hasBorder;

  const GlassmorphismDecorator({
    super.key,
    required this.child,
    this.blur = DesignTokens.glassBlurLight, // Ignored for performance
    this.radius = DesignTokens.radiusMedium,
    this.tintColor,
    this.tintOpacity = 0.1,
    this.borderOpacity = 0.2,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTint = isDark ? Colors.white : Colors.white;

    // Performance optimization: Using simple Container instead of BackdropFilter
    // This maintains the visual style while being much faster on low-end devices
    return Container(
      decoration: BoxDecoration(
        color: (tintColor ?? defaultTint).withValues(alpha: tintOpacity),
        borderRadius: BorderRadius.circular(radius),
        border: hasBorder
            ? Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: 1,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

/// Glass container - Pre-configured glassmorphism container
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double radius;
  final double blur;
  final GlassStyle style;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.radius = DesignTokens.radiusMedium,
    this.blur = DesignTokens.glassBlurLight,
    this.style = GlassStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color tintColor;
    double tintOpacity;
    double borderOpacity;

    switch (style) {
      case GlassStyle.light:
        tintColor = Colors.white;
        tintOpacity = isDark ? 0.1 : 0.15;
        borderOpacity = isDark ? 0.15 : 0.25;
        break;
      case GlassStyle.dark:
        tintColor = Colors.black;
        tintOpacity = isDark ? 0.3 : 0.1;
        borderOpacity = 0.1;
        break;
      case GlassStyle.colored:
        tintColor = Theme.of(context).colorScheme.primary;
        tintOpacity = 0.1;
        borderOpacity = 0.2;
        break;
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: GlassmorphismDecorator(
        blur: blur,
        radius: radius,
        tintColor: tintColor,
        tintOpacity: tintOpacity,
        borderOpacity: borderOpacity,
        child: Padding(
          padding: padding ?? EdgeInsets.all(DesignTokens.spacing16),
          child: child,
        ),
      ),
    );
  }
}

enum GlassStyle { light, dark, colored }

/// Frosted glass card - Card with glassmorphism effect
class FrostedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double radius;
  final VoidCallback? onTap;
  final GlassStyle style;

  const FrostedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = DesignTokens.cardRadius,
    this.onTap,
    this.style = GlassStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = GlassContainer(
      radius: radius,
      padding: padding,
      margin: margin,
      style: style,
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
