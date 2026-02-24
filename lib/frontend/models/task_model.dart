import 'attachment_model.dart';

class TaskModel {
  final String id;
  final String title;
  final String course;
  final String dueLabel;
  final bool completed;
  final List<String> linkedNoteTitles;
  final List<AttachmentModel> attachments;

  TaskModel({
    required this.id,
    required this.title,
    required this.course,
    required this.dueLabel,
    this.completed = false,
    this.linkedNoteTitles = const [],
    this.attachments = const [],
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? course,
    String? dueLabel,
    bool? completed,
    List<String>? linkedNoteTitles,
    List<AttachmentModel>? attachments,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      dueLabel: dueLabel ?? this.dueLabel,
      completed: completed ?? this.completed,
      linkedNoteTitles: linkedNoteTitles ?? this.linkedNoteTitles,
      attachments: attachments ?? this.attachments,
    );
  }
}