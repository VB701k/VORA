import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePaths {
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  /// Get user document reference
  static DocumentReference userDoc([String? userId]) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');
    return db.collection('users').doc(uid);
  }

  /// Get user's tasks collection
  static CollectionReference tasksCollection(String userId) {
    return db.collection('users').doc(userId).collection('tasks');
  }

  /// Get user's notes collection
  static CollectionReference notesCollection(String userId) {
    return db.collection('users').doc(userId).collection('notes');
  }

  /// Get user's preferences collection
  static CollectionReference preferencesCollection(String userId) {
    return db.collection('users').doc(userId).collection('preferences');
  }

  /// Get daily quotes collection
  static CollectionReference dailyQuotesCollection() {
    return db.collection('dailyQuotes');
  }

  /// Get quotes collection
  static CollectionReference quotesCollection() {
    return db.collection('quotes');
  }
}
