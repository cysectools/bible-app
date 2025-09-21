import 'package:flutter/material.dart';
import '../services/streaks_service.dart';

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
  late AnimationController _slideController;
  late Animation<double> _bubbleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isBubbleOpen = false;
  int _currentStreak = 0;

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _loadCurrentStreak();
  }

  Future<void> _loadCurrentStreak() async {
    final streak = await StreaksService.getCurrentStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
      });
    }
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleBubble() {
    setState(() {
      _isBubbleOpen = !_isBubbleOpen;
    });

    if (_isBubbleOpen) {
      _bubbleController.forward();
      _slideController.forward();
    } else {
      _bubbleController.reverse();
      _slideController.reverse();
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
                    colors: [Colors.deepPurple, Color(0xFF4A2C7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
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
                    // Streaks counter in top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_currentStreak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main tabs (4 tabs above the line)
              ..._mainTabs.map((tab) => _buildMainTabItem(tab)),
              
              // Divider line
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: const Divider(
                  color: Colors.deepPurple,
                  thickness: 1,
                ),
              ),
              
              // More button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: _toggleBubble,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isBubbleOpen 
                          ? Colors.deepPurple.withOpacity(0.2)
                          : Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isBubbleOpen ? Icons.close : Icons.more_horiz,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isBubbleOpen ? 'Close' : 'More Options',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Settings and About
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text('Settings', style: TextStyle(color: Colors.deepPurple)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Settings coming soon!")),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
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
              ),
            ],
          ),
          
          // Floating overflow bubble
          if (_isBubbleOpen)
            Positioned(
              top: 280,
              left: 20,
              right: 20,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _bubbleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bubble header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.apps,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'More Options',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _toggleBubble,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Overflow tabs
                        ..._overflowTabs.map((tab) => _buildBubbleItem(tab)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainTabItem(Map<String, dynamic> tab) {
    final isSelected = _isCurrentTab(tab['index']);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          tab['icon'],
          color: isSelected ? Colors.deepPurple : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          tab['label'],
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          widget.onNavigate(tab['index']);
        },
      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.deepPurple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.deepPurple.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tab['icon'],
                color: isSelected ? Colors.deepPurple : Colors.grey[600],
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              tab['label'],
              style: TextStyle(
                color: isSelected ? Colors.deepPurple : Colors.grey[700],
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
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
