import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/achievement_model.dart';

class AchievementDetailScreen extends StatelessWidget {
  final AchievementModel achievement;
  const AchievementDetailScreen({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Achievement Details',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient:
                      achievement.gradient ??
                      const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  achievement.icon,
                  size: 60,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                achievement.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: achievement.earned
                      ? Colors.green.withOpacity(0.15)
                      : achievement.locked
                      ? Colors.grey.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: achievement.earned
                        ? Colors.green
                        : achievement.locked
                        ? Colors.grey
                        : AppColors.primary,
                  ),
                ),
                child: Text(
                  achievement.earned
                      ? 'EARNED'
                      : achievement.locked
                      ? 'LOCKED'
                      : 'IN PROGRESS',
                  style: TextStyle(
                    color: achievement.earned
                        ? Colors.green
                        : achievement.locked
                        ? Colors.grey
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!achievement.earned && !achievement.locked)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(achievement.progress * 100).toInt()}% Complete',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
