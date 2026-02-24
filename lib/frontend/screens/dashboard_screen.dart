import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/quote_of_the_day_card.dart';
import '../widgets/rewards_card.dart';
import '../widgets/streak_card.dart';
import 'task_list_screen.dart';
import 'study_notes_screen.dart';
import 'achievement_screen.dart';
import 'motivation_notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 14),
              const QuoteOfTheDayCard(
                category: 'Focus',
                quote:
                    'Dhamma thundu blade uh meala vecha nambikkaya oo meala wei.',
                author: 'Thalapathy',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RewardsCard(
                      points: 1450,
                      message: 'Complete tasks to earn more points.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StreakCard(
                      days: 7,
                      subtitle: 'Keep your streak alive today!',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.checklist_rounded,
                      label: 'Tasks',
                      onTap: () => _navigateTo(context, const TaskListScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.menu_book_rounded,
                      label: 'Notes',
                      onTap: () =>
                          _navigateTo(context, const StudyNotesScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.emoji_events_rounded,
                      label: 'Awards',
                      onTap: () =>
                          _navigateTo(context, const AchievementScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.notifications_active_rounded,
                      label: 'Quotes',
                      onTap: () => _navigateTo(
                        context,
                        const MotivationNotificationScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
