// lib/frontend/notes/notes_module.dart
// ONE-FILE NOTES MODULE (Polished + Backend Connected)

import 'package:flutter/material.dart';
import 'package:vora/backend/services/notes_backend.dart';

class AppColors {
  static const background = Color(0xFF0B1E2D);
  static const card = Color(0xFF0F2A3D);
  static const border = Color(0xFF2A4B63);

  static const primary = Color(0xFF4FA3D1);
  static const accent = Color(0xFF3B9BC6);

  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
}

class AttachmentModel {
  final String id;
  final String name;
  final String type;
  final String sizeLabel;
  final String? fileUrl;

  const AttachmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeLabel,
    this.fileUrl,
  });
}

class NoteModel {
  final String id;
  final String title;
  final String description;
  final String metaLeft;
  final String actionText;
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
      child: Padding(
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
                IconButton(
                  onPressed: onPinToggle,
                  icon: Icon(
                    note.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: note.isPinned ? AppColors.primary : Colors.white70,
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
                    if (value == 'delete') onDelete?.call();
                    if (value == 'edit') onEdit?.call();
                  },
                  itemBuilder: (_) => const [
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
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                          note.actionText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditorResult {
  final String title;
  final String content;
  final List<String> tags;

  const NoteEditorResult({
    required this.title,
    required this.content,
    required this.tags,
  });
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.initialTags = const [],
  });

  final String? noteId;
  final String? initialTitle;
  final String? initialContent;
  final List<String> initialTags;

  bool get isEdit => noteId != null;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initialTitle ?? '';
    _bodyCtrl.text = widget.initialContent ?? '';
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
      final up = t.toUpperCase();
      if (!_tags.contains(up)) _tags.add(up);
      _tagCtrl.clear();
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(
      context,
      NoteEditorResult(
        title: _titleCtrl.text.trim(),
        content: _bodyCtrl.text.trim(),
        tags: _tags.isEmpty ? const ['GENERAL'] : _tags,
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.isEdit ? 'Edit Note' : 'Create Note',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
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
              const Spacer(),
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

class StudyNotesScreen extends StatefulWidget {
  const StudyNotesScreen({super.key});

  @override
  State<StudyNotesScreen> createState() => _StudyNotesScreenState();
}

class _StudyNotesScreenState extends State<StudyNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

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
      tags: res.tags,
    );
  }

  Future<void> _openEdit(NoteModel note) async {
    final res = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          noteId: note.id,
          initialTitle: note.title,
          initialContent: note.description,
          initialTags: const ['GENERAL'],
        ),
      ),
    );
    if (res == null) return;

    await NotesBackend.instance.updateNote(
      noteId: note.id,
      title: res.title,
      content: res.content,
      tags: res.tags,
    );
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

                    final mapped = docs.map((d) {
                      return NoteModel(
                        id: d.id,
                        title: d.title,
                        description: d.summary.isEmpty ? d.content : d.summary,
                        metaLeft: d.updatedAt == null ? "JUST NOW" : "UPDATED",
                        actionText: "Open",
                        isPinned: d.isPinned,
                        isDeleted: d.isDeleted,
                      );
                    }).toList();

                    final all = _filter(mapped);

                    // ✅ Pinned first (client-side) to avoid Firestore index
                    all.sort((a, b) {
                      final pinCompare = (b.isPinned ? 1 : 0).compareTo(
                        a.isPinned ? 1 : 0,
                      );
                      if (pinCompare != 0) return pinCompare;
                      return 0;
                    });

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
        return NoteCard(
          note: note,
          onDelete: () => _delete(note),
          onEdit: () => _openEdit(note),
          onActionTap: () => _openEdit(note),
          onPinToggle: () async {
            await NotesBackend.instance.setPinned(note.id, !note.isPinned);
          },
        );
      }).toList(),
    );
  }
}
