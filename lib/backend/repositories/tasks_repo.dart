import 'package:cloud_firestore/cloud_firestore.dart';
import '../../frontend/models/task_model.dart';
import '../../frontend/models/attachment_model.dart';
import '../core/firestore_paths.dart';

class TasksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== GET METHODS ====================

  /// Get all tasks for a user
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await FirestorePaths.tasksCollection(userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TaskModel(
          id: doc.id,
          title: data['title'] ?? '',
          course: data['course'] ?? '',
          dueLabel: data['dueLabel'] ?? '',
          completed: data['completed'] ?? false,
          linkedNoteTitles: List<String>.from(data['linkedNoteTitles'] ?? []),
          attachments: (data['attachments'] as List? ?? []).map((a) {
            final attachmentMap = a as Map<String, dynamic>;
            return AttachmentModel(
              id: attachmentMap['id'] ?? '',
              name: attachmentMap['name'] ?? '',
              type: attachmentMap['type'] ?? '',
              sizeLabel: attachmentMap['sizeLabel'] ?? '',
              fileUrl: attachmentMap['fileUrl'],
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  /// Get pending tasks
  Future<List<TaskModel>> getPendingTasks(String userId) async {
    try {
      final snapshot = await FirestorePaths.tasksCollection(
        userId,
      ).where('completed', isEqualTo: false).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TaskModel(
          id: doc.id,
          title: data['title'] ?? '',
          course: data['course'] ?? '',
          dueLabel: data['dueLabel'] ?? '',
          completed: data['completed'] ?? false,
          linkedNoteTitles: List<String>.from(data['linkedNoteTitles'] ?? []),
          attachments: (data['attachments'] as List? ?? []).map((a) {
            final attachmentMap = a as Map<String, dynamic>;
            return AttachmentModel(
              id: attachmentMap['id'] ?? '',
              name: attachmentMap['name'] ?? '',
              type: attachmentMap['type'] ?? '',
              sizeLabel: attachmentMap['sizeLabel'] ?? '',
              fileUrl: attachmentMap['fileUrl'],
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      print('Error getting pending tasks: $e');
      return [];
    }
  }

  /// Create a new task
  Future<void> createTask(String userId, TaskModel task) async {
    try {
      await FirestorePaths.tasksCollection(userId).add({
        'title': task.title,
        'course': task.course,
        'dueLabel': task.dueLabel,
        'completed': task.completed,
        'linkedNoteTitles': task.linkedNoteTitles,
        'attachments': task.attachments
            .map(
              (a) => {
                'id': a.id,
                'name': a.name,
                'type': a.type,
                'sizeLabel': a.sizeLabel,
                'fileUrl': a.fileUrl,
              },
            )
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(
    String userId,
    String taskId,
    bool completed,
  ) async {
    try {
      await FirestorePaths.tasksCollection(userId).doc(taskId).update({
        'completed': completed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error toggling task: $e');
      rethrow;
    }
  }

  /// Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await FirestorePaths.tasksCollection(userId).doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }
}
