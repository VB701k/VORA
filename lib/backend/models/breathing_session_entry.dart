import 'package:cloud_firestore/cloud_firestore.dart';

class BreathingSessionEntry {
  final String id;
  final String exerciseType;
  final int totalCycles;
  final int completedCycles;
  final int phaseSeconds;
  final int durationSeconds;
  final bool soundOn;
  final DateTime completedAt;

  BreathingSessionEntry({
    required this.id,
    required this.exerciseType,
    required this.totalCycles,
    required this.completedCycles,
    required this.phaseSeconds,
    required this.durationSeconds,
    required this.soundOn,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseType': exerciseType,
      'totalCycles': totalCycles,
      'completedCycles': completedCycles,
      'phaseSeconds': phaseSeconds,
      'durationSeconds': durationSeconds,
      'soundOn': soundOn,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory BreathingSessionEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final completedAtTs = data['completedAt'] as Timestamp?;

    return BreathingSessionEntry(
      id: doc.id,
      exerciseType: data['exerciseType'] ?? 'box_breathing',
      totalCycles: data['totalCycles'] ?? 0,
      completedCycles: data['completedCycles'] ?? 0,
      phaseSeconds: data['phaseSeconds'] ?? 0,
      durationSeconds: data['durationSeconds'] ?? 0,
      soundOn: data['soundOn'] ?? true,
      completedAt: completedAtTs?.toDate() ?? DateTime.now(),
    );
  }
}
