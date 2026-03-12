import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyAnalysisScreen extends StatelessWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0F14);
    const card = Color(0xFF245A66);
    const glow = Color(0xFF73D7FF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                title: 'Weekly Analysis',
                subtitle: 'Nov 13–19, 2025',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              const _GlowCard(
                cardColor: card,
                glowColor: glow,
                child: _MostProductiveCard(),
              ),
              const SizedBox(height: 16),
              const _GlowCard(
                cardColor: card,
                glowColor: glow,
                child: _TaskCompletionCard(),
              ),
              const SizedBox(height: 16),
              const _GlowCard(
                cardColor: card,
                glowColor: glow,
                child: _StudyHoursCard(),
              ),
              const SizedBox(height: 22),
              const Text(
                'Weekly Mood Patterns',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _GlowCard(
                cardColor: const Color(0xFF0E141B),
                glowColor: glow.withAlpha(170),
                child: const _MoodRowCard(),
              ),
              const SizedBox(height: 14),
              const _GlowCard(
                cardColor: card,
                glowColor: glow,
                child: _MoodInsightCard(),
              ),
            ],
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
        InkWell(
          onTap: onBack,
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
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withAlpha(170),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
      ],
    );
  }
}

class _GlowCard extends StatelessWidget {
  final Widget child;
  final Color cardColor;
  final Color glowColor;

  const _GlowCard({
    required this.child,
    required this.cardColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glowColor.withAlpha(65), width: 1),
        boxShadow: [
          BoxShadow(
            color: glowColor.withAlpha(45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _MostProductiveCard extends StatelessWidget {
  const _MostProductiveCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Productive Day:\nWednesday',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You completed 85% of your tasks\nand studied for 14 hours this week.\nKeep up the great work!',
          style: TextStyle(
            color: Colors.white.withAlpha(230),
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TaskCompletionCard extends StatelessWidget {
  const _TaskCompletionCard();

  @override
  Widget build(BuildContext context) {
    const percent = 85;
    const delta = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Completion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '$percent%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'This Week  +$delta%',
                style: const TextStyle(
                  color: Color(0xFF7CFFB2),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
                      color: Colors.white.withAlpha(220),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Study Hours',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              hoursLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'This week  $delta%',
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 180, child: _StudyLineChart()),
      ],
    );
  }
}

class _StudyLineChart extends StatelessWidget {
  const _StudyLineChart();

  final List<FlSpot> spots = const [
    FlSpot(0, 2.2),
    FlSpot(0.5, 4.0),
    FlSpot(1, 3.4),
    FlSpot(1.4, 4.1),
    FlSpot(2, 2.6),
    FlSpot(2.4, 4.6),
    FlSpot(3, 3.1),
    FlSpot(3.5, 3.8),
    FlSpot(4, 2.2),
    FlSpot(4.6, 4.2),
    FlSpot(5, 2.8),
    FlSpot(5.4, 3.6),
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', ''];
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: const Color(0xFF6FE3FF).withAlpha(230),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2.2,
            color: const Color(0xFFB4F0FF),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(moods[i], style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              days[i],
              style: TextStyle(
                color: Colors.white.withAlpha(210),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MoodInsightCard extends StatelessWidget {
  const _MoodInsightCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.white.withAlpha(235),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: 'Your mood seems to dip on Fridays.\n',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text:
                      'Consider scheduling a lighter study load or a break to recharge for the weekend.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
