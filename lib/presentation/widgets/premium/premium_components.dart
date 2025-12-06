import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_system.dart';

// ═══════════════════════════════════════════════════════════
// 🎯 PREMIUM BUTTON
// ═══════════════════════════════════════════════════════════

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final bool enabled;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.enabled = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PremiumDesignSystem.animationFast,
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

  @override
  Widget build(BuildContext context) {
    final gradient =
        widget.gradient ?? PremiumDesignSystem.primaryGradient;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (widget.enabled && !widget.isLoading && widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: PremiumDesignSystem.animationNormal,
            curve: PremiumDesignSystem.animationCurve,
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.enabled ? gradient : null,
              color: widget.enabled ? null : Colors.grey.shade300,
              borderRadius: PremiumDesignSystem.borderRadiusLarge,
              boxShadow: widget.enabled && _isHovered
                  ? PremiumDesignSystem.elevatedShadow
                  : PremiumDesignSystem.softShadowMedium,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled && !widget.isLoading
                    ? widget.onPressed
                    : null,
                borderRadius: PremiumDesignSystem.borderRadiusLarge,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: widget.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: PremiumDesignSystem.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 💎 GLASS CARD
// ═══════════════════════════════════════════════════════════

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableHover;
  final Color? color;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.enableHover = true,
    this.color,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        if (widget.enableHover) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.enableHover) setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: PremiumDesignSystem.animationNormal,
        curve: PremiumDesignSystem.animationCurve,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -4.0, 0.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius:
              widget.borderRadius ?? PremiumDesignSystem.borderRadiusLarge,
          boxShadow: _isHovered
              ? PremiumDesignSystem.elevatedShadow
              : PremiumDesignSystem.softShadowMedium,
        ),
        child: ClipRRect(
          borderRadius:
              widget.borderRadius ?? PremiumDesignSystem.borderRadiusLarge,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: widget.color ??
                    (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.7)),
                borderRadius: widget.borderRadius ??
                    PremiumDesignSystem.borderRadiusLarge,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: widget.borderRadius ??
                      PremiumDesignSystem.borderRadiusLarge,
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.all(PremiumDesignSystem.spacing20),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📊 PREMIUM STAT CARD
// ═══════════════════════════════════════════════════════════

class PremiumStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? trend;
  final bool? isPositive;
  final Gradient gradient;
  final Color? iconColor;

  const PremiumStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trend,
    this.isPositive,
    required this.gradient,
    this.iconColor,
  });

  @override
  State<PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<PremiumStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PremiumDesignSystem.animationSlow,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: PremiumDesignSystem.animationCurveElastic,
      ),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: PremiumDesignSystem.animationNormal,
          curve: PremiumDesignSystem.animationCurve,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -8.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: PremiumDesignSystem.borderRadiusXLarge,
            boxShadow: _isHovered
                ? PremiumDesignSystem.elevatedShadow
                : PremiumDesignSystem.softShadowMedium,
          ),
          child: ClipRRect(
            borderRadius: PremiumDesignSystem.borderRadiusXLarge,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? PremiumDesignSystem.darkSurface
                    : Colors.white,
                borderRadius: PremiumDesignSystem.borderRadiusXLarge,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PremiumDesignSystem.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icon with gradient background
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                              borderRadius:
                                  PremiumDesignSystem.borderRadiusMedium,
                              boxShadow: PremiumDesignSystem.glowEffect(
                                widget.iconColor ?? PremiumDesignSystem.primary,
                                intensity: 0.3,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        // Trend indicator
                        if (widget.trend != null)
                          AnimatedContainer(
                            duration: PremiumDesignSystem.animationNormal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (widget.isPositive ?? true)
                                  ? PremiumDesignSystem.success.withOpacity(0.1)
                                  : PremiumDesignSystem.error.withOpacity(0.1),
                              borderRadius:
                                  PremiumDesignSystem.borderRadiusSmall,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (widget.isPositive ?? true)
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 12,
                                  color: (widget.isPositive ?? true)
                                      ? PremiumDesignSystem.success
                                      : PremiumDesignSystem.error,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.trend!,
                                  style: PremiumDesignSystem.caption.copyWith(
                                    color: (widget.isPositive ?? true)
                                        ? PremiumDesignSystem.success
                                        : PremiumDesignSystem.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: PremiumDesignSystem.spacing12),
                    // Value
                    Text(
                      widget.value,
                      style: PremiumDesignSystem.h2.copyWith(
                        color: isDark
                            ? PremiumDesignSystem.darkTextPrimary
                            : PremiumDesignSystem.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PremiumDesignSystem.spacing4),
                    // Title
                    Text(
                      widget.title,
                      style: PremiumDesignSystem.body2.copyWith(
                        color: isDark
                            ? PremiumDesignSystem.darkTextSecondary
                            : PremiumDesignSystem.textSecondary,
                      ),
                    ),
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

// ═══════════════════════════════════════════════════════════
// 🎨 PREMIUM APP BAR
// ═══════════════════════════════════════════════════════════

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showNotificationBadge;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        color: isDark ? PremiumDesignSystem.darkSurface : null,
        boxShadow: PremiumDesignSystem.softShadowSmall,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PremiumDesignSystem.spacing16,
            vertical: PremiumDesignSystem.spacing8,
          ),
          child: Row(
            children: [
              // Leading
              if (leading != null) leading!,
              // Title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: PremiumDesignSystem.spacing12),
                  child: Text(
                    title,
                    style: PremiumDesignSystem.h3.copyWith(
                      color: isDark
                          ? PremiumDesignSystem.darkTextPrimary
                          : PremiumDesignSystem.textPrimary,
                    ),
                  ),
                ),
              ),
              // Actions
              if (showNotificationBadge) _buildNotificationButton(context),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).brightness == Brightness.dark
                ? PremiumDesignSystem.darkTextPrimary
                : PremiumDesignSystem.textPrimary,
          ),
          onPressed: onNotificationTap,
        ),
        if (notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: PremiumDesignSystem.errorGradient,
                shape: BoxShape.circle,
                boxShadow: PremiumDesignSystem.glowEffect(
                  PremiumDesignSystem.error,
                  intensity: 0.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: PremiumDesignSystem.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ✨ ANIMATED BADGE
// ═══════════════════════════════════════════════════════════

class AnimatedBadge extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  const AnimatedBadge({
    super.key,
    required this.text,
    this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PremiumDesignSystem.animationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: PremiumDesignSystem.animationNormal,
            padding: EdgeInsets.symmetric(
              horizontal: widget.icon != null ? 12 : 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: PremiumDesignSystem.borderRadiusXLarge,
              boxShadow: _isHovered
                  ? PremiumDesignSystem.elevatedShadow
                  : PremiumDesignSystem.softShadowSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.text,
                  style: PremiumDesignSystem.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 🎬 SHIMMER LOADING
// ═══════════════════════════════════════════════════════════

class PremiumShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const PremiumShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<PremiumShimmer> createState() => _PremiumShimmerState();
}

class _PremiumShimmerState extends State<PremiumShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? PremiumDesignSystem.borderRadiusMedium,
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: isDark
                  ? [
                      PremiumDesignSystem.darkSurface,
                      PremiumDesignSystem.darkSurfaceVariant,
                      PremiumDesignSystem.darkSurface,
                    ]
                  : [
                      Colors.grey.shade200,
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                    ],
            ),
          ),
        );
      },
    );
  }
}
