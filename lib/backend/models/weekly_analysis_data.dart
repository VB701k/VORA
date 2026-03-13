import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyAnalysisData {
  final DateTime weekStart;
  final DateTime weekEnd;

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int taskCompletionPercent;
  final List<double> taskChartValues;
  final String taskSummary;

  final int currentWeekStudyMinutes;
  final int previousWeekStudyMinutes;
  final int studyDeltaPercent;
  final List<double> studyChartValues;
  final String studySummary;

  final List<String> moodEmojis;
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

  String get weekId {
    final y = weekStart.year.toString().padLeft(4, '0');
    final m = weekStart.month.toString().padLeft(2, '0');
    final d = weekStart.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic> toMap() {
    return {
      'weekStart': Timestamp.fromDate(weekStart),
      'weekEnd': Timestamp.fromDate(weekEnd),
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'taskCompletionPercent': taskCompletionPercent,
      'taskChartValues': taskChartValues,
      'taskSummary': taskSummary,
      'currentWeekStudyMinutes': currentWeekStudyMinutes,
      'previousWeekStudyMinutes': previousWeekStudyMinutes,
      'studyDeltaPercent': studyDeltaPercent,
      'studyChartValues': studyChartValues,
      'studySummary': studySummary,
      'moodEmojis': moodEmojis,
      'moodSummary': moodSummary,
      'motivationalMessage': motivationalMessage,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  