import 'package:cloud_firestore/cloud_firestore.dart';

class MindfulPopSession {
  final String id;
  final int score;
  final int bestStreak;
  final int poppedBubbles;
  final int missedBubbles;
  final int durationSeconds;
  final bool soundEnabled;
  final String endedReason;
  final DateTime startedAt;
  final DateTime endedAt;

  const MindfulPopSession({
    required this.id,
    required this.score,
    required this.bestStreak,
    required this.poppedBubbles,
    required this.missedBubbles,
    required this.durationSeconds,
    required this.soundEnabled,
    required this.endedReason,
    required this.startedAt,
    required this.endedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'bestStreak': bestStreak,
      'poppedBubbles': poppedBubbles,
      'missedBubbles': missedBubbles,
      'durationSeconds': durationSeconds,
      'soundEnabled': soundEnabled,
      'endedReason': endedReason,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': Timestamp.fromDate(endedAt),
    };
  }

  factory MindfulPopSession.fromMap(Map<String, dynamic> map) {
    return MindfulPopSession(
      id: map['id'] as String? ?? '',
      score: _readInt(map['score']),
      bestStreak: _readInt(map['bestStreak']),
      poppedBubbles: _readInt(map['poppedBubbles']),
      missedBubbles: _readInt(map['missedBubbles']),
      durationSeconds: _readInt(map['durationSeconds']),
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      endedReason: map['endedReason'] as String? ?? 'unknown',
      startedAt: _readDate(map['startedAt']),
      endedAt: _readDate(map['endedAt']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
