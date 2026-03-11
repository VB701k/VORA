class WeeklyAnalysisModel {
  final String weekLabel;
  final String mostProductiveDay;
  final int completionPercent;
  final int completionDeltaPercent;
  final List<double> taskCompletionByDay;
  final String totalStudyLabel;
  final int studyDeltaPercent;
  final List<double> studyHoursByDay;
  final List<String> moodsByDay;
  final String moodInsight;

  const WeeklyAnalysisModel({
    required this.weekLabel,
    required this.mostProductiveDay,
    required this.completionPercent,
    required this.completionDeltaPercent,
    required this.taskCompletionByDay,
    required this.totalStudyLabel,
    required this.studyDeltaPercent,
    required this.studyHoursByDay,
    required this.moodsByDay,
    required this.moodInsight,
  });
}
