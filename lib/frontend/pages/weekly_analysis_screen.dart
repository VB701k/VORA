import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'task_progress_detail_page.dart';
import 'study_time_detail_page.dart';
import 'mood_pattern_detail_page.dart';

class WeeklyAnalysisScreen extends StatelessWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF081018), Color(0xFF0D1C28), Color(0xFF081018)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  title: "Weekly Analysis",
                  subtitle: "Overview of your week",
                  onBack: () => Navigator.of(context).maybePop(),
                ),

                const SizedBox(height: 18),

                const _SummaryHeroCard(),

                const SizedBox(height: 18),

                const _SectionHeading(
                  title: "Task Progress",
                  subtitle:
                      "See how much of your weekly work was completed and how it changed compared to last week.",
                ),
                const SizedBox(height: 12),

                /// TASK PROGRESS CLICK
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskProgressDetailPage(),
                      ),
                    );
                  },
                  child: const _TaskCompletionCard(),
                ),

                const SizedBox(height: 20),

                const _SectionHeading(
                  title: "Study Time",
                  subtitle:
                      "Track how many hours you studied this week and how your study pattern changed day by day.",
                ),
                const SizedBox(height: 12),
                const _StudyHoursCard(),

                const SizedBox(height: 20),

                const _SectionHeading(
                  title: "Mood Patterns",
                  subtitle:
                      "Review your daily mood across the week and spot days where you may need more balance or rest.",
                ),
                const SizedBox(height: 12),
                const _MoodRowCard(),

                const SizedBox(height: 14),
                const _MoodInsightCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withAlpha(170),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withAlpha(180),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF163241),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x3373D7FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2273D7FF),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF245A66), Color(0xFF183744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3373D7FF),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Summary",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Wednesday was your strongest day.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "You completed 85% of your planned work and studied for 14 hours 32 minutes this week.",
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCompletionCard extends StatelessWidget {
  const _TaskCompletionCard();

  @override
  Widget build(BuildContext context) {
    const percent = 85;
    const delta = 5;

    return const _GlassCard(
      child: _TaskCompletionContent(percent: percent, delta: delta),
    );
  }
}

class _TaskCompletionContent extends StatelessWidget {
  final int percent;
  final int delta;

  const _TaskCompletionContent({required this.percent, required this.delta});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Completed this week",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            SizedBox(
              width: 78,
              height: 78,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF73D7FF)),
                  ),
                  Text(
                    "$percent%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "completion rate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You completed most of the work scheduled for this week.",
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "+$delta% compared to last week",
                    style: const TextStyle(
                      color: Color(0xFF7CFFB2),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        const Text(
          "Daily completion pattern",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 150, child: _TaskBarChart()),
      ],
    );
  }
}

class _TaskBarChart extends StatelessWidget {
  const _TaskBarChart({super.key});

  final List<double> values = const [18, 55, 72, 46, 78, 26, 22];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                const labels = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(values.length, (i) {
          final v = values[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: v,
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF3BAEDC).withAlpha(140),
                    const Color(0xFF6FE3FF),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StudyHoursCard extends StatelessWidget {
  const _StudyHoursCard();

  @override
  Widget build(BuildContext context) {
    const hoursLabel = '14h 32m';
    const delta = -2;

    return const _GlassCard(
      child: _StudyHoursContent(hoursLabel: hoursLabel, delta: delta),
    );
  }
}

class _StudyHoursContent extends StatelessWidget {
  final String hoursLabel;
  final int delta;

  const _StudyHoursContent({required this.hoursLabel, required this.delta});

  @override
  Widget build(BuildContext context) {
    final deltaColor = delta >= 0
        ? const Color(0xFF7CFFB2)
        : const Color(0xFFFF7B7B);
    final deltaText = delta >= 0
        ? '+$delta% compared to last week'
        : '$delta% compared to last week';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Total study time",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hoursLabel,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "This shows the total number of hours you focused on your work this week.",
          style: TextStyle(
            color: Colors.white.withAlpha(210),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          deltaText,
          style: TextStyle(
            color: deltaColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Daily study trend",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 180, child: _StudyLineChart()),
      ],
    );
  }
}

class _StudyLineChart extends StatelessWidget {
  const _StudyLineChart({super.key});

  final List<FlSpot> spots = const [
    FlSpot(0, 2.2),
    FlSpot(1, 3.4),
    FlSpot(2, 2.6),
    FlSpot(3, 3.1),
    FlSpot(4, 2.2),
    FlSpot(5, 2.8),
    FlSpot(6, 5.6),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                return Text(
                  days[value.toInt()],
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF73D7FF),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF73D7FF).withAlpha(35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodRowCard extends StatelessWidget {
  const _MoodRowCard();

  @override
  Widget build(BuildContext context) {
    const moods = ['😊', '😐', '😊', '😊', '☹️', '😐', '😊'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const labels = [
      'Good',
      'Neutral',
      'Good',
      'Good',
      'Low',
      'Neutral',
      'Good',
    ];

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily mood check",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Expanded(
                child: Column(
                  children: [
                    Text(moods[i], style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(
                      days[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(170),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MoodInsightCard extends StatelessWidget {
  const _MoodInsightCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mood insight",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your mood seems lower on Fridays. A lighter task load or a short break on that day may help you finish the week with less stress.",
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
