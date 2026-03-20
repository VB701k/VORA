import 'dart:convert';
import 'package:http/http.dart' as http;

class AIChatService {
  static const String apiKey = 'AIzaSyDqYusAy9sXjLn_2oFCAQrhtoTluHbmjjg';

  static Future<String> sendMessage(String userMessage) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );
    try {
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
                      'If the question is not related to education, studies, coursework, exams, learning, '
                      'or academic help, politely refuse.',
                },
              ],
            },
            {
              'parts': [
                {'text': userMessage},
              ],
            },
          ],
        }),
      );

      print('Gemini status: ${response.statusCode}');
      print('Gemini body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final candidates = data['candidates'];
        if (candidates != null &&
            candidates is List &&
            candidates.isNotEmpty &&
            candidates[0]['content'] != null &&
            candidates[0]['content']['parts'] != null &&
            candidates[0]['content']['parts'] is List &&
            candidates[0]['content']['parts'].isNotEmpty &&
            candidates[0]['content']['parts'][0]['text'] != null) {
          return candidates[0]['content']['parts'][0]['text'];
        }

        return 'Sorry, I could not understand the AI response.';
      } else {
        return 'Sorry, I could not get a response right now.';
      }
    } catch (e) {
      print('Gemini error: $e');
      return 'Sorry, something went wrong while contacting the AI service.';
    }
  }
}
