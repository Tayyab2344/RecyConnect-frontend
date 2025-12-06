import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import 'glassmorphism_decorator.dart';

/// Curved card widget - Base reusable card with curvy design
/// SRP: Only responsible for card appearance
/// Builder pattern available via CurvedCardBuilder
class CurvedCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? shadows;
  final bool hasGlassmorphism;
  final double blurAmount;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Border? border;

  const CurvedCard({
    super.key,
    required this.child,
    this.radius = DesignTokens.cardRadius,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(DesignTokens.spacing16),
    this.margin,
    this.shadows,
    this.hasGlassmorphism = false,
    this.blurAmount = DesignTokens.glassBlurLight,
    this.onTap,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkCard : AppColors.white;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: hasGlassmorphism ? null : (backgroundColor ?? defaultBg),
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: hasGlassmorphism ? null : (shadows ?? _defaultShadows(isDark)),
      ),
      child: child,
    );

    if (hasGlassmorphism) {
      cardContent = GlassmorphismDecorator(
        radius: radius,
        blur: blurAmount,
        child: Container(
          padding: padding,
          child: child,
        ),
      );
    }

    if (margin != null) {
      cardContent = Padding(padding: margin!, child: cardContent);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  List<BoxShadow> _defaultShadows(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Curved card builder - Fluent API for building curved cards
/// Pattern: Builder
/// Benefits: Readability, optional params, immutability
class CurvedCardBuilder {
  double _radius = DesignTokens.cardRadius;
  Color? _backgroundColor;
  bool _hasGlass = false;
  double _blur = DesignTokens.glassBlurLight;
  List<BoxShadow>? _shadows;
  EdgeInsets _padding = const EdgeInsets.all(DesignTokens.spacing16);
  EdgeInsets? _margin;
  Widget? _child;
  VoidCallback? _onTap;
  Gradient? _gradient;
  Border? _border;

  CurvedCardBuilder();

  CurvedCardBuilder withRadius(double radius) {
    _radius = radius;
    return this;
  }

  CurvedCardBuilder withBackground(Color color) {
    _backgroundColor = color;
    return this;
  }

  CurvedCardBuilder withGlassmorphism({double blur = DesignTokens.glassBlurLight}) {
    _hasGlass = true;
    _blur = blur;
    return this;
  }

  CurvedCardBuilder withShadows(List<BoxShadow> shadows) {
    _shadows = shadows;
    return this;
  }

  CurvedCardBuilder withPadding(EdgeInsets padding) {
    _padding = padding;
    return this;
  }

  CurvedCardBuilder withMargin(EdgeInsets margin) {
    _margin = margin;
    return this;
  }

  CurvedCardBuilder withGradient(Gradient gradient) {
    _gradient = gradient;
    return this;
  }

  CurvedCardBuilder withBorder(Border border) {
    _border = border;
    return this;
  }

  CurvedCardBuilder withOnTap(VoidCallback onTap) {
    _onTap = onTap;
    return this;
  }

  CurvedCardBuilder withChild(Widget child) {
    _child = child;
    return this;
  }

  Widget build() {
    return CurvedCard(
      radius: _radius,
      backgroundColor: _backgroundColor,
      hasGlassmorphism: _hasGlass,
      blurAmount: _blur,
      shadows: _shadows,
      padding: _padding,
      margin: _margin,
      gradient: _gradient,
      border: _border,
      onTap: _onTap,
      child: _child ?? const SizedBox(),
    );
  }
}

/// Interactive curved card with selection state
class SelectableCurvedCard extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final Color? selectedBorderColor;
  final double selectedBorderWidth;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsets padding;
  final bool hasGlassmorphism;

  const SelectableCurvedCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.selectedBorderColor,
    this.selectedBorderWidth = 2.5,
    this.onTap,
    this.radius = DesignTokens.cardRadius,
    this.padding = const EdgeInsets.all(DesignTokens.spacing16),
    this.hasGlassmorphism = false,
  });

  @override
  State<SelectableCurvedCard> createState() => _SelectableCurvedCardState();
}

class _SelectableCurvedCardState extends State<SelectableCurvedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = widget.selectedBorderColor ?? primaryColor;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: DesignTokens.animationNormal,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                border: widget.isSelected
                    ? Border.all(
                        color: borderColor,
                        width: widget.selectedBorderWidth,
                      )
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: CurvedCard(
                radius: widget.radius,
                padding: widget.padding,
                hasGlassmorphism: widget.hasGlassmorphism,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
