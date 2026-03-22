import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuotesService {
  QuotesService._();
  static final QuotesService instance = QuotesService._();

  final _db = FirebaseFirestore.instance;

  Future<void> seedQuotesIfEmpty() async {
    final snap = await _db.collection('quotes').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final starter = [
      {
        'text': 'Start where you are. Use what you have. Do what you can.',
        'author': 'Arthur Ashe',
        'category': 'Motivation',
      },
      {
        'text': 'Small progress is still progress.',
        'author': 'Unknown',
        'category': 'Focus',
      },
      {
        'text': 'Discipline beats motivation when motivation fades.',
        'author': 'Unknown',
        'category': 'Discipline',
      },
    ];

    final batch = _db.batch();
    for (final q in starter) {
      batch.set(_db.collection('quotes').doc(), {
        ...q,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<Map<String, dynamic>?> getRandomQuote({
    List<String> categories = const [],
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('quotes');
    if (categories.isNotEmpty) {
      q = q.where('category', whereIn: categories.take(10).toList());
    }

    final snap = await q.limit(30).get();
    if (snap.docs.isEmpty) return null;

    final idx = Random().nextInt(snap.docs.length);
    final data = snap.docs[idx].data();
    return {
      'text': (data['text'] ?? '').toString(),
      'author': (data['author'] ?? 'Unknown').toString(),
      'category': (data['category'] ?? 'Motivation').toString(),
    };
  }
}
