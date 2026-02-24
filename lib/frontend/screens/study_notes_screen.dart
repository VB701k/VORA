import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class StudyNotesScreen extends StatefulWidget {
  const StudyNotesScreen({super.key});

  @override
  State<StudyNotesScreen> createState() => _StudyNotesScreenState();
}

class _StudyNotesScreenState extends State<StudyNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<NoteModel> notes = [
    NoteModel(
      id: '1',
      title: 'Organic Chemistry',
      description: 'Covalent bonds and molecular orbital theory...',
      metaLeft: '2 HOURS AGO • #SCIENCE',
      actionText: '2 Files',
      featured: true,
    ),
    NoteModel(
      id: '2',
      title: 'Calculus III',
      description: 'Vectors and 3D spaces...',
      metaLeft: 'Yesterday • #MATH',
      actionText: 'Add Files',
      featured: false,
    ),
    NoteModel(
      id: '3',
      title: 'Ancient Rome',
      description: 'Julius Caesar and the Roman Empire...',
      metaLeft: '3 DAYS AGO • #HISTORY',
      actionText: '1 PDF',
      featured: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NoteModel> get _allNotes => notes;
  List<NoteModel> get _recentNotes => notes.take(3).toList();
  List<NoteModel> get _favoriteNotes => notes.where((n) => n.featured).toList();

  void _showQuickAddNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickAddNoteModal(
        onAdd: (newNote) {
          setState(() => notes.insert(0, newNote));
        },
      ),
    );
  }

  void _deleteNote(NoteModel note) {
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => notes.removeWhere((n) => n.id == note.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddNote,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 40),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Study Notes',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
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
                    _buildNotesList(_allNotes, 'No notes yet'),
                    _buildNotesList(_recentNotes, 'No recent notes'),
                    _buildNotesList(_favoriteNotes, 'No favorite notes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<NoteModel> noteList, String emptyMessage) {
    if (noteList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: noteList.length,
      itemBuilder: (context, i) => NoteCard(
        note: noteList[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NoteEditorScreen(isEdit: true),
          ),
        ),
        onDelete: () => _deleteNote(noteList[i]),
      ),
    );
  }
}

class _QuickAddNoteModal extends StatefulWidget {
  final Function(NoteModel) onAdd;
  const _QuickAddNoteModal({required this.onAdd});

  @override
  State<_QuickAddNoteModal> createState() => __QuickAddNoteModalState();
}

class __QuickAddNoteModalState extends State<_QuickAddNoteModal> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Add Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Note Title',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  widget.onAdd(
                    NoteModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      description: 'New note',
                      metaLeft: 'JUST NOW • #GENERAL',
                      actionText: 'Add Files',
                      featured: false,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Add Note', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
