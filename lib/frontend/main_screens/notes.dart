// lib/frontend/notes/notes_module.dart
// ONE-FILE NOTES MODULE (polished)
// Includes: AppColors, models, widgets, StudyNotesScreen, NoteEditorScreen

import 'package:flutter/material.dart';

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

/// ==================== MODELS ====================
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

class NoteModel {
  final String id;
  final String title;
  final String description; // short preview
  final String metaLeft; // e.g. "2 HOURS AGO • #SCIENCE"
  final String actionText; // e.g. "2 Files"
  final bool featured;

  const NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.metaLeft,
    required this.actionText,
    this.featured = false,
  });

  NoteModel copyWith({
    String? title,
    String? description,
    String? metaLeft,
    String? actionText,
    bool? featured,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      metaLeft: metaLeft ?? this.metaLeft,
      actionText: actionText ?? this.actionText,
      featured: featured ?? this.featured,
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
/// (same UI behavior as your NoteCard: menu with edit/delete + action pill)
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onEdit;
  final VoidCallback? onActionTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onEdit,
    this.onActionTap,
    this.onDelete,
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
              Icons.attach_file_rounded,
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
  final NoteModel note;
  final List<AttachmentModel> attachments;
  const NoteEditorResult({required this.note, required this.attachments});
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.initialNote,
    this.initialAttachments = const [],
  });

  final NoteModel? initialNote;
  final List<AttachmentModel> initialAttachments;

  bool get isEdit => initialNote != null;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final List<AttachmentModel> _attachments;

  @override
  void initState() {
    super.initState();

    _titleCtrl.text = widget.initialNote?.title ?? '';
    _bodyCtrl.text = widget.initialNote?.description ?? '';
    _attachments = [...widget.initialAttachments];

    // If create mode and you want a sample attachment (optional), you can remove this.
    if (!widget.isEdit && _attachments.isEmpty) {
      _attachments.add(
        AttachmentModel(
          id: 'att1',
          name: 'Lecture_Slides.pdf',
          type: 'PDF',
          sizeLabel: '2.1 MB',
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _addFakeAttachment() {
    // UI only (you can replace with file_picker later)
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

    final id =
        widget.initialNote?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    final note = NoteModel(
      id: id,
      title: title,
      description: body,
      metaLeft: widget.isEdit ? 'UPDATED • #GENERAL' : 'JUST NOW • #GENERAL',
      actionText: _attachments.isEmpty
          ? 'Add Files'
          : '${_attachments.length} Files',
      featured: widget.initialNote?.featured ?? false,
    );

    Navigator.pop(
      context,
      NoteEditorResult(note: note, attachments: _attachments),
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Title is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Content',
                      controller: _bodyCtrl,
                      hint: 'Write your note…',
                      maxLines: 7,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Content is required';
                        return null;
                      },
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
                        itemBuilder: (context, i) {
                          return AttachmentRow(
                            attachment: _attachments[i],
                            onRemove: () =>
                                setState(() => _attachments.removeAt(i)),
                          );
                        },
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
/// Polished:
/// - Search
/// - Tabs (All / Recent / Favorites)
/// - Create & Edit uses NoteEditorScreen and returns result
class StudyNotesScreen extends StatefulWidget {
  const StudyNotesScreen({super.key});

  @override
  State<StudyNotesScreen> createState() => _StudyNotesScreenState();
}

class _StudyNotesScreenState extends State<StudyNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _searchCtrl = TextEditingController();

  final List<NoteModel> _notes = [
    const NoteModel(
      id: '1',
      title: 'Organic Chemistry',
      description: 'Covalent bonds...',
      metaLeft: '2 HOURS AGO • #SCIENCE',
      actionText: '2 Files',
      featured: true,
    ),
    const NoteModel(
      id: '2',
      title: 'Calculus III',
      description: 'Vectors...',
      metaLeft: 'Yesterday • #MATH',
      actionText: 'Add Files',
      featured: false,
    ),
  ];

  // attachments stored in-memory per note (UI demo)
  final Map<String, List<AttachmentModel>> _noteAttachments = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // demo attachments for note id '1'
    _noteAttachments['1'] = const [
      AttachmentModel(
        id: 'att1',
        name: 'Lecture_Slides.pdf',
        type: 'PDF',
        sizeLabel: '2.1 MB',
      ),
      AttachmentModel(
        id: 'att2',
        name: 'Lab_Notes.png',
        type: 'IMG',
        sizeLabel: '860 KB',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openCreate() async {
    final res = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );

    if (res == null) return;
    setState(() {
      _notes.insert(0, res.note);
      _noteAttachments[res.note.id] = res.attachments;
    });
  }

  void _openEdit(NoteModel note) async {
    final res = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          initialNote: note,
          initialAttachments: _noteAttachments[note.id] ?? const [],
        ),
      ),
    );

    if (res == null) return;
    setState(() {
      final idx = _notes.indexWhere((n) => n.id == note.id);
      if (idx != -1) _notes[idx] = res.note;
      _noteAttachments[note.id] = res.attachments;
    });
  }

  void _delete(NoteModel note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Delete Note',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete "${note.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
                _noteAttachments.remove(note.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  List<NoteModel> get _allNotes => _filter(_notes);
  List<NoteModel> get _recentNotes => _filter(_notes.take(10).toList());
  List<NoteModel> get _favoriteNotes =>
      _filter(_notes.where((n) => n.featured).toList());

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

              // Tabs
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
                    Tab(text: 'Favorites'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_allNotes),
                    _buildList(_recentNotes),
                    _buildList(_favoriteNotes),
                  ],
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
          actionText: files == 0 ? 'Add Files' : '$files Files',
        );
        return NoteCard(
          note: patched,
          onDelete: () => _delete(note),
          onEdit: () => _openEdit(note),
          onActionTap: () => _openEdit(note),
        );
      }).toList(),
    );
  }
}
