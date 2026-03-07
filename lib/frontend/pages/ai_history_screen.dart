import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/models/chat_session.dart';

class AiHistoryScreen extends StatelessWidget {
  final List<ChatSession> chatHistory;

  const AiHistoryScreen({super.key, required this.chatHistory});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFF071A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Chat History"),
        centerTitle: true,
      ),
      body: chatHistory.isEmpty
          ? const Center(
              child: Text(
                "No previous chats yet.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];

                return ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                  title: Text(
                    chat.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    dateFormat.format(chat.createdAt),
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
    );
  }
}
