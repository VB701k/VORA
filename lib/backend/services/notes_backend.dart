// lib/backend/services/notes_backend.dart
//
// VORA Notes Backend (Polished + Index-free reads)
// Commits included:
//  - Commit 1: chore(notes): add module version header
//  - Commit 2: chore(notes): add debug logger
//  - Commit 3: chore(notes): log note lifecycle actions (create/update/moveToTrash)
//
// Firestore:
//   users/{uid}/notes/{noteId}
//   users/{uid}/notes/{noteId}/attachments/{attachmentId}
//
// Storage:
//   users/{uid}/notes/{noteId}/attachments/{filename}
//
// IMPORTANT:
// - Notes reads avoid compound Firestore queries to prevent index errors.
// - Pinned sorting should be done in frontend.
//
// Dependencies:
//   cloud_firestore, firebase_auth, firebase_storage

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// ==================== COMMIT 1: VERSION HEADER ====================
const String kNotesBackendVersion = "1.0.0";

/// ==================== COMMIT 2: DEBUG LOGGER ====================
void notesLog(String msg) {
  // Prints only in debug mode (assert runs only in debug)
  assert(() {
    // ignore: avoid_print
    print("[NOTES] $msg");
    return true;
  }());
}

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
  ValidationException(super.message);
}

/// ==================== Models ====================

class NoteDoc {
  final String id;
  final String title;
  final String content;
  final String summary;

  final List<String> tags;
  final bool isPinned;

  final bool isDeleted;
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
  final String fileName;
  final String type;
  final String sizeLabel;

  final String? downloadUrl;
  final String? storagePath;

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
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  // ---------- Helpers ----------

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
    if (t.isEmpty) {
      throw ValidationException('Title is required');
    }
    if (t.length > 80) {
      throw ValidationException('Title too long (max 80 chars)');
    }
  }

  void _validateContent(String content) {
    if (content.trim().isEmpty) {
      throw ValidationException('Content is required');
    }
  }

  String _safeFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) throw ValidationException('File name is required');
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  // =========================================================
  // NOTES: STREAMS / READ
  // =========================================================

  // Sort notes in Dart so reads stay compatible with Firestore's automatic
  // single-field indexes.
  int _compareDateDesc(DateTime? a, DateTime? b) {
    final aMs = a?.millisecondsSinceEpoch ?? 0;
    final bMs = b?.millisecondsSinceEpoch ?? 0;
    return bMs.compareTo(aMs);
  }

  List<NoteDoc> _sortedAndLimited(
    Iterable<NoteDoc> docs, {
    required DateTime? Function(NoteDoc note) dateSelector,
    required int limit,
  }) {
    final list = docs.toList();
    list.sort((a, b) {
      final dateCompare = _compareDateDesc(dateSelector(a), dateSelector(b));
      if (dateCompare != 0) return dateCompare;
      return a.id.compareTo(b.id);
    });

    if (limit <= 0 || list.length <= limit) return list;
    return list.take(limit).toList();
  }

  Stream<List<NoteDoc>> streamNotesActive({int limit = 100}) {
    return _notesCol
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map(
          (snap) => _sortedAndLimited(
            snap.docs.map((d) => NoteDoc.fromDoc(d)),
            dateSelector: (note) => note.updatedAt ?? note.createdAt,
            limit: limit,
          ),
        );
  }

  Stream<List<NoteDoc>> streamNotesTrash({int limit = 100}) {
    return _notesCol
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => _sortedAndLimited(
            snap.docs.map((d) => NoteDoc.fromDoc(d)),
            dateSelector: (note) => note.deletedAt ?? note.updatedAt,
            limit: limit,
          ),
        );
  }

  Stream<List<NoteDoc>> searchNotes(String query, {int limit = 50}) {
    final q = query.trim().toLowerCase();
    if (q.length < 3) return Stream.value(const <NoteDoc>[]);

    return _notesCol
        .where('keywords', arrayContains: q)
        .snapshots()
        .map(
          (snap) => _sortedAndLimited(
            snap.docs
                .map((d) => NoteDoc.fromDoc(d))
                .where((note) => !note.isDeleted),
            dateSelector: (note) => note.updatedAt ?? note.createdAt,
            limit: limit,
          ),
        );
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

    /// ✅ Commit 3 log
    notesLog("createNote: ${title.trim()}");

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

    /// ✅ Commit 3 log
    notesLog("updateNote: $noteId");

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
  // NOTES: TRASH / RESTORE / HARD DELETE
  // =========================================================

  Future<void> moveToTrash(String noteId) async {
    /// ✅ Commit 3 log
    notesLog("moveToTrash: $noteId");

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

  Future<void> hardDeleteNote(String noteId) async {
    final noteRef = _noteRef(noteId);
    final noteSnap = await noteRef.get();
    if (!noteSnap.exists) throw NotFoundException('Note');

    final attSnap = await _attachmentsCol(noteId).get();

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

  Future<String> uploadAttachmentBytes({
    required String noteId,
    required Uint8List bytes,
    required String fileName,
    required String type,
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

    await bumpUpdateAt(noteId);
    return attRef.id;
  }

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

    await bumpUpdatedAt(noteId);

    return attRef.id;
  }

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

  Future<int> countActiveNotes() async {
    final snap = await _notesCol.where('isDeleted', isEqualTo: false).get();
    return snap.size;
  }

  Future<int> countTrashNotes() async {
    final snap = await _notesCol.where('isDeleted', isEqualTo: true).get();
    return snap.size;
  }

  Future<void> bumpUpdatedAt(String noteId) async {
    await _noteRef(
      noteId,
    ).set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
