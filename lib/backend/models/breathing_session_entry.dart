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

  // Factory constructor for empty session
  factory BreathingSessionEntry.empty() {
    return BreathingSessionEntry(
      id: '',
      exerciseType: 'box_breathing',
      totalCycles: 0,
      completedCycles: 0,
      phaseSeconds: 0,
      durationSeconds: 0,
      soundOn: true,
      completedAt: DateTime.now(),
    );
  }

  // Convert to map for Firestore
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

  // Create from Firestore document
  factory BreathingSessionEntry.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null for ID: ${doc.id}');
    }

    return BreathingSessionEntry(
      id: doc.id,
      exerciseType: data['exerciseType'] as String? ?? 'box_breathing',
      totalCycles: data['totalCycles'] as int? ?? 0,
      completedCycles: data['completedCycles'] as int? ?? 0,
      phaseSeconds: data['phaseSeconds'] as int? ?? 0,
      durationSeconds: data['durationSeconds'] as int? ?? 0,
      soundOn: data['soundOn'] as bool? ?? true,
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Computed properties
  double get completionPercentage {
    if (totalCycles == 0) return 0;
    return completedCycles / totalCycles;
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );

    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${completedAt.month}/${completedAt.day}/${completedAt.year}';
    }
  }

  String get formattedTime {
    return '${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';
  }

  // Get phase description
  String get phaseDescription {
    switch (phaseSeconds) {
      case 4:
        return 'Standard (4-4-4-4)';
      case 3:
        return 'Quick (3-3-3-3)';
      case 5:
        return 'Deep (5-5-5-5)';
      default:
        return '$phaseSeconds-$phaseSeconds-$phaseSeconds-$phaseSeconds';
    }
  }

  // Check if session was completed (all cycles finished)
  bool get isCompleted => completedCycles >= totalCycles;

  // Get completion status message
  String get completionStatus {
    if (isCompleted) return 'Completed';
    if (completedCycles == 0) return 'Not Started';
    return 'Partially Completed';
  }

  @override
  String toString() {
    return 'BreathingSessionEntry(id: $id, completed: $formattedDate, '
        'cycles: $completedCycles/$totalCycles, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreathingSessionEntry &&
        other.id == id &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode => id.hashCode ^ completedAt.hashCode;
}
