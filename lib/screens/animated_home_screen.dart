import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/animated_background.dart';
import '../widgets/animated_border_container.dart';
import '../widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'verse_screen_image.dart';
import '../services/streaks_service.dart';
import '../services/verses_service.dart';
import '../services/smart_verse_service.dart';
import 'main_navigation.dart';

class AnimatedHomeScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab;
  const AnimatedHomeScreen({super.key, this.onSelectTab});

  @override
  _AnimatedHomeScreenState createState() => _AnimatedHomeScreenState();
}

enum Mood { sad, happy, angry, anxious, grateful, peaceful }

class _AnimatedHomeScreenState extends State<AnimatedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _emojiController;
  late Animation<double> _emojiAnimation;
  
  final List<DraggableEmoji> _emojis = [];
  final math.Random _random = math.Random();
  bool _showVerse = false;
  String _currentVerse = "";
  Map<String, Offset> _emojiPositions = {};
  Mood? _currentMood;
  bool _ocdMode = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Initialize smart verse service and load emoji positions
    SmartVerseService.initialize().then((_) {
      _loadEmojiPositions().then((_) => _createEmojis());
    });
  }

  void _initializeAnimations() {
    _emojiController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Reduced from 3 seconds
      vsync: this,
    );

    _emojiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emojiController,
      curve: Curves.easeOut, // Changed from elasticOut for faster animation
    ));

    _emojiController.forward();
  }

  Future<void> _loadEmojiPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsJson = prefs.getString('emoji_positions');
      if (positionsJson != null) {
        final Map<String, dynamic> positionsMap = json.decode(positionsJson);
        _emojiPositions = positionsMap.map(
          (key, value) => MapEntry(key, Offset(value['dx'], value['dy'])),
        );
      }
    } catch (e) {
      print('Error loading emoji positions: $e');
    }
  }

  Future<void> _saveEmojiPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsMap = _emojiPositions.map(
        (key, value) => MapEntry(key, {'dx': value.dx, 'dy': value.dy}),
      );
      await prefs.setString('emoji_positions', json.encode(positionsMap));
    } catch (e) {
      print('Error saving emoji positions: $e');
    }
  }

  void _createEmojis() {
    _emojis.clear(); // Clear existing emojis
    final emojiData = [
      {"emoji": "😢", "mood": Mood.sad, "label": "Sad"},
      {"emoji": "😊", "mood": Mood.happy, "label": "Happy"},
      {"emoji": "😠", "mood": Mood.angry, "label": "Angry"},
      {"emoji": "😰", "mood": Mood.anxious, "label": "Anxious"},
      {"emoji": "🙏", "mood": Mood.grateful, "label": "Grateful"},
      {"emoji": "😌", "mood": Mood.peaceful, "label": "Peaceful"},
    ];

    // If no saved positions exist, create perfect circle and enable OCD mode
    if (_emojiPositions.isEmpty) {
      _ocdMode = true;
      _createPerfectCirclePositions(emojiData.length);
    }

    for (int i = 0; i < emojiData.length; i++) {
      final emojiKey = emojiData[i]["emoji"] as String;
      final savedPosition = _emojiPositions[emojiKey];
      final initialPosition = savedPosition ?? Offset(
        _random.nextDouble() * 300 + 50,
        _random.nextDouble() * 400 + 100,
      );
      
      _emojis.add(DraggableEmoji(
        emoji: emojiKey,
        mood: emojiData[i]["mood"] as Mood,
        label: emojiData[i]["label"] as String,
        initialPosition: initialPosition,
        ocdMode: _ocdMode,
        onTap: () => _selectMood(emojiData[i]["mood"] as Mood),
        onPositionChanged: (newPosition) {
          if (!_ocdMode) {
            _emojiPositions[emojiKey] = newPosition;
            _saveEmojiPositions();
          }
        },
      ));
    }
    
    print('Created ${_emojis.length} emojis');
    setState(() {}); // Force rebuild to show emojis
  }

  void _createPerfectCirclePositions(int emojiCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Center of the screen
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;
    
    // Radius for the circle (adjust based on screen size)
    final radius = math.min(screenWidth, screenHeight) * 0.25;
    
    final emojiData = [
      {"emoji": "😢", "mood": Mood.sad, "label": "Sad"},
      {"emoji": "😊", "mood": Mood.happy, "label": "Happy"},
      {"emoji": "😠", "mood": Mood.angry, "label": "Angry"},
      {"emoji": "😰", "mood": Mood.anxious, "label": "Anxious"},
      {"emoji": "🙏", "mood": Mood.grateful, "label": "Grateful"},
      {"emoji": "😌", "mood": Mood.peaceful, "label": "Peaceful"},
    ];
    
    for (int i = 0; i < emojiCount; i++) {
      final angle = (2 * math.pi * i) / emojiCount - math.pi / 2; // Start from top
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      _emojiPositions[emojiData[i]["emoji"] as String] = Offset(x, y);
    }
    
    // Save the perfect circle positions
    _saveEmojiPositions();
  }

  Future<void> _selectMood(Mood mood) async {
    setState(() {
      _showVerse = true;
      _currentMood = mood;
    });

    // Record mood selection for streak
    await StreaksService.recordMoodSelection();

    try {
      final verse = await _getMoodSpecificVerse(mood);
      setState(() => _currentVerse = verse);
    } catch (e) {
      setState(() => _currentVerse = "Error loading verse: $e");
    }
  }

  Future<void> _loadNewVerse() async {
    if (_currentMood != null) {
      try {
        setState(() => _currentVerse = "Loading new verse...");
        final verse = await _getMoodSpecificVerse(_currentMood!);
        setState(() => _currentVerse = verse);
      } catch (e) {
        setState(() => _currentVerse = "Error loading verse: $e");
      }
    }
  }

  Future<String> _getMoodSpecificVerse(Mood mood) async {
    try {
      final moodString = mood.toString().split('.').last;
      return await SmartVerseService.getVerseForMood(moodString);
    } catch (e) {
      print('Error getting mood-specific verse: $e');
      // Ultimate fallback
      return "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. - John 3:16";
    }
  }

  void _resetSelection() {
    setState(() {
      _showVerse = false;
      _currentVerse = "";
      _currentMood = null;
    });
    // Ensure emojis are recreated when returning to emoji selection
    _createEmojis();
    // Restart the emoji animation
    _emojiController.reset();
    _emojiController.forward();
  }

  void _toggleOCDMode() {
    setState(() {
      _ocdMode = !_ocdMode;
      if (_ocdMode) {
        _alignEmojis();
      }
      _createEmojis(); // Recreate emojis with new OCD mode
    });
  }

  void _alignEmojis() {
    if (_emojis.isEmpty) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Create a grid layout for emojis
    final cols = 3;
    final rows = 2;
    final cellWidth = (screenWidth - 100) / cols;
    final cellHeight = (screenHeight - 200) / rows;
    
    final alignedPositions = <String, Offset>{};
    
    for (int i = 0; i < _emojis.length && i < cols * rows; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      
      final x = 50 + col * cellWidth + cellWidth / 2 - 30; // Center in cell
      final y = 150 + row * cellHeight + cellHeight / 2 - 30; // Center in cell
      
      alignedPositions[_emojis[i].emoji] = Offset(x, y);
    }
    
    setState(() {
      _emojiPositions = alignedPositions;
    });
    
    // Save the aligned positions
    _saveEmojiPositions();
  }

  @override
  void dispose() {
    _emojiController.dispose();
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
          title: const Text("🌟 Space of Emotions"),
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
          actions: [
            IconButton(
              icon: Icon(
                _ocdMode ? Icons.grid_on : Icons.grid_off,
                color: _ocdMode ? Colors.deepPurple : Colors.grey,
              ),
              onPressed: _toggleOCDMode,
              tooltip: _ocdMode ? 'Disable OCD Mode' : 'Enable OCD Mode',
            ),
          ],
        ),
        drawer: CustomDrawer(
          currentScreen: 'Home',
          onNavigate: (index) {
            Navigator.of(context).pop(); // Close drawer first
            // Use push instead of pushReplacement to avoid navigation errors
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainNavigation(initialIndex: index),
              ),
            );
          },
        ),
        body: Stack(
          children: [
            // Main content
            if (!_showVerse) _buildEmojiSpace(),
            if (_showVerse) _buildVerseDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiSpace() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    
    return AnimatedBuilder(
      animation: _emojiAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _emojiAnimation.value,
          child: Stack(
            children: [
              // Title
              Positioned(
                top: isMobile ? 30 : 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "How are you feeling today?",
                    style: TextStyle(
                      fontSize: isMobile ? 22 : (isTablet ? 25 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      shadows: [
                        Shadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Draggable emojis
              ..._emojis.map((emoji) => emoji),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerseDisplay() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    
    return Center(
      child: AnimatedBorderContainer(
        margin: EdgeInsets.all(isMobile ? 12 : 20),
        padding: EdgeInsets.all(isMobile ? 20 : (isTablet ? 26 : 32)),
        width: MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.9),
        height: MediaQuery.of(context).size.height * (isMobile ? 0.7 : 0.6),
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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Text(
                        _currentVerse,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black87,
                            ),
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadNewVerse,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text("New Verse"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Actions button with popup menu
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
          ),
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
                'Verse Actions',
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
                  // New Mood button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetSelection();
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text("New Mood"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.deepPurple.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Add to Verses button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _addToVerses();
                      },
                      icon: const Icon(Icons.bookmark_add, size: 20),
                      label: const Text("Add to Verses"),
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
                  
                  // Save as Image button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VerseImageScreen(verse: _currentVerse),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image, size: 20),
                      label: const Text("Save as Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Refresh Cache button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _refreshCache();
                      },
                      icon: const Icon(Icons.cloud_download, size: 20),
                      label: const Text("Refresh Cache"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Future<void> _addToVerses() async {
    final success = await VersesService.add(_currentVerse);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Verse added to your collection!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Verse already exists in your collection"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _refreshCache() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔄 Refreshing verse cache..."),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    
    await SmartVerseService.forceRefresh();
    
    // Load a new verse with the refreshed cache
    if (_currentMood != null) {
      try {
        setState(() => _currentVerse = "Loading fresh verse...");
        final verse = await _getMoodSpecificVerse(_currentMood!);
        setState(() => _currentVerse = verse);
      } catch (e) {
        setState(() => _currentVerse = "Error loading fresh verse: $e");
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Verse cache refreshed! Fresh verses loaded."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

}

class DraggableEmoji extends StatefulWidget {
  final String emoji;
  final Mood mood;
  final String label;
  final Offset initialPosition;
  final bool ocdMode;
  final VoidCallback onTap;
  final Function(Offset)? onPositionChanged;

  const DraggableEmoji({
    super.key,
    required this.emoji,
    required this.mood,
    required this.label,
    required this.initialPosition,
    required this.ocdMode,
    required this.onTap,
    this.onPositionChanged,
  });

  @override
  _DraggableEmojiState createState() => _DraggableEmojiState();
}

class _DraggableEmojiState extends State<DraggableEmoji>
    with TickerProviderStateMixin {
  late Offset _position;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _isDragging = false;
  bool _showLabel = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    
    // Simplified to use only one animation controller for better performance
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Reduced duration
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -5.0, // Reduced movement range
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          if (!widget.ocdMode) {
            setState(() {
              _isDragging = true;
              _showLabel = true;
            });
          }
        },
        onPanUpdate: (details) {
          if (!widget.ocdMode) {
            setState(() {
              _position += details.delta;
              _showLabel = true;
            });
            widget.onPositionChanged?.call(_position);
          }
        },
        onPanEnd: (details) {
          if (!widget.ocdMode) {
            setState(() {
              _isDragging = false;
            });
            
            // Hide label after a delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showLabel = false;
                });
              }
            });
          }
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _isDragging ? 0 : _floatAnimation.value),
              child: Transform.scale(
                scale: _isDragging ? 1.3 : 1.0, // Removed pulse animation for better performance
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
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
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    if (_showLabel)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

