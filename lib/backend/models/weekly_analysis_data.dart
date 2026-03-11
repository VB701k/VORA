class WeeklyAnalysisData {
  final DateTime weekStart;
  final DateTime weekEnd;

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int taskCompletionPercent;
  final List<double> taskChartValues; // Mon-Sun completed count
  final String taskSummary;

  final int currentWeekStudyMinutes;
  final int previousWeekStudyMinutes;
  final int studyDeltaPercent;
  final List<double> studyChartValues; // Mon-Sun hours
  final String studySummary;

  final List<String> moodEmojis; // Mon-Sun
  final String moodSummary;

  final String motivationalMessage;

  const WeeklyAnalysisData({
    required this.weekStart,
    required this.weekEnd,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.taskCompletionPercent,
    required this.taskChartValues,
    required this.taskSummary,
    required this.currentWeekStudyMinutes,
    required this.previousWeekStudyMinutes,
    required this.studyDeltaPercent,
    required this.studyChartValues,
    required this.studySummary,
    required this.moodEmojis,
    required this.moodSummary,
    required this.motivationalMessage,
  });

  String get studyHoursLabel {
    final h = currentWeekStudyMinutes ~/ 60;
    final m = currentWeekStudyMinutes % 60;
    return '${h}h ${m}m';
  }
}
