import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  final String currentScreen;
  final Function(int) onNavigate;

  const CustomDrawer({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;
  bool _isBubbleOpen = false;

  final List<Map<String, dynamic>> _mainTabs = [
    {'icon': Icons.home, 'label': 'Home', 'index': 1},
    {'icon': Icons.menu_book, 'label': 'Verses', 'index': 0},
    {'icon': Icons.school, 'label': 'Memorization', 'index': 2},
    {'icon': Icons.shield, 'label': 'Armor of God', 'index': 3},
  ];

  final List<Map<String, dynamic>> _overflowTabs = [
    {'icon': Icons.note, 'label': 'Notes', 'index': 4},
    {'icon': Icons.group, 'label': 'Groups', 'index': 5},
    {'icon': Icons.person, 'label': 'Profile', 'index': 6},
  ];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  void _toggleBubble() {
    setState(() {
      _isBubbleOpen = !_isBubbleOpen;
    });

    if (_isBubbleOpen) {
      _bubbleController.forward();
    } else {
      _bubbleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getScreenIcon(),
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bible App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.currentScreen,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
              // Main tabs
              ..._mainTabs.map((tab) => _buildMainTabItem(tab)),
              
              // Overflow section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Colors.deepPurple),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A4C93).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onTap: _toggleBubble,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isBubbleOpen ? Icons.close : Icons.more_horiz,
                              color: const Color(0xFF6A4C93),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'More',
                              style: TextStyle(
                                color: const Color(0xFF6A4C93),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
              
              // Settings and About
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
          
          // Floating overflow bubble
          Positioned(
            top: 200,
            right: 20,
            child: AnimatedBuilder(
              animation: _bubbleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bubbleAnimation.value,
                  child: Opacity(
                    opacity: _bubbleAnimation.value,
                    child: Container(
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A4C93).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bubble header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6A4C93),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.more_horiz,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'More',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggleBubble,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Overflow tabs
                          ..._overflowTabs.map((tab) => _buildBubbleItem(tab)),
                        ],
                      ),
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

  Widget _buildMainTabItem(Map<String, dynamic> tab) {
    final isSelected = _isCurrentTab(tab['index']);
    return ListTile(
      leading: Icon(
        tab['icon'],
        color: isSelected ? const Color(0xFF6A4C93) : Colors.grey[600],
      ),
      title: Text(
        tab['label'],
        style: TextStyle(
          color: isSelected ? const Color(0xFF6A4C93) : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onNavigate(tab['index']);
      },
    );
  }

  Widget _buildBubbleItem(Map<String, dynamic> tab) {
    final isSelected = _isCurrentTab(tab['index']);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.onNavigate(tab['index']);
        _toggleBubble();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              tab['icon'],
              color: isSelected ? const Color(0xFF6A4C93) : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              tab['label'],
              style: TextStyle(
                color: isSelected ? const Color(0xFF6A4C93) : Colors.grey[600],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF6A4C93),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isCurrentTab(int index) {
    // This is a simplified check - in a real app you'd want to track the current tab more precisely
    return false; // For now, we'll let the main navigation handle selection
  }

  IconData _getScreenIcon() {
    switch (widget.currentScreen.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'verses':
        return Icons.menu_book;
      case 'memorization':
        return Icons.school;
      case 'armor of god':
        return Icons.shield;
      case 'notes':
        return Icons.note;
      case 'groups':
        return Icons.group;
      case 'profile':
        return Icons.person;
      default:
        return Icons.book;
    }
  }
}
