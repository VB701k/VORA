class DateKey {
  /// Returns today's date as a string key (YYYY-MM-DD)
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Returns a date key for a specific date
  static String fromDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Converts a date key back to DateTime
  static DateTime toDate(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  /// Checks if two date keys are the same day
  static bool isSameDay(String key1, String key2) {
    return key1 == key2;
  }
}
