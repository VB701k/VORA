class NoteModel {
  final String id;
  final String title;
  final String description;
  final String metaLeft;
  final String actionText;
  final bool featured;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.metaLeft,
    required this.actionText,
    this.featured = false,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? description,
    String? metaLeft,
    String? actionText,
    bool? featured,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      metaLeft: metaLeft ?? this.metaLeft,
      actionText: actionText ?? this.actionText,
      featured: featured ?? this.featured,
    );
  }
}