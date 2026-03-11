import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vora/backend/services/notification_service.dart';
import 'package:vora/backend/models/calendar_schedule.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CalendarService {
  static const String _manualSchedulesKey = 'manual_schedules_v1';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _schedulerReady = false;

  Future<void> _initSchedulerIfNeeded() async {
    if (_schedulerReady) return;

    tz.initializeTimeZones();

    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    _schedulerReady = true;
  }

  NotificationDetails _deadlineNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'deadline_channel',
      'Deadline Notifications',
      channelDescription: 'Deadline and reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  int _beforeDeadlineNotificationId(String id) => id.hashCode.abs() + 1000;

  int _deadlineNotificationId(String id) => id.hashCode.abs() + 2000;

  Future<void> _scheduleNotifications(CalendarSchedule schedule) async {
    await _initSchedulerIfNeeded();

    final now = DateTime.now();
    final deadline = schedule.deadline;
    final oneDayBefore = deadline.subtract(const Duration(days: 1));

    try {
      // Schedule 1-day-before reminder
      if (oneDayBefore.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          _beforeDeadlineNotificationId(schedule.id),
          'Reminder: ${schedule.title}',
          'This task is due in 1 day.',
          tz.TZDateTime.from(oneDayBefore, tz.local),
          _deadlineNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // Schedule exact-deadline notification
      if (deadline.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          _deadlineNotificationId(schedule.id),
          'Deadline reached: ${schedule.title}',
          'Your deadline has arrived.',
          tz.TZDateTime.from(deadline, tz.local),
          _deadlineNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      print('Notification scheduling failed: $e');
    }
  }

  Future<void> _cancelScheduledNotifications(String id) async {
    await _notificationsPlugin.cancel(_beforeDeadlineNotificationId(id));
    await _notificationsPlugin.cancel(_deadlineNotificationId(id));
  }

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

    if (!schedule.isCompleted) {
      await _scheduleNotifications(schedule);
    }
  }

  Future<void> toggleCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _loadManualSchedules();

    final updated = items.map((e) {
      if (e.id == id) {
        final newValue = !e.isCompleted;
        return e.copyWith(isCompleted: newValue);
      }
      return e;
    }).toList();

    final encoded = updated.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_manualSchedulesKey, encoded);

    final changedItem = updated.firstWhere((e) => e.id == id);

    if (changedItem.isCompleted) {
      await _cancelScheduledNotifications(id);
    } else {
      await _scheduleNotifications(changedItem);
    }
  }

  Future<void> checkExpiredAndNotify() async {
    final all = await getAllSchedules();

    for (final item in all) {
      if (item.isExpired && !item.isCompleted) {
        await NotificationService().showNotification(
          title: 'Missed deadline',
          body: '${item.title} has expired.',
        );
      }
    }
  }

  Future<List<CalendarSchedule>> _loadManualSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_manualSchedulesKey) ?? [];

    return raw.map((e) => CalendarSchedule.fromJson(jsonDecode(e))).toList();
  }

  List<CalendarSchedule> _loadFromCourseworkBreakdown() {
    return [];
  }
}
