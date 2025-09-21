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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 1; // Start on Home (middle tab)
  }

  List<Widget> get _screens => [
  VersesScreen(
    onSelectTab: (index) => setState(() => _currentIndex = index),
  ),
  AnimatedHomeScreen(
    onSelectTab: (index) => setState(() => _currentIndex = index),
  ),
  MemorizationScreen(
    onSelectTab: (index) => setState(() => _currentIndex = index),
  ),
  ArmorOfGodScreen(
    onSelectTab: (index) => setState(() => _currentIndex = index),
  ),
  const NotesListScreen(),
  const GroupsListScreen(),
  const ProfileScreen(),
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
