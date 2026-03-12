import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/wellness_mood_entry.dart';
import '../models/breathing_session_entry.dart';

class WellnessService {
  WellnessService._();
  static final WellnessService instance = WellnessService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _moodsRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('wellness')
        .doc('tracker')
        .collection('moods');
  }

  CollectionReference<Map<String, dynamic>> get _breathingRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('wellness')
        .doc('tracker')
        .collection('breathing_sessions');
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> saveMoodForDate({
    required DateTime date,
    required String mood,
  }) async {
    final normalized = normalizeDate(date);
    final docId = _dateKey(normalized);

    await _moodsRef.doc(docId).set({
      'mood': mood,
      'date': Timestamp.fromDate(normalized),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<WellnessMoodEntry?> getMoodForDate(DateTime date) async {
    final normalized = normalizeDate(date);
    final docId = _dateKey(normalized);

    final doc = await _moodsRef.doc(docId).get();
    if (!doc.exists) return null;

    return WellnessMoodEntry.fromDoc(doc);
  }

  Future<List<WellnessMoodEntry>> getMoodHistory() async {
    final snapshot = await _moodsRef.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => WellnessMoodEntry.fromDoc(doc)).toList();
  }

  Stream<List<WellnessMoodEntry>> streamMoodHistory() {
    return _moodsRef.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => WellnessMoodEntry.fromDoc(doc))
          .toList();
    });
  }

  Future<void> saveBoxBreathingSession({
    required int totalCycles,
    required int completedCycles,
    required int phaseSeconds,
    required bool soundOn,
  }) async {
    final durationSeconds = totalCycles * 4 * phaseSeconds;

    await _breathingRef.add({
      'exerciseType': 'box_breathing',
      'totalCycles': totalCycles,
      'completedCycles': completedCycles,
      'phaseSeconds': phaseSeconds,
      'durationSeconds': durationSeconds,
      'soundOn': soundOn,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<BreathingSessionEntry>> getBreathingHistory() async {
    final snapshot = await _breathingRef
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BreathingSessionEntry.fromDoc(doc))
        .toList();
  }

  Stream<List<BreathingSessionEntry>> streamBreathingHistory() {
    return _breathingRef
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BreathingSessionEntry.fromDoc(doc))
              .toList();
        });
  }
}
