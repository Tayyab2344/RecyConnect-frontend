import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable RecyConnect Logo Widget
/// Draws the logo with code (geometric leaf-arrows meeting in the center)
/// Can be used at any size throughout the app

class RecyConnectLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animated;
  final Color? holeColor;
  final Color? coreColor;
  
  const RecyConnectLogo({
    super.key,
    this.size = 120,
    this.showText = false,
    this.animated = false,
    this.holeColor,
    this.coreColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedHoleColor = holeColor ?? (isDark ? const Color(0xFF071410) : Colors.white);
    final resolvedCoreColor = coreColor ?? (isDark ? const Color(0xFFF7F5F0) : const Color(0xFF0C241B));

    if (animated) {
      return _AnimatedLogo(
        size: size,
        showText: showText,
        holeColor: resolvedHoleColor,
        coreColor: resolvedCoreColor,
      );
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: RecyConnectLogoPainterStatic(
            size: size,
            holeColor: resolvedHoleColor,
            coreColor: resolvedCoreColor,
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.1),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'recy',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00D2C4), // Vivid electric teal
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'connect',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF7F5F0) : const Color(0xFF0C241B), // Warm sand or Deep Forest Green
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color holeColor;
  final Color coreColor;
  
  const _AnimatedLogo({
    required this.size,
    required this.showText,
    required this.holeColor,
    required this.coreColor,
  });
  
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: RecyConnectLogoPainterStatic(
                size: widget.size,
                rotation: _controller.value * 2 * math.pi, // Spin fully
                holeColor: widget.holeColor,
                coreColor: widget.coreColor,
              ),
            ),
            if (widget.showText) ...[
              SizedBox(height: widget.size * 0.1),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'recy',
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00D2C4), // Vivid electric teal
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'connect',
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF7F5F0) : const Color(0xFF0C241B),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Static painter for the RecyConnect logo using custom geometric leaf-arrows
class RecyConnectLogoPainterStatic extends CustomPainter {
  final double size;
  final double rotation;
  final Color holeColor;
  final Color coreColor;
  
  RecyConnectLogoPainterStatic({
    required this.size,
    this.rotation = 0,
    required this.holeColor,
    required this.coreColor,
  });
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(size / 2, size / 2);
    final baseRadius = size * 0.38;
    
    // Draw leaf-arrows with rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    // Arrow 1: Teal leaf (Left)
    final Path leftLeaf = Path();
    final Paint leftPaint = Paint()
      ..color = const Color(0xFF00D2C4)
      ..style = PaintingStyle.fill;
    _buildLeafShape(leftLeaf, center, baseRadius, isLeft: true);
    canvas.drawPath(leftLeaf, leftPaint);
    
    // Arrow 2: Lime leaf (Right)
    final Path rightLeaf = Path();
    final Paint rightPaint = Paint()
      ..color = const Color(0xFFB5FF00)
      ..style = PaintingStyle.fill;
    _buildLeafShape(rightLeaf, center, baseRadius, isLeft: false);
    canvas.drawPath(rightLeaf, rightPaint);
    
    // Central connection node
    final nodePaint = Paint()
      ..color = holeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.28, nodePaint);
    
    final coreGlowPaint = Paint()
      ..color = coreColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.16, coreGlowPaint);
    
    canvas.restore();
  }
  
  void _buildLeafShape(Path path, Offset center, double radius, {required bool isLeft}) {
    final double sideMultiplier = isLeft ? -1.0 : 1.0;
    final start = Offset(center.dx, center.dy - radius);
    final end = Offset(center.dx, center.dy + radius);
    
    final controlPoint1 = Offset(center.dx + (radius * 1.15 * sideMultiplier), center.dy - (radius * 0.1));
    final controlPoint2 = Offset(center.dx + (radius * 0.3 * sideMultiplier), center.dy + (radius * 0.2));

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, end.dx, end.dy);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, start.dx, start.dy);
    path.close();
  }
  
  @override
  bool shouldRepaint(covariant RecyConnectLogoPainterStatic oldDelegate) {
    return rotation != oldDelegate.rotation ||
           holeColor != oldDelegate.holeColor ||
           coreColor != oldDelegate.coreColor;
  }
}
