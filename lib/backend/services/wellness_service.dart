import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wellness_mood_entry.dart';
import '../models/breathing_session_entry.dart';

class WellnessService {
  WellnessService._();
  static final WellnessService instance = WellnessService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid {
    return _auth.currentUser?.uid;
  }

  bool get isAuthenticated => _uid != null;

  CollectionReference<Map<String, dynamic>>? get _moodsRef {
    final uid = _uid;
    if (uid == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wellness')
        .doc('tracker')
        .collection('moods');
  }

  CollectionReference<Map<String, dynamic>>? get _breathingRef {
    final uid = _uid;
    if (uid == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
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
    final ref = _moodsRef;
    if (ref == null) throw Exception('User not authenticated');

    final normalized = normalizeDate(date);
    final docId = _dateKey(normalized);

    await ref.doc(docId).set({
      'mood': mood,
      'date': Timestamp.fromDate(normalized),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<WellnessMoodEntry?> getMoodForDate(DateTime date) async {
    final ref = _moodsRef;
    if (ref == null) throw Exception('User not authenticated');

    final normalized = normalizeDate(date);
    final docId = _dateKey(normalized);

    final doc = await ref.doc(docId).get();
    if (!doc.exists) return null;

    return WellnessMoodEntry.fromDoc(doc);
  }

  Future<List<WellnessMoodEntry>> getMoodHistory() async {
    final ref = _moodsRef;
    if (ref == null) throw Exception('User not authenticated');

    final snapshot = await ref.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => WellnessMoodEntry.fromDoc(doc)).toList();
  }

  Stream<List<WellnessMoodEntry>> streamMoodHistory() {
    final ref = _moodsRef;
    if (ref == null) return Stream.error('User not authenticated');

    return ref.orderBy('date', descending: true).snapshots().map((snapshot) {
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
    final ref = _breathingRef;
    if (ref == null) throw Exception('User not authenticated');

    final durationSeconds = totalCycles * 4 * phaseSeconds;

    await ref.add({
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
    final ref = _breathingRef;
    if (ref == null) throw Exception('User not authenticated');

    final snapshot = await ref.orderBy('completedAt', descending: true).get();

    return snapshot.docs
        .map((doc) => BreathingSessionEntry.fromDoc(doc))
        .toList();
  }

  Stream<List<BreathingSessionEntry>> streamBreathingHistory() {
    final ref = _breathingRef;
    if (ref == null) return Stream.error('User not authenticated');

    return ref.orderBy('completedAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => BreathingSessionEntry.fromDoc(doc))
          .toList();
    });
  }
}
