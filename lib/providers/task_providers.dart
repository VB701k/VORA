import 'package:flutter/material.dart';
import '../backend/repositories/tasks_repo.dart';
import '../frontend/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  final TasksRepository _tasksRepo = TasksRepository();

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.completed).toList();
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.completed).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _tasksRepo.getTasks(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String userId, TaskModel task) async {
    try {
      await _tasksRepo.createTask(userId, task);
      _tasks.insert(0, task);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTask(String userId, String taskId, bool completed) async {
    try {
      await _tasksRepo.toggleTaskCompletion(userId, taskId, completed);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final updatedTask = TaskModel(
          id: _tasks[index].id,
          title: _tasks[index].title,
          course: _tasks[index].course,
          dueLabel: _tasks[index].dueLabel,
          completed: completed,
          linkedNoteTitles: _tasks[index].linkedNoteTitles,
          attachments: _tasks[index].attachments,
        );
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksRepo.deleteTask(userId, taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
