import 'package:flutter/material.dart';
import 'coursework_breakdown_screen.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
        ],
      ),

      // ✅ + button -> opens CW Breakdown screen
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D5BFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourseworkBreakdownScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),

      body: const Center(
        child: Text(
          "Task Manager Screen\n\nPress + to add Coursework Breakdown",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
