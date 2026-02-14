import 'package:flutter/material.dart';

import 'package:sdgp/frontend/tabs/chatbot_tab.dart';
import 'package:sdgp/frontend/tabs/feature_tab.dart';
import 'package:sdgp/frontend/tabs/home_tab.dart';
import 'package:sdgp/frontend/tabs/pomodoro_tab.dart';
import 'package:sdgp/frontend/tabs/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = const [
    HomeTab(),
    ChatbotTab(),
    PomodoroTab(),
    FeatureTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show selected tab

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: "AI Chatbot",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Pomodoro"),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Feature",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
