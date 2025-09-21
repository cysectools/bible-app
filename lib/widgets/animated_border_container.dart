import 'package:flutter/material.dart';

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
    this.borderColor = Colors.deepPurple,
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
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    
    _borderController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedBorderPainter(
              animationValue: _borderAnimation.value,
              borderRadius: widget.borderRadius,
              borderColor: widget.borderColor,
              borderWidth: widget.borderWidth,
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

  AnimatedBorderPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Calculate the perimeter of the rounded rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, 
                   size.width - borderWidth, size.height - borderWidth),
      Radius.circular(borderRadius),
    );
    
    // Create the rounded rectangle path
    path.addRRect(rect);
    
    // Calculate the total path length
    final pathMetrics = path.computeMetrics();
    final totalLength = pathMetrics.first.length;
    
    // Calculate the animated segment
    final segmentLength = totalLength * 0.3; // 30% of the perimeter
    final startOffset = (animationValue * totalLength) % totalLength;
    final endOffset = (startOffset + segmentLength) % totalLength;
    
    // Create a new path for the animated segment
    final animatedPath = Path();
    
    if (startOffset < endOffset) {
      // Normal case: segment doesn't wrap around
      final startPoint = pathMetrics.first.getTangentForOffset(startOffset)?.position;
      final endPoint = pathMetrics.first.getTangentForOffset(endOffset)?.position;
      
      if (startPoint != null && endPoint != null) {
        // Extract the segment from the original path
        final segmentPath = pathMetrics.first.extractPath(startOffset, endOffset);
        animatedPath.addPath(segmentPath, Offset.zero);
      }
    } else {
      // Wrapping case: segment goes from end to beginning
      final startPoint = pathMetrics.first.getTangentForOffset(startOffset)?.position;
      final endPoint = pathMetrics.first.getTangentForOffset(endOffset)?.position;
      
      if (startPoint != null && endPoint != null) {
        // Extract two segments: from start to end, and from 0 to endOffset
        final segment1 = pathMetrics.first.extractPath(startOffset, totalLength);
        final segment2 = pathMetrics.first.extractPath(0, endOffset);
        animatedPath.addPath(segment1, Offset.zero);
        animatedPath.addPath(segment2, Offset.zero);
      }
    }
    
    // Draw the animated border segment
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.borderRadius != borderRadius ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth;
  }
}
