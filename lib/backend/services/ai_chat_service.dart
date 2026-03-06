import 'dart:convert';
import 'package:http/http.dart' as http;

class AIChatService {
  static const String apiKey = 'YOUR_API_KEY_HERE';

  static Future<String> sendMessage(String userMessage) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are a study assistant. Only answer educational questions. '
                    'If the question is not related to education, studies, coursework, exams, learning, or academic help, '
                    'politely refuse.\n\nUser question: $userMessage',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      return 'Sorry, I could not get a response right now.';
    }
  }
}
