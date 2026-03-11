class ChatSession {
  final String id;
  final DateTime createdAt;
  final String title;
  final List<Map<String, String>> messages;

  ChatSession({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.messages,
  });
}
