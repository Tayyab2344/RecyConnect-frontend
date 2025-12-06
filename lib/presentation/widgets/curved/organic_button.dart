import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';

/// Organic button - Rounded button with micro animations
/// Features: Scale press animation, gradient support, loading state
class OrganicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final OrganicButtonStyle style;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool iconTrailing;
  final double? width;
  final double height;

  const OrganicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = OrganicButtonStyle.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconTrailing = false,
    this.width,
    this.height = DesignTokens.buttonHeight,
  });

  @override
  State<OrganicButton> createState() => _OrganicButtonState();
}

class _OrganicButtonState extends State<OrganicButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final config = _getStyleConfig(context);

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => _controller.forward() : null,
      onTapUp: _isEnabled
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: DesignTokens.animationNormal,
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: config.hasGradient ? null : config.backgroundColor,
            gradient: config.gradient,
            borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
            border: config.border,
            boxShadow: _isEnabled
                ? [
                    BoxShadow(
                      color: (config.shadowColor ?? config.backgroundColor)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: AnimatedOpacity(
            duration: DesignTokens.animationFast,
            opacity: _isEnabled ? 1.0 : DesignTokens.opacityDisabled,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(config.textColor),
                      ),
                    )
                  : _buildContent(config),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(_ButtonStyleConfig config) {
    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: config.textColor,
        letterSpacing: 0.5,
      ),
    );

    if (widget.icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      widget.icon,
      color: config.textColor,
      size: 20,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.iconTrailing
          ? [textWidget, const SizedBox(width: 8), iconWidget]
          : [iconWidget, const SizedBox(width: 8), textWidget],
    );
  }

  _ButtonStyleConfig _getStyleConfig(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen;

    switch (widget.style) {
      case OrganicButtonStyle.primary:
        return _ButtonStyleConfig(
          backgroundColor: primaryColor,
          textColor: isDark ? AppColors.darkBackground : Colors.white,
          shadowColor: primaryColor,
        );
      case OrganicButtonStyle.secondary:
        return _ButtonStyleConfig(
          backgroundColor: Colors.transparent,
          textColor: primaryColor,
          border: Border.all(color: primaryColor, width: 2),
        );
      case OrganicButtonStyle.gradient:
        return _ButtonStyleConfig(
          backgroundColor: primaryColor,
          textColor: Colors.white,
          gradient: AppColors.primaryGradient,
          hasGradient: true,
          shadowColor: primaryColor,
        );
      case OrganicButtonStyle.soft:
        return _ButtonStyleConfig(
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          textColor: primaryColor,
        );
      case OrganicButtonStyle.danger:
        return _ButtonStyleConfig(
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          shadowColor: AppColors.error,
        );
      case OrganicButtonStyle.ghost:
        return _ButtonStyleConfig(
          backgroundColor: Colors.transparent,
          textColor: primaryColor,
        );
    }
  }
}

class _ButtonStyleConfig {
  final Color backgroundColor;
  final Color textColor;
  final Gradient? gradient;
  final Border? border;
  final Color? shadowColor;
  final bool hasGradient;

  _ButtonStyleConfig({
    required this.backgroundColor,
    required this.textColor,
    this.gradient,
    this.border,
    this.shadowColor,
    this.hasGradient = false,
  });
}

enum OrganicButtonStyle {
  primary,
  secondary,
  gradient,
  soft,
  danger,
  ghost,
}

/// Icon button with organic styling
class OrganicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final bool hasShadow;

  const OrganicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.hasShadow = true,
  });

  @override
  State<OrganicIconButton> createState() => _OrganicIconButtonState();
}

class _OrganicIconButtonState extends State<OrganicIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.darkCard : Colors.white);
    final fgColor = widget.iconColor ??
        (isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen);

    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel:
          widget.onPressed != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: widget.hasShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: fgColor,
            size: widget.iconSize,
          ),
        ),
      ),
    );
  }
}

/// FAB style organic button
class OrganicFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isExtended;

  const OrganicFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.backgroundColor,
    this.iconColor,
    this.isExtended = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen);
    final fgColor = iconColor ??
        (isDark ? AppColors.darkBackground : Colors.white);

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 4,
        icon: Icon(icon),
        label: Text(
          label!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 4,
      child: Icon(icon),
    );
  }
}
