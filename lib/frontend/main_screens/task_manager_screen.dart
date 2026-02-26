import 'package:flutter/material.dart';

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D5BFF),
        onPressed: () {
          // Later you can connect Coursework Breakdown here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Coursework Breakdown not connected yet"),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: const Center(
        child: Text(
          "✅ Task Manager Screen Connected!\n\n(We will connect real tasks later)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
