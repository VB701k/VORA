import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vora/backend/models/app_task.dart';
import 'package:vora/backend/models/weekly_analysis_data.dart';

class WeeklyAnalysisService {
  WeeklyAnalysisService._();
  static final WeeklyAnalysisService instance = WeeklyAnalysisService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _taskCol =>
      _db.collection('users').doc(_uid).collection('tasks');

  CollectionReference<Map<String, dynamic>> get _moodCol =>
      _db.collection('users').doc(_uid).collection('moods');

  CollectionReference<Map<String, dynamic>> get _pomodoroCol =>
      _db.collection('users').doc(_uid).collection('pomodoro_sessions');

  Future<WeeklyAnalysisData> getWeeklyAnalysis({DateTime? anchorDate}) async {
    final now = anchorDate ?? DateTime.now();
    final weekStart = _startOfWeek(now);
    final weekEnd = weekStart.add(
      const Duration(days: 6, hours: 23, minutes: 59),
    );

    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final prevWeekEnd = weekEnd.subtract(const Duration(days: 7));

    final tasks = await _fetchTasksBetween(weekStart, weekEnd);
    final prevTasks = await _fetchTasksBetween(prevWeekStart, prevWeekEnd);

    final moods = await _fetchMoodsBetween(weekStart, weekEnd);

    final studyMinutes = await _fetchPomodoroMinutesByDay(weekStart, weekEnd);
    final prevStudyMinutes = await _fetchPomodoroMinutesByDay(
      prevWeekStart,
      prevWeekEnd,
    );

    // TASK CALCULATIONS
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    final taskCompletionPercent = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round();

    final taskChartValues = _buildTaskChart(tasks);

    final taskSummary =
        "You completed $completedTasks out of $totalTasks tasks this week.";

    // STUDY CALCULATIONS
    final currentWeekStudyMinutes = studyMinutes.fold<int>(
      0,
      (a, b) => a + b.round(),
    );

    final previousWeekStudyMinutes = prevStudyMinutes.fold<int>(
      0,
      (a, b) => a + b.round(),
    );

    final studyDeltaPercent = _percentageDelta(
      previousWeekStudyMinutes,
      currentWeekStudyMinutes,
    );

    final studyChartValues = studyMinutes.map((e) => e / 60).toList();

    final studySummary =
        "You studied ${(currentWeekStudyMinutes / 60).toStringAsFixed(1)} hours this week.";

    // MOOD
    final moodEmojis = _buildMoodEmojiRow(moods);

    final moodSummary =
        "Your mood pattern shows how your week went emotionally.";

    final motivationalMessage =
        "Keep pushing forward — consistency builds success.";

    return WeeklyAnalysisData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      taskCompletionPercent: taskCompletionPercent,
      taskChartValues: taskChartValues,
      taskSummary: taskSummary,
      currentWeekStudyMinutes: currentWeekStudyMinutes,
      previousWeekStudyMinutes: previousWeekStudyMinutes,
      studyDeltaPercent: studyDeltaPercent,
      studyChartValues: studyChartValues,
      studySummary: studySummary,
      moodEmojis: moodEmojis,
      moodSummary: moodSummary,
      motivationalMessage: motivationalMessage,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  Future<List<AppTask>> _fetchTasksBetween(DateTime start, DateTime end) async {
    final snap = await _taskCol
        .where('hidden', isEqualTo: false)
        .where('dueAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snap.docs.map((d) => AppTask.fromDoc(d)).toList();
  }

  Future<Map<int, String>> _fetchMoodsBetween(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snap = await _moodCol
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final result = <int, String>{};

      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['date'];
        final mood = (data['mood'] ?? '').toString();

        if (ts is Timestamp && mood.isNotEmpty) {
          final dt = ts.toDate();
          final dayIndex = dt.weekday - 1;
          result[dayIndex] = mood;
        }
      }

      return result;
    } catch (_) {
      return {};
    }
  }

  Future<List<double>> _fetchPomodoroMinutesByDay(
    DateTime start,
    DateTime end,
  ) async {
    final values = List<double>.filled(7, 0);

    try {
      final snap = await _pomodoroCol
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['completedAt'];
        final minutesRaw = data['durationMinutes'];

        if (ts is Timestamp && minutesRaw != null) {
          final dt = ts.toDate();
          final dayIndex = dt.weekday - 1;
          final minutes = (minutesRaw as num).toDouble();

          if (dayIndex >= 0 && dayIndex < 7) {
            values[dayIndex] += minutes;
          }
        }
      }
    } catch (_) {}

    return values;
  }

  List<double> _buildTaskChart(List<AppTask> tasks) {
    final values = List<double>.filled(7, 0);

    for (final task in tasks) {
      if (!task.isCompleted) continue;

      final index = task.dueDate.weekday - 1;

      if (index >= 0 && index < 7) {
        values[index]++;
      }
    }

    return values;
  }

  List<String> _buildMoodEmojiRow(Map<int, String> moods) {
    return List<String>.generate(7, (i) => _moodToEmoji(moods[i]));
  }

  String _moodToEmoji(String? mood) {
    final value = (mood ?? '').toLowerCase();

    if (value.contains('happy') || value.contains('good')) return '😊';
    if (value.contains('neutral') || value.contains('okay')) return '😐';
    if (value.contains('sad') || value.contains('bad')) return '☹️';

    return '😐';
  }

  int _percentageDelta(int previous, int current) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return (((current - previous) / previous) * 100).round();
  }
}
