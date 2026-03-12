import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vora/backend/models/app_task.dart';
import 'package:vora/backend/models/weekly_analysis_model.dart';

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
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final prevWeekEnd = weekEnd.subtract(const Duration(days: 7));

    final currentTasks = await _fetchTasksBetween(weekStart, weekEnd);
    final previousTasks = await _fetchTasksBetween(prevWeekStart, prevWeekEnd);

    final currentMoods = await _fetchMoodsBetween(weekStart, weekEnd);

    final currentPomodoroMinutes = await _fetchPomodoroMinutesByDay(
      weekStart,
      weekEnd,
    );
    final previousPomodoroMinutes = await _fetchPomodoroMinutesByDay(
      prevWeekStart,
      prevWeekEnd,
    );

    final taskCompletionByDay = _buildTaskCompletionByDay(currentTasks);
    final mostProductiveDay = _mostProductiveDayFromTasks(currentTasks);

    final taskCompletionPercent = _taskCompletionPercent(currentTasks);
    final previousTaskCompletionPercent = _taskCompletionPercent(previousTasks);
    final taskCompletionDeltaPercent =
        taskCompletionPercent - previousTaskCompletionPercent;

    final totalStudyMinutes = currentPomodoroMinutes.fold<int>(
      0,
      (a, b) => a + b.round(),
    );
    final previousTotalStudyMinutes = previousPomodoroMinutes.fold<int>(
      0,
      (a, b) => a + b.round(),
    );

    final studyHoursLabel = _formatMinutes(totalStudyMinutes);
    final studyHoursDeltaPercent = _percentageDelta(
      previousTotalStudyMinutes,
      totalStudyMinutes,
    );

    final moodEmojis = _buildMoodEmojiRow(currentMoods);
    final moodInsight = _buildMoodInsight(currentMoods);

    return WeeklyAnalysisData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      mostProductiveDay: mostProductiveDay,
      taskCompletionPercent: taskCompletionPercent,
      taskCompletionDeltaPercent: taskCompletionDeltaPercent,
      taskCompletionByDay: taskCompletionByDay,
      studyHoursLabel: studyHoursLabel,
      studyHoursDeltaPercent: studyHoursDeltaPercent,
      studyHoursByDay: currentPomodoroMinutes.map((e) => e / 60.0).toList(),
      moodEmojis: moodEmojis,
      moodInsightTitle: moodInsight.$1,
      moodInsightBody: moodInsight.$2,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final weekday = normalized.weekday; // Mon=1 ... Sun=7
    return normalized.subtract(Duration(days: weekday - 1));
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
      // keep zeros if no data
    }

    return values;
  }

  List<double> _buildTaskCompletionByDay(List<AppTask> tasks) {
    final totalByDay = List<int>.filled(7, 0);
    final completedByDay = List<int>.filled(7, 0);

    for (final task in tasks) {
      final index = task.dueDate.weekday - 1;
      if (index < 0 || index > 6) continue;

      totalByDay[index]++;
      if (task.isCompleted) {
        completedByDay[index]++;
      }
    }

    return List<double>.generate(7, (i) {
      if (totalByDay[i] == 0) return 0;
      return (completedByDay[i] / totalByDay[i]) * 100;
    });
  }

  String _mostProductiveDayFromTasks(List<AppTask> tasks) {
    final completedByDay = List<int>.filled(7, 0);

    for (final task in tasks) {
      if (!task.isCompleted) continue;
      final index = task.dueDate.weekday - 1;
      if (index >= 0 && index < 7) {
        completedByDay[index]++;
      }
    }

    int bestIndex = 0;
    int bestValue = completedByDay[0];

    for (int i = 1; i < completedByDay.length; i++) {
      if (completedByDay[i] > bestValue) {
        bestValue = completedByDay[i];
        bestIndex = i;
      }
    }

    const labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return labels[bestIndex];
  }

  int _taskCompletionPercent(List<AppTask> tasks) {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return ((completed / tasks.length) * 100).round();
  }

  int _percentageDelta(int previous, int current) {
    if (previous <= 0) return current > 0 ? 100 : 0;
    return (((current - previous) / previous) * 100).round();
  }

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return '${hours}h ${mins}m';
  }

  List<String> _buildMoodEmojiRow(Map<int, String> moods) {
    return List<String>.generate(7, (i) {
      final raw = moods[i];
      return _moodToEmoji(raw);
    });
  }

  String _moodToEmoji(String? mood) {
    final value = (mood ?? '').toLowerCase();

    if (value.contains('happy') ||
        value.contains('great') ||
        value.contains('good')) {
      return '😊';
    }
    if (value.contains('calm') ||
        value.contains('okay') ||
        value.contains('neutral')) {
      return '😐';
    }
    if (value.contains('sad') ||
        value.contains('bad') ||
        value.contains('stressed')) {
      return '☹️';
    }
    return '😐';
  }

  int _moodScore(String? mood) {
    final value = (mood ?? '').toLowerCase();

    if (value.contains('happy') ||
        value.contains('great') ||
        value.contains('good')) {
      return 3;
    }
    if (value.contains('calm') ||
        value.contains('okay') ||
        value.contains('neutral')) {
      return 2;
    }
    if (value.contains('sad') ||
        value.contains('bad') ||
        value.contains('stressed')) {
      return 1;
    }
    return 2;
  }

  (String, String) _buildMoodInsight(Map<int, String> moods) {
    if (moods.isEmpty) {
      return (
        'No mood pattern yet.',
        'Track your mood daily to unlock weekly wellness insights.',
      );
    }

    int lowestIndex = 0;
    int lowestScore = 999;

    for (int i = 0; i < 7; i++) {
      final score = _moodScore(moods[i]);
      if (score < lowestScore) {
        lowestScore = score;
        lowestIndex = i;
      }
    }

    const labels = [
      'Mondays',
      'Tuesdays',
      'Wednesdays',
      'Thursdays',
      'Fridays',
      'Saturdays',
      'Sundays',
    ];

    return (
      'Your mood seems to dip on ${labels[lowestIndex]}.',
      'Consider scheduling a lighter study load or a short reset break on that day.',
    );
  }
}
