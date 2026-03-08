import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0F14);
    const card = Color(0xFF245A66);
    const glow = Color(0xFF73D7FF);

    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Calendar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: glow.withAlpha(65), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: glow.withAlpha(45),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      today,
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Your calendar screen is connected ✅\nNext step: add real events UI.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
