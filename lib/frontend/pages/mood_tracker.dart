import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'wellness_hub_screen.dart';
import 'package:vora/backend/services/wellness_service.dart';

class MoodTrackerCard extends StatefulWidget {
  const MoodTrackerCard({super.key});

  @override
  State<MoodTrackerCard> createState() => _MoodTrackerCardState();
}

class _MoodTrackerCardState extends State<MoodTrackerCard> {
  DateTime month = DateTime.now();
  int selectedDay = DateTime.now().day;

  String? selectedMood;

  @override
  void initState() {
    super.initState();
    _loadMoodForSelectedDate();
  }

  Future<void> _loadMoodForSelectedDate() async {
    try {
      final selectedDate = DateTime(month.year, month.month, selectedDay);
      final entry = await WellnessService.instance.getMoodForDate(selectedDate);

      if (!mounted) return;

      setState(() {
        selectedMood = entry?.mood;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(month);

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
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        month = DateTime(month.year, month.month - 1, 1);
                        selectedDay = 1;
                        selectedMood = null;
                      });
                      await _loadMoodForSelectedDate();
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      color: WellnessColors.text,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      monthLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: WellnessColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        month = DateTime(month.year, month.month + 1, 1);
                        selectedDay = 1;
                        selectedMood = null;
                      });
                      await _loadMoodForSelectedDate();
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                      color: WellnessColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _Dow('S'),
                  _Dow('M'),
                  _Dow('T'),
                  _Dow('W'),
                  _Dow('T'),
                  _Dow('F'),
                  _Dow('S'),
                ],
              ),
              const SizedBox(height: 10),
              _WeekStrip(
                month: month,
                selectedDay: selectedDay,
                onSelect: (d) async {
                  setState(() {
                    selectedDay = d;
                    selectedMood = null;
                  });
                  await _loadMoodForSelectedDate();
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WellnessColors.card2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WellnessColors.stroke),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Reflection',
                            style: TextStyle(
                              color: WellnessColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Choose your mood for the selected day",
                            style: TextStyle(
                              color: WellnessColors.textDim,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.waves_rounded, color: WellnessColors.textDim),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _moodOption('😄'),
                  _moodOption('🙂'),
                  _moodOption('😐'),
                  _moodOption('🙁'),
                  _moodOption('😣'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedMood == null
                      ? null
                      : () async {
                          try {
                            final selectedDate = DateTime(
                              month.year,
                              month.month,
                              selectedDay,
                            );
                            await WellnessService.instance.saveMoodForDate(
                              date: selectedDate,
                              mood: selectedMood!,
                            );
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Saved mood $selectedMood for day $selectedDay',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save mood: $e'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WellnessColors.mint,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: WellnessColors.mint.withValues(
                      alpha: 0.35,
                    ),
                    disabledForegroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    selectedMood == null ? 'Select a Mood' : 'Log Mood',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moodOption(String emoji) {
    final isSelected = selectedMood == emoji;

    return InkWell(
      onTap: () => setState(() => selectedMood = emoji),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? WellnessColors.mint : WellnessColors.card2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: WellnessColors.stroke),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _Dow extends StatelessWidget {
  final String t;
  const _Dow(this.t);

  @override
  Widget build(BuildContext context) {
    return Text(
      t,
      style: const TextStyle(
        color: WellnessColors.textDim,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime month;
  final int selectedDay;
  final ValueChanged<int> onSelect;

  const _WeekStrip({
    required this.month,
    required this.selectedDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final startOffset = first.weekday % 7;

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final prevMonthDays = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    final cells = List<int>.generate(7, (i) {
      final dayNum = i - startOffset + 1;
      if (dayNum <= 0) return prevMonthDays + dayNum;
      return dayNum;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final d = cells[i];
        final dayNum = i - startOffset + 1;
        final isCurrentMonth = dayNum > 0 && dayNum <= daysInMonth;
        final isSelected = isCurrentMonth && d == selectedDay;

        return InkWell(
          onTap: isCurrentMonth ? () => onSelect(d) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? WellnessColors.mint : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : WellnessColors.stroke,
              ),
            ),
            child: Text(
              '$d',
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : (isCurrentMonth
                          ? WellnessColors.text
                          : WellnessColors.textDim.withValues(alpha: 0.35)),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }),
    );
  }
}
