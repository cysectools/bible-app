import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../services/api_service.dart';
import '../widgets/animated_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'verse_screen_image.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEmojiPositions();
    _createEmojis();
  }

  void _initializeAnimations() {
    _emojiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _emojiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emojiController,
      curve: Curves.elasticOut,
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
    final emojiData = [
      {"emoji": "😢", "mood": Mood.sad, "label": "Sad"},
      {"emoji": "😊", "mood": Mood.happy, "label": "Happy"},
      {"emoji": "😠", "mood": Mood.angry, "label": "Angry"},
      {"emoji": "😰", "mood": Mood.anxious, "label": "Anxious"},
      {"emoji": "🙏", "mood": Mood.grateful, "label": "Grateful"},
      {"emoji": "😌", "mood": Mood.peaceful, "label": "Peaceful"},
    ];

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
        onTap: () => _selectMood(emojiData[i]["mood"] as Mood),
        onPositionChanged: (newPosition) {
          _emojiPositions[emojiKey] = newPosition;
          _saveEmojiPositions();
        },
      ));
    }
  }

  Future<void> _selectMood(Mood mood) async {
    setState(() {
      _showVerse = true;
      _currentMood = mood;
    });

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
    final moodVerses = {
      Mood.sad: [
        "The Lord is close to the brokenhearted and saves those who are crushed in spirit. - Psalm 34:18",
        "Come to me, all you who are weary and burdened, and I will give you rest. - Matthew 11:28",
        "He heals the brokenhearted and binds up their wounds. - Psalm 147:3",
        "Cast all your anxiety on him because he cares for you. - 1 Peter 5:7",
        "The Lord your God is with you, the Mighty Warrior who saves. - Zephaniah 3:17"
      ],
      Mood.happy: [
        "This is the day the Lord has made; let us rejoice and be glad in it. - Psalm 118:24",
        "Rejoice in the Lord always. I will say it again: Rejoice! - Philippians 4:4",
        "The joy of the Lord is your strength. - Nehemiah 8:10",
        "In all things God works for the good of those who love him. - Romans 8:28",
        "Shout for joy to the Lord, all the earth! - Psalm 100:1"
      ],
      Mood.angry: [
        "Be still before the Lord and wait patiently for him; do not fret when people succeed in their ways. - Psalm 37:7",
        "A gentle answer turns away wrath, but a harsh word stirs up anger. - Proverbs 15:1",
        "In your anger do not sin. - Ephesians 4:26",
        "Love is patient, love is kind. It does not envy, it does not boast, it is not proud. - 1 Corinthians 13:4",
        "Get rid of all bitterness, rage and anger, brawling and slander. - Ephesians 4:31"
      ],
      Mood.anxious: [
        "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. - Philippians 4:6",
        "Cast all your anxiety on him because he cares for you. - 1 Peter 5:7",
        "Peace I leave with you; my peace I give you. - John 14:27",
        "When anxiety was great within me, your consolation brought me joy. - Psalm 94:19",
        "The Lord is my light and my salvation—whom shall I fear? - Psalm 27:1"
      ],
      Mood.grateful: [
        "Give thanks to the Lord, for he is good; his love endures forever. - Psalm 107:1",
        "In everything give thanks; for this is God's will for you in Christ Jesus. - 1 Thessalonians 5:18",
        "I will give thanks to you, Lord, with all my heart. - Psalm 9:1",
        "Let us come before him with thanksgiving. - Psalm 95:2",
        "Every good and perfect gift is from above. - James 1:17"
      ],
      Mood.peaceful: [
        "Peace I leave with you; my peace I give you. - John 14:27",
        "The Lord gives strength to his people; the Lord blesses his people with peace. - Psalm 29:11",
        "You will keep in perfect peace those whose minds are steadfast, because they trust in you. - Isaiah 26:3",
        "And the peace of God, which transcends all understanding, will guard your hearts and your minds. - Philippians 4:7",
        "The Lord is my shepherd, I lack nothing. - Psalm 23:1"
      ]
    };

    try {
      return await BibleApi.getRandomVerse();
    } catch (e) {
      final verses = moodVerses[mood]!;
      final random = DateTime.now().millisecondsSinceEpoch % verses.length;
      return verses[random];
    }
  }

  void _resetSelection() {
    setState(() {
      _showVerse = false;
      _currentVerse = "";
      _currentMood = null;
    });
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🌟 Space of Emotions"),
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
        drawer: _buildDrawer(),
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
    return AnimatedBuilder(
      animation: _emojiAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _emojiAnimation.value,
          child: Stack(
            children: [
              // Title
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "How are you feeling today?",
                    style: TextStyle(
                      fontSize: 28,
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
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(0.8),
              Colors.indigo.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentVerse,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                height: 1.5,
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
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetSelection,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("New Mood"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VerseImageScreen(verse: _currentVerse),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image, color: Colors.white),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.star, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  'Bible App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Space of emotions',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.deepPurple),
            title: const Text('Home', style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.pop(context);
              widget.onSelectTab?.call(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
            title: const Text('Verses', style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.pop(context);
              widget.onSelectTab?.call(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school, color: Colors.deepPurple),
            title: const Text('Memorization', style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.pop(context);
              widget.onSelectTab?.call(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield, color: Colors.deepPurple),
            title: const Text('Armor of God', style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.pop(context);
              widget.onSelectTab?.call(3);
            },
          ),
          const Divider(color: Colors.deepPurple),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.deepPurple),
            title: const Text('Settings', style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings coming soon!")),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DraggableEmoji extends StatefulWidget {
  final String emoji;
  final Mood mood;
  final String label;
  final Offset initialPosition;
  final VoidCallback onTap;
  final Function(Offset)? onPositionChanged;

  const DraggableEmoji({
    super.key,
    required this.emoji,
    required this.mood,
    required this.label,
    required this.initialPosition,
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
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  bool _isDragging = false;
  bool _showLabel = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _floatAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _showLabel = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
            _showLabel = true;
          });
          widget.onPositionChanged?.call(_position);
        },
        onPanEnd: (details) {
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
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatAnimation, _pulseAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _isDragging ? 0 : _floatAnimation.value),
              child: Transform.scale(
                scale: _isDragging ? 1.3 : _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _isDragging ? 0 : _rotationAnimation.value * 2 * math.pi * 0.1, // Very slow rotation
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
              ),
            );
          },
        ),
      ),
    );
  }
}

