import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int totalSeconds = 25 * 60; // 25 minutes
  int remainingSeconds = totalSeconds;

  Timer? timer;
  bool isRunning = false;

  void startPause() {
    if (isRunning) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer.cancel();
        }
      });
    }

    setState(() {
      isRunning = !isRunning;
    });
  }

  void reset() {
    timer?.cancel();
    setState(() {
      remainingSeconds = totalSeconds;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (remainingSeconds / totalSeconds);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Pomodoro Timer",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 30),

            // CIRCULAR TIMER
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade700,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFC77DFF)),
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      "FOCUS",
                      style: TextStyle(color: Color(0xFFC77DFF), fontSize: 14),
                    ),
                    Text(
                      formatTime(remainingSeconds),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // PLAY / PAUSE BUTTON
            FloatingActionButton(
              backgroundColor: const Color(0xFFC77DFF),
              onPressed: startPause,
              child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
            ),

            const SizedBox(height: 40),

            // RESET & SKIP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {}, // no function as requested
                  icon: const Icon(Icons.skip_next),
                  label: const Text("Skip"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
