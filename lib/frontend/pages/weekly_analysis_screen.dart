import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vora/backend/models/weekly_analysis_data.dart';
import 'package:vora/backend/services/weekly_analysis_service.dart';
import 'package:vora/frontend/pages/study_time_detail_page.dart';
import 'package:vora/frontend/pages/task_progress_detail_page.dart';

class WeeklyAnalysisScreen extends StatefulWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  State<WeeklyAnalysisScreen> createState() => _WeeklyAnalysisScreenState();
}

class _WeeklyAnalysisScreenState extends State<WeeklyAnalysisScreen> {
  late Future<WeeklyAnalysisData> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _loadAnalysis();
  }

  Future<WeeklyAnalysisData> _loadAnalysis({bool forceRefresh = false}) {
    return WeeklyAnalysisService.instance.getOrGenerateWeeklyAnalysis(
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _refresh() async {
    final future = _loadAnalysis(forceRefresh: true);
    setState(() {
      _analysisFuture = future;
    });
    await future;
  }

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
          child: FutureBuilder<WeeklyAnalysisData>(
            future: _analysisFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingView();
              }

              if (snapshot.hasError) {
                return _ErrorView(
                  onRetry: () {
                    setState(() {
                      _analysisFuture = _loadAnalysis(forceRefresh: true);
                    });
                  },
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return _ErrorView(
                  onRetry: () {
                    setState(() {
                      _analysisFuture = _loadAnalysis(forceRefresh: true);
                    });
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        title: "Weekly Analysis",
                        subtitle: "Overview of your week",
                        onBack: () => Navigator.of(context).maybePop(),
                        onRefresh: _refresh,
                      ),

                      const SizedBox(height: 18),

                      _SummaryHeroCard(data: data),

                      const SizedBox(height: 18),

                      const _SectionHeading(
                        title: "Task Progress",
                        subtitle:
                            "See how much of your weekly work was completed based on your actual stored tasks.",
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TaskProgressDetailPage(),
                            ),
                          );
                        },
                        child: _TaskCompletionCard(data: data),
                      ),

                      const SizedBox(height: 20),

                      const _SectionHeading(
                        title: "Study Time",
                        subtitle:
                            "Track how many hours you studied this week and how your study pattern changed day by day.",
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudyTimeDetailPage(),
                            ),
                          );
                        },
                        child: _StudyHoursCard(data: data),
                      ),

                      const SizedBox(height: 20),

                      const _SectionHeading(
                        title: "Mood Patterns",
                        subtitle:
                            "Review your daily mood across the week and spot where you may need more balance or rest.",
                      ),
                      const SizedBox(height: 12),

                      _MoodRowCard(moodEmojis: data.moodEmojis),

                      const SizedBox(height: 14),

                      _MoodInsightCard(
                        moodSummary: data.moodSummary,
                        motivationalMessage: data.motivationalMessage,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF73D7FF)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white70,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              "Could not load weekly analysis",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please try refreshing the screen.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF245A66),
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onRefresh,
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
        IconButton(
          onPressed: () => onRefresh(),
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
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
  final WeeklyAnalysisData data;

  const _SummaryHeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final strongestDay = _findStrongestDay(data);

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
                Text(
                  strongestDay == null
                      ? "Your weekly data is building up."
                      : "$strongestDay was your strongest day.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "You completed ${data.taskCompletionPercent}% of your planned work and studied for ${data.studyHoursLabel} this week.",
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
  final WeeklyAnalysisData data;

  const _TaskCompletionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: _TaskCompletionContent(
        percent: data.taskCompletionPercent,
        completedTasks: data.completedTasks,
        pendingTasks: data.pendingTasks,
        totalTasks: data.totalTasks,
        taskSummary: data.taskSummary,
        chartValues: data.taskChartValues,
      ),
    );
  }
}

class _TaskCompletionContent extends StatelessWidget {
  final int percent;
  final int completedTasks;
  final int pendingTasks;
  final int totalTasks;
  final String taskSummary;
  final List<double> chartValues;

  const _TaskCompletionContent({
    required this.percent,
    required this.completedTasks,
    required this.pendingTasks,
    required this.totalTasks,
    required this.taskSummary,
    required this.chartValues,
  });

  @override
  Widget build(BuildContext context) {
    final int safePercent = percent.clamp(0, 100).toInt();
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
                    value: safePercent / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF73D7FF)),
                  ),
                  Text(
                    "$safePercent%",
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
                    taskSummary,
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$completedTasks completed • $pendingTasks pending • $totalTasks total",
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
        SizedBox(height: 150, child: _TaskBarChart(values: chartValues)),
      ],
    );
  }
}

