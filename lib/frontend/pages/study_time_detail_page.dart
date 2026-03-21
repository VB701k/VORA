import 'package:flutter/material.dart';

class StudyTimeDetailPage extends StatelessWidget {
  const StudyTimeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text("Weekly Study Time"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "This page will show detailed study hours for each day.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
