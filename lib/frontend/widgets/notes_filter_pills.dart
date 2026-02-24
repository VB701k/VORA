import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotesFilterPills extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<String>? onChanged;

  const NotesFilterPills({super.key, required this.filters, this.onChanged});

  @override
  State<NotesFilterPills> createState() => _NotesFilterPillsState();
}

class _NotesFilterPillsState extends State<NotesFilterPills> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == selected;
          return GestureDetector(
            onTap: () {
              setState(() => selected = index);
              widget.onChanged?.call(widget.filters[index]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                widget.filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
