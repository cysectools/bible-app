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

    // Wait for animations to complete then navigate (extended to 2500ms for better experience)
    Future.delayed(const Duration(milliseconds: 2500), () {
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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A1B9A), // Deep purple
              Color(0xFF8E24AA), // Medium purple
              Color(0xFFAB47BC), // Light purple
              Color(0xFFBA68C8), // Very light purple
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background swirls
            ...List.generate(3, (index) {
              return Positioned(
                top: 50 + (index * 100),
                left: 20 + (index * 50),
                child: AnimatedBuilder(
                  animation: _swirlAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _swirlAnimation.value * (index + 1) * 0.5,
                      child: Transform.scale(
                        scale: 0.5 + (index * 0.2),
                        child: Container(
                          width: 80 + (index * 20),
                          height: 80 + (index * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.1 - (index * 0.02)),
                                Colors.white.withOpacity(0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            
            // Main content
            Center(
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
                          // Main animated logo with enhanced swirl effect
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer rotating ring
                              Transform.rotate(
                                angle: _swirlAnimation.value * 1.5,
                                child: Container(
                                  width: isMobile ? 140 : (isTablet ? 160 : 180),
                                  height: isMobile ? 140 : (isTablet ? 160 : 180),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.15),
                                        Colors.white.withOpacity(0.05),
                                        Colors.transparent,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: isMobile ? 1.5 : 2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Middle rotating ring
                              Transform.rotate(
                                angle: -_swirlAnimation.value * 0.8,
                                child: Container(
                                  width: isMobile ? 110 : (isTablet ? 125 : 140),
                                  height: isMobile ? 110 : (isTablet ? 125 : 140),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.03),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Inner logo
                              Transform.rotate(
                                angle: _swirlAnimation.value * 0.3,
                                child: Container(
                                  padding: EdgeInsets.all(isMobile ? 20 : (isTablet ? 22 : 25)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: isMobile ? 15 : 20,
                                        spreadRadius: isMobile ? 3 : 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    size: isMobile ? 60 : (isTablet ? 70 : 80),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 30 : 40),
                          
                          // Animated app title with glow effect
                          Transform.translate(
                            offset: Offset(
                              0,
                              math.sin(_swirlAnimation.value * 2) * (isMobile ? 6 : 8),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: isMobile ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: isMobile ? 12 : 15,
                                    spreadRadius: isMobile ? 1.5 : 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                "Bible App",
                                style: TextStyle(
                                  fontSize: isMobile ? 28 : (isTablet ? 32 : 36),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: isMobile ? 2 : 3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: isMobile ? 8 : 10,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Animated verse text with floating effect
                          Transform.translate(
                            offset: Offset(
                              0,
                              math.cos(_swirlAnimation.value * 2) * 5,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                "\"Thy word have I hid in mine heart…\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // Enhanced animated loading indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer rotating ring
                              Transform.rotate(
                                angle: _swirlAnimation.value * 3,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Inner rotating heart
                              Transform.rotate(
                                angle: -_swirlAnimation.value * 2,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.8),
                                        Colors.white.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: Colors.pink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
