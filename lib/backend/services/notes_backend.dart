// lib/backend/services/notes_backend.dart
//
// VORA Notes Backend (Fixed + Polished)
// ------------------------------------
// Firestore:
//   users/{uid}/notes/{noteId}
//   users/{uid}/notes/{noteId}/attachments/{attachmentId}
//
// Storage:
//   users/{uid}/notes/{noteId}/attachments/{filename}
//
// Features:
// - Create/update notes (pin + tags)
// - Soft delete (trash) + restore + hard delete
// - Search indexing: titleLower + keywords (token list)
// - Attachments: upload bytes to storage + store metadata in Firestore
// - Link attachments (no storage)
// - Best-effort cleanup on hard delete
//
// Dependencies:
//   cloud_firestore, firebase_auth, firebase_storage

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String kNotesBackendVersion = "1.0.0";

/// ==================== Errors ====================

class NotesBackendException implements Exception {
  final String message;
  final Object? cause;
  NotesBackendException(this.message, {this.cause});

  @override
  String toString() => 'NotesBackendException($message, cause: $cause)';
}

class NotLoggedInException extends NotesBackendException {
  NotLoggedInException() : super('User not logged in');
}

class NotFoundException extends NotesBackendException {
  NotFoundException(String what) : super('$what not found');
}

class ValidationException extends NotesBackendException {
  ValidationException(String message) : super(message);
}

/// ==================== Models ====================

class NoteDoc {
  final String id;

  final String title;
  final String content;
  final String summary; // short preview for cards

  final List<String> tags;
  final bool isPinned;

