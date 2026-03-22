import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  StreakService._();
  static final StreakService instance = StreakService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception("User not logged in");
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  String _todayKey() {
    final now = DateTime.now().toUtc();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  String _yesterdayKey() {
    final dt = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  Future<void> markActiveToday() async {
    final today = _todayKey();
    final yesterday = _yesterdayKey();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userRef);
      final data = snap.data() ?? {};

      final last = data['lastActiveDate'] as String?;
      int streak = (data['streak'] as num?)?.toInt() ?? 0;
      int longest = (data['longestStreak'] as num?)?.toInt() ?? 0;

      if (last == today) return;

      if (last == yesterday) {
        streak += 1;
      } else {
        streak = 1;
      }

      if (streak > longest) longest = streak;

      tx.set(_userRef, {
        'lastActiveDate': today,
        'streak': streak,
        'longestStreak': longest,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<int> getCurrentStreak() async {
    final doc = await _userRef.get();
    final data = doc.data() ?? {};
    return (data['streak'] as num?)?.toInt() ?? 0;
  }

  Future<int> getLongestStreak() async {
    final doc = await _userRef.get();
    final data = doc.data() ?? {};
    return (data['longestStreak'] as num?)?.toInt() ?? 0;
  }
}
