import 'package:flutter/material.dart';

import 'package:vora/frontend/main_screens/search_screen.dart';
import 'package:vora/frontend/main_screens/home_screen.dart';
import 'package:vora/frontend/main_screens/ai_screen.dart';
import 'package:vora/frontend/main_screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _goToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  late final List<Widget> _pages = [
    const HomeScreen(),
    SearchScreen(onBackToHome: _goToHome),
    const AiScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF172B35),
        selectedItemColor: const Color(0xFF2EC4F1),
        unselectedItemColor: const Color(0xFF9FB4C4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
