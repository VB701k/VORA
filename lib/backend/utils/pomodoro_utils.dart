class PomodoroUtils {
  static String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static double progress({
    required int secondsLeft,
    required int totalSeconds,
  }) {
    if (totalSeconds <= 0) return 0;
    return secondsLeft / totalSeconds;
  }

  static int totalSecondsFromMinutes(int minutes) {
    return minutes * 60;
  }
}