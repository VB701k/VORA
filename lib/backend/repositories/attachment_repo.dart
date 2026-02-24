import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../frontend/models/attachment_model.dart';
import '../core/firestore_paths.dart';

class AttachmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file to storage
  Future<String?> uploadFile(String userId, File file, String fileName) async {
    try {
      final ref = _storage.ref().child('users/$userId/attachments/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Add attachment to a note
  Future<void> addAttachmentToNote(
    String userId,
    String noteId,
    AttachmentModel attachment,
  ) async {
    try {
      await FirestorePaths.notesCollection(
        userId,
      ).doc(noteId).collection('attachments').add({
        'id': attachment.id,
        'name': attachment.name,
        'type': attachment.type,
        'sizeLabel': attachment.sizeLabel,
        'fileUrl': attachment.fileUrl ?? '',
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding attachment: $e');
      rethrow;
    }
  }

  /// Get attachments for a note
  Future<List<AttachmentModel>> getNoteAttachments(
    String userId,
    String noteId,
  ) async {
    try {
      final snapshot = await FirestorePaths.notesCollection(
        userId,
      ).doc(noteId).collection('attachments').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AttachmentModel(
          id: doc.id,
          name: data['name'] ?? '',
          type: data['type'] ?? '',
          sizeLabel: data['sizeLabel'] ?? '',
          fileUrl: data['fileUrl'],
        );
      }).toList();
    } catch (e) {
      print('Error getting attachments: $e');
      return [];
    }
  }

  /// Delete attachment
  Future<void> deleteAttachment(
    String userId,
    String noteId,
    String attachmentId,
  ) async {
    try {
      await FirestorePaths.notesCollection(
        userId,
      ).doc(noteId).collection('attachments').doc(attachmentId).delete();
    } catch (e) {
      print('Error deleting attachment: $e');
      rethrow;
    }
  }
}
