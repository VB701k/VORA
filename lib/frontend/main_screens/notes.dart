// lib/frontend/notes/notes_module.dart
// ONE-FILE NOTES MODULE (FINAL + BACKEND CONNECTED)
// - Uses Firestore via NotesBackend (stream notes, create/update/trash, pin toggle)
// - Still keeps your polished UI and editor
//
// Requires:
//   lib/backend/services/notes_backend.dart  (NotesBackend, NoteDoc)
//   firebase initialized in main.dart

import 'package:flutter/material.dart';
import 'package:vora/backend/services/notes_backend.dart';

/// ==================== THEME ====================
class AppColors {
  static const background = Color(0xFF0B1E2D);
  static const card = Color(0xFF0F2A3D);
  static const border = Color(0xFF2A4B63);

  static const primary = Color(0xFF4FA3D1);
  static const accent = Color(0xFF3B9BC6);

  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
}

/// ==================== UI MODELS ====================
/// (UI-only attachment model; backend attachments can be wired later)
class AttachmentModel {
  final String id;
  final String name;
  final String type; // "PDF", "IMG", "LINK"
  final String sizeLabel; // "2.1 MB", "URL"
  final String? fileUrl;

  const AttachmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeLabel,
    this.fileUrl,
  });
}

/// UI-only note model (maps from backend NoteDoc)
class NoteModel {
  final String id;
  final String title;
  final String description; // summary / preview
  final String metaLeft; // "UPDATED" / etc
  final String actionText; // "Open" / "2 Files" etc
  final bool featured;

  final bool isPinned;
  final bool isDeleted;

  const NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.metaLeft,
    required this.actionText,
    this.featured = false,
    this.isPinned = false,
    this.isDeleted = false,
  });

  NoteModel copyWith({
    String? title,
    String? description,
    String? metaLeft,
    String? actionText,
    bool? featured,
    bool? isPinned,
    bool? isDeleted,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      metaLeft: metaLeft ?? this.metaLeft,
      actionText: actionText ?? this.actionText,
      featured: featured ?? this.featured,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

/// ==================== SMALL WIDGETS ====================

class AttachmentRow extends StatelessWidget {
  final AttachmentModel attachment;
  final VoidCallback? onRemove;

  const AttachmentRow({super.key, required this.attachment, this.onRemove});

  IconData get _icon {
    switch (attachment.type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'IMG':
        return Icons.image_rounded;
      case 'LINK':
        return Icons.link_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${attachment.type} • ${attachment.sizeLabel}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, color: Colors.white54),
            ),
        ],
      ),
    );
  }
}

