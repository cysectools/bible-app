import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/memorization_service.dart';
import '../widgets/animated_background.dart';

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
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.menu_book, color: Colors.white, size: 48),
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
                      'Verses',
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
              ListTile(
                leading: const Icon(Icons.note, color: Colors.deepPurple),
                title: const Text('Notes', style: TextStyle(color: Colors.deepPurple)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSelectTab?.call(4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.deepPurple),
                title: const Text('Groups', style: TextStyle(color: Colors.deepPurple)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSelectTab?.call(5);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: const Text('Profile', style: TextStyle(color: Colors.deepPurple)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSelectTab?.call(6);
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
              ListTile(
                leading: const Icon(Icons.info, color: Colors.deepPurple),
                title: const Text('About', style: TextStyle(color: Colors.deepPurple)),
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: Padding(
                              padding: const EdgeInsets.all(20),
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
