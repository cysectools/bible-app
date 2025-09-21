import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_drawer.dart';

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
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🛡️ Armor of God"),
          titleTextStyle: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
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
            Navigator.pop(context);
            widget.onSelectTab?.call(index);
          },
        ),
        body: _showAdvice ? _buildAdviceDisplay() : _buildArmorGrid(),
      ),
    );
  }

  Widget _buildArmorGrid() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Put on the full armor of God",
                    style: TextStyle(
                      fontSize: 24,
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
                  const SizedBox(height: 8),
                  Text(
                    "Ephesians 6:10-18",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArmorPiece(String title, String verse, IconData icon, String advice) {
    return GestureDetector(
      onTap: () => _selectArmorPiece(title, advice),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                verse,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.deepPurple.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceDisplay() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.shield,
                size: 48,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentArmorPiece,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _currentAdvice,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
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
    );
  }

}