/// ==================== NOTE CARD ====================
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onEdit;
  final VoidCallback? onActionTap;
  final VoidCallback? onDelete;
  final VoidCallback? onPinToggle;

  const NoteCard({
    super.key,
    required this.note,
    this.onEdit,
    this.onActionTap,
    this.onDelete,
    this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.featured)
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                color: Colors.white.withOpacity(0.06),
              ),
              child: Center(
                child: Icon(
                  Icons.image_rounded,
                  color: Colors.white.withOpacity(0.15),
                  size: 56,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Pin icon
                    IconButton(
                      onPressed: onPinToggle,
                      icon: Icon(
                        note.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        color: note.isPinned
                            ? AppColors.primary
                            : Colors.white70,
                        size: 20,
                      ),
                    ),

                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white70,
                      ),
                      color: AppColors.card,
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete?.call();
                        } else if (value == 'edit') {
                          onEdit?.call();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.metaLeft,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    _ActionPill(text: note.actionText, onTap: onActionTap),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _ActionPill({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==================== NOTE EDITOR SCREEN ====================
/// Returns NoteEditorResult via Navigator.pop()
class NoteEditorResult {
  final String title;
  final String content;
  final List<String> tags;
  final List<AttachmentModel> attachments;

  const NoteEditorResult({
    required this.title,
    required this.content,
    required this.tags,
    required this.attachments,
  });
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.initialTags = const [],
    this.initialAttachments = const [],
  });

  final String? noteId; // null => create mode
  final String? initialTitle;
  final String? initialContent;
  final List<String> initialTags;
  final List<AttachmentModel> initialAttachments;

  bool get isEdit => noteId != null;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final List<AttachmentModel> _attachments;
  late final List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initialTitle ?? '';
    _bodyCtrl.text = widget.initialContent ?? '';
    _attachments = [...widget.initialAttachments];
    _tags = [...widget.initialTags];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final t = _tagCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      if (!_tags.contains(t.toUpperCase())) {
        _tags.add(t.toUpperCase());
      }
      _tagCtrl.clear();
    });
  }

  void _addFakeAttachment() {
    // UI only (replace with file_picker later)
    setState(() {
      _attachments.add(
        AttachmentModel(
          id: 'att${DateTime.now().millisecondsSinceEpoch}',
          name: 'Reference_Link',
          type: 'LINK',
          sizeLabel: 'URL',
          fileUrl: 'https://example.com',
        ),
      );
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(
      context,
      NoteEditorResult(
        title: _titleCtrl.text.trim(),
        content: _bodyCtrl.text.trim(),
        tags: _tags,
        attachments: _attachments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _TopBar(
                title: widget.isEdit ? 'Edit Note' : 'Create Note',
                onBack: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _Field(
                      label: 'Title',
                      controller: _titleCtrl,
                      hint: 'Enter note title',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Content',
                      controller: _bodyCtrl,
                      hint: 'Write your note…',
                      maxLines: 7,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Content is required'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Tags
                    Row(
                      children: [
                        Expanded(
                          child: _Field(
                            label: 'Tags',
                            controller: _tagCtrl,
                            hint: 'Add tag (e.g., MATH)',
                            maxLines: 1,
                            validator: (_) => null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _addTag,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map(
                              (t) => Chip(
                                backgroundColor: AppColors.card,
                                side: const BorderSide(color: AppColors.border),
                                label: Text(
                                  t,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.white54,
                                ),
                                onDeleted: () =>
                                    setState(() => _tags.remove(t)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Attachments',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addFakeAttachment,
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Add',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _attachments.isEmpty
                    ? const Center(
                        child: Text(
                          'No attachments',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _attachments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => AttachmentRow(
                          attachment: _attachments[i],
                          onRemove: () =>
                              setState(() => _attachments.removeAt(i)),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Note',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onBack,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 36),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

/// ==================== STUDY NOTES SCREEN ====================
/// Connected to NotesBackend:
/// - List uses streamNotesActive()
/// - Create -> createNote()
/// - Edit -> updateNote()
/// - Delete -> moveToTrash()
/// - Pin -> togglePinned()
class StudyNotesScreen extends StatefulWidget {
  const StudyNotesScreen({super.key});

  @override
  State<StudyNotesScreen> createState() => _StudyNotesScreenState();
}

class _StudyNotesScreenState extends State<StudyNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  // UI-only attachments map (you can wire backend attachments later)
  final Map<String, List<AttachmentModel>> _noteAttachments = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<NoteModel> _filter(List<NoteModel> base) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return base;
    return base
        .where(
          (n) =>
              n.title.toLowerCase().contains(q) ||
              n.description.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _openCreate() async {
    final res = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
    if (res == null) return;

    await NotesBackend.instance.createNote(
      title: res.title,
      content: res.content,
      tags: res.tags.isEmpty ? const ['GENERAL'] : res.tags,
    );

    // keep UI-only attachments locally (optional)
    // (For real attachment upload, wire NotesBackend.uploadAttachmentBytes)
  }

  Future<void> _openEdit(NoteModel note) async {
    final res = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          noteId: note.id,
          initialTitle: note.title,
          initialContent: note.description,
          initialTags:
              const [], // can be wired from backend if you store tags in UI
          initialAttachments: _noteAttachments[note.id] ?? const [],
        ),
      ),
    );
    if (res == null) return;

    await NotesBackend.instance.updateNote(
      noteId: note.id,
      title: res.title,
      content: res.content,
      tags: res.tags.isEmpty ? const ['GENERAL'] : res.tags,
    );

    // keep UI-only attachments locally (optional)
    _noteAttachments[note.id] = res.attachments;
  }

  Future<void> _delete(NoteModel note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Delete Note',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Move "${note.title}" to Trash?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await NotesBackend.instance.moveToTrash(note.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Study Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),

              // Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded, color: Colors.white54),
                    hintText: 'Search notes…',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tabs (All / Recent / Pinned)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Recent'),
                    Tab(text: 'Pinned'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<List<NoteDoc>>(
                  stream: NotesBackend.instance.streamNotesActive(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snap.error}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final docs = snap.data ?? [];

                    // Map backend NoteDoc -> UI NoteModel
                    final mapped = docs.map((d) {
                      final meta = (d.updatedAt == null)
                          ? "JUST NOW"
                          : "UPDATED";
                      return NoteModel(
                        id: d.id,
                        title: d.title,
                        description: d.summary.isEmpty ? d.content : d.summary,
                        metaLeft: meta,
                        actionText: "Open",
                        featured: false,
                        isPinned: d.isPinned,
                        isDeleted: d.isDeleted,
                      );
                    }).toList();

                    final all = _filter(mapped);
                    final recent = all.take(10).toList();
                    final pinned = all.where((n) => n.isPinned).toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(all),
                        _buildList(recent),
                        _buildList(pinned),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<NoteModel> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No notes', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView(
      children: list.map((note) {
        final files = _noteAttachments[note.id]?.length ?? 0;
        final patched = note.copyWith(
          actionText: files == 0 ? 'Open' : '$files Files',
        );

        return NoteCard(
          note: patched,
          onDelete: () => _delete(note),
          onEdit: () => _openEdit(note),
          onActionTap: () => _openEdit(note),
          onPinToggle: () async {
            await NotesBackend.instance.togglePinned(note.id);
          },
        );
      }).toList(),
    );
  }
}
