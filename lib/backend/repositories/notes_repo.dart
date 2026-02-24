import 'package:cloud_firestore/cloud_firestore.dart';
import '../../frontend/models/note_model.dart';
import '../core/firestore_paths.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all notes for a user
  Future<List<NoteModel>> getNotes(String userId) async {
    try {
      final snapshot = await FirestorePaths.notesCollection(userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NoteModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          metaLeft: data['metaLeft'] ?? '',
          actionText: data['actionText'] ?? '',
          featured: data['featured'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  /// Create a new note
  Future<void> createNote(String userId, NoteModel note) async {
    try {
      await FirestorePaths.notesCollection(userId).add({
        'title': note.title,
        'description': note.description,
        'metaLeft': note.metaLeft,
        'actionText': note.actionText,
        'featured': note.featured,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }

  /// Delete a note
  Future<void> deleteNote(String userId, String noteId) async {
    try {
      await FirestorePaths.notesCollection(userId).doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }
}
