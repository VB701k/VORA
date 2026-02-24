import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/quote_category_model.dart';

class QuoteCategoryChip extends StatelessWidget {
  final QuoteCategoryModel category;
  final VoidCallback onTap;

  const QuoteCategoryChip({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: category.selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: category.selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          category.title,
          style: TextStyle(
            color: category.selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
