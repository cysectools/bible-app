import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBorderContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;

  const AnimatedBorderContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.borderColor = const Color(0xFF9E9E9E),
    this.borderWidth = 2.0,
    this.backgroundColor,
    this.boxShadow,
    this.width,
    this.height,
  });

  @override
  State<AnimatedBorderContainer> createState() => _AnimatedBorderContainerState();
}

class _AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with TickerProviderStateMixin {
  late AnimationController _borderController;
  late AnimationController _lineController;
  late AnimationController _particleController;
  late Animation<double> _borderAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _borderController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _lineController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.linear,
    ));

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
    _borderController.dispose();
    _lineController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: Listenable.merge([_borderAnimation, _lineAnimation, _particleAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedBorderPainter(
              animationValue: _borderAnimation.value,
              borderRadius: widget.borderRadius,
              borderColor: widget.borderColor,
              borderWidth: widget.borderWidth,
              lineAnimationValue: _lineAnimation.value,
              particleAnimationValue: _particleAnimation.value,
            ),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.boxShadow,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final double lineAnimationValue;
  final double particleAnimationValue;

  AnimatedBorderPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.lineAnimationValue,
    required this.particleAnimationValue,
  });

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

    // Draw animated border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate the perimeter for animation (inside the container)
    final inset = borderWidth + 4; // Move border inside by this amount
    final innerWidth = size.width - (2 * inset);
    final innerHeight = size.height - (2 * inset);
    final perimeter = 2 * (innerWidth + innerHeight);
    final segmentLength = perimeter * 0.4; // 40% of the perimeter
    final startOffset = (animationValue * perimeter) % perimeter;
    
    // Create the animated segment path
    final animatedPath = Path();
    
    // Top edge (inside)
    if (startOffset < innerWidth) {
      final startX = inset + startOffset;
      final endX = (startX + segmentLength).clamp(inset, size.width - inset);
      animatedPath.moveTo(startX, inset);
      animatedPath.lineTo(endX, inset);
    }
    // Right edge (inside)
    else if (startOffset < innerWidth + innerHeight) {
      final startY = inset + (startOffset - innerWidth);
      final endY = (startY + segmentLength).clamp(inset, size.height - inset);
      animatedPath.moveTo(size.width - inset, startY);
      animatedPath.lineTo(size.width - inset, endY);
    }
    // Bottom edge (inside)
    else if (startOffset < 2 * innerWidth + innerHeight) {
      final startX = size.width - inset - (startOffset - innerWidth - innerHeight);
      final endX = (startX - segmentLength).clamp(inset, size.width - inset);
      animatedPath.moveTo(startX, size.height - inset);
      animatedPath.lineTo(endX, size.height - inset);
    }
    // Left edge (inside)
    else {
      final startY = size.height - inset - (startOffset - 2 * innerWidth - innerHeight);
      final endY = (startY - segmentLength).clamp(inset, size.height - inset);
      animatedPath.moveTo(inset, startY);
      animatedPath.lineTo(inset, endY);
    }
    
    // Draw the animated border segment
    canvas.drawPath(animatedPath, borderPaint);
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.borderRadius != borderRadius ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth ||
           oldDelegate.lineAnimationValue != lineAnimationValue ||
           oldDelegate.particleAnimationValue != particleAnimationValue;
  }
}
