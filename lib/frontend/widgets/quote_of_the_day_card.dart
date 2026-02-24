import 'package:flutter/material.dart';
import '../../frontend/theme/app_colors.dart';

class QuoteOfTheDayCard extends StatelessWidget {
  final String category;
  final String quote;
  final String author;

  const QuoteOfTheDayCard({
    super.key,
    required this.category,
    required this.quote,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Quote of the Day', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(category, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('“$quote”', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, height: 1.35)),
          const SizedBox(height: 10),
          Text('— $author', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}