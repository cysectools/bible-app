import 'package:flutter/material.dart';
import '../services/memorization_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_border_container.dart';
import '../widgets/custom_drawer.dart';
import 'auditory_practice_screen.dart'; // 👈 import the auditory practice screen
import 'main_navigation.dart';

class MemorizationScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab; // 0: Verses, 1: Home, 2: Memorization
  const MemorizationScreen({super.key, this.onSelectTab});

  @override
  _MemorizationScreenState createState() => _MemorizationScreenState();
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
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("📚 Memorization"),
          titleTextStyle: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.deepPurple),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),

        drawer: CustomDrawer(
          currentScreen: 'Memorization',
          onNavigate: (index) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainNavigation(initialIndex: index),
              ),
            );
          },
        ),

        body: RefreshIndicator(
          onRefresh: _load,
          child: _memorizedVerses.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.bookmark_border,
                                size: 64, color: Colors.deepPurple),
                            SizedBox(height: 16),
                            Text(
                              "No verses memorized yet",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Start memorizing verses from the Home screen!",
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _memorizedVerses.length,
                  itemBuilder: (context, index) {
                    final verse = _memorizedVerses[index];
                    return AnimatedBorderContainer(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
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
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            verse,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black54,
                                ),
                              ],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AuditoryPracticeScreen(verse: verse),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.volume_up,
                                    color: Colors.deepPurple),
                                label: const Text("Listen",
                                    style:
                                        TextStyle(color: Colors.deepPurple)),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurple.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final removed =
                                      await MemorizationService.remove(verse);
                                  if (removed) {
                                    await _load();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Verse removed from memorization")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.deepPurple),
                                label: const Text("Remove",
                                    style:
                                        TextStyle(color: Colors.deepPurple)),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurple.withOpacity(0.1),
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
                  },
                ),
        ),
      ),
    );
  }
}
