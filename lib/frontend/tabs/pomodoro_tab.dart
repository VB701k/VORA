import 'package:flutter/material.dart';

class PomodoroTab extends StatelessWidget {
  const PomodoroTab({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF64B5F6);
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Pomodoro Timer",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            Expanded(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // background ring
                        CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.1),
                          ),
                        ),

                        // progress ring (static for now)
                        CircularProgressIndicator(
                          value: 0.8,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                          backgroundColor: Colors.transparent,
                        ),

                        const Text(
                          "25:00",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔵 Buttons section
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Start"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                      ),
                      child: const Text("Pause"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text("Reset"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}