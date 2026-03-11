import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vora/backend/models/calendar_schedule.dart';

class CalendarService {
  static const String _manualSchedulesKey = 'manual_schedules_v1';

  Future<void> checkExpiredAndNotify() async {
    // Placeholder for notification logic.
    // Safe to leave empty for now.
  }

  Future<void> addManualSchedule(CalendarSchedule item) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_manualSchedulesKey) ?? [];

    final updated = [...existing, jsonEncode(_toMap(item))];
    await prefs.setStringList(_manualSchedulesKey, updated);
  }

  Future<void> toggleCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_manualSchedulesKey) ?? [];

    final updated = existing.map((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if ((map['id'] ?? '').toString() == id) {
        map['isCompleted'] = !((map['isCompleted'] ?? false) as bool);
      }
      return jsonEncode(map);
    }).toList();

    await prefs.setStringList(_manualSchedulesKey, updated);
  }

  Future<List<CalendarSchedule>> getSchedulesForMonth(DateTime month) async {
    final all = await _loadManualSchedules();

    final filtered = all.where((item) {
      return item.startDateTime.year == month.year &&
          item.startDateTime.month == month.month;
    }).toList();

    filtered.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return filtered;
  }

  Future<List<CalendarSchedule>> getSchedulesForWeek(
    DateTime selectedDay,
  ) async {
    final all = await _loadManualSchedules();

    final startOfWeek = _startOfWeek(selectedDay);
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    final filtered = all.where((item) {
      return !item.startDateTime.isBefore(startOfWeek) &&
          !item.startDateTime.isAfter(endOfWeek);
    }).toList();

    filtered.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return filtered;
  }

  Future<List<CalendarSchedule>> getSchedulesForDay(DateTime day) async {
    final all = await _loadManualSchedules();

    final filtered = all.where((item) {
      return item.startDateTime.year == day.year &&
          item.startDateTime.month == day.month &&
          item.startDateTime.day == day.day;
    }).toList();

    filtered.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return filtered;
  }

  Future<List<CalendarSchedule>> _loadManualSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_manualSchedulesKey) ?? [];

    return rawList.map((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _fromMap(map);
    }).toList();
  }

  DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  Map<String, dynamic> _toMap(CalendarSchedule item) {
    return {
      'id': item.id,
      'title': item.title,
      'type': item.type,
      'startDateTime': item.startDateTime.toIso8601String(),
      'deadline': item.deadline.toIso8601String(),
      'place': item.place,
      'durationText': item.durationText,
      'badge': item.badge,
      'isCompleted': item.isCompleted,
      'isManuallyCreated': item.isManuallyCreated,
    };
  }

  CalendarSchedule _fromMap(Map<String, dynamic> map) {
    return CalendarSchedule(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      type: (map['type'] ?? 'assignment').toString(),
      startDateTime:
          DateTime.tryParse((map['startDateTime'] ?? '').toString()) ??
          DateTime.now(),
      deadline:
          DateTime.tryParse((map['deadline'] ?? '').toString()) ??
          DateTime.now(),
      place: (map['place'] ?? '').toString(),
      durationText: map['durationText']?.toString(),
      badge: (map['badge'] ?? '').toString(),
      isCompleted: (map['isCompleted'] ?? false) as bool,
      isManuallyCreated: (map['isManuallyCreated'] ?? true) as bool,
    );
  }
}
