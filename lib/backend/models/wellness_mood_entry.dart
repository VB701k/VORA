import 'package:cloud_firestore/cloud_firestore.dart';

class WellnessMoodEntry {
  final String id;
  final String mood;
  final DateTime date;
  final DateTime updatedAt;

  WellnessMoodEntry({
    required this.id,
    required this.mood,
    required this.date,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'date': Timestamp.fromDate(date),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WellnessMoodEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final dateTs = data['date'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;

    return WellnessMoodEntry(
      id: doc.id,
      mood: data['mood'] ?? '',
      date: dateTs?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate() ?? DateTime.now(),
    );
  }
}
