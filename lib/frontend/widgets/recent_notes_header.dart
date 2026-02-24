import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RecentNotesHeader extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentNotesHeader({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Recent Notes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'View all',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
