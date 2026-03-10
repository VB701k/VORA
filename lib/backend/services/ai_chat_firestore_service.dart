import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vora/backend/models/chat_session.dart';

class AiChatFirestoreService {
  AiChatFirestoreService._();
  static final AiChatFirestoreService instance = AiChatFirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _chatCol {
    return _db.collection('users').doc(_uid).collection('ai_chats');
  }

  Future<void> saveChat(ChatSession chat) async {
    await _chatCol.doc(chat.id).set({
      'title': chat.title,
      'createdAt': Timestamp.fromDate(chat.createdAt),
      'messages': chat.messages,
    });
  }

  Future<List<ChatSession>> loadChats() async {
    final snapshot = await _chatCol
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      final rawMessages = (data['messages'] as List<dynamic>? ?? []);
      final messages = rawMessages
          .map(
            (item) => Map<String, String>.from(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      return ChatSession(
        id: doc.id,
        title: (data['title'] ?? 'New Chat').toString(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        messages: messages,
      );
    }).toList();
  }
}
