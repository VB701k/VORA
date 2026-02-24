import 'package:flutter/material.dart';
import '../../frontend/models/achievement_model.dart';
import '../../frontend/theme/app_colors.dart';

class AchievementTile extends StatelessWidget {
  final AchievementModel item;
  final VoidCallback? onTap;

  const AchievementTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                gradient: item.gradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      size: 54,
                      color: Colors.white.withOpacity(item.locked ? 0.25 : 0.35),
                    ),
                  ),
                  if (item.locked)
                    const Positioned(
                      right: 12,
                      bottom: 12,
                      child: Icon(Icons.lock_rounded, color: Colors.white70, size: 20),
                    ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.12),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (item.earned) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
              if (item.earned) const SizedBox(width: 6),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: item.earned ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}