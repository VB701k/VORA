import 'package:cloud_firestore/cloud_firestore.dart';

class AppTask {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final bool isCompleted;
  final String source;

  AppTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.isCompleted,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "subtitle": subtitle,
      "dueDate": Timestamp.fromDate(dueDate),
      "isCompleted": isCompleted,
      "source": source,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory AppTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppTask(
      id: doc.id,
      title: data["title"],
      subtitle: data["subtitle"],
      dueDate: (data["dueDate"] as Timestamp).toDate(),
      isCompleted: data["isCompleted"],
      source: data["source"],
    );
  }
}
