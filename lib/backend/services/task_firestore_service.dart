import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sdgp/backend/models/app_task.dart';

class TaskFirestoreService {
  TaskFirestoreService._();
  static final TaskFirestoreService instance = TaskFirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _taskCol {
    return _db.collection('users').doc(_uid).collection('tasks');
  }

  Future<void> addTask({
    required String id,
    required String title,
    required String subtitle,
    required DateTime dueAt,
    required String source,
  }) async {
    await _taskCol.doc(id).set({
      'title': title,
      'subtitle': subtitle,
      'dueAt': Timestamp.fromDate(dueAt),
      'isCompleted': false,
      'source': source,
      'hidden': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppTask>> streamTasks() {
    return _taskCol
        .where('hidden', isEqualTo: false)
        .orderBy('dueAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppTask.fromDoc(d)).toList());
  }

  Future<void> toggleDone(String taskId, bool currentValue) async {
    await _taskCol.doc(taskId).update({'isCompleted': !currentValue});
  }

  Future<void> hideTask(String taskId) async {
    await _taskCol.doc(taskId).update({'hidden': true});
  }
}
