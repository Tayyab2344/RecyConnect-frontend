import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Collection of Reusable Animated Components
/// Production-ready widgets with smooth animations and interactions

// ============================================================================
// ANIMATED BUTTON
// ============================================================================

/// Modern Gradient Button with Press Animation
class AnimatedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final double borderRadius;

  const AnimatedGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 48,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.isDisabled || widget.isLoading
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isDisabled || widget.isLoading
            ? null
            : (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: widget.height,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            gradient: widget.isDisabled
                ? const LinearGradient(
                    colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                  )
                : gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isDisabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(
                        _isHovered ? 0.4 : 0.2,
                      ),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: widget.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 0.5,
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

// ============================================================================
// ANIMATED COUNTER
// ============================================================================

/// Animated Number Counter
class AnimatedCounter extends StatefulWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle? textStyle;
  final Duration duration;
  final int decimals;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.textStyle,
    this.duration = const Duration(milliseconds: 800),
    this.decimals = 0,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(begin: _previousValue, end: widget.value)
          .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toStringAsFixed(widget.decimals)}${widget.suffix}',
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }
}

// ============================================================================
// SKELETON LOADERS
// ============================================================================

/// Versatile Skeleton Loader
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    Key? key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for Text Lines
class SkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;

  const SkeletonText({
    Key? key,
    this.lines = 3,
    this.lineHeight = 16,
    this.spacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        // Last line is shorter
        final width = index == lines - 1 ? 0.7 : 1.0;
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: FractionallySizedBox(
            widthFactor: width,
            child: SkeletonLoader(height: lineHeight, borderRadius: 4),
          ),
        );
      }),
    );
  }
}

/// Skeleton for Avatar
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    Key? key,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ============================================================================
// PROGRESS INDICATORS
// ============================================================================

/// Linear Progress Bar
class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color? color;
  final Duration duration;
  final double borderRadius;

  const AnimatedProgressBar({
    Key? key,
    required this.value,
    this.height = 6,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.gradient,
    this.color,
    this.duration = const Duration(milliseconds: 500),
    this.borderRadius = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: duration,
            curve: Curves.easeOutCubic,
            widthFactor: value.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ??
                    (color != null
                        ? LinearGradient(colors: [color!, color!])
                        : const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular Progress Indicator (Custom)
class AnimatedCircularProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color? color;
  final Widget? child;

  const AnimatedCircularProgress({
    Key? key,
    required this.value,
    this.size = 100,
    this.strokeWidth = 8,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.gradient,
    this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          value: value,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor,
          gradient: gradient,
          color: color ?? const Color(0xFF10B981),
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color color;

  _CircularProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.gradient,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      progressPaint.shader = gradient!.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    } else {
      progressPaint.color = color;
    }

    final sweepAngle = 2 * 3.14159 * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

// ============================================================================
// ANIMATED BADGE
// ============================================================================

/// Notification Badge with Pulse Animation
class PulseBadge extends StatefulWidget {
  final String text;
  final Color color;
  final double size;

  const PulseBadge({
    Key? key,
    required this.text,
    this.color = const Color(0xFFEF4444),
    this.size = 20,
  }) : super(key: key);

  @override
  State<PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<PulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.color, widget.color.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// RIPPLE EFFECT
// ============================================================================

/// Material Ripple Effect Widget
class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color rippleColor;
  final double borderRadius;

  const RippleEffect({
    Key? key,
    required this.child,
    required this.onTap,
    this.rippleColor = const Color(0xFF10B981),
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        splashColor: widget.rippleColor.withOpacity(0.2),
        highlightColor: widget.rippleColor.withOpacity(0.1),
        child: widget.child,
      ),
    );
  }
}
