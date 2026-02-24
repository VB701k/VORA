import 'package:flutter/material.dart';
import '../backend/repositories/notes_repo.dart';
import '../frontend/models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _error;

  final NotesRepository _notesRepo = NotesRepository();

  List<NoteModel> get notes => _notes;
  List<NoteModel> get recentNotes => _notes.take(5).toList();
  List<NoteModel> get featuredNotes => _notes.where((n) => n.featured).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _notesRepo.getNotes(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String userId, NoteModel note) async {
    try {
      await _notesRepo.createNote(userId, note);
      _notes.insert(0, note);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String userId, String noteId) async {
    try {
      await _notesRepo.deleteNote(userId, noteId);
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
