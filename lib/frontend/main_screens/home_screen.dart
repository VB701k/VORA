import 'package:flutter/material.dart';
import 'package:vora/backend/services/home_profile_service.dart';
import 'package:vora/frontend/pages/task_manager_screen.dart';
import 'package:vora/frontend/pages/wellness_hub_screen.dart';
import 'package:vora/frontend/pages/pomodoro_tab.dart';
import "package:vora/frontend/main_screens/notes.dart";
import "package:vora/frontend/pages/calendar_screen.dart";
import "package:vora/frontend/pages/weekly_analysis_screen.dart";

// ✅ IMPORTANT: make sure your Quotes service file name & class match.
// If your file is quotes_services.dart, keep it like this:
import "package:vora/backend/services/quotes_services.dart";
import "package:vora/backend/services/streak_services.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color bg = Color(0xFF0E1A22);
  static const Color card = Color(0xFF172B35);
  static const Color cardLight = Color(0xFF1D3642);
  static const Color accent = Color(0xFF2EC4F1);
  static const Color accentSoft = Color(0x332EC4F1);
  static const Color text = Color(0xFFEAF6FB);
  static const Color textDim = Color(0xFF9FB4C4);
  static const Color stroke = Color(0xFF264554);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              _buildTopBar(),
              const SizedBox(height: 26),

              _buildHeroCard(), // ✅ now shows Firebase quote
              const SizedBox(height: 28),

              _buildSectionTitle("QUICK ACCESS"),
              const SizedBox(height: 16),
              _buildQuickAccessGrid(context),
              const SizedBox(height: 28),

              _buildSectionTitle("SHORTCUTS"),
              const SizedBox(height: 16),
              _buildShortcutsGrid(context),
              const SizedBox(height: 28),

              _buildSectionTitle("RECENT"),
              const SizedBox(height: 16),
              _buildRecentSection(),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return FutureBuilder<String>(
      future: HomeProfileService.instance.fetchMyName(),
      builder: (context, snap) {
        final name = (snap.data != null && snap.data!.trim().isNotEmpty)
            ? snap.data!
            : "VORA Student";

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _TopIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  children: [
                    const Text(
                      "Welcome back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            _TopIconButton(icon: Icons.settings_outlined, onTap: () {}),
          ],
        );
      },
    );
  }

  /// ✅ Motivation card (shows quote from Firebase)
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3540), Color(0xFF12262F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // ✅ Quote text from Firebase (no hardcoded quote)
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              // ✅ This must exist in your quotes service
              future: QuotesService.instance.getRandomQuote(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loading motivation…",
                        style: TextStyle(
                          color: text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Open your tools quickly and keep your study flow going.",
                        style: TextStyle(
                          color: textDim,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                }

                final q = snap.data;
                final quoteText = (q?['text'] ?? 'Stay consistent today ✨')
                    .toString();
                final author = (q?['author'] ?? 'Unknown').toString();
                final category = (q?['category'] ?? 'Motivation').toString();
                if (q == null) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stay consistent today ✨",
                        style: TextStyle(
                          color: text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Add some quotes in Firestore → quotes collection.",
                        style: TextStyle(
                          color: textDim,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${q['text'] ?? ''}"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "— ${q['author'] ?? 'Unknown'} • ${q['category'] ?? 'Motivation'}",
                      style: const TextStyle(
                        color: textDim,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: [
        _QuickTile(
          title: "Notes",
          subtitle: "Keep study notes",
          icon: Icons.note_alt_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyNotesScreen()),
            );
          },
        ),
        _QuickTile(
          title: "Pomodoro",
          subtitle: "Start timer sessions",
          icon: Icons.timer_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PomodoroTab()),
            );
          },
        ),
        _QuickTile(
          title: "Mental Wellness",
          subtitle: "Relax your mind",
          icon: Icons.spa_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WellnessHubScreen()),
            );
          },
        ),
        _QuickTile(
          title: "Weekly Analytics",
          subtitle: "Track your progress",
          icon: Icons.bar_chart_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeeklyAnalysisScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShortcutsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 2.6,
      children: [
        _ShortcutTile(
          title: "Calendar",
          icon: Icons.calendar_month_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
          },
        ),
        _ShortcutTile(
          title: "Task Manager",
          icon: Icons.checklist_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskManagerScreen()),
            );
          },
        ),
        _ShortcutTile(
          title: "Motivation",
          icon: Icons.auto_awesome_rounded,
          onTap: () {},
        ),
        _ShortcutTile(
          title: "Add",
          icon: Icons.add_rounded,
          isAddButton: true,
          onTap: () {},
        ),
      ],
    );
  }

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

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeScreen.cardLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomeScreen.stroke),
          ),
          child: Icon(icon, color: HomeScreen.text, size: 22),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _QuickTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  static const Color card = HomeScreen.card;
  static const Color cardLight = HomeScreen.cardLight;
  static const Color accent = HomeScreen.accent;
  static const Color accentSoft = HomeScreen.accentSoft;
  static const Color text = HomeScreen.text;
  static const Color textDim = HomeScreen.textDim;
  static const Color stroke = HomeScreen.stroke;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [cardLight, card],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: stroke),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textDim,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAddButton;

  const _ShortcutTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isAddButton = false,
  });

  static const Color card = HomeScreen.card;
  static const Color cardLight = HomeScreen.cardLight;
  static const Color accent = HomeScreen.accent;
  static const Color text = HomeScreen.text;
  static const Color textDim = HomeScreen.textDim;
  static const Color stroke = HomeScreen.stroke;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [cardLight, card],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: stroke),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAddButton
                      ? const Color(0xFF243E4B)
                      : const Color(0x332EC4F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isAddButton ? textDim : accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isAddButton ? textDim : text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isAddButton ? textDim : accent,
              ),
            ],
          ),
        ),
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
  static const Color cardLight = HomeScreen.cardLight;
  static const Color accent = HomeScreen.accent;
  static const Color text = HomeScreen.text;
  static const Color textDim = HomeScreen.textDim;
  static const Color stroke = HomeScreen.stroke;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [cardLight, card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x332EC4F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
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
                    fontSize: 14,
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
          const Icon(Icons.chevron_right_rounded, color: accent),
        ],
      ),
    );
  }
}
