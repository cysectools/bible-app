import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late AnimationController _particleController;
  late Animation<double> _lineAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _lineController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _lineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lineController,
      curve: Curves.linear,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _lineController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: Listenable.merge([_lineAnimation, _particleAnimation]),
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedBackgroundPainter(
                  _lineAnimation.value,
                  _particleAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Main content
          widget.child,
        ],
      ),
    );
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  final double lineAnimationValue;
  final double particleAnimationValue;

  AnimatedBackgroundPainter(this.lineAnimationValue, this.particleAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent patterns
    
    // Draw animated flowing lines
    final linePaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final startX = (lineAnimationValue * 100 + i * 150) % (size.width + 100);
      final startY = size.height * 0.2 + i * 80;
      final endX = startX + 200;
      final endY = startY + 100;
      
      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 100,
        startY + 50,
        endX,
        endY,
      );
      
      canvas.drawPath(path, linePaint);
    }

    // Draw floating particles
    final particlePaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = (random.nextDouble() * size.width + particleAnimationValue * 30) % size.width;
      final y = (random.nextDouble() * size.height + particleAnimationValue * 20) % size.height;
      final radius = random.nextDouble() * 3 + 1;
      final opacity = (math.sin(particleAnimationValue * math.pi * 2 + i) + 1) / 2;
      
      particlePaint.color = Colors.deepPurple.withOpacity(opacity * 0.2);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Draw subtle gradient overlay
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.deepPurple.withOpacity(0.02),
          Colors.transparent,
          Colors.indigo.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
  }

  @override
  bool shouldRepaint(AnimatedBackgroundPainter oldDelegate) {
    return oldDelegate.lineAnimationValue != lineAnimationValue ||
           oldDelegate.particleAnimationValue != particleAnimationValue;
  }
}
