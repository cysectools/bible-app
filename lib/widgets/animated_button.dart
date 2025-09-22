import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration animationDuration;
  final double scaleFactor;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class AnimatedElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration animationDuration;
  final double scaleFactor;

  const AnimatedElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      animationDuration: animationDuration,
      scaleFactor: scaleFactor,
      child: ElevatedButton(
        onPressed: null, // Disable default onPressed
        style: style,
        child: child,
      ),
    );
  }
}

class AnimatedElevatedButtonIcon extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration animationDuration;
  final double scaleFactor;

  const AnimatedElevatedButtonIcon({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.style,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      animationDuration: animationDuration,
      scaleFactor: scaleFactor,
      child: ElevatedButton.icon(
        onPressed: null, // Disable default onPressed
        icon: icon,
        label: label,
        style: style,
      ),
    );
  }
}
