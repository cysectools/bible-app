// import 'package:bible_app/screens/armor_of_god.dart';
import 'package:flutter/material.dart';
import 'animated_home_screen.dart';
import 'verses_screen.dart';
import 'memorization_screen.dart';
import 'armor_of_god_screen.dart';
import 'notes_list_screen.dart';
import 'groups_list_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  final int? initialIndex;
  
  const MainNavigation({super.key, this.initialIndex});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  final Map<int, Widget> _screenCache = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 1; // Start on Home (middle tab)
  }

  Widget _getScreen(int index) {
    if (_screenCache.containsKey(index)) {
      return _screenCache[index]!;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = VersesScreen(
          onSelectTab: (index) => setState(() => _currentIndex = index),
        );
        break;
      case 1:
        screen = AnimatedHomeScreen(
          onSelectTab: (index) => setState(() => _currentIndex = index),
        );
        break;
      case 2:
        screen = MemorizationScreen(
          onSelectTab: (index) => setState(() => _currentIndex = index),
        );
        break;
      case 3:
        screen = ArmorOfGodScreen(
          onSelectTab: (index) => setState(() => _currentIndex = index),
        );
        break;
      case 4:
        screen = const NotesListScreen();
        break;
      case 5:
        screen = const GroupsListScreen();
        break;
      case 6:
        screen = const ProfileScreen();
        break;
      default:
        screen = AnimatedHomeScreen(
          onSelectTab: (index) => setState(() => _currentIndex = index),
        );
    }

    _screenCache[index] = screen;
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
