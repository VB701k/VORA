import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vora/backend/services/home_profile_service.dart';

class ProfilePageServices {
  ProfilePageServices._();
  static final ProfilePageServices instance = ProfilePageServices._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserName() {
    return HomeProfileService.instance.fetchMyName();
  }

  String getUserEmail() {
    return (_auth.currentUser?.email ?? '').trim();
  }

  Future<String> getUserAge() async {
    final user = _auth.currentUser;
    if (user == null) {
      return '-';
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    final age = data?['age'];

    return age?.toString() ?? '-';
  }
}
