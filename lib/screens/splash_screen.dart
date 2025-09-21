import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'main_navigation.dart';
import '../utils/performance_monitor.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _swirlController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<double> _swirlAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers (reduced durations for faster launch)
    _swirlController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animations
    _swirlAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _swirlController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _startAnimations();

    // Wait for animations to complete then navigate (reduced from 3000ms to 1500ms)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        PerformanceMonitor.endTimer('app_launch');
        PerformanceMonitor.logLaunchTime();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    });
  }

  void _startAnimations() async {
    // Start swirl animation immediately
    _swirlController.forward();
    
    // Start scale animation after a short delay
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    // Start fade animation after swirl begins
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _swirlController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _swirlAnimation,
            _fadeAnimation,
            _scaleAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with swirl effect
                    Transform.rotate(
                      angle: _swirlAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Animated app title
                    Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(_swirlAnimation.value * 2) * 5,
                      ),
                      child: const Text(
                        "Bible App",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Animated verse text
                    Transform.translate(
                      offset: Offset(
                        0,
                        math.cos(_swirlAnimation.value * 2) * 3,
                      ),
                      child: const Text(
                        "\"Thy word have I hid in mine heart…\"",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Animated loading indicator
                    Transform.rotate(
                      angle: _swirlAnimation.value * 2,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