class _TaskBarChart extends StatelessWidget {
  final List<double> values;

  const _TaskBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final safeValues = _normalizeToSeven(values);
    final maxY = _taskChartMaxY(safeValues);

    return BarChart(
      BarChartData(
        maxY: maxY,
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
        barGroups: List.generate(safeValues.length, (i) {
          final v = safeValues[i];
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
  final WeeklyAnalysisData data;

  const _StudyHoursCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: _StudyHoursContent(
        hoursLabel: data.studyHoursLabel,
        delta: data.studyDeltaPercent,
        summary: data.studySummary,
        chartValues: data.studyChartValues,
      ),
    );
  }
}

class _StudyHoursContent extends StatelessWidget {
  final String hoursLabel;
  final int delta;
  final String summary;
  final List<double> chartValues;

  const _StudyHoursContent({
    required this.hoursLabel,
    required this.delta,
    required this.summary,
    required this.chartValues,
  });

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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          summary,
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
        SizedBox(height: 180, child: _StudyLineChart(values: chartValues)),
      ],
    );
  }
}

class _StudyLineChart extends StatelessWidget {
  final List<double> values;

  const _StudyLineChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final safeValues = _normalizeToSeven(values);
    final spots = List.generate(
      safeValues.length,
      (i) => FlSpot(i.toDouble(), safeValues[i]),
    );

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: _studyChartMaxY(safeValues),
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
                final index = value.toInt();
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }

                return Text(
                  days[index],
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
  final List<String> moodEmojis;

  const _MoodRowCard({required this.moodEmojis});

  @override
  Widget build(BuildContext context) {
    final moods = _normalizeMoodEmojis(moodEmojis);

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
                      _weekdayShort(i),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _moodLabelFromEmoji(moods[i]),
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
  final String moodSummary;
  final String motivationalMessage;

  const _MoodInsightCard({
    required this.moodSummary,
    required this.motivationalMessage,
  });

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
                  moodSummary,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  motivationalMessage,
                  style: const TextStyle(
                    color: Color(0xFFFFD87A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
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

List<double> _normalizeToSeven(List<double> values) {
  final safe = List<double>.filled(7, 0.0);
  for (int i = 0; i < values.length && i < 7; i++) {
    safe[i] = values[i];
  }
  return safe;
}

List<String> _normalizeMoodEmojis(List<String> values) {
  final safe = List<String>.filled(7, '😐');
  for (int i = 0; i < values.length && i < 7; i++) {
    safe[i] = values[i];
  }
  return safe;
}

double _taskChartMaxY(List<double> values) {
  double maxValue = 0;
  for (final v in values) {
    if (v > maxValue) maxValue = v;
  }

  if (maxValue <= 0) return 4.0;
  return maxValue + 1;
}

double _studyChartMaxY(List<double> values) {
  double maxValue = 0;
  for (final v in values) {
    if (v > maxValue) maxValue = v;
  }

  if (maxValue <= 0) return 2.0;
  return math.max(2.0, maxValue + 1).toDouble();
}

String _weekdayShort(int index) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[index];
}

String _weekdayFull(int index) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[index];
}

String _moodLabelFromEmoji(String emoji) {
  switch (emoji) {
    case '😊':
      return 'Good';
    case '☹️':
      return 'Low';
    default:
      return 'Neutral';
  }
}

String? _findStrongestDay(WeeklyAnalysisData data) {
  final task = _normalizeToSeven(data.taskChartValues);
  final study = _normalizeToSeven(data.studyChartValues);

  double maxTask = 0;
  double maxStudy = 0;

  for (final v in task) {
    if (v > maxTask) maxTask = v;
  }

  for (final v in study) {
    if (v > maxStudy) maxStudy = v;
  }

  if (maxTask == 0 && maxStudy == 0) {
    return null;
  }

  double bestScore = -1;
  int bestIndex = 0;

  for (int i = 0; i < 7; i++) {
    final double taskScore = maxTask == 0 ? 0.0 : task[i] / maxTask;
    final double studyScore = maxStudy == 0 ? 0.0 : study[i] / maxStudy;
    final double totalScore = taskScore + studyScore;

    if (totalScore > bestScore) {
      bestScore = totalScore;
      bestIndex = i;
    }
  }

  return _weekdayFull(bestIndex);
}
