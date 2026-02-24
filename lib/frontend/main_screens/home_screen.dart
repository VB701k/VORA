import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Home screen colors
  static const Color card = Color(0xFF172B35);
  static const Color accent = Color(0xFF2EC4F1);
  static const Color text = Color(0xFFEAF6FB);
  static const Color textDim = Color(0xFF9FB4C4);
  static const Color stroke = Color(0xFF243E4B);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          const SizedBox(height: 20),

          _buildSectionTitle("QUICK ACCESS"),
          const SizedBox(height: 16),

          _buildQuickAccessGrid(),
          const SizedBox(height: 40),

          _buildSectionTitle("RECENT"),
          const SizedBox(height: 16),

          _buildRecentSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Top Bar
  Widget _buildTopBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.notifications_none_rounded, color: text),
        Text(
          "VORA Student",
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Icon(Icons.settings_outlined, color: text),
      ],
    );
  }

  //  Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textDim,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  //  Quick Access Grid
  Widget _buildQuickAccessGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: const [
        _QuickTile(title: "Notes", icon: Icons.note_alt_rounded),
        _QuickTile(title: "Pomodoro", icon: Icons.timer_rounded),
        _QuickTile(title: "Mental Wellness", icon: Icons.spa_rounded),
        _QuickTile(title: "Weekly Analytics", icon: Icons.bar_chart_rounded),
      ],
    );
  }

  // Recent Section
  Widget _buildRecentSection() {
    return const Column(
      children: [
        _RecentCard(
          title: "Molecular Biology Notes",
          subtitle: "Edited 12m ago",
          icon: Icons.description_rounded,
        ),
        SizedBox(height: 12),
        _RecentCard(
          title: "Summarize: Calculus Ch. 4",
          subtitle: "Active Chat • VORA AI",
          icon: Icons.chat_bubble_rounded,
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _QuickTile({required this.title, required this.icon});

  static const Color card = HomeScreen.card;
  static const Color accent = HomeScreen.accent;
  static const Color text = HomeScreen.text;
  static const Color stroke = HomeScreen.stroke;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 32),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _RecentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static const Color card = HomeScreen.card;
  static const Color accent = HomeScreen.accent;
  static const Color text = HomeScreen.text;
  static const Color textDim = HomeScreen.textDim;
  static const Color stroke = HomeScreen.stroke;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: textDim),
        ],
      ),
    );
  }
}
