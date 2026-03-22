import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardService {
  RewardService._();
  static final RewardService instance = RewardService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception("User not logged in");
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  Future<void> addPoints(int points) async {
    await _userRef.set({
      'points': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<int> getPoints() async {
    final doc = await _userRef.get();
    final data = doc.data() ?? {};
    return (data['points'] as num?)?.toInt() ?? 0;
  }
}
