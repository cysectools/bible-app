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
  
  // Hints system
  List<String> _currentWords = [];
  List<bool> _revealedWords = [];
  int _hintsUsed = 0;
  
  // Gamification
  int _userPoints = 0;
  int _totalCorrectAnswers = 0;
  bool _hasUnlockedThemes = false;
  bool _hasUnlockedBadges = false;
  

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
    
    // Configure TTS to work with both bluetooth and regular audio
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);
    
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
      
      // Initialize hints system
      _currentWords = fullText.split(' ');
      _revealedWords = List.filled(_currentWords.length, false);
      _hintsUsed = 0;
    });
  }

  void _resetSelection() {
    setState(() {
      _showAdvice = false;
      _currentArmorPiece = "";
      _currentArmorText = "";
      _writingController.clear();
      _currentWords.clear();
      _revealedWords.clear();
      _hintsUsed = 0;
    });
  }

  void _revealHint() {
    if (_hintsUsed < _currentWords.length) {
      setState(() {
        _revealedWords[_hintsUsed] = true;
        _hintsUsed++;
      });
    }
  }

  void _checkWriting() {
    final userText = _writingController.text.toLowerCase().trim();
    final correctText = _currentArmorText.toLowerCase().trim();
    
    if (userText == correctText) {
      // Award points for correct answer without hints
      final pointsEarned = _hintsUsed == 0 ? 5 : 2; // 5 points if no hints, 2 if hints used
      setState(() {
        _userPoints += pointsEarned;
        _totalCorrectAnswers++;
        
        // Check for unlocks
        if (_userPoints >= 500 && !_hasUnlockedThemes) {
          _hasUnlockedThemes = true;
        }
        if (_userPoints >= 1000 && !_hasUnlockedBadges) {
          _hasUnlockedBadges = true;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Perfect! You earned $pointsEarned points! Total: $_userPoints"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _showAdvice ? _buildPracticeDisplay() : _buildArmorGrid(),
          ),
        ),
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
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

  Widget _buildPracticeDisplay() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        children: [
          // Points display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "$_userPoints",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const Text(
                      "Points",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "$_totalCorrectAnswers",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const Text(
                      "Correct",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                if (_hasUnlockedThemes)
                  const Column(
                    children: [
                      Icon(Icons.palette, color: Colors.green, size: 24),
                      Text(
                        "Themes",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                if (_hasUnlockedBadges)
                  const Column(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.orange, size: 24),
                      Text(
                        "Badges",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
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
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: isMobile ? 400 : 500,
              maxHeight: isMobile ? 600 : 700,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(0.3),
                width: 2,
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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return Column(
      children: [
        Icon(
          Icons.volume_up,
          size: isMobile ? 40 : 48,
          color: Colors.deepPurple.withOpacity(0.7),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          _currentArmorPiece,
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          _currentArmorText,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: Colors.deepPurple,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 20 : 30),
        
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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return Column(
      children: [
        Icon(
          Icons.edit,
          size: isMobile ? 40 : 48,
          color: Colors.deepPurple.withOpacity(0.7),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          _currentArmorPiece,
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          "Write the verse from memory:",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.deepPurple.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        
        // Hints display
        if (_currentWords.isNotEmpty) ...[
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            ),
            child: Wrap(
              spacing: isMobile ? 2 : 4,
              runSpacing: isMobile ? 2 : 4,
              children: _currentWords.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                final isRevealed = _revealedWords[index];
                
                return Container(
                  margin: EdgeInsets.all(isMobile ? 1 : 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8, 
                    vertical: isMobile ? 3 : 4
                  ),
                  decoration: BoxDecoration(
                    color: isRevealed 
                        ? Colors.deepPurple.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRevealed 
                          ? Colors.deepPurple.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isRevealed ? word : "___",
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: isRevealed 
                          ? Colors.deepPurple
                          : Colors.grey,
                      fontWeight: isRevealed 
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Writing area - responsive height
        Container(
          constraints: BoxConstraints(
            minHeight: isMobile ? 120 : 150,
            maxHeight: isMobile ? 200 : 250,
          ),
          child: TextField(
            controller: _writingController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.deepPurple,
            ),
            decoration: InputDecoration(
              hintText: "Type the verse here...",
              hintStyle: TextStyle(
                color: Colors.deepPurple.withOpacity(0.5),
                fontSize: isMobile ? 14 : 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                borderSide: BorderSide(
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
            ),
          ),
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Action buttons with popup menu
        Column(
          children: [
            // Main action button that opens popup
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showActionMenu(context);
                },
                icon: Icon(Icons.more_horiz, color: Colors.white, size: isMobile ? 20 : 24),
                label: Text(
                  "Actions",
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
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  ),
                ),
              ),
            ),
          ],
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

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Practice Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Hint button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (_hintsUsed < _currentWords.length) {
                          _revealHint();
                        }
                      },
                      icon: const Icon(Icons.lightbulb_outline, size: 20),
                      label: Text("Hint ($_hintsUsed/${_currentWords.length})"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Check button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _checkWriting();
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text("Check Answer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Show answer button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _writingController.text = _currentArmorText;
                      },
                      icon: const Icon(Icons.visibility, color: Colors.deepPurple),
                      label: const Text(
                        "Show Full Answer",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
