import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_border_container.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/animated_button.dart';
import 'armor_of_god_practice.dart';
import 'main_navigation.dart';

class ArmorOfGodScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab;
  const ArmorOfGodScreen({super.key, this.onSelectTab});

  @override
  _ArmorOfGodScreenState createState() => _ArmorOfGodScreenState();
}

class _ArmorOfGodScreenState extends State<ArmorOfGodScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _showAdvice = false;
  String _currentAdvice = "";
  String _currentArmorPiece = "";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _selectArmorPiece(String piece, String advice) {
    setState(() {
      _currentArmorPiece = piece;
      _currentAdvice = advice;
      _showAdvice = true;
    });
  }

  void _resetSelection() {
    setState(() {
      _showAdvice = false;
      _currentAdvice = "";
      _currentArmorPiece = "";
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🛡️ Armor of God"),
          titleTextStyle: TextStyle(
            color: Colors.deepPurple,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.deepPurple),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: CustomDrawer(
          currentScreen: 'Armor of God',
          onNavigate: (index) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainNavigation(initialIndex: index),
              ),
            );
          },
        ),
        body: _showAdvice ? _buildAdviceDisplay() : _buildArmorGrid(),
      ),
    );
  }

  Widget _buildArmorGrid() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    
    // Responsive grid columns
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    final padding = isMobile ? 12.0 : 16.0;
    final spacing = isMobile ? 12.0 : 16.0;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 16 : 20),
                  Text(
                    "Put on the full armor of God",
                    style: TextStyle(
                      fontSize: isMobile ? 20 : (isTablet ? 22 : 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      shadows: [
                        Shadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    "Ephesians 6:10-18",
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.deepPurple.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 20 : 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: isMobile ? 2.2 : 1.3,
                      children: [
                        _buildArmorPiece(
                          "Belt of Truth",
                          "Stand firm with the belt of truth buckled around your waist",
                          Icons.security,
                          "The belt of truth holds everything together. It represents God's truth as the foundation of our spiritual armor. When we know and live by God's truth, we can stand firm against the enemy's lies and deceptions.",
                        ),
                        _buildArmorPiece(
                          "Breastplate of Righteousness",
                          "With the breastplate of righteousness in place",
                          Icons.favorite,
                          "The breastplate protects our heart and vital organs. Righteousness guards our heart from the enemy's attacks. It's not our own righteousness, but Christ's righteousness that protects us.",
                        ),
                        _buildArmorPiece(
                          "Shoes of Peace",
                          "With your feet fitted with the readiness that comes from the gospel of peace",
                          Icons.directions_walk,
                          "The shoes of peace give us stability and readiness. The gospel of peace prepares us to stand firm and move forward in God's purposes, even in the midst of spiritual battles.",
                        ),
                        _buildArmorPiece(
                          "Shield of Faith",
                          "Take up the shield of faith, with which you can extinguish all the flaming arrows of the evil one",
                          Icons.shield,
                          "Faith is our shield that protects us from the enemy's attacks. When we trust in God's promises and character, we can extinguish the doubts, fears, and lies that the enemy throws at us.",
                        ),
                        _buildArmorPiece(
                          "Helmet of Salvation",
                          "Take the helmet of salvation",
                          Icons.psychology,
                          "The helmet protects our mind and thoughts. Salvation guards our thinking from the enemy's attempts to make us doubt our identity in Christ and our eternal security.",
                        ),
                        _buildArmorPiece(
                          "Sword of the Spirit",
                          "Take the sword of the Spirit, which is the word of God",
                          Icons.gavel,
                          "The sword is our only offensive weapon. God's Word is powerful and effective against the enemy. When we know and speak God's truth, we can overcome temptation and spiritual attacks.",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedElevatedButtonIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ArmorOfGodPracticeScreen()),
                        );
                      },
                      icon: Icon(Icons.school, color: Colors.deepPurple, size: isMobile ? 20 : 24),
                      label: Text(
                        'Memorize Armor Of God',
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 24, 
                          vertical: isMobile ? 12 : 16
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArmorPiece(String title, String verse, IconData icon, String advice) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return GestureDetector(
      onTap: () => _selectArmorPiece(title, advice),
      child: AnimatedBorderContainer(
        borderRadius: isMobile ? 16 : 20,
        borderColor: const Color(0xFF9E9E9E),
        borderWidth: isMobile ? 2 : 3,
        backgroundColor: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E9E9E).withOpacity(0.2),
            blurRadius: isMobile ? 10 : 15,
            spreadRadius: isMobile ? 2 : 4,
            offset: Offset(0, isMobile ? 2 : 4),
          ),
          BoxShadow(
            color: const Color(0xFFE0E0E0).withOpacity(0.1),
            blurRadius: isMobile ? 6 : 8,
            spreadRadius: isMobile ? 1 : 2,
            offset: Offset(0, isMobile ? 1 : 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: isMobile ? 3 : 5,
            spreadRadius: isMobile ? 0.5 : 1,
            offset: Offset(0, isMobile ? 0.5 : 1),
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: isMobile ? 2 : 2.5,
            ),
          ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 24 : 32,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 6 : 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      verse,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildAdviceDisplay() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    
    return Center(
      child: Container(
        margin: EdgeInsets.all(isMobile ? 12 : 20),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: isMobile ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: isMobile ? 15 : 20,
              spreadRadius: isMobile ? 3 : 5,
              offset: Offset(0, isMobile ? 4 : 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                child: Icon(
                  Icons.shield,
                  size: isMobile ? 36 : (isTablet ? 44 : 48),
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                _currentArmorPiece,
                style: TextStyle(
                  fontSize: isMobile ? 18 : (isTablet ? 22 : 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                _currentAdvice,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.deepPurple,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 20 : 24),
              isMobile 
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _resetSelection,
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          label: const Text("Back"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Add to memorization or share
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Feature coming soon!")),
                            );
                          },
                          icon: const Icon(Icons.bookmark_add, color: Colors.white),
                          label: const Text("Save"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetSelection,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text("Back"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Add to memorization or share
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Feature coming soon!")),
                          );
                        },
                        icon: const Icon(Icons.bookmark_add, color: Colors.white),
                        label: const Text("Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

}
