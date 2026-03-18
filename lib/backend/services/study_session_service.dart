import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudySessionService {
  StudySessionService._();
  static final StudySessionService instance = StudySessionService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _studyCol {
    return _db.collection('users').doc(_uid).collection('study_sessions');
  }

  Future<void> saveSession({
    required DateTime startedAt,
    required int minutes,
  }) async {
    await _studyCol.add({
      'startedAt': Timestamp.fromDate(startedAt),
      'minutes': minutes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
