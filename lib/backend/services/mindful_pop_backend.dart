import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/mindful_pop_session.dart';

class MindfulPopBackend {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MindfulPopBackend({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to use Mindful Pop backend.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _sessionsRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('mindful_pop_sessions');

  CollectionReference<Map<String, dynamic>> get _metaRef =>
      _firestore.collection('users').doc(_uid).collection('mindful_pop_meta');

  Future<void> saveSession(MindfulPopSession session) async {
    final sessionDoc = _sessionsRef.doc(session.id);
    final summaryDoc = _metaRef.doc('summary');

    await _firestore.runTransaction((transaction) async {
      final summarySnap = await transaction.get(summaryDoc);
      final summary = summarySnap.data() ?? <String, dynamic>{};

      final currentBestScore = _readInt(summary['bestScore']);
      final currentBestStreak = _readInt(summary['bestStreak']);
      final currentTotalSessions = _readInt(summary['totalSessions']);
      final currentTotalPopped = _readInt(summary['totalPopped']);
      final currentTotalMissed = _readInt(summary['totalMissed']);
      final currentTotalPlaySeconds = _readInt(summary['totalPlaySeconds']);

      transaction.set(sessionDoc, {
        ...session.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(summaryDoc, {
        'totalSessions': currentTotalSessions + 1,
        'totalPopped': currentTotalPopped + session.poppedBubbles,
        'totalMissed': currentTotalMissed + session.missedBubbles,
        'totalPlaySeconds': currentTotalPlaySeconds + session.durationSeconds,
        'bestScore': max(currentBestScore, session.score),
        'bestStreak': max(currentBestStreak, session.bestStreak),
        'lastScore': session.score,
        'lastPlayedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> saveSoundPreference(bool soundOn) async {
    await _metaRef.doc('settings').set({
      'soundOn': soundOn,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> getSoundPreference() async {
    final doc = await _metaRef.doc('settings').get();
    final data = doc.data();
    return data?['soundOn'] as bool? ?? true;
  }

  Stream<Map<String, dynamic>> streamSummary() {
    return _metaRef
        .doc('summary')
        .snapshots()
        .map((doc) => doc.data() ?? <String, dynamic>{});
  }

  Stream<List<MindfulPopSession>> streamRecentSessions({int limit = 10}) {
    return _sessionsRef
        .orderBy('endedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MindfulPopSession.fromMap(doc.data()))
              .toList(),
        );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
