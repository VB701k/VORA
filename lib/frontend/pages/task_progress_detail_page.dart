import 'package:flutter/material.dart';

class TaskProgressDetailPage extends StatelessWidget {
  const TaskProgressDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text("Weekly Task Progress"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Here you will see all the tasks completed this week and pending tasks.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
