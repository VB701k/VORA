import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBootstrap {
  static Future<void> init() async {
    print('FirebaseBootstrap.init() started');

    try {
      // Check if quotes collection exists
      final quotesSnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .limit(1)
          .get();

      if (quotesSnapshot.docs.isEmpty) {
        print('Adding sample quotes...');

        final sampleQuotes = [
          {
            'text': 'The only way to do great work is to love what you do.',
            'author': 'Steve Jobs',
            'category': 'Motivation',
          },
          {
            'text': 'Success is not final, failure is not fatal.',
            'author': 'Winston Churchill',
            'category': 'Success',
          },
          {
            'text': 'Believe you can and you\'re halfway there.',
            'author': 'Theodore Roosevelt',
            'category': 'Motivation',
          },
        ];

        for (var quote in sampleQuotes) {
          await FirebaseFirestore.instance.collection('quotes').add(quote);
          print('Added quote: ${quote['text']}');
        }
      }

      print('FirebaseBootstrap.init() completed successfully');
    } catch (e) {
      print('FirebaseBootstrap.init() error: $e');
    }
  }
}
