import 'package:flutter/material.dart';
import '../../frontend/theme/app_colors.dart';

class CoachCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CoachCard({super.key, this.onTap});

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
        children: [
          const Text('Keep going, Anaaff!', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            "Complete 3 more sessions this week to unlock the 'Consistency King' badge.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Start Study Session', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}