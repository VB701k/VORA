import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyAnalysisScreen extends StatelessWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F14), Color(0xFF0F1C26), Color(0xFF0B0F14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  title: "Weekly Analysis",
                  subtitle: "Nov 13 – 19",
                  onBack: () => Navigator.pop(context),
                ),

                const SizedBox(height: 20),

                const _MostProductiveCard(),

                const SizedBox(height: 18),

                const _TaskCompletionCard(),

                const SizedBox(height: 18),

                const _StudyHoursCard(),

                const SizedBox(height: 22),

                const Text(
                  "Mood This Week",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const _MoodRowCard(),

                const SizedBox(height: 16),

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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: Colors.white.withOpacity(.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 36),
      ],
    );
  }
}

class _MostProductiveCard extends StatelessWidget {
  const _MostProductiveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF245A66), Color(0xFF193C46)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x5573D7FF), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Most Productive Day",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 6),

          const Text(
            "Wednesday",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "You completed 85% of your tasks\nand studied 14 hours this week.",
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontSize: 13,
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
    const percent = 0.85;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3E49),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 7,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF73D7FF)),
                ),

                const Text(
                  "85%",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task Completion",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "+5% improvement from last week",
                  style: TextStyle(color: Color(0xFF7CFFB2), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyHoursCard extends StatelessWidget {
  const _StudyHoursCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3E49),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Study Hours",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "14h 32m",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 160, child: _StudyLineChart()),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3E49),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          return Column(
            children: [
              Text(moods[i], style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                days[i],
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MoodInsightCard extends StatelessWidget {
  const _MoodInsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3E49),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              "Your mood dips on Fridays. Consider lighter study sessions.",
              style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
