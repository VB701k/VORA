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

  factory WeeklyAnalysisData.fromMap(Map<String, dynamic> map) {
    final Timestamp weekStartTs = map['weekStart'] as Timestamp;
    final Timestamp weekEndTs = map['weekEnd'] as Timestamp;

    return WeeklyAnalysisData(
      weekStart: weekStartTs.toDate(),
      weekEnd: weekEndTs.toDate(),
      totalTasks: (map['totalTasks'] ?? 0) as int,
      completedTasks: (map['completedTasks'] ?? 0) as int,
      pendingTasks: (map['pendingTasks'] ?? 0) as int,
      taskCompletionPercent: (map['taskCompletionPercent'] ?? 0) as int,
      taskChartValues: ((map['taskChartValues'] ?? []) as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      taskSummary: (map['taskSummary'] ?? '').toString(),
      currentWeekStudyMinutes: (map['currentWeekStudyMinutes'] ?? 0) as int,
      previousWeekStudyMinutes: (map['previousWeekStudyMinutes'] ?? 0) as int,
      studyDeltaPercent: (map['studyDeltaPercent'] ?? 0) as int,
      studyChartValues: ((map['studyChartValues'] ?? []) as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      studySummary: (map['studySummary'] ?? '').toString(),
      moodEmojis: ((map['moodEmojis'] ?? []) as List)
          .map((e) => e.toString())
          .toList(),
      moodSummary: (map['moodSummary'] ?? '').toString(),
      motivationalMessage: (map['motivationalMessage'] ?? '').toString(),
    );
  }
}
