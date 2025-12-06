import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 3D Tilt Card Effect
///
/// A widget that applies a 3D tilt effect to its child based on pointer position.
/// Perfect for dashboard cards, feature highlights, and interactive elements.
///
/// Usage:
/// ```dart
/// TiltCard(
///   maxTilt: 0.05,  // ~3 degrees rotation
///   child: Container(
///     width: 300,
///     height: 200,
///     decoration: BoxDecoration(...),
///     child: YourContent(),
///   ),
/// );
/// ```
class TiltCard extends StatefulWidget {
  final Widget child;

  /// Maximum tilt angle in radians (default: 0.05 = ~3 degrees)
  final double maxTilt;

  /// Enable/disable tilt effect (useful for mobile)
  final bool enabled;

  /// Duration of the tilt animation
  final Duration duration;

  /// Animation curve
  final Curve curve;

  /// Whether to add elevation (scale) on hover
  final bool addElevation;

  const TiltCard({
    Key? key,
    required this.child,
    this.maxTilt = 0.05,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.addElevation = true,
  }) : super(key: key);

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  double _scale = 1.0;
  bool _isHovered = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent details, BoxConstraints constraints) {
    if (!widget.enabled) return;

    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Calculate rotation based on pointer position
    final centerX = width / 2;
    final centerY = height / 2;
    final deltaX = (x - centerX) / centerX;
    final deltaY = (y - centerY) / centerY;

    setState(() {
      // Apply tilt with max angle limit
      _rotateY = deltaX * widget.maxTilt;
      _rotateX = -deltaY * widget.maxTilt;
      _isHovered = true;
    });

    if (widget.addElevation) {
      _controller.forward();
    }
  }

  void _onPointerExit(PointerExitEvent event) {
    setState(() {
      _rotateX = 0.0;
      _rotateY = 0.0;
      _isHovered = false;
    });

    if (widget.addElevation) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _onPointerMove(event, constraints),
          onExit: _onPointerExit,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return AnimatedContainer(
                duration: widget.duration,
                curve: widget.curve,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateX(_rotateX)
                  ..rotateY(_rotateY)
                  ..scale(widget.addElevation ? _scaleAnimation.value : 1.0),
                transformAlignment: Alignment.center,
                child: widget.child,
              );
            },
          ),
        );
      },
    );
  }
}

/// Tilt Card with Shadow Animation
///
/// Extends TiltCard with animated shadow that follows the tilt direction
class TiltCardWithShadow extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final bool enabled;
  final Color shadowColor;
  final double maxShadowOffset;

  const TiltCardWithShadow({
    Key? key,
    required this.child,
    this.maxTilt = 0.05,
    this.enabled = true,
    this.shadowColor = const Color(0xFF10B981),
    this.maxShadowOffset = 12.0,
  }) : super(key: key);

  @override
  State<TiltCardWithShadow> createState() => _TiltCardWithShadowState();
}

class _TiltCardWithShadowState extends State<TiltCardWithShadow> {
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  double _shadowX = 0.0;
  double _shadowY = 0.0;

  void _onPointerMove(PointerEvent details, BoxConstraints constraints) {
    if (!widget.enabled) return;

    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    final centerX = width / 2;
    final centerY = height / 2;
    final deltaX = (x - centerX) / centerX;
    final deltaY = (y - centerY) / centerY;

    setState(() {
      _rotateY = deltaX * widget.maxTilt;
      _rotateX = -deltaY * widget.maxTilt;

      // Shadow moves opposite to tilt for depth effect
      _shadowX = -deltaX * widget.maxShadowOffset;
      _shadowY = -deltaY * widget.maxShadowOffset;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    setState(() {
      _rotateX = 0.0;
      _rotateY = 0.0;
      _shadowX = 0.0;
      _shadowY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _onPointerMove(event, constraints),
          onExit: _onPointerExit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_rotateX)
              ..rotateY(_rotateY),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor.withOpacity(0.3),
                  blurRadius: 24,
                  offset: Offset(_shadowX, _shadowY + 8),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Simple 3D Lift Effect (Mobile-Friendly Alternative)
///
/// Simpler effect for mobile devices - just scale without rotation
class LiftCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const LiftCard({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<LiftCard> createState() => _LiftCardState();
}

class _LiftCardState extends State<LiftCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        transform: Matrix4.identity()
          ..translate(0.0, _isPressed ? 2.0 : 0.0)
          ..scale(_isPressed ? 0.98 : 1.0),
        child: AnimatedContainer(
          duration: widget.duration,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.15),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
