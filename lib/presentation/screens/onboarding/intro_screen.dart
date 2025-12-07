import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../auth/login_screen.dart';

/// Premium RecyConnect Splash Screen - First screen shown to users on app launch.
/// Features: Full-screen splash image, glowing swipe-up arrow with floating animation,
/// elastic drag gesture, and smooth fade+slide transition to Login Screen.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  // Arrow animation controllers
  late AnimationController _arrowFloatController;
  late AnimationController _arrowPulseController;
  late AnimationController _arrowScaleController;
  late AnimationController _glowController;
  
  // Drag-related state
  late AnimationController _dragController;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _isNavigating = false;
  
  // Arrow animations
  late Animation<double> _arrowFloat;
  late Animation<double> _arrowOpacity;
  late Animation<double> _arrowScale;
  late Animation<double> _glowIntensity;
  
  // Swipe threshold
  static const double _swipeThreshold = 120.0;
  static const double _velocityThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Arrow floating animation (continuous smooth up-down motion, 10-20px range)
    _arrowFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _arrowFloat = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -18.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -18.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_arrowFloatController);
    
    // Arrow pulse animation (smooth fade in/out, 0.4-1.0 opacity)
    _arrowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _arrowOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_arrowPulseController);
    
    // Arrow scale animation (subtle breathing, 1.0-1.1)
    _arrowScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _arrowScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_arrowScaleController);
    
    // Glow intensity animation (soft pulsing glow)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _glowIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.2)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_glowController);
    
    // Drag spring animation controller
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _dragController.addListener(() {
      if (!_isDragging) {
        setState(() {
          _dragOffset = _dragController.value;
        });
      }
    });
    
    // Start all looping animations with staggered timing for natural feel
    _arrowFloatController.repeat();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _arrowPulseController.repeat();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _arrowScaleController.repeat();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _glowController.repeat();
    });
  }

  @override
  void dispose() {
    _arrowFloatController.dispose();
    _arrowPulseController.dispose();
    _arrowScaleController.dispose();
    _glowController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (_isNavigating) return;
    _isDragging = true;
    _dragController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isNavigating) return;
    setState(() {
      // Only allow upward drag (negative values)
      _dragOffset = math.min(0, _dragOffset + details.delta.dy);
      // Add elastic resistance as user drags further
      _dragOffset = _elasticDrag(_dragOffset);
    });
  }

  double _elasticDrag(double offset) {
    // Apply elastic resistance - the further you drag, the more resistance
    const double resistance = 0.55;
    if (offset < 0) {
      return -math.pow(-offset, resistance) * 2;
    }
    return offset;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isNavigating) return;
    _isDragging = false;
    
    final velocity = details.primaryVelocity ?? 0;
    final shouldNavigate = _dragOffset < -_swipeThreshold || velocity < -_velocityThreshold;
    
    if (shouldNavigate) {
      _navigateToLogin();
    } else {
      // Spring back to original position
      _springBack();
    }
  }

  void _springBack() {
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1.0,
        stiffness: 350.0,
        damping: 22.0,
      ),
      _dragOffset,
      0.0,
      0.0,
    );
    
    _dragController.animateWith(simulation);
  }

  void _navigateToLogin() {
    if (_isNavigating) return;
    _isNavigating = true;
    
    // Animate the page sliding up completely before navigating
    final screenHeight = MediaQuery.of(context).size.height;
    
    _dragController.animateTo(
      -screenHeight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ).then((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Premium fade + slide-up transition matching eco-friendly theme
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure white background
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _arrowFloatController,
            _arrowPulseController,
            _arrowScaleController,
            _glowController,
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                // Pure white background
                Container(
                  color: const Color(0xFFFFFFFF),
                ),
                
                // Main splash image with drag offset
                Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: Center(
                    child: Image.asset(
                      'assets/images/recyconnect_splash.jpg',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                
                // Bottom swipe-up indicator section
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.95),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Animated arrow indicator
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 60 + (_dragOffset * 0.3).abs(),
                  child: Opacity(
                    opacity: math.max(0.0, 1.0 - (_dragOffset.abs() / 150)),
                    child: _buildAnimatedArrow(),
                  ),
                ),
                
                // Swipe hint text
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: Opacity(
                    opacity: math.max(0, 1 - (_dragOffset.abs() / 100)),
                    child: Text(
                      'Swipe Up to Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4CAF50).withOpacity(0.8),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                
                // Progress indicator during drag
                if (_dragOffset < -30)
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: math.min(1, _dragOffset.abs() / _swipeThreshold),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  value: math.min(1, _dragOffset.abs() / _swipeThreshold),
                                  strokeWidth: 2.5,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF4CAF50),
                                  ),
                                  backgroundColor: const Color(0xFF4CAF50).withOpacity(0.15),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _dragOffset.abs() >= _swipeThreshold
                                    ? 'Release to continue!'
                                    : 'Keep swiping...',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedArrow() {
    return Transform.translate(
      offset: Offset(0, _arrowFloat.value),
      child: Transform.scale(
        scale: _arrowScale.value,
        child: Opacity(
          opacity: _arrowOpacity.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing arrow container
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Outer glow effect
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(_glowIntensity.value),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                    // Inner glow
                    BoxShadow(
                      color: const Color(0xFF81C784).withOpacity(_glowIntensity.value * 0.6),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow arrow for depth
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 32,
                          color: const Color(0xFF4CAF50).withOpacity(0.25),
                        ),
                      ),
                      // Main arrow
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
