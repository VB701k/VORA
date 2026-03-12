import 'package:flutter/material.dart';
import 'package:vora/frontend/pages/calendar_screen.dart';
import 'package:vora/frontend/pages/weekly_analysis_screen.dart';
import 'package:vora/frontend/pages/wellness_hub_screen.dart';
import 'package:vora/frontend/pages/pomodoro_tab.dart';
import 'package:vora/frontend/main_screens/task_manager_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SearchScreen({super.key, this.onBackToHome});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String query = '';

  final List<_SearchItem> _items = const [
    _SearchItem(
      title: 'Calendar',
      keywords: ['calendar', 'schedule', 'dates', 'events'],
      icon: Icons.calendar_month_rounded,
      page: CalendarScreen(),
    ),
    _SearchItem(
      title: 'Weekly Analytics',
      keywords: ['weekly', 'analytics', 'analysis', 'report', 'stats'],
      icon: Icons.bar_chart_rounded,
      page: WeeklyAnalysisScreen(),
    ),
    _SearchItem(
      title: 'Pomodoro',
      keywords: ['pomodoro', 'timer', 'focus', 'study timer'],
      icon: Icons.timer_rounded,
      page: PomodoroTab(),
    ),
    _SearchItem(
      title: 'Mental Wellness',
      keywords: ['mental', 'wellness', 'mood', 'health', 'relax'],
      icon: Icons.spa_rounded,
      page: WellnessHubScreen(),
    ),
    _SearchItem(
      title: 'Task Manager',
      keywords: ['task', 'tasks', 'checklist', 'to do', 'manager'],
      icon: Icons.checklist_rounded,
      page: TaskManagerScreen(),
    ),
  ];

  List<_SearchItem> get _filteredItems {
    if (query.trim().isEmpty) {
      return _items;
    }

    final q = query.toLowerCase().trim();

    return _items.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.keywords.any((k) => k.toLowerCase().contains(q));
    }).toList();
  }

  void _goBackToHome() {
    FocusScope.of(context).unfocus();

    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
      return;
    }

    Navigator.of(context).maybePop();
  }

  void _openMatchedFeature(String value) {
    final q = value.toLowerCase().trim();
    if (q.isEmpty) return;

    _SearchItem? exactOrBestMatch;

    for (final item in _items) {
      final titleMatch = item.title.toLowerCase() == q;
      final keywordMatch = item.keywords.any((k) => k.toLowerCase() == q);

      if (titleMatch || keywordMatch) {
        exactOrBestMatch = item;
        break;
      }
    }

    exactOrBestMatch ??= _items.cast<_SearchItem?>().firstWhere(
      (item) =>
          item!.title.toLowerCase().contains(q) ||
          item.keywords.any((k) => k.toLowerCase().contains(q)),
      orElse: () => null,
    );

    if (exactOrBestMatch != null) {
      _openPage(exactOrBestMatch);
    }
  }

  void _openPage(_SearchItem item) {
    FocusScope.of(context).unfocus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => item.page));
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF172B35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF243E4B)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goBackToHome,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xFF2EC4F1),
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Search features...',
                          hintStyle: TextStyle(color: Color(0xFF9FB4C4)),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                        onSubmitted: _openMatchedFeature,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF2EC4F1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Suggestions',
                style: TextStyle(
                  color: Color(0xFF9FB4C4),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: suggestions.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching features found',
                          style: TextStyle(
                            color: Color(0xFF9FB4C4),
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = suggestions[index];
                          return InkWell(
                            onTap: () => _openPage(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF172B35),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF243E4B),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1C3441),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: const Color(0xFF2EC4F1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF9FB4C4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchItem {
  final String title;
  final List<String> keywords;
  final IconData icon;
  final Widget page;

  const _SearchItem({
    required this.title,
    required this.keywords,
    required this.icon,
    required this.page,
  });
}
