import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

/// Light Mode Story Welcome Screen (Pivot)
/// Narrative: Waste -> Recycled Particles -> Healed Earth -> RecyConnect Solution.
/// Aesthetic: Soft Teal-Mint, Eye-friendly, No harsh flashes.
class AnimatedStoryWelcomeScreen extends StatefulWidget {
  const AnimatedStoryWelcomeScreen({super.key});

  @override
  State<AnimatedStoryWelcomeScreen> createState() => _AnimatedStoryWelcomeScreenState();
}

class _AnimatedStoryWelcomeScreenState extends State<AnimatedStoryWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _storyController;

  // Phase Animations
  late Animation<double> _phase1IconsMove; // 0.0 -> 0.25 (Waste moves to center)
  late Animation<double> _phase1IconsFade; // 0.20 -> 0.25 (Waste disappears)
  late Animation<double> _phase2ParticleSwirl; // 0.20 -> 0.45 (Particles form globe)
  late Animation<double> _phase3EarthScale; // 0.35 -> 0.55 (Earth appears)
  late Animation<double> _phase4NatureGrow; // 0.50 -> 0.75 (Rings/Leaves appear)
  late Animation<double> _phase5LogoReveal; // 0.75 -> 0.90 (Logo Fades In)
  late Animation<double> _phase5EarthFade; // 0.75 -> 0.90 (Earth Fades Out for Logo)
  late Animation<double> _phase6Exit; // 0.95 -> 1.00 (Fade to Login)

  final List<IconData> _wasteIcons = const [
    Icons.delete_outline_rounded, 
    Icons.newspaper_rounded,      // Paper/Newspaper (Clearer than description)
    Icons.water_drop_outlined,     
    Icons.inventory_2_outlined,   
  ];

  @override
  void initState() {
    super.initState();
    _storyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 6 seconds for a relaxed pace
    );

    // Phase 1: Waste Moves to Center
    _phase1IconsMove = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeInOutCubic),
    ));

    // Phase 1b: Waste Fades Out
    _phase1IconsFade = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.20, 0.25, curve: Curves.easeIn),
    ));

    // Phase 2: Particles Swirl
    _phase2ParticleSwirl = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.20, 0.45, curve: Curves.easeOut),
    ));

    // Phase 3: Earth Forms/Scales Up
    _phase3EarthScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.35, 0.55, curve: Curves.elasticOut),
    ));

    // Phase 4: Nature Elements (Rings/Leaves)
    _phase4NatureGrow = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.50, 0.75, curve: Curves.easeOutBack),
    ));

    // Phase 5: Logo Reveal (Earth fades slightly to background or out)
    _phase5LogoReveal = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.75, 0.90, curve: Curves.easeOut),
    ));

    _phase5EarthFade = Tween(begin: 1.0, end: 0.3).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.75, 0.90, curve: Curves.easeInOut),
    ));

    // Phase 6: Exit
    _phase6Exit = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.92, 1.0, curve: Curves.easeIn),
    ));

    _storyController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToLogin();
      }
    });

    _storyController.forward();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _storyController,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                   Color(0xFFE0F7FA), // Mint/Cyan 50 (Top Left)
                   Color(0xFFE8F5E9), // Green 50 (Center)
                   Color(0xFFB2DFDB), // Teal 100 (Bottom Right)
                ],
              ),
            ),
            child: Opacity(
              opacity: (1.0 - _phase6Exit.value).clamp(0.0, 1.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                   // Main Canvas (Earth, Particles, Rings)
                   CustomPaint(
                     painter: LightStoryPainter(
                       particleProgress: _phase2ParticleSwirl.value,
                       earthScale: _phase3EarthScale.value,
                       natureProgress: _phase4NatureGrow.value,
                       earthOpacity: _phase5EarthFade.value,
                     ),
                     size: MediaQuery.of(context).size,
                   ),

                   // Phase 1: Floating Icons
                   if (_phase1IconsFade.value > 0)
                     ...List.generate(_wasteIcons.length, (index) => _buildFloatingIcon(index)),

                   // Phase 5: Logo (Widget Overlay for text quality)
                   if (_phase5LogoReveal.value > 0)
                     _buildLogo(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingIcon(int index) {
    final size = MediaQuery.of(context).size;
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    
    // Start from different corners
    final startPositions = [
      Offset(size.width * 0.1, size.height * 0.1), // Top-Left
      Offset(size.width * 0.9, size.height * 0.1), // Top-Right
      Offset(size.width * 0.1, size.height * 0.9), // Bottom-Left
      Offset(size.width * 0.9, size.height * 0.9), // Bottom-Right
    ];

    final currentPos = Offset.lerp(
      startPositions[index],
      Offset(centerX, centerY),
      _phase1IconsMove.value,
    )!;

    return Positioned(
      left: currentPos.dx - 24,
      top: currentPos.dy - 24,
      child: Transform.scale(
        scale: 1.0 - (_phase1IconsMove.value * 0.5),
        child: Opacity(
          opacity: _phase1IconsFade.value,
          child: Icon(
            _wasteIcons[index],
            size: 48,
            color: Colors.teal.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
     return Center(
       child: Opacity(
         opacity: _phase5LogoReveal.value,
         child: Transform.translate(
           offset: Offset(0, -50 + (50 * _phase5LogoReveal.value)), // Slide Up
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                const SizedBox(height: 120), // Offset below earth center used to be
                const Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: Color(0xFF2E7D32), // Darker Green
                ),
                const SizedBox(height: 16),
                const Text(
                  'RecyConnect',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C), // Teal 800
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transforming Waste to Life',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF004D40).withValues(alpha: 0.7),
                  ),
                ),
             ],
           ),
         ),
       ),
     );
  }
}

class LightStoryPainter extends CustomPainter {
  final double particleProgress; // 0.0 -> 1.0 (Swirl in)
  final double earthScale;       // 0.0 -> 1.0 (Pop up)
  final double natureProgress;   // 0.0 -> 1.0 (Rings/Leaves)
  final double earthOpacity;     // 1.0 -> 0.3 (Fade out)

  LightStoryPainter({
    required this.particleProgress,
    required this.earthScale,
    required this.natureProgress,
    required this.earthOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final earthRadius = size.width * 0.25;

    // 1. Draw Particles Swirling In
    // They start spread out and spiraling, then become the globe
    if (particleProgress > 0 && earthScale < 1.0) {
      _drawSwirl(canvas, center, size.width);
    }

    // 2. Draw Holographic Earth
    if (earthScale > 0) {
      _drawEarth(canvas, center, earthRadius);
    }

    // 3. Draw Nature Rings & Leaves
    if (natureProgress > 0) {
      _drawNature(canvas, center, earthRadius);
    }
  }

  void _drawSwirl(Canvas canvas, Offset center, double width) {
    // 20 particles
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
        double relativePos = i / 20.0;
        // Spiral closer as progress increases
        double r = (width * 0.4) * (1.0 - particleProgress); 
        double angle = (particleProgress * 4 * math.pi) + (relativePos * 2 * math.pi);
        
        double x = center.dx + math.cos(angle) * r;
        double y = center.dy + math.sin(angle) * r;

        double opacity = (particleCurve(particleProgress) * earthOpacity).clamp(0.0, 1.0);
        
        paint.color = const Color(0xFF26A69A).withValues(alpha: opacity); // Teal 400
        canvas.drawCircle(Offset(x, y), 3 + (2 * particleProgress), paint);
    }
  }
  
  // Custom simple curve for particle visibility
  double particleCurve(double t) {
      if (t < 0.2) return t * 5;
      if (t > 0.8) return (1-t) * 5;
      return 1.0;
  }

  void _drawEarth(Canvas canvas, Offset center, double baseRadius) {
    final radius = baseRadius * earthScale;
    
    // Fade out earth when Logo appears
    
    
    // 1. Wireframe/Base
    final earthPaint = Paint()
      ..color = const Color(0xFF4DB6AC).withValues(alpha: earthOpacity * 0.2) // Teal 300
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, earthPaint);
    
    // 2. Grid Lines (Lat/Long)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: earthOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Simple grid representation
    canvas.drawCircle(center, radius, gridPaint); // Outline
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.8), gridPaint); // Equator-ish
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), gridPaint); // Prime meridian
  }

  void _drawNature(Canvas canvas, Offset center, double baseRadius) {
    final radius = baseRadius * earthScale;
    final ringRadius = radius * 1.4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(natureProgress * 0.5); // Slow rotation

    // 1. Energy Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF66BB6A).withValues(alpha: earthOpacity * natureProgress); // Green 400
      
    // Draw dashed ring or partial arc
    canvas.drawArc(
        Rect.fromCenter(center: Offset.zero, width: ringRadius*2, height: ringRadius*2), 
        0, math.pi * 1.5, false, ringPaint);

    // 2. Tiny Leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: earthOpacity * natureProgress) // Green 600
      ..style = PaintingStyle.fill;

    for(int i = 0; i < 5; i++) {
        double angle = (2 * math.pi / 5) * i + (natureProgress * 2);
        double lx = math.cos(angle) * ringRadius;
        double ly = math.sin(angle) * ringRadius;
        
        // Leaf shape (simple oval)
        canvas.drawOval(Rect.fromCenter(center: Offset(lx,ly), width: 8, height: 4), leafPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LightStoryPainter oldDelegate) => true;
}
