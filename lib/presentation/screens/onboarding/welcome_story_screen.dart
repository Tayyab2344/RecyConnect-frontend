import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

/// RecyConnect Animated Splash Screen
/// Story: Circuit nodes emerge → arrows sweep in → logo pulses → text reveals
/// Aesthetic: Light mode with green/blue accents matching login

class AnimatedStoryWelcomeScreen extends StatefulWidget {
  const AnimatedStoryWelcomeScreen({super.key});

  @override
  State<AnimatedStoryWelcomeScreen> createState() => _AnimatedStoryWelcomeScreenState();
}

class _AnimatedStoryWelcomeScreenState extends State<AnimatedStoryWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  
  // Phase animations - compressed timing
  late Animation<double> _phase1Background;    // 0.00 - 0.12 Background pulse
  late Animation<double> _phase2Circuit;       // 0.08 - 0.35 Circuit nodes grow
  late Animation<double> _phase3GreenArrow;    // 0.28 - 0.55 Green arrow sweeps
  late Animation<double> _phase4BlueArrow;     // 0.45 - 0.72 Blue arrow sweeps
  late Animation<double> _phase5LogoPulse;     // 0.65 - 0.82 Logo pulses/glows
  late Animation<double> _phase6TextReveal;    // 0.75 - 0.92 Text fades in
  late Animation<double> _phase7Exit;          // 0.90 - 1.00 Fade to next screen
  
  // Rotation for arrows
  late Animation<double> _arrowRotation;
  
  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // 2.5 seconds total (fast)
    );
    
    // Phase 1: Background pulse emerges
    _phase1Background = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
    ));
    
    // Phase 2: Circuit nodes and lines grow outward
    _phase2Circuit = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.08, 0.35, curve: Curves.easeOutCubic),
    ));
    
    // Phase 3: Green arrow sweeps in
    _phase3GreenArrow = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.28, 0.55, curve: Curves.easeOutBack),
    ));
    
    // Phase 4: Blue arrow sweeps in
    _phase4BlueArrow = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.45, 0.72, curve: Curves.easeOutBack),
    ));
    
    // Phase 5: Logo pulses with glow
    _phase5LogoPulse = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.65, 0.82, curve: Curves.easeInOut),
    ));
    
    // Phase 6: Text reveals
    _phase6TextReveal = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.75, 0.92, curve: Curves.easeOut),
    ));
    
    // Phase 7: Exit fade
    _phase7Exit = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.90, 1.0, curve: Curves.easeIn),
    ));
    
    // Continuous slow rotation for arrows
    _arrowRotation = Tween(begin: 0.0, end: 0.08).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 1.0, curve: Curves.linear),
    ));
    
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToLogin();
      }
    });
    
    _mainController.forward();
  }
  
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Opacity(
            opacity: (1.0 - _phase7Exit.value).clamp(0.0, 1.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background (light)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        const Color(0xFFF5F5F5),
                        const Color(0xFFE8F5E9).withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                
                // Background pulse effect
                _buildBackgroundPulse(),
                
                // Main logo canvas
                CustomPaint(
                  painter: RecyConnectLogoPainter(
                    circuitProgress: _phase2Circuit.value,
                    greenArrowProgress: _phase3GreenArrow.value,
                    blueArrowProgress: _phase4BlueArrow.value,
                    pulseProgress: _phase5LogoPulse.value,
                    rotation: _arrowRotation.value,
                  ),
                  size: MediaQuery.of(context).size,
                ),
                
                // Floating particles
                if (_phase1Background.value > 0)
                  ...List.generate(10, (i) => _buildParticle(i)),
                
                // Text at bottom
                if (_phase6TextReveal.value > 0)
                  _buildText(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBackgroundPulse() {
    final size = MediaQuery.of(context).size;
    final pulseSize = size.width * 0.7 * _phase1Background.value;
    
    return Center(
      child: Container(
        width: pulseSize,
        height: pulseSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.08 * _phase1Background.value),
              const Color(0xFF4CAF50).withOpacity(0.03 * _phase1Background.value),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
  
  Widget _buildParticle(int index) {
    final random = math.Random(index * 42);
    final size = MediaQuery.of(context).size;
    
    final angle = (index / 10) * 2 * math.pi;
    final distance = 100 + random.nextDouble() * 80;
    
    final x = size.width / 2 + math.cos(angle) * distance * _phase2Circuit.value;
    final y = size.height / 2 - 40 + math.sin(angle) * distance * _phase2Circuit.value;
    
    final particleSize = 4 + random.nextDouble() * 4;
    
    return Positioned(
      left: x - particleSize / 2,
      top: y - particleSize / 2,
      child: Opacity(
        opacity: (_phase2Circuit.value * 0.5).clamp(0.0, 1.0),
        child: Container(
          width: particleSize,
          height: particleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index % 2 == 0 
              ? const Color(0xFF4CAF50).withOpacity(0.6)
              : const Color(0xFF42A5F5).withOpacity(0.6),
          ),
        ),
      ),
    );
  }
  
  Widget _buildText() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.15,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _phase6TextReveal.value,
        child: Transform.translate(
          offset: Offset(0, 15 * (1 - _phase6TextReveal.value)),
          child: Column(
            children: [
              // RecyConnect text with gradient
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF42A5F5), // Blue for "Recy"
                    Color(0xFF333333), // Dark gray for "Connect"
                  ],
                  stops: [0.35, 0.35],
                ).createShader(bounds),
                child: const Text(
                  'RecyConnect',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Connecting Waste to Worth',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws the RecyConnect logo (light theme)
class RecyConnectLogoPainter extends CustomPainter {
  final double circuitProgress;
  final double greenArrowProgress;
  final double blueArrowProgress;
  final double pulseProgress;
  final double rotation;
  
  RecyConnectLogoPainter({
    required this.circuitProgress,
    required this.greenArrowProgress,
    required this.blueArrowProgress,
    required this.pulseProgress,
    required this.rotation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);
    final logoRadius = size.width * 0.26;
    
    // Draw circuit board pattern first (behind arrows)
    if (circuitProgress > 0) {
      _drawCircuitBoard(canvas, center, logoRadius * 0.55);
    }
    
    // Draw recycling arrows
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    if (greenArrowProgress > 0) {
      _drawGreenArrow(canvas, center, logoRadius);
    }
    
    if (blueArrowProgress > 0) {
      _drawBlueArrow(canvas, center, logoRadius);
    }
    
    canvas.restore();
    
    // Draw center glow pulse
    if (pulseProgress > 0) {
      _drawCenterGlow(canvas, center);
    }
  }
  
  void _drawCircuitBoard(Canvas canvas, Offset center, double radius) {
    // Central core - teal color
    final corePaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(circuitProgress * 0.9)
      ..style = PaintingStyle.fill;
    
    final coreGlowPaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(circuitProgress * 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    // Glow
    canvas.drawCircle(center, 22 * circuitProgress, coreGlowPaint);
    
    // Concentric circles
    final ringPaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(circuitProgress * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, (12 + i * 10) * circuitProgress, ringPaint);
    }
    
    // Core center
    canvas.drawCircle(center, 10 * circuitProgress, corePaint);
    canvas.drawCircle(center, 5 * circuitProgress, Paint()..color = Colors.white);
    
    // Draw circuit lines emanating outward
    final linePaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(circuitProgress * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    
    final nodeCount = 8;
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount) * 2 * math.pi - math.pi / 2;
      final lineLength = radius * circuitProgress;
      
      // Main line from center
      final startOffset = 18.0;
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
        ..color = const Color(0xFF26A69A).withOpacity(circuitProgress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(end, 3.5 * circuitProgress, nodePaint);
      
      // Branch lines for some nodes
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
        canvas.drawCircle(branchEnd, 2.5 * circuitProgress, nodePaint);
      }
    }
  }
  
  void _drawGreenArrow(Canvas canvas, Offset center, double radius) {
    final progress = greenArrowProgress;
    
    // Green gradient arrow
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: math.pi,
      colors: const [
        Color(0xFF81C784), // Light green
        Color(0xFF4CAF50), // Primary green
        Color(0xFF388E3C), // Dark green
      ],
    );
    
    final arrowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    // Subtle shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.15 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    // Draw arc
    final sweepAngle = math.pi * 0.82 * progress;
    final startAngle = -math.pi / 2 - math.pi / 8;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arrowPaint);
    
    // Arrowhead
    if (progress > 0.8) {
      final arrowheadProgress = (progress - 0.8) / 0.2;
      _drawArrowhead(
        canvas, 
        center, 
        radius, 
        startAngle + sweepAngle, 
        const Color(0xFF4CAF50),
        arrowheadProgress,
      );
    }
  }
  
  void _drawBlueArrow(Canvas canvas, Offset center, double radius) {
    final progress = blueArrowProgress;
    
    // Blue gradient arrow
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = SweepGradient(
      startAngle: math.pi / 2,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0xFF90CAF9), // Light blue
        Color(0xFF42A5F5), // Primary blue  
        Color(0xFF1E88E5), // Dark blue
      ],
    );
    
    final arrowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    // Subtle shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.15 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    // Draw arc
    final sweepAngle = math.pi * 0.82 * progress;
    final startAngle = math.pi / 2 - math.pi / 8;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arrowPaint);
    
    // Arrowhead
    if (progress > 0.8) {
      final arrowheadProgress = (progress - 0.8) / 0.2;
      _drawArrowhead(
        canvas, 
        center, 
        radius, 
        startAngle + sweepAngle, 
        const Color(0xFF42A5F5),
        arrowheadProgress,
      );
    }
  }
  
  void _drawArrowhead(
    Canvas canvas, 
    Offset center, 
    double radius, 
    double angle, 
    Color color,
    double progress,
  ) {
    final tipX = center.dx + math.cos(angle) * radius;
    final tipY = center.dy + math.sin(angle) * radius;
    
    final arrowSize = 18.0 * progress;
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
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
  }
  
  void _drawCenterGlow(Canvas canvas, Offset center) {
    final pulseFactor = 0.85 + 0.15 * math.sin(pulseProgress * math.pi * 2);
    
    final glowPaint = Paint()
      ..color = const Color(0xFF26A69A).withOpacity(0.15 * pulseProgress * pulseFactor)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    
    canvas.drawCircle(center, 50 * pulseProgress * pulseFactor, glowPaint);
  }
  
  @override
  bool shouldRepaint(covariant RecyConnectLogoPainter oldDelegate) {
    return circuitProgress != oldDelegate.circuitProgress ||
           greenArrowProgress != oldDelegate.greenArrowProgress ||
           blueArrowProgress != oldDelegate.blueArrowProgress ||
           pulseProgress != oldDelegate.pulseProgress ||
           rotation != oldDelegate.rotation;
  }
}
