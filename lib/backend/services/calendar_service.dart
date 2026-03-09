import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vora/backend/services/notification_service.dart';
import 'package:vora/backend/models/calendar_schedule.dart';

class CalendarService {
  static const String _manualSchedulesKey = 'manual_schedules_v1';

  Future<List<CalendarSchedule>> getAllSchedules() async {
    final courseworkSchedules = _loadFromCourseworkBreakdown();
    final manualSchedules = await _loadManualSchedules();

    final all = [...courseworkSchedules, ...manualSchedules];
    all.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return all;
  }

  Future<List<CalendarSchedule>> getSchedulesForDay(DateTime day) async {
    final all = await getAllSchedules();
    return all.where((item) {
      return item.startDateTime.year == day.year &&
          item.startDateTime.month == day.month &&
          item.startDateTime.day == day.day;
    }).toList();
  }

  Future<List<CalendarSchedule>> getSchedulesForWeek(
    DateTime selectedDay,
  ) async {
    final all = await getAllSchedules();

    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday % 7),
    );
    final weekStart = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final weekEnd = weekStart.add(const Duration(days: 7));

    return all.where((item) {
      return item.startDateTime.isAfter(
            weekStart.subtract(const Duration(seconds: 1)),
          ) &&
          item.startDateTime.isBefore(weekEnd);
    }).toList();
  }

  Future<List<CalendarSchedule>> getSchedulesForMonth(DateTime month) async {
    final all = await getAllSchedules();
    return all.where((item) {
      return item.startDateTime.year == month.year &&
          item.startDateTime.month == month.month;
    }).toList();
  }

  Future<void> addManualSchedule(CalendarSchedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _loadManualSchedules();
    items.add(schedule);

    final encoded = items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_manualSchedulesKey, encoded);

    await NotificationService().scheduleDeadlineReminder(
      id: schedule.id.hashCode,
      title: schedule.title,
      deadline: schedule.deadline,
    );
  }

  Future<void> markCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _loadManualSchedules();

    final updated = items.map((e) {
      if (e.id == id) {
        return e.copyWith(isCompleted: true);
      }
      return e;
    }).toList();

    final encoded = updated.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_manualSchedulesKey, encoded);

    await NotificationService().cancelNotification(id.hashCode);
  }

  Future<void> checkExpiredAndNotify() async {
    final all = await getAllSchedules();

    for (final item in all) {
      if (item.isExpired) {
        await NotificationService().showExpiredNotification(title: item.title);
      }
    }
  }

  Future<List<CalendarSchedule>> _loadManualSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_manualSchedulesKey) ?? [];

    return raw.map((e) => CalendarSchedule.fromJson(jsonDecode(e))).toList();
  }

  List<CalendarSchedule> _loadFromCourseworkBreakdown() {
    // TEMPORARY SAFE VERSION
    // Return empty list for now until coursework_breakdown data is connected.
    return [];
  }
}
