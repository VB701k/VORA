import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:vora/backend/models/app_task.dart';
import 'package:vora/backend/models/weekly_analysis_model.dart';

class WeeklyAnalysisService {
  WeeklyAnalysisService._();
  static final WeeklyAnalysisService instance = WeeklyAnalysisService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _taskCol {
    return _db.collection('users').doc(_uid).collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> get _studyCol {
    return _db.collection('users').doc(_uid).collection('study_sessions');
  }

  CollectionReference<Map<String, dynamic>> get _moodCol {
    return _db.collection('users').doc(_uid).collection('moods');
  }

  Future<WeeklyAnalysisModel> getCurrentWeekAnalysis() async {
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final previousWeekStart = startOfWeek.subtract(const Duration(days: 7));
    final previousWeekEnd = startOfWeek;

    final currentTasks = await _fetchTasksBetween(startOfWeek, endOfWeek);
    final previousTasks = await _fetchTasksBetween(
      previousWeekStart,
      previousWeekEnd,
    );

    final taskCompletionByDay = _buildDailyTaskCompletion(
      currentTasks,
      startOfWeek,
    );

    final completionPercent = _overallCompletionPercent(currentTasks);
    final previousCompletionPercent = _overallCompletionPercent(previousTasks);
    final completionDelta = completionPercent - previousCompletionPercent;

    final mostProductiveDay = _findMostProductiveDay(taskCompletionByDay);

    final currentStudyByDay = await _fetchStudyHoursByDay(
      startOfWeek,
      endOfWeek,
    );
    final previousStudyByDay = await _fetchStudyHoursByDay(
      previousWeekStart,
      previousWeekEnd,
    );

    final totalStudyHours = currentStudyByDay.fold<double>(0, (a, b) => a + b);
    final previousStudyHours = previousStudyByDay.fold<double>(
      0,
      (a, b) => a + b,
    );

    final studyDelta = previousStudyHours == 0
        ? 0
        : (((totalStudyHours - previousStudyHours) / previousStudyHours) * 100)
              .round();

    final moodsByDay = await _fetchMoodsByDay(startOfWeek, endOfWeek);
    final moodInsight = _buildMoodInsight(moodsByDay);

    return WeeklyAnalysisModel(
      weekLabel:
          "${DateFormat('MMM d').format(startOfWeek)}–${DateFormat('d, y').format(endOfWeek.subtract(const Duration(days: 1)))}",
      mostProductiveDay: mostProductiveDay,
      completionPercent: completionPercent,
      completionDeltaPercent: completionDelta,
      taskCompletionByDay: taskCompletionByDay,
      totalStudyLabel: _formatHours(totalStudyHours),
      studyDeltaPercent: studyDelta,
      studyHoursByDay: currentStudyByDay,
      moodsByDay: moodsByDay,
      moodInsight: moodInsight,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final weekday = normalized.weekday;
    return normalized.subtract(Duration(days: weekday - 1));
  }

  Future<List<AppTask>> _fetchTasksBetween(DateTime start, DateTime end) async {
    final snap = await _taskCol
        .where('hidden', isEqualTo: false)
        .where('dueAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueAt', isLessThan: Timestamp.fromDate(end))
        .get();

    return snap.docs.map((d) => AppTask.fromDoc(d)).toList();
  }

  List<double> _buildDailyTaskCompletion(
    List<AppTask> tasks,
    DateTime weekStart,
  ) {
    final done = List<double>.filled(7, 0);
    final total = List<double>.filled(7, 0);

    for (final task in tasks) {
      final dayIndex = task.dueDate.difference(weekStart).inDays;
      if (dayIndex < 0 || dayIndex > 6) continue;

      total[dayIndex] += 1;
      if (task.isCompleted) {
        done[dayIndex] += 1;
      }
    }

    return List.generate(7, (i) {
      if (total[i] == 0) return 0;
      return (done[i] / total[i]) * 100;
    });
  }

  int _overallCompletionPercent(List<AppTask> tasks) {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return ((completed / tasks.length) * 100).round();
  }

  String _findMostProductiveDay(List<double> dailyCompletion) {
    const labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    double bestValue = -1;
    int bestIndex = 0;

    for (int i = 0; i < dailyCompletion.length; i++) {
      if (dailyCompletion[i] > bestValue) {
        bestValue = dailyCompletion[i];
        bestIndex = i;
      }
    }

    return labels[bestIndex];
  }

  Future<List<double>> _fetchStudyHoursByDay(
    DateTime start,
    DateTime end,
  ) async {
    final result = List<double>.filled(7, 0);

    final snap = await _studyCol
        .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startedAt', isLessThan: Timestamp.fromDate(end))
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final Timestamp? ts = data['startedAt'];
      final num minutes = (data['minutes'] ?? 0) as num;

      if (ts == null) continue;
      final dt = ts.toDate();
      final dayIndex = dt.difference(start).inDays;
      if (dayIndex < 0 || dayIndex > 6) continue;

      result[dayIndex] += minutes / 60.0;
    }

    return result;
  }

  Future<List<String>> _fetchMoodsByDay(DateTime start, DateTime end) async {
    final result = List<String>.filled(7, '😐');

    final snap = await _moodCol
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final Timestamp? ts = data['date'];
      final String mood = (data['mood'] ?? 'neutral').toString();

      if (ts == null) continue;
      final dt = ts.toDate();
      final dayIndex = dt.difference(start).inDays;
      if (dayIndex < 0 || dayIndex > 6) continue;

      result[dayIndex] = _mapMoodToEmoji(mood);
    }

    return result;
  }

  String _mapMoodToEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'good':
      case 'great':
        return '😊';
      case 'sad':
      case 'bad':
        return '☹️';
      case 'calm':
        return '😌';
      case 'stressed':
        return '😣';
      default:
        return '😐';
    }
  }

  String _buildMoodInsight(List<String> moods) {
    if (moods[4] == '☹️' || moods[4] == '😣') {
      return 'Your mood seems to dip on Fridays. Consider keeping that day lighter.';
    }
    return 'Your mood looks fairly balanced this week. Keep following your routine.';
  }

  String _formatHours(double totalHours) {
    final hours = totalHours.floor();
    final minutes = ((totalHours - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }
}
