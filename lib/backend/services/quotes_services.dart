import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuotesService {
  QuotesService._();
  static final QuotesService instance = QuotesService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds a few starter quotes only if the collection is empty
  Future<void> seedQuotesIfEmpty() async {
    final snap = await _db.collection('quotes').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final starter = <Map<String, dynamic>>[
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

  /// ✅ AUTO UPLOAD MANY QUOTES
  /// - If force=false: uploads only when quotes collection is empty
  /// - If force=true: always uploads (be careful, it will create duplicates)
  Future<void> seedBulkQuotes({bool force = false}) async {
    final col = _db.collection('quotes');

    if (!force) {
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) return;
    }

    final quotes = <Map<String, dynamic>>[
      // Motivation
      {
        'text': 'One day or day one. You decide.',
        'author': 'Unknown',
        'category': 'Motivation',
      },
      {
        'text': 'The future depends on what you do today.',
        'author': 'Mahatma Gandhi',
        'category': 'Motivation',
      },
      {
        'text': 'The secret of getting ahead is getting started.',
        'author': 'Mark Twain',
        'category': 'Motivation',
      },
      {
        'text': 'You are capable of more than you know.',
        'author': 'Unknown',
        'category': 'Motivation',
      },
      {
        'text': 'Dream big. Start small. Act now.',
        'author': 'Unknown',
        'category': 'Motivation',
      },
      {
        'text': 'Don’t stop until you’re proud.',
        'author': 'Unknown',
        'category': 'Motivation',
      },

      // Focus
      {
        'text': 'Focus on being productive, not busy.',
        'author': 'Tim Ferriss',
        'category': 'Focus',
      },
      {
        'text': 'Do one thing at a time.',
        'author': 'Unknown',
        'category': 'Focus',
      },
      {
        'text': 'If it matters, schedule it.',
        'author': 'Unknown',
        'category': 'Focus',
      },
      {
        'text': 'Your attention is your life. Spend it wisely.',
        'author': 'Unknown',
        'category': 'Focus',
      },
      {
        'text': 'Clarity comes from action, not thought.',
        'author': 'Marie Forleo',
        'category': 'Focus',
      },

      // Discipline
      {
        'text': 'Motivation gets you started. Discipline keeps you going.',
        'author': 'Unknown',
        'category': 'Discipline',
      },
      {
        'text': 'Consistency beats intensity.',
        'author': 'Unknown',
        'category': 'Discipline',
      },
      {
        'text': 'Do it even when you don’t feel like it.',
        'author': 'Unknown',
        'category': 'Discipline',
      },
      {
        'text': 'The cost of discipline is less than the pain of regret.',
        'author': 'Unknown',
        'category': 'Discipline',
      },
      {
        'text': 'Keep promises you make to yourself.',
        'author': 'Unknown',
        'category': 'Discipline',
      },

      // Study
      {
        'text': 'A little study every day adds up.',
        'author': 'Unknown',
        'category': 'Study',
      },
      {
        'text': 'Understanding beats memorizing.',
        'author': 'Unknown',
        'category': 'Study',
      },
      {
        'text': 'Don’t just read—practice.',
        'author': 'Unknown',
        'category': 'Study',
      },
      {
        'text': 'Today’s effort is tomorrow’s confidence.',
        'author': 'Unknown',
        'category': 'Study',
      },
      {
        'text': 'Study smart, not just hard.',
        'author': 'Unknown',
        'category': 'Study',
      },

      // Success
      {
        'text': 'Success is the sum of small efforts repeated daily.',
        'author': 'Robert Collier',
        'category': 'Success',
      },
      {
        'text': 'Hard work beats talent when talent doesn’t work hard.',
        'author': 'Unknown',
        'category': 'Success',
      },
      {
        'text': 'Action is the foundation of success.',
        'author': 'Pablo Picasso',
        'category': 'Success',
      },
      {
        'text': 'Keep going. You’re closer than you think.',
        'author': 'Unknown',
        'category': 'Success',
      },

      // Calm
      {
        'text': 'Breathe. You’re doing better than you think.',
        'author': 'Unknown',
        'category': 'Calm',
      },
      {
        'text': 'Rest is part of the process.',
        'author': 'Unknown',
        'category': 'Calm',
      },
      {
        'text': 'You can restart your day anytime.',
        'author': 'Unknown',
        'category': 'Calm',
      },
    ];

    // Firestore batch limit is 500, we stay under it safely
    WriteBatch batch = _db.batch();
    int count = 0;

    for (final q in quotes) {
      final doc = col.doc();
      batch.set(doc, {...q, 'createdAt': FieldValue.serverTimestamp()});
      count++;

      // Commit every 450 writes (safe buffer)
      if (count % 450 == 0) {
        await batch.commit();
        batch = _db.batch();
      }
    }

    await batch.commit();
  }

  /// Gets 1 random quote
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
