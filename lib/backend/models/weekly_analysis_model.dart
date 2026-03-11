class WeeklyAnalysisData {
  final DateTime weekStart;
  final DateTime weekEnd;

  final String mostProductiveDay;
  final int taskCompletionPercent;
  final int taskCompletionDeltaPercent;

  final List<double> taskCompletionByDay; // 7 values, Mon -> Sun
  final String studyHoursLabel;
  final int studyHoursDeltaPercent;
  final List<double> studyHoursByDay; // 7 values, Mon -> Sun

  final List<String> moodEmojis; // 7 values, Mon -> Sun
  final String moodInsightTitle;
  final String moodInsightBody;

  const WeeklyAnalysisData({
    required this.weekStart,
    required this.weekEnd,
    required this.mostProductiveDay,
    required this.taskCompletionPercent,
    required this.taskCompletionDeltaPercent,
    required this.taskCompletionByDay,
    required this.studyHoursLabel,
    required this.studyHoursDeltaPercent,
    required this.studyHoursByDay,
    required this.moodEmojis,
    required this.moodInsightTitle,
    required this.moodInsightBody,
  });
}
