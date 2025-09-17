import 'package:flutter/material.dart';
import '../services/memorization_service.dart';
import 'flashcard_screen.dart'; // 👈 import the flashcard screen

class MemorizationScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab; // 0: Verses, 1: Home, 2: Memorization
  const MemorizationScreen({super.key, this.onSelectTab});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen>
    with RouteAware {
  List<String> _memorizedVerses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await MemorizationService.getAll();
    if (!mounted) return;
    setState(() => _memorizedVerses = items);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // reload whenever this screen is revisited
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Daily Bible Verse"),
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
                  applicationVersion: '1.0.1',
                  applicationIcon: const Icon(Icons.book, size: 48),
                );
              },
            ),
          ],
        ),
      ),


      body: RefreshIndicator(
        onRefresh: _load,
        child: _memorizedVerses.isEmpty
            ? ListView( // so RefreshIndicator can still pull-to-refresh
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No verses memorized yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start memorizing verses from the Home screen!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _memorizedVerses.length,
                itemBuilder: (context, index) {
                  final verse = _memorizedVerses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verse,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // 👇 navigate to FlashcardScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FlashcardScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("Practice"),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final removed = await MemorizationService.remove(verse);
                                  if (removed) {
                                    await _load();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Verse removed from memorization")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text("Remove"),
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
    );
  }
}
