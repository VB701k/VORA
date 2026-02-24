import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/date_key.dart';
import '../core/firestore_paths.dart';

class StreakService {
  /// Call this when user completes a task or logs study session.
  Future<void> markActiveToday(String userId) async {
    try {
      final userRef = FirestorePaths.userDoc(userId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(userRef);

        if (!snap.exists) {
          // Create user document if it doesn't exist
          tx.set(userRef, {
            'lastActiveDate': DateKey.todayKey(),
            'streak': 1,
            'longestStreak': 1,
            'userId': userId,
          });
          return;
        }

        final data = snap.data() as Map<String, dynamic>? ?? {};

        final todayKey = DateKey.todayKey();
        final lastKey = data['lastActiveDate'] as String?;
        final currentStreak = (data['streak'] ?? 0) as int;
        final longestStreak = (data['longestStreak'] ?? 0) as int;

        if (lastKey == todayKey) return;

        int newStreak = 1;
        if (lastKey != null) {
          final last = DateKey.toDate(lastKey);
          final expected = DateKey.fromDate(last.add(const Duration(days: 1)));
          if (expected == todayKey) {
            newStreak = currentStreak + 1;
          }
        }

        // Update longest streak if needed
        final newLongestStreak = newStreak > longestStreak
            ? newStreak
            : longestStreak;

        tx.set(userRef, {
          'lastActiveDate': todayKey,
          'streak': newStreak,
          'longestStreak': newLongestStreak,
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  /// Get current streak for a user
  Future<int> getCurrentStreak(String userId) async {
    try {
      final doc = await FirestorePaths.userDoc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['streak'] ?? 0;
    } catch (e) {
      print('Error getting streak: $e');
      return 0;
    }
  }

  /// Get longest streak for a user
  Future<int> getLongestStreak(String userId) async {
    try {
      final doc = await FirestorePaths.userDoc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['longestStreak'] ?? 0;
    } catch (e) {
      print('Error getting longest streak: $e');
      return 0;
    }
  }
}
