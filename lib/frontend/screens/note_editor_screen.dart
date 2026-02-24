import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/attachment_model.dart';
import '../widgets/attachment_row.dart';

class NoteEditorScreen extends StatefulWidget {
  final bool isEdit;
  const NoteEditorScreen({super.key, this.isEdit = false});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();

  final attachments = <AttachmentModel>[
    AttachmentModel(
      id: 'att1',
      name: 'Lecture_Slides.pdf',
      type: 'PDF',
      sizeLabel: '2.1 MB',
    ),
  ];

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    super.dispose();
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.isEdit ? 'Edit Note' : 'Create Note',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              _Field(
                label: 'Title',
                controller: titleCtrl,
                hint: 'Enter note title',
              ),
              const SizedBox(height: 12),
              _Field(
                label: 'Content',
                controller: bodyCtrl,
                hint: 'Write your note…',
                maxLines: 6,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Attachments',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        attachments.add(
                          AttachmentModel(
                            id: 'att${DateTime.now().millisecondsSinceEpoch}',
                            name: 'Reference_Link',
                            type: 'LINK',
                            sizeLabel: 'URL',
                          ),
                        );
                      });
                    },
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
                child: ListView.separated(
                  itemCount: attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => AttachmentRow(
                    attachment: attachments[i],
                    onRemove: () => setState(() => attachments.removeAt(i)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Note',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
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
          child: TextField(
            controller: controller,
            maxLines: maxLines,
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
