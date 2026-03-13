import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PomodoroService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> saveSession(int seconds) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('pomodoro_sessions')
        .add({
      'duration': seconds,
      'date':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'created_at': Timestamp.now(),
    });
  }
}