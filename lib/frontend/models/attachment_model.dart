class AttachmentModel {
  final String id;
  final String name;
  final String type;
  final String sizeLabel;
  final String? fileUrl;

  const AttachmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeLabel,
    this.fileUrl,
  });
}