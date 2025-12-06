import 'package:flutter/material.dart';
import '../../../core/theme/app_design_system.dart';

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool hoverable;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.hoverable = false,
    this.onTap,
    this.color,
    this.gradient,
  }) : super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.hoverable ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.hoverable ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: AppDesignSystem.animationNormal,
        curve: AppDesignSystem.animationCurve,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(AppDesignSystem.spacing20),
            decoration: BoxDecoration(
              color: widget.gradient == null ? (widget.color ?? AppDesignSystem.surface) : null,
              gradient: widget.gradient,
              borderRadius: AppDesignSystem.borderRadiusLarge,
              boxShadow: _isHovered
                  ? AppDesignSystem.hoverShadow
                  : AppDesignSystem.cardShadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
