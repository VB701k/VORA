import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeProfileService {
  HomeProfileService._();
  static final HomeProfileService instance = HomeProfileService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  Future<String> fetchMyName() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data();
    return (data?['name'] ?? 'VORA Student').toString();
  }
}
