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
    final moods = await _fetchMoodsBetween(weekStart, weekEnd);

    final studyMinutes = await _fetchPomodoroMinutesByDay(weekStart, weekEnd);
    final prevStudyMinutes = await _fetchPomodoroMinutesByDay(
      prevWeekStart,
      prevWeekEnd,
    );

    // TASKS
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    final taskCompletionPercent = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round();

    final taskChartValues = _buildTaskChart(tasks);

    final taskSummary =
        'You completed $completedTasks out of $totalTasks tasks this week.';

    // STUDY
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
        'You studied ${(currentWeekStudyMinutes / 60).toStringAsFixed(1)} hours this week.';

    // MOOD
    final moodEmojis = _buildMoodEmojiRow(moods);
    final moodSummary = _buildMoodSummary(moodEmojis);
    final motivationalMessage = _buildMotivationalMessage(moodEmojis);

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
          final dayIndex = dt.weekday - 1; // Mon=0 ... Sun=6
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
    } catch (_) {
      // keep default zeros
    }

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
    return List<String>.generate(7, (i) {
      final rawMood = moods[i];
      return _moodToEmoji(rawMood);
    });
  }

  String _moodToEmoji(String? mood) {
    final value = (mood ?? '').toLowerCase().trim();

    if (value.contains('happy') ||
        value.contains('great') ||
        value.contains('good') ||
        value.contains('excited') ||
        value.contains('motivated') ||
        value.contains('productive') ||
        value.contains('calm')) {
      return '😊';
    }

    if (value.contains('okay') ||
        value.contains('neutral') ||
        value.contains('fine') ||
        value.contains('normal') ||
        value.contains('average')) {
      return '😐';
    }

    if (value.contains('sad') ||
        value.contains('bad') ||
        value.contains('stressed') ||
        value.contains('tired') ||
        value.contains('angry') ||
        value.contains('upset') ||
        value.contains('anxious') ||
        value.contains('overwhelmed')) {
      return '☹️';
    }

    return '😐';
  }

  String _buildMoodSummary(List<String> moodEmojis) {
    final happyCount = moodEmojis.where((e) => e == '😊').length;
    final neutralCount = moodEmojis.where((e) => e == '😐').length;
    final sadCount = moodEmojis.where((e) => e == '☹️').length;

    if (happyCount >= 5) {
      return 'Your week looked emotionally strong and positive overall.';
    }

    if (sadCount >= 4) {
      return 'This week seems emotionally heavy, with several lower-mood days.';
    }

    if (neutralCount >= 4) {
      return 'Your week felt mostly steady and balanced, without major emotional swings.';
    }

    if (happyCount > sadCount) {
      return 'You had more positive days than difficult ones this week.';
    }

    if (sadCount > happyCount) {
      return 'You had a few tough days this week, so extra care and rest may help.';
    }

    return 'Your week had a mix of emotions, showing both good moments and harder ones.';
  }

  String _buildMotivationalMessage(List<String> moodEmojis) {
    final happyCount = moodEmojis.where((e) => e == '😊').length;
    final neutralCount = moodEmojis.where((e) => e == '😐').length;
    final sadCount = moodEmojis.where((e) => e == '☹️').length;

    // Mostly happy
    if (happyCount >= 5) {
      return 'You have built strong momentum this week. Keep going — your energy and consistency are paying off.';
    }

    // Mostly sad
    if (sadCount >= 5) {
      return 'This week may have felt difficult, but hard weeks do not define you. Take things one step at a time and be kind to yourself.';
    }

    // Mostly neutral
    if (neutralCount >= 5) {
      return 'A steady week is still progress. Keep moving forward with small, consistent steps.';
    }

    // Mixed moods
    if (happyCount >= 3 && sadCount >= 2) {
      return 'This week had both highs and lows. Even with ups and downs, you kept showing up — and that matters.';
    }

    // More happy than sad
    if (happyCount > sadCount) {
      return 'You had a fairly positive week. Stay focused and carry this good energy into the next one.';
    }

    // More sad than happy
    if (sadCount > happyCount) {
      return 'You faced some challenging moments this week. Give yourself credit for making it through, and remember tomorrow is a fresh start.';
    }

    // Default
    return 'Every week is part of your journey. Keep learning, keep growing, and trust your progress.';
  }

  int _percentageDelta(int previous, int current) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return (((current - previous) / previous) * 100).round();
  }
}
