import 'package:cloud_firestore/cloud_firestore.dart';

class AppTask {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate; // ✅ UI uses dueDate
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
      "dueAt": Timestamp.fromDate(dueDate), // ✅ store as dueAt
      "isCompleted": isCompleted,
      "source": source,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory AppTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final Timestamp? ts = data["dueAt"]; // ✅ read dueAt
    final DateTime due = ts?.toDate() ?? DateTime.now();

    return AppTask(
      id: doc.id,
      title: (data["title"] ?? "").toString(),
      subtitle: (data["subtitle"] ?? "").toString(),
      dueDate: due, // ✅ map dueAt -> dueDate
      isCompleted: (data["isCompleted"] ?? false) as bool,
      source: (data["source"] ?? "task").toString(),
    );
  }
}
