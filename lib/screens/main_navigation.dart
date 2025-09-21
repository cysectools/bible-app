// import 'package:bible_app/screens/armor_of_god.dart';
import 'package:flutter/material.dart';
import 'animated_home_screen.dart';
import 'verses_screen.dart';
import 'memorization_screen.dart';
import 'armor_of_god_screen.dart';
import 'notes_list_screen.dart';
import 'groups_list_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Start on Home (middle tab)

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Verses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Memorization',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Armor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
