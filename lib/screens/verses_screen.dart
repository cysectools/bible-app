import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/memorization_service.dart';

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
      final List<String> fetched = [];
      for (int i = 0; i < 10; i++) {
        final v = await BibleApi.getRandomVerse();
        if (!fetched.contains(v)) fetched.add(v);
      }
      setState(() {
        _verses
          ..clear()
          ..addAll(fetched);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Failed to load verses: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("📖 Verses"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20
          ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search verses...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_isLoading) Expanded(
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _filteredVerses[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
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
                                    icon: const Icon(Icons.bookmark_add),
                                    label: const Text("Memorize"),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      // TODO: Share verse
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Share feature coming soon!")),
                                      );
                                    },
                                    icon: const Icon(Icons.share),
                                    label: const Text("Share"),
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
        ],
      ),
    );
  }
}
