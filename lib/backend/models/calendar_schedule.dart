class CalendarSchedule {
  final String id;
  final String title;
  final String type; // class / assignment / exam / custom
  final DateTime startDateTime;
  final DateTime deadline;
  final String place;
  final String? durationText;
  final String badge;
  final bool isCompleted;
  final bool isManuallyCreated;

  CalendarSchedule({
    required this.id,
    required this.title,
    required this.type,
    required this.startDateTime,
    required this.deadline,
    required this.place,
    this.durationText,
    this.badge = '',
    this.isCompleted = false,
    this.isManuallyCreated = false,
  });

  bool get isExpired => !isCompleted && deadline.isBefore(DateTime.now());

  CalendarSchedule copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? startDateTime,
    DateTime? deadline,
    String? place,
    String? durationText,
    String? badge,
    bool? isCompleted,
    bool? isManuallyCreated,
  }) {
    return CalendarSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startDateTime: startDateTime ?? this.startDateTime,
      deadline: deadline ?? this.deadline,
      place: place ?? this.place,
      durationText: durationText ?? this.durationText,
      badge: badge ?? this.badge,
      isCompleted: isCompleted ?? this.isCompleted,
      isManuallyCreated: isManuallyCreated ?? this.isManuallyCreated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'startDateTime': startDateTime.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'place': place,
      'durationText': durationText,
      'badge': badge,
      'isCompleted': isCompleted,
      'isManuallyCreated': isManuallyCreated,
    };
  }

  factory CalendarSchedule.fromJson(Map<String, dynamic> json) {
    return CalendarSchedule(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      startDateTime: DateTime.parse(json['startDateTime']),
      deadline: DateTime.parse(json['deadline']),
      place: json['place'] ?? '',
      durationText: json['durationText'],
      badge: json['badge'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      isManuallyCreated: json['isManuallyCreated'] ?? false,
    );
  }
}
