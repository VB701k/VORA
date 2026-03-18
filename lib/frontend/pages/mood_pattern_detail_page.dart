import 'package:flutter/material.dart';

class MoodPatternDetailPage extends StatelessWidget {
  const MoodPatternDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text("Weekly Mood Patterns"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Here you can see your mood trends and suggestions.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
