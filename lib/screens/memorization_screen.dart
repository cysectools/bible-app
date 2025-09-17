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
        title: const Text("📚 Memorization"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
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
