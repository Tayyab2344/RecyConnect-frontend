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
                'Recy',
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4CAF50), // Premium Green
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Connect',
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF2196F3) : const Color(0xFF0D47A1), // Accent Blue / Dark Blue
                  letterSpacing: -0.5,
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
                    'Recy',
                    style: TextStyle(
                      fontSize: widget.size * 0.24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4CAF50), // Premium Green
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: widget.size * 0.24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF2196F3) : const Color(0xFF0D47A1), // Accent Blue
                      letterSpacing: -0.5,
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
    final baseRadius = size * 0.45; // slightly larger to fill space
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final loopCenter = Offset(center.dx + baseRadius * 0.05, center.dy - baseRadius * 0.25);
    final loopRadiusOuter = baseRadius * 0.75;
    final loopRadiusInner = baseRadius * 0.45;

    // 1. R Loop Path (Green Gradient)
    final Path rPath = Path();
    rPath.moveTo(loopCenter.dx - loopRadiusOuter, loopCenter.dy + baseRadius * 0.1);
    rPath.quadraticBezierTo(
      loopCenter.dx - loopRadiusOuter * 0.9, loopCenter.dy - loopRadiusOuter * 0.9,
      loopCenter.dx, loopCenter.dy - loopRadiusOuter
    );
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusOuter * 1.0, loopCenter.dy - loopRadiusOuter * 0.9,
      loopCenter.dx + loopRadiusOuter * 0.95, loopCenter.dy + baseRadius * 0.05
    );
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusOuter * 0.8, loopCenter.dy + loopRadiusOuter * 0.7,
      center.dx + baseRadius * 0.65, center.dy + baseRadius * 0.85 // leg outer
    );
    rPath.lineTo(center.dx + baseRadius * 0.35, center.dy + baseRadius * 0.85); // leg bottom
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusInner * 0.8, loopCenter.dy + loopRadiusInner * 0.9,
      loopCenter.dx + loopRadiusInner * 0.7, loopCenter.dy + baseRadius * 0.1 // leg inner
    );
    rPath.quadraticBezierTo(
      loopCenter.dx + loopRadiusInner * 0.8, loopCenter.dy - loopRadiusInner * 0.8,
      loopCenter.dx, loopCenter.dy - loopRadiusInner
    );
    rPath.quadraticBezierTo(
      loopCenter.dx - loopRadiusInner * 0.8, loopCenter.dy - loopRadiusInner * 0.6,
      loopCenter.dx - loopRadiusInner * 0.9, loopCenter.dy + baseRadius * 0.2
    );
    rPath.quadraticBezierTo(
      loopCenter.dx - loopRadiusOuter * 0.95, loopCenter.dy + baseRadius * 0.35,
      loopCenter.dx - loopRadiusOuter, loopCenter.dy + baseRadius * 0.1
    );
    rPath.close();

    final Paint rPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8BC34A),
          Color(0xFF4CAF50),
          Color(0xFF2E7D32),
        ],
      ).createShader(Rect.fromCircle(center: loopCenter, radius: loopRadiusOuter))
      ..style = PaintingStyle.fill;
    canvas.drawPath(rPath, rPaint);

    // 2. Green Leaf inside loop
    final Path leafPath = Path();
    final leafStart = Offset(loopCenter.dx - loopRadiusInner * 0.2, loopCenter.dy + loopRadiusInner * 0.4);
    final leafEnd = Offset(loopCenter.dx + loopRadiusInner * 0.5, loopCenter.dy - loopRadiusInner * 0.5);
    final leafControl1 = Offset(loopCenter.dx + loopRadiusInner * 0.6, loopCenter.dy + loopRadiusInner * 0.1);
    final leafControl2 = Offset(loopCenter.dx - loopRadiusInner * 0.4, loopCenter.dy - loopRadiusInner * 0.3);

    leafPath.moveTo(leafStart.dx, leafStart.dy);
    leafPath.quadraticBezierTo(leafControl1.dx, leafControl1.dy, leafEnd.dx, leafEnd.dy);
    leafPath.quadraticBezierTo(leafControl2.dx, leafControl2.dy, leafStart.dx, leafStart.dy);
    leafPath.close();

    final Paint leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF4CAF50),
          Color(0xFF8BC34A),
        ],
      ).createShader(Rect.fromPoints(leafStart, leafEnd))
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafPaint);

    // 3. Blue Circuit Nodes on the left
    final Paint tracePaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseRadius * 0.045
      ..strokeCap = StrokeCap.round;

    final Paint nodePaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    final startNode = Offset(loopCenter.dx - loopRadiusOuter * 0.6, loopCenter.dy + baseRadius * 0.25);

    // Trace 1: Top-left
    final Path path1 = Path();
    path1.moveTo(startNode.dx, startNode.dy);
    final node1 = Offset(loopCenter.dx - baseRadius * 0.95, loopCenter.dy - baseRadius * 0.15);
    path1.cubicTo(
      startNode.dx - baseRadius * 0.2, startNode.dy - baseRadius * 0.1,
      node1.dx + baseRadius * 0.1, node1.dy + baseRadius * 0.2,
      node1.dx, node1.dy
    );
    canvas.drawPath(path1, tracePaint);
    canvas.drawCircle(node1, baseRadius * 0.07, nodePaint);

    // Trace 2: Middle-left
    final Path path2 = Path();
    path2.moveTo(startNode.dx + baseRadius * 0.05, startNode.dy + baseRadius * 0.05);
    final node2 = Offset(loopCenter.dx - baseRadius * 1.0, loopCenter.dy + baseRadius * 0.15);
    path2.quadraticBezierTo(
      startNode.dx - baseRadius * 0.25, startNode.dy + baseRadius * 0.05,
      node2.dx, node2.dy
    );
    canvas.drawPath(path2, tracePaint);
    canvas.drawCircle(node2, baseRadius * 0.07, nodePaint);

    // Trace 3: Bottom-left
    final Path path3 = Path();
    path3.moveTo(startNode.dx + baseRadius * 0.1, startNode.dy + baseRadius * 0.1);
    final node3 = Offset(loopCenter.dx - baseRadius * 0.8, loopCenter.dy + baseRadius * 0.45);
    path3.quadraticBezierTo(
      startNode.dx - baseRadius * 0.1, startNode.dy + baseRadius * 0.2,
      node3.dx, node3.dy
    );
    canvas.drawPath(path3, tracePaint);
    canvas.drawCircle(node3, baseRadius * 0.07, nodePaint);

    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant RecyConnectLogoPainterStatic oldDelegate) {
    return rotation != oldDelegate.rotation ||
           holeColor != oldDelegate.holeColor ||
           coreColor != oldDelegate.coreColor;
  }
}