  final bool isDeleted; // soft delete
  final DateTime? deletedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteDoc({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.tags,
    required this.isPinned,
    required this.isDeleted,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteDoc.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NoteDoc(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      summary: (data['summary'] ?? '').toString(),
      tags: List<String>.from((data['tags'] ?? const <dynamic>[]) as List),
      isPinned: (data['isPinned'] ?? false) as bool,
      isDeleted: (data['isDeleted'] ?? false) as bool,
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class NoteAttachmentDoc {
  final String id;
  final String fileName; // display name
  final String type; // PDF / IMG / LINK / OTHER
  final String sizeLabel; // "2.1 MB" or "URL"

  final String? downloadUrl; // storage URL or link URL
  final String? storagePath; // null for LINK attachments

  final DateTime? uploadedAt;

  const NoteAttachmentDoc({
    required this.id,
    required this.fileName,
    required this.type,
    required this.sizeLabel,
    required this.downloadUrl,
    required this.storagePath,
    required this.uploadedAt,
  });

  factory NoteAttachmentDoc.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return NoteAttachmentDoc(
      id: doc.id,
      fileName: (data['fileName'] ?? '').toString(),
      type: (data['type'] ?? 'OTHER').toString(),
      sizeLabel: (data['sizeLabel'] ?? '').toString(),
      downloadUrl: data['downloadUrl'] as String?,
      storagePath: data['storagePath'] as String?,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// ==================== Backend Service ====================

class NotesBackend {
  NotesBackend._();
  static final NotesBackend instance = NotesBackend._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ FIX: This is what your file was missing / out-of-scope
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------- Auth / paths ----------

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw NotLoggedInException();
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _notesCol =>
      _db.collection('users').doc(_uid).collection('notes');

  DocumentReference<Map<String, dynamic>> _noteRef(String noteId) =>
      _db.collection('users').doc(_uid).collection('notes').doc(noteId);

  CollectionReference<Map<String, dynamic>> _attachmentsCol(String noteId) =>
      _noteRef(noteId).collection('attachments');

  String _storageBase(String noteId) => 'users/$_uid/notes/$noteId/attachments';

  // ---------- Helpers (summary + search index) ----------

  String _makeSummary(String content, {int max = 110}) {
    final cleaned = content
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('\n', ' ')
        .trim();
    if (cleaned.length <= max) return cleaned;
    return '${cleaned.substring(0, max).trim()}…';
  }

  List<String> _keywordsFrom(String title, String content, List<String> tags) {
    final combined = [title, content, ...tags].join(' ').toLowerCase();

    final tokens = combined
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.trim().length >= 3)
        .map((t) => t.trim())
        .toSet()
        .toList();

    tokens.sort();
    return tokens.take(40).toList();
  }

  void _validateTitle(String title) {
    final t = title.trim();
    if (t.isEmpty) throw ValidationException('Title is required');
    if (t.length > 80)
      throw ValidationException('Title too long (max 80 chars)');
  }

  void _validateContent(String content) {
    if (content.trim().isEmpty)
      throw ValidationException('Content is required');
  }

  String _safeFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) throw ValidationException('File name is required');
    // Windows-illegal characters replaced
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  // =========================================================
  // NOTES: STREAMS / READ
  // =========================================================

  Stream<List<NoteDoc>> streamNotesActive({int limit = 100}) {
    return _notesCol
        .where('isDeleted', isEqualTo: false)
        .orderBy('isPinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NoteDoc.fromDoc(d)).toList());
  }

  Stream<List<NoteDoc>> streamNotesTrash({int limit = 100}) {
    return _notesCol
        .where('isDeleted', isEqualTo: true)
        .orderBy('deletedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NoteDoc.fromDoc(d)).toList());
  }

  /// Basic token search (query must be >= 3 chars)
  Stream<List<NoteDoc>> searchNotes(String query, {int limit = 50}) {
    final q = query.trim().toLowerCase();
    if (q.length < 3) return Stream.value(const <NoteDoc>[]);

    return _notesCol
        .where('isDeleted', isEqualTo: false)
        .where('keywords', arrayContains: q)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NoteDoc.fromDoc(d)).toList());
  }

  Future<NoteDoc> getNoteById(String noteId) async {
    final doc = await _noteRef(noteId).get();
    if (!doc.exists) throw NotFoundException('Note');
    return NoteDoc.fromDoc(doc);
  }

  // =========================================================
  // NOTES: CREATE / UPDATE / PIN
  // =========================================================

  Future<String> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
    bool isPinned = false,
  }) async {
    _validateTitle(title);
    _validateContent(content);

    final ref = _notesCol.doc();
    final summary = _makeSummary(content);
    final keywords = _keywordsFrom(title, content, tags);

    await ref.set({
      'title': title.trim(),
      'titleLower': title.trim().toLowerCase(),
      'content': content.trim(),
      'summary': summary,
      'tags': tags,
      'isPinned': isPinned,
      'isDeleted': false,
      'deletedAt': null,
      'keywords': keywords,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
    List<String>? tags,
    bool? isPinned,
  }) async {
    final ref = _noteRef(noteId);
    final snap = await ref.get();
    if (!snap.exists) throw NotFoundException('Note');

    final current = snap.data() ?? {};
    final newTitle = (title ?? (current['title'] ?? '')).toString();
    final newContent = (content ?? (current['content'] ?? '')).toString();
    final newTags =
        tags ??
        List<String>.from((current['tags'] ?? const <dynamic>[]) as List);

    _validateTitle(newTitle);
    _validateContent(newContent);

    final updates = <String, dynamic>{};

    if (title != null) {
      updates['title'] = newTitle.trim();
      updates['titleLower'] = newTitle.trim().toLowerCase();
    }
    if (content != null) {
      updates['content'] = newContent.trim();
      updates['summary'] = _makeSummary(newContent);
    }
    if (tags != null) updates['tags'] = newTags;
    if (isPinned != null) updates['isPinned'] = isPinned;

    if (title != null || content != null || tags != null) {
      updates['keywords'] = _keywordsFrom(newTitle, newContent, newTags);
    }

    if (updates.isEmpty) return;

    updates['updatedAt'] = FieldValue.serverTimestamp();
    await ref.update(updates);
  }

  Future<void> setPinned(String noteId, bool pinned) async {
    await _noteRef(
      noteId,
    ).update({'isPinned': pinned, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // =========================================================
  // NOTES: TRASH (soft delete) / RESTORE / HARD DELETE
  // =========================================================

  Future<void> moveToTrash(String noteId) async {
    await _noteRef(noteId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreFromTrash(String noteId) async {
    await _noteRef(noteId).update({
      'isDeleted': false,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hard delete: deletes attachment docs, note doc, and best-effort deletes storage files.
  Future<void> hardDeleteNote(String noteId) async {
    final noteRef = _noteRef(noteId);
    final noteSnap = await noteRef.get();
    if (!noteSnap.exists) throw NotFoundException('Note');

    final attSnap = await _attachmentsCol(noteId).get();

    // delete storage best-effort
    for (final d in attSnap.docs) {
      final data = d.data();
      final storagePath = data['storagePath'] as String?;
      if (storagePath != null && storagePath.isNotEmpty) {
        try {
          await _storage.ref(storagePath).delete();
        } catch (_) {}
      }
    }

    final batch = _db.batch();
    for (final d in attSnap.docs) {
      batch.delete(d.reference);
    }
    batch.delete(noteRef);
    await batch.commit();
  }

  // =========================================================
  // ATTACHMENTS
  // =========================================================

  Stream<List<NoteAttachmentDoc>> streamAttachments(String noteId) {
    return _attachmentsCol(noteId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => NoteAttachmentDoc.fromDoc(d)).toList(),
        );
  }

  /// Upload bytes to Storage and record attachment in Firestore.
  /// contentType examples: application/pdf, image/png
  Future<String> uploadAttachmentBytes({
    required String noteId,
    required Uint8List bytes,
    required String fileName,
    required String type, // PDF/IMG/OTHER
    required String sizeLabel,
    String contentType = 'application/octet-stream',
  }) async {
    final safeName = _safeFileName(fileName);
    final storagePath = '${_storageBase(noteId)}/$safeName';

    final storageRef = _storage.ref(storagePath);
    await storageRef.putData(bytes, SettableMetadata(contentType: contentType));
    final url = await storageRef.getDownloadURL();

    final attRef = _attachmentsCol(noteId).doc();
    await attRef.set({
      'fileName': safeName,
      'type': type,
      'sizeLabel': sizeLabel,
      'downloadUrl': url,
      'storagePath': storagePath,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    // bump note ordering
    await _noteRef(
      noteId,
    ).set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    return attRef.id;
  }

  /// Add a link attachment (no storage).
  Future<String> addLinkAttachment({
    required String noteId,
    required String title,
    required String url,
  }) async {
    final t = title.trim().isEmpty ? 'Link' : title.trim();
    final u = url.trim();
    if (u.isEmpty) throw ValidationException('URL is required');

    final attRef = _attachmentsCol(noteId).doc();
    await attRef.set({
      'fileName': t,
      'type': 'LINK',
      'sizeLabel': 'URL',
      'downloadUrl': u,
      'storagePath': null,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    await _noteRef(
      noteId,
    ).set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    return attRef.id;
  }

  /// Delete attachment doc and storage file (if any).
  Future<void> deleteAttachment({
    required String noteId,
    required String attachmentId,
  }) async {
    final ref = _attachmentsCol(noteId).doc(attachmentId);
    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data() ?? {};
    final storagePath = data['storagePath'] as String?;

    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        await _storage.ref(storagePath).delete();
      } catch (_) {}
    }

    await ref.delete();

    await _noteRef(
      noteId,
    ).set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
