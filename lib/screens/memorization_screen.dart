import 'package:flutter/material.dart';
import '../services/memorization_service.dart';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Memorization"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _memorizedVerses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _memorizedVerses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _memorizedVerses[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Practice mode coming soon!")),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Practice"),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final removed = await MemorizationService.remove(_memorizedVerses[index]);
                                if (removed) {
                                  await _load();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Verse removed from memorization")),
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
    );
  }
}
