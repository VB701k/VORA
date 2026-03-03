import 'package:flutter/material.dart';

import 'mood_tracker.dart';

class WellnessColors {
  static const bg = Color(0xFF0B1F1C);
  static const card = Color(0xFF12322C);
  static const card2 = Color(0xFF0F2A25);
  static const mint = Color(0xFF29D3B0);
  static const text = Color(0xFFEAF6F3);
  static const textDim = Color(0xFFB5D2CC);
  static const stroke = Color(0xFF1B4C42);
}

class WellnessHubScreen extends StatelessWidget {
  const WellnessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WellnessColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TopBar(),
              SizedBox(height: 18),
              MoodTrackerCard(),
              SizedBox(height: 22),
              SectionTitle('Breathing Exercises'),
              SizedBox(height: 12),
              BreathingSection(),
              SizedBox(height: 22),
              SectionTitle('Mindful Games'),
              SizedBox(height: 12),
              MindfulGamesSection(),
              SizedBox(height: 18),
              SupportCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GOOD MORNING',
                style: TextStyle(
                  color: WellnessColors.textDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Wellness Hub',
                style: TextStyle(
                  color: WellnessColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: WellnessColors.text,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: WellnessColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class BreathingSection extends StatelessWidget {
  const BreathingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          BreathingCard(
            title: 'Box Breathing',
            subtitle: 'Reset your focus and calm your nervous system.',
            minutes: 4,
          ),
          SizedBox(width: 14),
          BreathingCard(
            title: '4-7-8 Relax',
            subtitle: 'Natural tranquility and better sleep.',
            minutes: 5,
          ),
        ],
      ),
    );
  }
}

class BreathingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int minutes;

  const BreathingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WellnessColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WellnessColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: WellnessColors.card2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.landscape_rounded,
                  color: WellnessColors.textDim,
                  size: 42,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: WellnessColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: WellnessColors.textDim)),
        ],
      ),
    );
  }
}

class MindfulGamesSection extends StatelessWidget {
  const MindfulGamesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.35,
      children: const [
        MindfulGameTile(
          title: 'Zen Pattern',
          subtitle: 'Visual matching',
          icon: Icons.grid_view_rounded,
        ),
        MindfulGameTile(
          title: 'Flow State',
          subtitle: 'Fluid physics',
          icon: Icons.water_drop_rounded,
        ),
        MindfulGameTile(
          title: 'Starlight',
          subtitle: 'Connect dots',
          icon: Icons.auto_awesome_rounded,
        ),
        MindfulGameTile(
          title: 'Bubble Pop',
          subtitle: 'Stress relief',
          icon: Icons.bubble_chart_rounded,
        ),
      ],
    );
  }
}

class MindfulGameTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const MindfulGameTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WellnessColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WellnessColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WellnessColors.mint),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: WellnessColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: WellnessColors.textDim)),
        ],
      ),
    );
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WellnessColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WellnessColors.stroke),
      ),
      child: const Text(
        'Need immediate support? Contact VORA Study 24/7.',
        style: TextStyle(
          color: WellnessColors.text,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
