import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Animation strategy interface
/// Pattern: Strategy
/// SRP: Each strategy handles ONE animation type
abstract class AnimationStrategy {
  Widget apply(Widget child, Animation<double> animation);
}

/// Fade and slide animation strategy
class FadeSlideAnimation implements AnimationStrategy {
  final Offset slideOffset;
  final Curve curve;

  const FadeSlideAnimation({
    this.slideOffset = const Offset(0, 0.1),
    this.curve = Curves.easeOut,
  });

  @override
  Widget apply(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: slideOffset, end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: curve),
        ),
        child: child,
      ),
    );
  }
}

/// Scale and fade animation strategy
class ScaleFadeAnimation implements AnimationStrategy {
  final double beginScale;
  final Curve curve;

  const ScaleFadeAnimation({
    this.beginScale = 0.95,
    this.curve = Curves.easeOut,
  });

  @override
  Widget apply(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: beginScale, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        ),
        child: child,
      ),
    );
  }
}

/// Bounce animation strategy
class BounceAnimation implements AnimationStrategy {
  final double beginScale;

  const BounceAnimation({this.beginScale = 0.8});

  @override
  Widget apply(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: beginScale, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      ),
      child: child,
    );
  }
}

/// Fade only animation strategy
class FadeAnimation implements AnimationStrategy {
  final Curve curve;

  const FadeAnimation({this.curve = Curves.easeIn});

  @override
  Widget apply(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }
}

/// Slide from direction animation strategy
class SlideAnimation implements AnimationStrategy {
  final SlideDirection direction;
  final Curve curve;

  const SlideAnimation({
    this.direction = SlideDirection.fromBottom,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget apply(Widget child, Animation<double> animation) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.fromLeft:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.fromRight:
        beginOffset = const Offset(1, 0);
        break;
      case SlideDirection.fromTop:
        beginOffset = const Offset(0, -1);
        break;
      case SlideDirection.fromBottom:
        beginOffset = const Offset(0, 1);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: curve),
      ),
      child: child,
    );
  }
}

enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

/// Rotation animation strategy
class RotateAnimation implements AnimationStrategy {
  final double beginRotation;
  final Curve curve;

  const RotateAnimation({
    this.beginRotation = 0.1,
    this.curve = Curves.easeOut,
  });

  @override
  Widget apply(Widget child, Animation<double> animation) {
    return RotationTransition(
      turns: Tween<double>(begin: beginRotation, end: 0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      ),
      child: child,
    );
  }
}

/// Combined animation strategy (compose multiple strategies)
class CombinedAnimation implements AnimationStrategy {
  final List<AnimationStrategy> strategies;

  const CombinedAnimation(this.strategies);

  @override
  Widget apply(Widget child, Animation<double> animation) {
    Widget result = child;
    for (final strategy in strategies.reversed) {
      result = strategy.apply(result, animation);
    }
    return result;
  }
}

// ============================================
// PRE-DEFINED ANIMATION STRATEGIES
// ============================================

class AppAnimations {
  /// Standard screen entrance animation
  static const screenEntrance = FadeSlideAnimation(
    slideOffset: Offset(0, 0.1),
    curve: Curves.easeOutCubic,
  );

  /// Card pop animation
  static const cardPop = ScaleFadeAnimation(
    beginScale: 0.9,
    curve: Curves.easeOutBack,
  );

  /// Bounce in animation
  static const bounceIn = BounceAnimation(beginScale: 0.8);

  /// Subtle fade
  static const subtleFade = FadeAnimation(curve: Curves.easeIn);

  /// Slide from bottom
  static const slideUp = SlideAnimation(
    direction: SlideDirection.fromBottom,
    curve: Curves.easeOutCubic,
  );

  /// Slide from right (for navigation)
  static const slideFromRight = SlideAnimation(
    direction: SlideDirection.fromRight,
    curve: Curves.easeOutCubic,
  );

  /// Hero-style combined animation
  static const heroEntrance = CombinedAnimation([
    FadeAnimation(),
    ScaleFadeAnimation(beginScale: 0.95),
  ]);
}

// ============================================
// ANIMATED WIDGET HELPERS
// ============================================

/// Widget that applies animation strategy on build
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final AnimationStrategy strategy;
  final Duration duration;
  final Duration delay;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.strategy = const FadeSlideAnimation(),
    this.duration = DesignTokens.animationNormal,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.strategy.apply(widget.child, _animation);
  }
}

/// Staggered animation for list items
class StaggeredListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int totalItems;
  final Animation<double> controller;
  final AnimationStrategy strategy;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    required this.totalItems,
    required this.controller,
    this.strategy = const FadeSlideAnimation(),
  });

  @override
  Widget build(BuildContext context) {
    final start = (index / totalItems) * 0.5;
    final end = start + 0.5;

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => strategy.apply(child, animation),
    );
  }
}
