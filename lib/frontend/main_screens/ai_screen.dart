import 'package:flutter/material.dart';
import 'package:vora/backend/services/ai_chat_service.dart';
import 'package:vora/frontend/pages/ai_history_screen.dart';
import '../../backend/models/chat_session.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();

  ChatSession? currentChat;
  List<Map<String, String>> messages = [];
  List<ChatSession> chatHistory = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    currentChat = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      title: "New Chat",
      messages: [],
    );

    chatHistory.add(currentChat!);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userText = text.trim();

    setState(() {
      messages.add({"role": "user", "text": userText});

      if (currentChat != null && messages.length == 1) {
        currentChat = ChatSession(
          id: currentChat!.id,
          createdAt: currentChat!.createdAt,
          title: userText,
          messages: List.from(messages),
        );

        final index = chatHistory.indexWhere(
          (chat) => chat.id == currentChat!.id,
        );
        if (index != -1) {
          chatHistory[index] = currentChat!;
        }
      } else if (currentChat != null) {
        currentChat = ChatSession(
          id: currentChat!.id,
          createdAt: currentChat!.createdAt,
          title: currentChat!.title,
          messages: List.from(messages),
        );

        final index = chatHistory.indexWhere(
          (chat) => chat.id == currentChat!.id,
        );
        if (index != -1) {
          chatHistory[index] = currentChat!;
        }
      }

      _isLoading = true;
    });

    _controller.clear();

    try {
      final reply = await AIChatService.sendMessage(userText);

      setState(() {
        messages.add({"role": "bot", "text": reply});

        if (currentChat != null) {
          currentChat = ChatSession(
            id: currentChat!.id,
            createdAt: currentChat!.createdAt,
            title: currentChat!.title,
            messages: List.from(messages),
          );

          final index = chatHistory.indexWhere(
            (chat) => chat.id == currentChat!.id,
          );
          if (index != -1) {
            chatHistory[index] = currentChat!;
          }
        }
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Sorry, something went wrong. Please try again.",
        });

        if (currentChat != null) {
          currentChat = ChatSession(
            id: currentChat!.id,
            createdAt: currentChat!.createdAt,
            title: currentChat!.title,
            messages: List.from(messages),
          );

          final index = chatHistory.indexWhere(
            (chat) => chat.id == currentChat!.id,
          );
          if (index != -1) {
            chatHistory[index] = currentChat!;
          }
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startNewChat() {
    setState(() {
      messages.clear();

      currentChat = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        title: "New Chat",
        messages: [],
      );

      chatHistory.insert(0, currentChat!);
    });
  }

  Future<void> _openHistory() async {
    final selectedChat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiHistoryScreen(chatHistory: chatHistory),
      ),
    );

    if (selectedChat != null && selectedChat is ChatSession) {
      setState(() {
        currentChat = selectedChat;
        messages = List<Map<String, String>>.from(selectedChat.messages);
      });
    }
  }

  Widget _suggestion(String text) {
    return ElevatedButton(
      onPressed: () => _sendMessage(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Study AI"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _openHistory),
          IconButton(icon: const Icon(Icons.add), onPressed: _startNewChat),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.smart_toy_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Hello! I’m your VORA study assistant.\nHow can I help you?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _suggestion("Explain photosynthesis"),
              _suggestion("Help with my essay"),
              _suggestion("Quiz me on History"),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "VORA is thinking...",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blueAccent
                          : const Color(0xFF12343B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: _isLoading
                        ? null
                        : (value) => _sendMessage(value),
                    decoration: InputDecoration(
                      hintText: "Ask me anything...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF12343B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading
                      ? null
                      : () => _sendMessage(_controller.text),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
