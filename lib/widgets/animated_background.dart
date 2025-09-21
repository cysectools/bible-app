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
    
    // Draw animated flowing lines - Enhanced with more lines
    final linePaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Primary flowing lines (8 lines)
    for (int i = 0; i < 8; i++) {
      final startX = (lineAnimationValue * 120 + i * 150) % (size.width + 150);
      final startY = size.height * 0.1 + i * 80;
      final endX = startX + 180;
      final endY = startY + 120;
      
      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 90,
        startY + 60,
        endX,
        endY,
      );
      
      canvas.drawPath(path, linePaint);
    }

    // Secondary diagonal lines (6 lines)
    final diagonalPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final startX = (lineAnimationValue * 80 + i * 200) % (size.width + 200);
      final startY = size.height * 0.3 + i * 100;
      final endX = startX + 150;
      final endY = startY - 80;
      
      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 75,
        startY - 40,
        endX,
        endY,
      );
      
      canvas.drawPath(path, diagonalPaint);
    }

    // Horizontal accent lines (4 lines)
    final horizontalPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final startX = (lineAnimationValue * 60 + i * 300) % (size.width + 300);
      final startY = size.height * 0.2 + i * 150;
      final endX = startX + 250;
      final endY = startY;
      
      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 125,
        startY + 20,
        endX,
        endY,
      );
      
      canvas.drawPath(path, horizontalPaint);
    }

    // Draw floating particles - Enhanced
    final particlePaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Primary particles (18 particles)
    for (int i = 0; i < 18; i++) {
      final x = (random.nextDouble() * size.width + particleAnimationValue * 40) % size.width;
      final y = (random.nextDouble() * size.height + particleAnimationValue * 25) % size.height;
      final radius = random.nextDouble() * 4 + 1;
      final opacity = (math.sin(particleAnimationValue * math.pi * 2 + i) + 1) / 2;
      
      particlePaint.color = Colors.deepPurple.withOpacity(opacity * 0.25);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Secondary smaller particles (12 particles)
    final smallParticlePaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = (random.nextDouble() * size.width + particleAnimationValue * 20) % size.width;
      final y = (random.nextDouble() * size.height + particleAnimationValue * 15) % size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      final opacity = (math.cos(particleAnimationValue * math.pi * 1.5 + i) + 1) / 2;
      
      smallParticlePaint.color = Colors.deepPurple.withOpacity(opacity * 0.15);
      canvas.drawCircle(Offset(x, y), radius, smallParticlePaint);
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
