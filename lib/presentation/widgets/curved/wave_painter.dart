import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';

/// Wave painter - Draws curved wave shapes
/// SRP: Only responsible for painting wave curves
/// Used for headers and decorative backgrounds
class WavePainter extends CustomPainter {
  final Color color;
  final Gradient? gradient;
  final double waveHeight;
  final bool isTop;
  final int waveCount;

  WavePainter({
    required this.color,
    this.gradient,
    this.waveHeight = DesignTokens.waveHeight,
    this.isTop = true,
    this.waveCount = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = color;
    }

    final path = Path();

    if (isTop) {
      // Wave at the bottom of header
      path.lineTo(0, size.height - waveHeight);

      // Create smooth wave curve
      path.quadraticBezierTo(
        size.width * 0.25,
        size.height,
        size.width * 0.5,
        size.height - waveHeight * 0.5,
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        size.height - waveHeight,
        size.width,
        size.height - waveHeight * 0.3,
      );

      path.lineTo(size.width, 0);
    } else {
      // Wave at the top (for bottom nav or footers)
      path.moveTo(0, waveHeight);

      path.quadraticBezierTo(
        size.width * 0.25,
        0,
        size.width * 0.5,
        waveHeight * 0.5,
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        waveHeight,
        size.width,
        waveHeight * 0.3,
      );

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return color != oldDelegate.color ||
        waveHeight != oldDelegate.waveHeight ||
        isTop != oldDelegate.isTop;
  }
}

/// Organic blob painter for decorative backgrounds
/// Creates organic, flowing blob shapes
class OrganicBlobPainter extends CustomPainter {
  final Color color;
  final double scale;
  final Offset offset;

  OrganicBlobPainter({
    required this.color,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(
      size.width / 2 + offset.dx,
      size.height / 2 + offset.dy,
    );

    final path = Path();
    final radius = (size.width < size.height ? size.width : size.height) / 2 * scale;

    // Create organic blob shape
    path.moveTo(center.dx, center.dy - radius);

    // Top right curve
    path.cubicTo(
      center.dx + radius * 0.8,
      center.dy - radius * 0.9,
      center.dx + radius * 1.1,
      center.dy - radius * 0.3,
      center.dx + radius,
      center.dy,
    );

    // Bottom right curve
    path.cubicTo(
      center.dx + radius * 0.9,
      center.dy + radius * 0.4,
      center.dx + radius * 0.5,
      center.dy + radius * 1.1,
      center.dx,
      center.dy + radius,
    );

    // Bottom left curve
    path.cubicTo(
      center.dx - radius * 0.6,
      center.dy + radius * 0.9,
      center.dx - radius * 1.1,
      center.dy + radius * 0.3,
      center.dx - radius,
      center.dy,
    );

    // Top left curve
    path.cubicTo(
      center.dx - radius * 0.9,
      center.dy - radius * 0.5,
      center.dx - radius * 0.4,
      center.dy - radius * 1.1,
      center.dx,
      center.dy - radius,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant OrganicBlobPainter oldDelegate) {
    return color != oldDelegate.color ||
        scale != oldDelegate.scale ||
        offset != oldDelegate.offset;
  }
}

/// Curved bottom navigation wave painter
class BottomNavWavePainter extends CustomPainter {
  final Color color;
  final double notchRadius;
  final double notchMargin;

  BottomNavWavePainter({
    required this.color,
    this.notchRadius = 28,
    this.notchMargin = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final curveHeight = DesignTokens.bottomNavWaveHeight;

    // Start from top left with curve
    path.moveTo(0, curveHeight);

    // Left curve to center
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      centerX - notchRadius - notchMargin,
      0,
    );

    // Notch for FAB
    path.quadraticBezierTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius,
      notchRadius * 0.5,
    );
    path.arcToPoint(
      Offset(centerX + notchRadius, notchRadius * 0.5),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + notchRadius,
      0,
      centerX + notchRadius + notchMargin,
      0,
    );

    // Right curve to end
    path.quadraticBezierTo(
      size.width * 0.75,
      0,
      size.width,
      curveHeight,
    );

    // Complete the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BottomNavWavePainter oldDelegate) {
    return color != oldDelegate.color ||
        notchRadius != oldDelegate.notchRadius;
  }
}

/// Gradient wave background widget
/// Provides easy-to-use wave background for screens
class WaveBackground extends StatelessWidget {
  final double height;
  final Color? color;
  final Gradient? gradient;
  final double waveHeight;
  final bool isTop;

  const WaveBackground({
    super.key,
    this.height = 200,
    this.color,
    this.gradient,
    this.waveHeight = DesignTokens.waveHeight,
    this.isTop = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: WavePainter(
        color: color ?? AppColors.primaryGreen,
        gradient: gradient,
        waveHeight: waveHeight,
        isTop: isTop,
      ),
    );
  }
}
