import 'dart:math';
import '../core/date_key.dart';
import '../repositories/quotes_repo.dart';
import '../seed/quote_bank.dart';

class QuoteService {
  final QuotesRepo _quotesRepo;

  QuoteService(this._quotesRepo);

  /// Ensures a quote exists for today. If not, picks one and stores it.
  Future<void> ensureTodayQuote({
    List<String> allowedCategories = const [],
  }) async {
    final key = DateKey.todayKey();

    try {
      final snap = await _quotesRepo.getDailyQuote(key);
      if (snap.exists) return;
    } catch (e) {
      print('Error checking daily quote: $e');
    }

    final list = allowedCategories.isEmpty
        ? QuoteBank.quotes
        : QuoteBank.quotes
              .where((q) => allowedCategories.contains(q['category']))
              .toList();

    final safeList = list.isEmpty ? QuoteBank.quotes : list;

    // stable random pick by date
    final rnd = Random(key.hashCode);
    final item = safeList[rnd.nextInt(safeList.length)];

    await _quotesRepo.setDailyQuote(
      dateKey: key,
      text: item['text']!,
      author: item['author']!,
      category: item['category']!,
    );
  }

  /// Get today's quote
  Future<Map<String, dynamic>?> getTodayQuote() async {
    try {
      final key = DateKey.todayKey();
      final snap = await _quotesRepo.getDailyQuote(key);

      if (!snap.exists) return null;

      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) return null;

      return {
        'id': snap.id,
        'text': data['text'] ?? '',
        'author': data['author'] ?? 'Unknown',
        'category': data['category'] ?? 'Motivation',
      };
    } catch (e) {
      print('Error getting today\'s quote: $e');
      return null;
    }
  }
}
