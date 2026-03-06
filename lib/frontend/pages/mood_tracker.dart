import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'wellness_hub_screen.dart';

class MoodTrackerCard extends StatefulWidget {
  const MoodTrackerCard({super.key});

  @override
  State<MoodTrackerCard> createState() => _MoodTrackerCardState();
}

class _MoodTrackerCardState extends State<MoodTrackerCard> {
  DateTime month = DateTime.now();
  int selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Tracker',
          style: TextStyle(
            color: WellnessColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: WellnessColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WellnessColors.stroke),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    month = DateTime(month.year, month.month - 1, 1);
                  });
                },
                icon: const Icon(
                  Icons.chevron_left,
                  color: WellnessColors.text,
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: WellnessColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    month = DateTime(month.year, month.month + 1, 1);
                  });
                },
                icon: const Icon(
                  Icons.chevron_right,
                  color: WellnessColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
