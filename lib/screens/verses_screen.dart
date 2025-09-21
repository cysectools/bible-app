import 'package:flutter/material.dart';
import '../services/memorization_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_border_container.dart';
import '../widgets/custom_drawer.dart';
import '../services/api_service.dart';
import 'main_navigation.dart';

class VersesScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab; // 0: Verses, 1: Home, 2: Memorization
  const VersesScreen({super.key, this.onSelectTab});

  @override
  _VersesScreenState createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _verses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    setState(() => _isLoading = true);
    
    try {
      // Try to get a random verse from API
      final randomVerse = await BibleApi.getRandomVerse();
      setState(() {
        _verses
          ..clear()
          ..add(randomVerse);
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to local verses if API fails
      final List<String> localVerses = [
        "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. - John 3:16",
        "I can do all this through him who gives me strength. - Philippians 4:13",
        "Trust in the Lord with all your heart and lean not on your own understanding. - Proverbs 3:5",
        "The Lord is my shepherd, I lack nothing. - Psalm 23:1",
        "And we know that in all things God works for the good of those who love him. - Romans 8:28",
        "Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go. - Joshua 1:9",
        "Cast all your anxiety on him because he cares for you. - 1 Peter 5:7",
        "The Lord gives strength to his people; the Lord blesses his people with peace. - Psalm 29:11",
        "You will keep in perfect peace those whose minds are steadfast, because they trust in you. - Isaiah 26:3",
        "And the peace of God, which transcends all understanding, will guard your hearts and your minds. - Philippians 4:7"
      ];
      
      setState(() {
        _verses
          ..clear()
          ..addAll(localVerses);
        _isLoading = false;
      });
    }
  }

  List<String> get _filteredVerses {
    if (_searchController.text.isEmpty) return _verses;
    return _verses
        .where((verse) => verse.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("📖 Verses"),
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
          currentScreen: 'Verses',
          onNavigate: (index) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainNavigation(initialIndex: index),
              ),
            );
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search verses...",
                    hintStyle: TextStyle(color: Colors.deepPurple.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear, color: Colors.deepPurple),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_isLoading)
              Expanded(
                child: _filteredVerses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No verses found",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Try a different search term",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredVerses.length,
                        itemBuilder: (context, index) {
                          return AnimatedBorderContainer(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            borderRadius: 20,
                            borderColor: Colors.deepPurple,
                            borderWidth: 2,
                            backgroundColor: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _filteredVerses[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.deepPurple,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        final added = await MemorizationService.add(_filteredVerses[index]);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(added ? "Added to memorization!" : "Already memorized.")),
                                        );
                                      },
                                      icon: const Icon(Icons.bookmark_add, color: Colors.deepPurple),
                                      label: const Text("Memorize", style: TextStyle(color: Colors.deepPurple)),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        // TODO: Share verse
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Share feature coming soon!")),
                                        );
                                      },
                                      icon: const Icon(Icons.share, color: Colors.deepPurple),
                                      label: const Text("Share", style: TextStyle(color: Colors.deepPurple)),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
