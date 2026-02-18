import 'package:flutter/material.dart';

class PomodoroTab extends StatelessWidget {
  const PomodoroTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              "Pomodoro Timer",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 80),

            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.purpleAccent,
                  width: 6,
                ),
              ),
              child: const Center(
                child: Text(
                  "25:00",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }
}
