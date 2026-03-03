import 'package:cloud_firestore/cloud_firestore.dart';

class AppTask {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final bool isCompleted;
  final String source;
  final bool hidden;

  AppTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.isCompleted,
    required this.source,
    required this.hidden,
  });

  factory AppTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final Timestamp? ts = data["dueAt"];
    final DateTime due = ts?.toDate() ?? DateTime.now();

    return AppTask(
      id: doc.id,
      title: (data["title"] ?? "").toString(),
      subtitle: (data["subtitle"] ?? "").toString(),
      dueDate: due,
      isCompleted: (data["isCompleted"] ?? false) as bool,
      source: (data["source"] ?? "task").toString(),
      hidden: (data["hidden"] ?? false) as bool,
    );
  }
}
