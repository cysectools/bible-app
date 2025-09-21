import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;
  bool _isBubbleOpen = false;

  final List<Map<String, dynamic>> _mainTabs = [
    {'icon': Icons.menu_book, 'label': 'Verses', 'index': 0},
    {'icon': Icons.home, 'label': 'Home', 'index': 1},
    {'icon': Icons.school, 'label': 'Memorization', 'index': 2},
    {'icon': Icons.shield, 'label': 'Armor', 'index': 3},
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
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main bottom navigation
          Row(
            children: [
              // Main tabs
              ..._mainTabs.map((tab) => Expanded(
                    child: _buildNavItem(tab),
                  )),
              // Overflow button
              SizedBox(
                width: 60,
                child: _buildOverflowButton(),
              ),
            ],
          ),
          
          // Floating bubble drawer
          Positioned(
            bottom: 80,
            right: 10,
            child: AnimatedBuilder(
              animation: _bubbleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bubbleAnimation.value,
                  child: Opacity(
                    opacity: _bubbleAnimation.value,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
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
                              color: Colors.deepPurple,
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
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'More',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggleBubble,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
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

  Widget _buildNavItem(Map<String, dynamic> tab) {
    final isSelected = widget.currentIndex == tab['index'];
    return GestureDetector(
      onTap: () => widget.onTap(tab['index']),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab['icon'],
              color: isSelected ? Colors.deepPurple : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              tab['label'],
              style: TextStyle(
                color: isSelected ? Colors.deepPurple : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverflowButton() {
    return GestureDetector(
      onTap: _toggleBubble,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isBubbleOpen 
                    ? Colors.deepPurple 
                    : Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _isBubbleOpen ? Icons.close : Icons.more_horiz,
                color: _isBubbleOpen ? Colors.white : Colors.deepPurple,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'More',
              style: TextStyle(
                color: _isBubbleOpen ? Colors.deepPurple : Colors.grey,
                fontSize: 10,
                fontWeight: _isBubbleOpen ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleItem(Map<String, dynamic> tab) {
    final isSelected = widget.currentIndex == tab['index'];
    return GestureDetector(
      onTap: () {
        widget.onTap(tab['index']);
        _toggleBubble();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              tab['icon'],
              color: isSelected ? Colors.deepPurple : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              tab['label'],
              style: TextStyle(
                color: isSelected ? Colors.deepPurple : Colors.grey[600],
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
}
