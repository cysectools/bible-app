import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'verse_screen_image.dart';
import '/services/api_service.dart';
import '/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab; // 0: Verses, 1: Home, 2: Memorization
  const HomeScreen({super.key, this.onSelectTab});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum Mood { sad, happy, angry }

class _HomeScreenState extends State<HomeScreen> {
  String verse = "Loading verse...";
  final ScreenshotController screenshotController = ScreenshotController();
  Mood? selectedMood;
  bool showMoodSelector = true;

  @override
  void initState() {
    super.initState();
    // Don't load verse immediately - wait for mood selection
  }

  Future<void> _loadVerse({Mood? mood}) async {
    try {
      // Show loading state
      setState(() => verse = "Loading verse...");
      
      print("🔄 Starting to load verse...");
      String fetchedVerse;
      
      if (mood != null) {
        // Load mood-specific verse
        fetchedVerse = await _getMoodSpecificVerse(mood);
      } else {
        // Load daily verse
        fetchedVerse = await BibleApi.getVerse();
      }
      
      print("✅ Verse loaded successfully: $fetchedVerse");
      
      setState(() => verse = fetchedVerse);
    } catch (e) {
      setState(() => verse = "⚠️ Error loading verse: $e");
    }

    // Daily reminder at 9AM
    await NotificationService().scheduleDailyReminder(9, 0);
  }

  Future<String> _getMoodSpecificVerse(Mood mood) async {
    // Mood-specific verses
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
      ]
    };

    // Try to get a random verse from the API first, then fallback to mood-specific
    try {
      return await BibleApi.getRandomVerse();
    } catch (e) {
      // Fallback to mood-specific verses
      final verses = moodVerses[mood]!;
      final random = DateTime.now().millisecondsSinceEpoch % verses.length;
      return verses[random];
    }
  }

  Future<void> _loadRandomVerse() async {
    try {
      setState(() => verse = "Loading verse...");
      print("🎲 Fetching random verse...");
      final fetchedVerse = await BibleApi.getRandomVerse();
      print("✅ Random verse loaded: $fetchedVerse");
      setState(() => verse = fetchedVerse);
    } catch (e) {
      setState(() => verse = "⚠️ Error loading verse: $e");
    }
  }

  void _selectMood(Mood mood) {
    setState(() {
      selectedMood = mood;
      showMoodSelector = false;
    });
    _loadVerse(mood: mood);
  }

  void _showMoodSelectorAgain() {
    setState(() {
      showMoodSelector = true;
      selectedMood = null;
      verse = "Loading verse...";
    });
  }

  // Removed legacy save flow; now handled in VerseImageScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("📖 Daily Bible Verse"),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.book, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Bible App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Daily inspiration',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                widget.onSelectTab?.call(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Verses'),
              onTap: () {
                Navigator.pop(context);
                widget.onSelectTab?.call(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Memorization'),
              onTap: () {
                Navigator.pop(context);
                widget.onSelectTab?.call(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings coming soon!")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Bible App',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.book, size: 48),
                );
              },
            ),
          ],
        ),
      ),
      body: showMoodSelector ? _buildMoodSelector() : _buildMainContent(),
    );
  }

  Widget _buildMoodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "How're we feeling today?",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodButton("😢", Mood.sad),
                _buildMoodButton("😊", Mood.happy),
                _buildMoodButton("😠", Mood.angry),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(String emoji, Mood mood) {
    return GestureDetector(
      onTap: () => _selectMood(mood),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 60),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.indigo.shade400
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.book, color: Colors.white, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      verse,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                print("🔘 New Verse button pressed!");
                _loadRandomVerse();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("New Verse"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VerseImageScreen(verse: verse),
                  ),
                );
              },
              icon: const Icon(Icons.image),
              label: const Text("Save as Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _showMoodSelectorAgain,
              icon: const Icon(Icons.mood),
              label: const Text("Change Mood"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
