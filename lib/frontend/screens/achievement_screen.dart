import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/achievement_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/filter_pills.dart';
import '../widgets/achievement_tile.dart';
import '../widgets/coach_card.dart';
import 'motivation_notification_screen.dart';
import 'achievement_detail_screen.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <AchievementModel>[
      AchievementModel(
        id: '1',
        title: '7-Day Streak',
        subtitle: 'EARNED',
        earned: true,
        progress: 1.0,
        icon: Icons.local_fire_department_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFCF5B00), Color(0xFF7A2C00)],
        ),
      ),
      AchievementModel(
        id: '2',
        title: '100 Study Hours',
        subtitle: '85/100 Hours',
        progress: 0.85,
        icon: Icons.access_time_rounded,
      ),
      AchievementModel(
        id: '3',
        title: 'Task Master',
        subtitle: '60% Complete',
        progress: 0.60,
        icon: Icons.check_circle_rounded,
      ),
      AchievementModel(
        id: '4',
        title: 'Top 1% Club',
        subtitle: 'Locked',
        locked: true,
        progress: 0.0,
        icon: Icons.workspace_premium_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF2F62FF), Color(0xFF8A4DFF)],
        ),
      ),
      AchievementModel(
        id: '5',
        title: 'Library regular',
        subtitle: 'EARNED',
        earned: true,
        progress: 1.0,
        icon: Icons.menu_book_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF4BAE7A), Color(0xFF2D7C56)],
        ),
      ),
      AchievementModel(
        id: '6',
        title: 'Study Buddy',
        subtitle: '1/5 Sessions',
        progress: 0.2,
        icon: Icons.group_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                        'Achievement',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MotivationNotificationScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Badges',
                      value: '12',
                      icon: Icons.stars_rounded,
                      iconColor: const Color(0xFFFF8A2A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'VORA Points',
                      value: '1450',
                      icon: Icons.workspace_premium_rounded,
                      iconColor: const Color(0xFFF2C94C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const FilterPills(),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.86,
                            ),
                        itemBuilder: (context, index) => AchievementTile(
                          item: items[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AchievementDetailScreen(
                                achievement: items[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      CoachCard(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MotivationNotificationScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
