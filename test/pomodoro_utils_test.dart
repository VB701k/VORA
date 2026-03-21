import 'package:flutter_test/flutter_test.dart';
import 'package:vora/backend/utils/pomodoro_utils.dart';

void main() {
  group('PomodoroUtils', () {
    test('formatTime returns correct mm:ss format', () {
      expect(PomodoroUtils.formatTime(1500), '25:00');
      expect(PomodoroUtils.formatTime(65), '01:05');
      expect(PomodoroUtils.formatTime(5), '00:05');
    });

    test('progress returns correct fraction', () {
      expect(
        PomodoroUtils.progress(secondsLeft: 1500, totalSeconds: 1500),
        1.0,
      );

      expect(
        PomodoroUtils.progress(secondsLeft: 750, totalSeconds: 1500),
        0.5,
      );

      expect(
        PomodoroUtils.progress(secondsLeft: 0, totalSeconds: 1500),
        0.0,
      );
    });

    test('progress returns 0 if totalSeconds is 0', () {
      expect(
        PomodoroUtils.progress(secondsLeft: 10, totalSeconds: 0),
        0.0,
      );
    });

    test('totalSecondsFromMinutes returns correct total seconds', () {
      expect(PomodoroUtils.totalSecondsFromMinutes(25), 1500);
      expect(PomodoroUtils.totalSecondsFromMinutes(1), 60);
    });
  });
}