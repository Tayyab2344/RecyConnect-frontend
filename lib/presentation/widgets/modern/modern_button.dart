import 'package:flutter/material.dart';
import '../../../core/theme/app_design_system.dart';

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Gradient? gradient;
  final Color? color;
  final bool outlined;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradient,
    this.color,
    this.outlined = false,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: AppDesignSystem.animationFast,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.outlined ? null : (widget.gradient ?? AppDesignSystem.primaryGradient),
            color: widget.outlined ? Colors.transparent : widget.color,
            borderRadius: AppDesignSystem.borderRadiusMedium,
            border: widget.outlined
                ? Border.all(color: widget.color ?? AppDesignSystem.primary, width: 2)
                : null,
            boxShadow: _isHovered && !widget.outlined
                ? AppDesignSystem.glowShadow(widget.color ?? AppDesignSystem.primary)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: AppDesignSystem.borderRadiusMedium,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacing24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    else ...[
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.outlined
                              ? (widget.color ?? AppDesignSystem.primary)
                              : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppDesignSystem.spacing8),
                      ],
                      Text(
                        widget.text,
                        style: AppDesignSystem.button.copyWith(
                          color: widget.outlined
                              ? (widget.color ?? AppDesignSystem.primary)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
