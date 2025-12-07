import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable RecyConnect Logo Widget
/// Draws the logo with code (recycling arrows + circuit board)
/// Can be used at any size throughout the app

class RecyConnectLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animated;
  
  const RecyConnectLogo({
    super.key,
    this.size = 120,
    this.showText = false,
    this.animated = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (animated) {
      return _AnimatedLogo(size: size, showText: showText);
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: RecyConnectLogoPainterStatic(size: size),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.1),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF333333),
              ],
              stops: [0.35, 0.35],
            ).createShader(bounds),
            child: Text(
              'RecyConnect',
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  
  const _AnimatedLogo({required this.size, required this.showText});
  
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
                rotation: _controller.value * 0.1,
              ),
            ),
            if (widget.showText) ...[
              SizedBox(height: widget.size * 0.1),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF42A5F5),
                    Color(0xFF333333),
                  ],
                  stops: [0.35, 0.35],
                ).createShader(bounds),
                child: Text(
                  'RecyConnect',
                  style: TextStyle(
                    fontSize: widget.size * 0.22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Static painter for the RecyConnect logo
class RecyConnectLogoPainterStatic extends CustomPainter {
  final double size;
  final double rotation;
  
  RecyConnectLogoPainterStatic({
    required this.size,
    this.rotation = 0,
  });
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(size / 2, size / 2);
    final logoRadius = size * 0.38;
    final circuitRadius = size * 0.2;
    
    // Draw circuit board pattern
    _drawCircuitBoard(canvas, center, circuitRadius);
    
    // Draw recycling arrows with rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    _drawGreenArrow(canvas, center, logoRadius);
    _drawBlueArrow(canvas, center, logoRadius);
    
    canvas.restore();
  }
  
  void _drawCircuitBoard(Canvas canvas, Offset center, double radius) {
    // Central core
    final corePaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final coreGlowPaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(center, size * 0.08, coreGlowPaint);
    
    // Concentric circles
    final ringPaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.008;
    
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, size * (0.04 + i * 0.03), ringPaint);
    }
    
    // Core center
    canvas.drawCircle(center, size * 0.035, corePaint);
    canvas.drawCircle(center, size * 0.018, Paint()..color = Colors.white);
    
    // Circuit lines
    final linePaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.012
      ..strokeCap = StrokeCap.round;
    
    final nodeCount = 8;
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount) * 2 * math.pi - math.pi / 2;
      final lineLength = radius * 0.9;
      
      final startOffset = size * 0.06;
      final start = Offset(
        center.dx + math.cos(angle) * startOffset,
        center.dy + math.sin(angle) * startOffset,
      );
      final end = Offset(
        center.dx + math.cos(angle) * lineLength,
        center.dy + math.sin(angle) * lineLength,
      );
      
      canvas.drawLine(start, end, linePaint);
      
      // Node at end
      final nodePaint = Paint()
        ..color = const Color(0xFF26A69A)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(end, size * 0.025, nodePaint);
      
      // Branch lines
      if (i % 2 == 0) {
        final branchAngle = angle + math.pi / 6;
        final branchLength = lineLength * 0.35;
        final branchStart = Offset(
          center.dx + math.cos(angle) * (lineLength * 0.6),
          center.dy + math.sin(angle) * (lineLength * 0.6),
        );
        final branchEnd = Offset(
          branchStart.dx + math.cos(branchAngle) * branchLength,
          branchStart.dy + math.sin(branchAngle) * branchLength,
        );
        
        canvas.drawLine(branchStart, branchEnd, linePaint);
        canvas.drawCircle(branchEnd, size * 0.018, nodePaint);
      }
    }
  }
  
  void _drawGreenArrow(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: math.pi,
      colors: const [
        Color(0xFF81C784),
        Color(0xFF4CAF50),
        Color(0xFF388E3C),
      ],
    );
    
    final arrowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.1
      ..strokeCap = StrokeCap.round;
    
    final shadowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final sweepAngle = math.pi * 0.82;
    final startAngle = -math.pi / 2 - math.pi / 8;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arrowPaint);
    
    // Arrowhead
    _drawArrowhead(canvas, center, radius, startAngle + sweepAngle, const Color(0xFF4CAF50));
  }
  
  void _drawBlueArrow(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = SweepGradient(
      startAngle: math.pi / 2,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0xFF90CAF9),
        Color(0xFF42A5F5),
        Color(0xFF1E88E5),
      ],
    );
    
    final arrowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.1
      ..strokeCap = StrokeCap.round;
    
    final shadowPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final sweepAngle = math.pi * 0.82;
    final startAngle = math.pi / 2 - math.pi / 8;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arrowPaint);
    
    // Arrowhead
    _drawArrowhead(canvas, center, radius, startAngle + sweepAngle, const Color(0xFF42A5F5));
  }
  
  void _drawArrowhead(Canvas canvas, Offset center, double radius, double angle, Color color) {
    final tipX = center.dx + math.cos(angle) * radius;
    final tipY = center.dy + math.sin(angle) * radius;
    
    final arrowSize = size * 0.12;
    final backAngle = angle + math.pi;
    
    final path = Path();
    path.moveTo(tipX, tipY);
    path.lineTo(
      tipX + math.cos(backAngle + 0.4) * arrowSize,
      tipY + math.sin(backAngle + 0.4) * arrowSize,
    );
    path.lineTo(
      tipX + math.cos(backAngle - 0.4) * arrowSize,
      tipY + math.sin(backAngle - 0.4) * arrowSize,
    );
    path.close();
    
    canvas.drawPath(path, Paint()..color = color);
  }
  
  @override
  bool shouldRepaint(covariant RecyConnectLogoPainterStatic oldDelegate) {
    return rotation != oldDelegate.rotation;
  }
}
