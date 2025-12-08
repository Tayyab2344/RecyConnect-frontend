import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Mixin for screen entrance animations
/// DRY: Reusable animation setup across all screens
/// Usage: class _MyScreenState extends State<MyScreen> 
///        with TickerProviderStateMixin, ScreenAnimationMixin
mixin ScreenAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  
  late AnimationController entranceController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;

  /// Initialize entrance animation with standard parameters
  void initEntranceAnimation({
    Duration duration = DesignTokens.animationXSlow,
    Curve curve = Curves.easeOutCubic,
    Offset slideOffset = const Offset(0, 0.1),
    bool autoStart = true,
  }) {
    entranceController = AnimationController(
      vsync: this,
      duration: duration,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Interval(0.0, 0.6, curve: curve),
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: curve,
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: curve,
      ),
    );

    if (autoStart) {
      entranceController.forward();
    }
  }

  /// Dispose entrance animation controller
  void disposeEntranceAnimation() {
    entranceController.dispose();
  }

  /// Wrap a widget with entrance animation
  Widget withEntranceAnimation(Widget child) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }

  /// Wrap with fade only
  Widget withFadeAnimation(Widget child) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  /// Wrap with scale animation
  Widget withScaleAnimation(Widget child) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: child,
    );
  }

  /// Create staggered animation for list items
  Animation<double> createStaggeredFade(int index, int totalItems) {
    final start = (index / totalItems) * 0.5;
    final end = start + 0.5;
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  /// Create staggered slide animation for list items
  Animation<Offset> createStaggeredSlide(int index, int totalItems) {
    final start = (index / totalItems) * 0.5;
    final end = start + 0.5;
    return Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }
}

/// Mixin for button press animations
/// Usage: class _MyButtonState extends State<MyButton> 
///        with SingleTickerProviderStateMixin, ButtonAnimationMixin
mixin ButtonAnimationMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  
  late AnimationController pressController;
  late Animation<double> scaleAnimation;

  void initButtonAnimation({
    Duration duration = DesignTokens.animationFast,
    double pressScale = 0.95,
  }) {
    pressController = AnimationController(
      vsync: this,
      duration: duration,
    );

    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: pressScale,
    ).animate(
      CurvedAnimation(
        parent: pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void disposeButtonAnimation() {
    pressController.dispose();
  }

  void onPressDown() {
    pressController.forward();
  }

  void onPressUp() {
    pressController.reverse();
  }

  Widget withPressAnimation(Widget child) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: child,
    );
  }
}

/// Mixin for loading state management
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _loadingMessage;

  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  void startLoading([String? message]) {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingMessage = message;
      });
    }
  }

  void stopLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
    }
  }

  Future<T> withLoading<T>(Future<T> Function() action, [String? message]) async {
    startLoading(message);
    try {
      return await action();
    } finally {
      stopLoading();
    }
  }
}
