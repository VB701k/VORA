import 'package:flutter/material.dart';
import 'package:vora/backend/models/weekly_analysis_data.dart';

class TaskProgressDetailPage extends StatelessWidget {
  final WeeklyAnalysisData data;

  const TaskProgressDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text("Weekly Task Progress"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statCard(
              "Total Tasks",
              data.totalTasks.toString(),
              const Color(0xFF73D7FF),
            ),
            const SizedBox(height: 12),
            _statCard(
              "Completed Tasks",
              data.completedTasks.toString(),
              const Color(0xFF7CFFB2),
            ),
            const SizedBox(height: 12),
            _statCard(
              "Pending Tasks",
              data.pendingTasks.toString(),
              const Color(0xFFFFB86B),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF163241),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x3373D7FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.taskSummary,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Completion Rate: ${data.taskCompletionPercent}%",
                    style: const TextStyle(
                      color: Color(0xFF7CFFB2),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF163241),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
