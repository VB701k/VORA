import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/task_model.dart';
import '../models/attachment_model.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<TaskModel> tasks = [
    TaskModel(
      id: '1',
      title: 'Biology Report Draft',
      course: 'BIO101',
      dueLabel: 'Today 6:00 PM',
      completed: false,
      linkedNoteTitles: const ['Organic Chemistry'],
      attachments: const [
        AttachmentModel(
          id: 'att1',
          name: 'Rubric.pdf',
          type: 'PDF',
          sizeLabel: '410 KB',
        ),
      ],
    ),
    TaskModel(
      id: '2',
      title: 'Calculus Quiz Practice',
      course: 'MATH203',
      dueLabel: 'Tomorrow',
      completed: true,
      linkedNoteTitles: const ['Calculus Notes'],
      attachments: const [],
    ),
    TaskModel(
      id: '3',
      title: 'Physics Lab Report',
      course: 'PHY101',
      dueLabel: 'Friday 5:00 PM',
      completed: false,
      linkedNoteTitles: const [],
      attachments: const [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> get _allTasks => tasks;
  List<TaskModel> get _pendingTasks =>
      tasks.where((t) => !t.completed).toList();
  List<TaskModel> get _completedTasks =>
      tasks.where((t) => t.completed).toList();

  void _showQuickAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickAddTaskModal(
        onAdd: (newTask) {
          setState(() => tasks.insert(0, newTask));
        },
      ),
    );
  }

  void _deleteTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Delete Task',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete "${task.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => tasks.removeWhere((t) => t.id == task.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
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
                        'My Tasks',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(_allTasks, 'No tasks yet'),
                    _buildTaskList(_pendingTasks, 'No pending tasks'),
                    _buildTaskList(_completedTasks, 'No completed tasks'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> taskList, String emptyMessage) {
    if (taskList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: taskList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => TaskCard(
        task: taskList[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: taskList[i]),
          ),
        ),
        onDelete: () => _deleteTask(taskList[i]),
      ),
    );
  }
}

class _QuickAddTaskModal extends StatefulWidget {
  final Function(TaskModel) onAdd;
  const _QuickAddTaskModal({required this.onAdd});

  @override
  State<_QuickAddTaskModal> createState() => __QuickAddTaskModalState();
}

class __QuickAddTaskModalState extends State<_QuickAddTaskModal> {
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Add Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Task Title',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _courseController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Course',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  widget.onAdd(
                    TaskModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      course: _courseController.text.isEmpty
                          ? 'General'
                          : _courseController.text,
                      dueLabel: 'Today',
                      completed: false,
                      linkedNoteTitles: const [],
                      attachments: const [],
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Add Task', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
