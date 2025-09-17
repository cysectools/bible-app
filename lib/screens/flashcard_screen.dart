import 'package:flutter/material.dart';
import '../services/memorization_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<String> verses = [];
  int currentIndex = 0;
  bool showVerse = false;

  @override
  void initState() {
    super.initState();
    _loadMemorizedVerses();
  }

  Future<void> _loadMemorizedVerses() async {
    final items = await MemorizationService.getAll();
    if (!mounted) return;
    setState(() => verses = items);
  }

  void _flipCard() {
    setState(() => showVerse = !showVerse);
  }

  void _nextCard() {
    if (verses.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + 1) % verses.length;
      showVerse = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Flashcards"),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text(
            "No memorized verses available.\nAdd some first!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final verse = verses[currentIndex];
    final parts = verse.split(" - ");
    final text = parts.isNotEmpty ? parts[0] : verse;
    final reference = parts.length > 1 ? parts[1] : "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                showVerse ? text : reference,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextCard,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
