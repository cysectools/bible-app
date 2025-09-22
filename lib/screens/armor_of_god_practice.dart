import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/animated_border_container.dart';
import '../widgets/animated_background.dart';
import 'main_navigation.dart';

class ArmorOfGodPracticeScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab;
  const ArmorOfGodPracticeScreen({super.key, this.onSelectTab});

  @override
  _ArmorOfGodPracticeScreenState createState() => _ArmorOfGodPracticeScreenState();
}

class _ArmorOfGodPracticeScreenState extends State<ArmorOfGodPracticeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late FlutterTts _flutterTts;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _showAdvice = false;
  String _currentArmorPiece = "";
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = 1.0;
  String _currentMode = "listen"; // "listen" or "write"
  final TextEditingController _writingController = TextEditingController();
  String _currentArmorText = "";

  // Armor of God data
  final List<Map<String, String>> _armorPieces = [
    {
      "title": "Belt of Truth",
      "verse": "Stand firm with the belt of truth buckled around your waist",
      "advice": "The belt of truth holds everything together. It represents God's truth as the foundation of our spiritual armor. When we know and live by God's truth, we can stand firm against the enemy's lies and deceptions.",
      "fullText": "Stand firm with the belt of truth buckled around your waist"
    },
    {
      "title": "Breastplate of Righteousness",
      "verse": "With the breastplate of righteousness in place",
      "advice": "The breastplate protects our heart and vital organs. Righteousness guards our heart from the enemy's attacks. It's not our own righteousness, but Christ's righteousness that protects us.",
      "fullText": "With the breastplate of righteousness in place"
    },
    {
      "title": "Shoes of Peace",
      "verse": "With your feet fitted with the readiness that comes from the gospel of peace",
      "advice": "The shoes of peace give us stability and readiness. The gospel of peace prepares us to stand firm and move forward in God's purposes, even in the midst of spiritual battles.",
      "fullText": "With your feet fitted with the readiness that comes from the gospel of peace"
    },
    {
      "title": "Shield of Faith",
      "verse": "Take up the shield of faith, with which you can extinguish all the flaming arrows of the evil one",
      "advice": "Faith is our shield that protects us from the enemy's attacks. When we trust in God's promises and character, we can extinguish the doubts, fears, and lies that the enemy throws at us.",
      "fullText": "Take up the shield of faith, with which you can extinguish all the flaming arrows of the evil one"
    },
    {
      "title": "Helmet of Salvation",
      "verse": "Take the helmet of salvation",
      "advice": "The helmet protects our mind and thoughts. Salvation guards our thinking from the enemy's attempts to make us doubt our identity in Christ and our eternal security.",
      "fullText": "Take the helmet of salvation"
    },
    {
      "title": "Sword of the Spirit",
      "verse": "Take the sword of the Spirit, which is the word of God",
      "advice": "The sword is our only offensive weapon. God's Word is powerful and effective against the enemy. When we know and speak God's truth, we can overcome temptation and spiritual attacks.",
      "fullText": "Take the sword of the Spirit, which is the word of God"
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTts();
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

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _initializeTts() async {
    _flutterTts = FlutterTts();
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
    });
  }

  void _selectArmorPiece(String piece, String advice, String fullText) {
    setState(() {
      _currentArmorPiece = piece;
      _currentArmorText = fullText;
      _showAdvice = true;
      _writingController.clear();
    });
  }

  void _resetSelection() {
    setState(() {
      _showAdvice = false;
      _currentArmorPiece = "";
      _currentArmorText = "";
      _writingController.clear();
    });
  }

  Future<void> _speak() async {
    if (_currentArmorText.isEmpty) return;
    
    if (_isPlaying && !_isPaused) {
      await _flutterTts.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_isPaused) {
      await _flutterTts.speak(_currentArmorText);
      setState(() {
        _isPaused = false;
      });
    } else {
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(_currentArmorText);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  void _setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(_speechRate);
    setState(() {});
  }

  void _checkWriting() {
    final userText = _writingController.text.toLowerCase().trim();
    final correctText = _currentArmorText.toLowerCase().trim();
    
    if (userText == correctText) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Perfect! You got it right!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Keep trying! You're getting closer!"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _flutterTts.stop();
    _writingController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🛡️ Armor of God Practice"),
          titleTextStyle: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        drawer: CustomDrawer(
          currentScreen: 'Armor of God Practice',
          onNavigate: (index) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainNavigation(initialIndex: index),
              ),
            );
          },
        ),
        body: _showAdvice ? _buildPracticeDisplay() : _buildArmorGrid(),
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
                    "Choose an armor piece to practice",
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
                      children: _armorPieces.map((armor) => _buildArmorPiece(
                        armor["title"]!,
                        armor["verse"]!,
                        armor["advice"]!,
                        armor["fullText"]!,
                      )).toList(),
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

  Widget _buildArmorPiece(String title, String verse, String advice, String fullText) {
    return GestureDetector(
      onTap: () => _selectArmorPiece(title, advice, fullText),
      child: AnimatedBorderContainer(
        borderRadius: 20,
        borderColor: const Color(0xFF9E9E9E),
        borderWidth: 3,
        backgroundColor: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E9E9E).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFE0E0E0).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2.5,
            ),
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
                    Icons.shield,
                    size: 32,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
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
                const SizedBox(height: 8),
                Text(
                  verse,
                  style: TextStyle(
                    fontSize: 12,
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeDisplay() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Mode selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton("Listen", "listen", Icons.volume_up),
                _buildModeButton("Write", "write", Icons.edit),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Main practice area
          Expanded(
            child: Container(
              width: double.infinity,
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
              child: _currentMode == "listen" ? _buildListenMode() : _buildWriteMode(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Back button
          ElevatedButton.icon(
            onPressed: _resetSelection,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text("Back to Selection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, IconData icon) {
    final isSelected = _currentMode == mode;
    
    return GestureDetector(
      onTap: () => setState(() => _currentMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.deepPurple 
              : Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenMode() {
    return Column(
      children: [
        Icon(
          Icons.volume_up,
          size: 48,
          color: Colors.deepPurple.withOpacity(0.7),
        ),
        const SizedBox(height: 20),
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
          _currentArmorText,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.deepPurple,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        
        // Speed controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                "Speech Speed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSpeedButton("Slow", 0.5, Icons.slow_motion_video),
                  _buildSpeedButton("Normal", 1.0, Icons.play_arrow),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Play/Pause button
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPlaying && !_isPaused ? _pulseAnimation.value : 1.0,
                  child: ElevatedButton.icon(
                    onPressed: _speak,
                    icon: Icon(
                      _isPlaying && !_isPaused 
                          ? Icons.pause 
                          : _isPaused 
                              ? Icons.play_arrow 
                              : Icons.play_arrow,
                      size: 32,
                    ),
                    label: Text(
                      _isPlaying && !_isPaused 
                          ? "Pause" 
                          : _isPaused 
                              ? "Restart" 
                              : "Play",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                );
              },
            ),
            
            // Stop button
            ElevatedButton.icon(
              onPressed: _isPlaying ? _stop : null,
              icon: const Icon(Icons.stop, size: 32),
              label: const Text(
                "Stop",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying 
                    ? Colors.red 
                    : Colors.white.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWriteMode() {
    return Column(
      children: [
        Icon(
          Icons.edit,
          size: 48,
          color: Colors.deepPurple.withOpacity(0.7),
        ),
        const SizedBox(height: 20),
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
          "Write the verse from memory:",
          style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Writing area
        Expanded(
          child: TextField(
            controller: _writingController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.deepPurple,
            ),
            decoration: InputDecoration(
              hintText: "Type the verse here...",
              hintStyle: TextStyle(
                color: Colors.deepPurple.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Check button
        ElevatedButton.icon(
          onPressed: _checkWriting,
          icon: const Icon(Icons.check, size: 24),
          label: const Text("Check Answer"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Show answer button
        TextButton.icon(
          onPressed: () {
            _writingController.text = _currentArmorText;
          },
          icon: const Icon(Icons.visibility, color: Colors.deepPurple),
          label: const Text(
            "Show Answer",
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedButton(String label, double rate, IconData icon) {
    final isSelected = _speechRate == rate;
    
    return GestureDetector(
      onTap: () => _setSpeechRate(rate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.deepPurple 
              : Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
