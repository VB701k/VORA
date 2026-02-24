import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';

class QuotesRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get daily quote by date key
  Future<DocumentSnapshot> getDailyQuote(String dateKey) async {
    try {
      return await FirestorePaths.dailyQuotesCollection().doc(dateKey).get();
    } catch (e) {
      print('Error getting daily quote: $e');
      rethrow;
    }
  }

  /// Set daily quote
  Future<void> setDailyQuote({
    required String dateKey,
    required String text,
    required String author,
    required String category,
  }) async {
    try {
      await FirestorePaths.dailyQuotesCollection().doc(dateKey).set({
        'text': text,
        'author': author,
        'category': category,
        'date': dateKey,
      });
    } catch (e) {
      print('Error setting daily quote: $e');
      rethrow;
    }
  }

  /// Get all quotes
  Future<List<Map<String, dynamic>>> getAllQuotes() async {
    try {
      final snapshot = await FirestorePaths.quotesCollection().get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'text': data['text'] ?? '',
          'author': data['author'] ?? 'Unknown',
          'category': data['category'] ?? 'Motivation',
        };
      }).toList();
    } catch (e) {
      print('Error getting quotes: $e');
      return [];
    }
  }
}
