import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vora/backend/models/app_task.dart';

void main() {
  group('AppTask.fromDoc', () {
    test('creates AppTask correctly from Firestore document', () async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('tasks').doc('task1').set({
        'title': 'Finish report',
        'subtitle': 'Do chapter 2',
        'dueAt': Timestamp.fromDate(DateTime(2026, 3, 20)),
        'isCompleted': true,
        'source': 'manual',
        'hidden': false,
      });

      final doc = await firestore.collection('tasks').doc('task1').get();
      final task = AppTask.fromDoc(doc);

      expect(task.id, 'task1');
      expect(task.title, 'Finish report');
      expect(task.subtitle, 'Do chapter 2');
      expect(task.dueDate, DateTime(2026, 3, 20));
      expect(task.isCompleted, true);
      expect(task.source, 'manual');
      expect(task.hidden, false);
    });

    test('uses default values when fields are missing', () async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('tasks').doc('task2').set({});

      final doc = await firestore.collection('tasks').doc('task2').get();
      final task = AppTask.fromDoc(doc);

      expect(task.id, 'task2');
      expect(task.title, '');
      expect(task.subtitle, '');
      expect(task.isCompleted, false);
      expect(task.source, 'task');
      expect(task.hidden, false);
    });
  });
}