import 'package:flutter/material.dart';
import 'package:vora/frontend/pages/calendar_screen.dart';
import 'package:vora/frontend/pages/weekly_analysis_screen.dart';
import 'package:vora/frontend/pages/wellness_hub_screen.dart';
import 'package:vora/frontend/pages/pomodoro_tab.dart';
import 'package:vora/frontend/main_screens/task_manager_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  String query = "";

  final Map<String, Widget> features = {
    "calendar": const CalendarScreen(),
    "weekly analytics": const WeeklyAnalysisScreen(),
    "pomodoro": const PomodoroTab(),
    "mental wellness": const WellnessHubScreen(),
    "task manager": const TaskManagerScreen(),
  };

  List<String> getSuggestions(String input) {
    if (input.isEmpty) return [];
    return features.keys
        .where((feature) => feature.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }

  void openFeature(String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => features[feature]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = getSuggestions(query);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF172B35),
        title: const Text("Search Features"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search features...",
                hintStyle: const TextStyle(color: Colors.white54),

                // BACK BUTTON
                prefixIcon: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                suffixIcon: const Icon(Icons.search, color: Colors.white),

                filled: true,
                fillColor: const Color(0xFF172B35),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },

              onSubmitted: (value) {
                final match = features.keys.firstWhere(
                  (f) => f.contains(value.toLowerCase()),
                  orElse: () => "",
                );

                if (match.isNotEmpty) {
                  openFeature(match);
                }
              },
            ),

            const SizedBox(height: 20),

            // Suggestions
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];

                  return ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    title: Text(
                      suggestion,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      openFeature(suggestion);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
