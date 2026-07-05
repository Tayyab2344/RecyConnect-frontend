import 'package:flutter/material.dart';

class AnimatedRobotIcon extends StatefulWidget {
  final Color color;
  final double size;
  const AnimatedRobotIcon({super.key, required this.color, this.size = 28});

  @override
  State<AnimatedRobotIcon> createState() => _AnimatedRobotIconState();
}

class _AnimatedRobotIconState extends State<AnimatedRobotIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yTranslation;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Subtle bobbing up and down
    _yTranslation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Subtle tilt/rotation
    _rotation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yTranslation.value),
          child: Transform.rotate(
            angle: _rotation.value,
            child: Icon(
              Icons.smart_toy_rounded,
              color: widget.color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
