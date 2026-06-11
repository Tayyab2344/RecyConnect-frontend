import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium recycling-themed loader animation.
///
/// Usage:
///   const RecycleLoader()                  — standard 60px spinner
///   const RecycleLoader(size: 36)          — custom size
///   const RecycleLoader.small()            — compact 22px for buttons
///   RecycleLoader.centered()               — wrapped in Center
class RecycleLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const RecycleLoader({Key? key, this.size = 60, this.color}) : super(key: key);

  const RecycleLoader.small({Key? key})
      : size = 22,
        color = null,
        super(key: key);

  /// Convenience constructor — wraps in Center widget
  static Widget centered({double size = 60, Color? color}) {
    return Center(child: RecycleLoader(size: size, color: color));
  }

  @override
  State<RecycleLoader> createState() => _RecycleLoaderState();
}

class _RecycleLoaderState extends State<RecycleLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _dotController;

  late Animation<double> _rotateAnimation;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();

    // Main rotation — full 360° in 1.6s
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Orbiting dots — slightly offset from main rotation
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _dotAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.color ?? const Color(0xFF4CAF50);
    final size = widget.size;
    final iconSize = size * 0.55;
    final dotRadius = size * 0.065;
    final orbitRadius = size * 0.42;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_rotateAnimation, _dotAnimation]),
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // ── Inner solid circle ────────────────────────────────────
                Container(
                  width: size * 0.72,
                  height: size * 0.72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.08),
                  ),
                ),

                // ── Rotating recycling icon ───────────────────────────────
                Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Icon(
                    Icons.recycling_rounded,
                    size: iconSize,
                    color: accentColor,
                  ),
                ),

                // ── Three orbiting dots ───────────────────────────────────
                ..._buildOrbitingDots(
                  orbitRadius: orbitRadius,
                  dotRadius: dotRadius,
                  baseAngle: _dotAnimation.value,
                  color: accentColor,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildOrbitingDots({
    required double orbitRadius,
    required double dotRadius,
    required double baseAngle,
    required Color color,
  }) {
    const count = 3;
    return List.generate(count, (i) {
      final angle = baseAngle + (i * 2 * math.pi / count);
      final x = orbitRadius * math.cos(angle);
      final y = orbitRadius * math.sin(angle);
      // Stagger opacity by index for a chasing effect
      final opacity = ((math.sin(angle + math.pi / 2) + 1) / 2)
          .clamp(0.3, 1.0);

      return Transform.translate(
        offset: Offset(x, y),
        child: Container(
          width: dotRadius * 2,
          height: dotRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        ),
      );
    });
  }
}

/// Full-screen loading overlay — use inside a Scaffold body or Stack
class RecycleLoadingScreen extends StatelessWidget {
  final String? message;
  const RecycleLoadingScreen({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RecycleLoader(size: 72),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
