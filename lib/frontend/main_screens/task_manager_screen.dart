import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sdgp/backend/models/app_task.dart';
import 'package:sdgp/backend/services/task_firestore_service.dart';
import 'package:sdgp/frontend/main_screens/coursework_breakdown_screen.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D5BFF),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourseworkBreakdownScreen(),
            ),
          );
          // StreamBuilder will update automatically when Firestore changes
        },
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: StreamBuilder<List<AppTask>>(
          stream: TaskFirestoreService.instance.streamTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            final allTasks = snapshot.data ?? [];

            // ✅ Split upcoming vs completed
            final upcoming = allTasks
                .where((t) => !t.isCompleted)
                .toList(growable: false);
            final completed = allTasks
                .where((t) => t.isCompleted)
                .toList(growable: false);

            // ✅ Sort upcoming by due date (closest first)
            final sortedUpcoming = [...upcoming]
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

            // ✅ Group upcoming into priority bands
            final high = _priorityGroup(sortedUpcoming, PriorityBand.high);
            final med = _priorityGroup(sortedUpcoming, PriorityBand.medium);
            final low = _priorityGroup(sortedUpcoming, PriorityBand.low);

            // ✅ Sort completed by due date (latest first optional)
            final sortedCompleted = [...completed]
              ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

            if (high.isEmpty &&
                med.isEmpty &&
                low.isEmpty &&
                sortedCompleted.isEmpty) {
              return _emptyState();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                const _BigTitle("Upcoming"),
                const SizedBox(height: 12),

                if (high.isNotEmpty) ...[
                  const _SectionTitle("High Priority (≤ 15 days)"),
                  const SizedBox(height: 10),
                  ...high.map(
                    (t) => _TaskCard(
                      task: t,
                      accent: const Color(0xFFFF4D4D), // RED
                      onToggle: () => TaskFirestoreService.instance.toggleDone(
                        t.id,
                        t.isCompleted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (med.isNotEmpty) ...[
                  const _SectionTitle("Medium Priority (16–30 days)"),
                  const SizedBox(height: 10),
                  ...med.map(
                    (t) => _TaskCard(
                      task: t,
                      accent: const Color(0xFFFFC14D), // YELLOW
                      onToggle: () => TaskFirestoreService.instance.toggleDone(
                        t.id,
                        t.isCompleted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (low.isNotEmpty) ...[
                  const _SectionTitle("Low Priority (> 30 days)"),
                  const SizedBox(height: 10),
                  ...low.map(
                    (t) => _TaskCard(
                      task: t,
                      accent: const Color(0xFF39D98A), // GREEN
                      onToggle: () => TaskFirestoreService.instance.toggleDone(
                        t.id,
                        t.isCompleted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 6),
                const Divider(color: Color(0xFF1B2A45)),
                const SizedBox(height: 14),

                const _BigTitle("Completed"),
                const SizedBox(height: 12),

                if (sortedCompleted.isEmpty)
                  const Text(
                    "No completed tasks yet.",
                    style: TextStyle(color: Color(0xFFAAB6D3)),
                  )
                else
                  ...sortedCompleted.map(
                    (t) => _TaskCard(
                      task: t,
                      accent: const Color(0xFF6C7A9A),
                      onToggle: () => TaskFirestoreService.instance.toggleDone(
                        t.id,
                        t.isCompleted,
                      ),
                      completedStyle: true,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ Priority logic based on due date difference
  List<AppTask> _priorityGroup(List<AppTask> tasks, PriorityBand band) {
    final now = DateTime.now();

    return tasks.where((t) {
      if (t.isCompleted) return false;

      final days = t.dueDate.difference(now).inDays;

      switch (band) {
        case PriorityBand.high:
          return days <= 15;
        case PriorityBand.medium:
          return days > 15 && days <= 30;
        case PriorityBand.low:
          return days > 30;
      }
    }).toList();
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1522),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1B2A45)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 44,
              color: Color(0xFF2D5BFF),
            ),
            SizedBox(height: 10),
            Text(
              "No tasks here",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Add a Coursework Breakdown using the + button.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFAAB6D3)),
            ),
          ],
        ),
      ),
    );
  }
}

enum PriorityBand { high, medium, low }

class _BigTitle extends StatelessWidget {
  final String text;
  const _BigTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFAAB6D3),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final AppTask task;
  final Color accent;
  final VoidCallback onToggle;
  final bool completedStyle;

  const _TaskCard({
    required this.task,
    required this.accent,
    required this.onToggle,
    this.completedStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("MMM d • h:mm a");
    final dueText = "Due ${df.format(task.dueDate)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1522),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2A45)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 74,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completedStyle
                          ? const Color(0xFF6C7A9A)
                          : Colors.white24,
                    ),
                    color: task.isCompleted
                        ? const Color(0xFF2D5BFF)
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              title: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  decoration: completedStyle
                      ? TextDecoration.lineThrough
                      : null,
                  color: completedStyle
                      ? const Color(0xFF6C7A9A)
                      : Colors.white,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: completedStyle
                              ? const Color(0xFF6C7A9A)
                              : const Color(0xFFAAB6D3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      dueText,
                      style: TextStyle(
                        fontSize: 11,
                        color: completedStyle
                            ? const Color(0xFF6C7A9A)
                            : const Color(0xFFAAB6D3),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFFAAB6D3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
