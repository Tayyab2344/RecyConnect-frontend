import 'package:flutter/material.dart';

/// Modern Page Transitions
///
/// Collection of smooth, production-ready page transition animations
/// optimized for admin dashboards and modern apps.

/// Slide + Fade Transition (Recommended for most screens)
///
/// Subtle horizontal slide with fade effect
/// Duration: 300ms | Curve: easeOutCubic
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;

  SlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = const Offset(0.03, 0.0), // Subtle 3% slide
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide animation
            var slideTween = Tween(begin: slideOffset, end: Offset.zero)
                .chain(CurveTween(curve: curve));
            var slideAnimation = animation.drive(slideTween);

            // Fade animation
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            var fadeAnimation = animation.drive(fadeTween);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Scale + Fade Transition (Best for modals and detail views)
///
/// Elegant zoom-in effect with fade
/// Duration: 300ms | Curve: easeOutCubic
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;
  final double beginScale;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.center,
    this.beginScale = 0.9,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Scale animation
            var scaleTween = Tween<double>(begin: beginScale, end: 1.0)
                .chain(CurveTween(curve: curve));
            var scaleAnimation = animation.drive(scaleTween);

            // Fade animation
            var fadeAnimation = animation.drive(Tween<double>(begin: 0.0, end: 1.0));

            return ScaleTransition(
              scale: scaleAnimation,
              alignment: alignment,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Fade Transition (Cleanest, most subtle)
///
/// Simple cross-fade between screens
/// Duration: 250ms | Curve: easeInOut
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Shared Axis Transition (Material Design 3)
///
/// Modern transition with exit and enter animations
/// Perfect for hierarchical navigation
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final SharedAxisTransitionType transitionType;

  SharedAxisPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;

            // Exit animation (previous screen)
            final exitAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: transitionType == SharedAxisTransitionType.horizontal
                  ? const Offset(-0.1, 0.0)
                  : const Offset(0.0, -0.1),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: curve,
            ));

            final exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.3, curve: curve),
              ),
            );

            // Enter animation (new screen)
            final enterAnimation = Tween<Offset>(
              begin: transitionType == SharedAxisTransitionType.horizontal
                  ? const Offset(0.1, 0.0)
                  : const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            final enterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: curve),
              ),
            );

            return Stack(
              children: [
                // Exiting screen
                SlideTransition(
                  position: exitAnimation,
                  child: FadeTransition(
                    opacity: exitFade,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Entering screen
                SlideTransition(
                  position: enterAnimation,
                  child: FadeTransition(
                    opacity: enterFade,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
}

/// Custom Navigation Extensions
///
/// Convenient methods for using custom transitions
extension NavigationExtensions on BuildContext {
  /// Navigate with slide transition
  Future<T?> pushSlide<T>(Widget page) {
    return Navigator.of(this).push<T>(SlidePageRoute(page: page));
  }

  /// Navigate with scale transition
  Future<T?> pushScale<T>(Widget page) {
    return Navigator.of(this).push<T>(ScalePageRoute(page: page));
  }

  /// Navigate with fade transition
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.of(this).push<T>(FadePageRoute(page: page));
  }

  /// Replace current route with slide transition
  Future<T?> pushReplacementSlide<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, void>(
      SlidePageRoute(page: page),
    );
  }
}

/// Example Usage:
///
/// // Option 1: Direct route
/// Navigator.of(context).push(SlidePageRoute(page: NewScreen()));
///
/// // Option 2: Extension method
/// context.pushSlide(NewScreen());
///
/// // Option 3: Replace current route
/// context.pushReplacementSlide(NewScreen());
///
/// // Customize transition
/// Navigator.of(context).push(
///   SlidePageRoute(
///     page: NewScreen(),
///     duration: Duration(milliseconds: 400),
///     curve: Curves.easeOutBack,
///     slideOffset: Offset(0.1, 0.0),  // More pronounced slide
///   ),
/// );
