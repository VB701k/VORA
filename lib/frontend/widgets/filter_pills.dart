import 'package:flutter/material.dart';
import '../../frontend/theme/app_colors.dart';

class FilterPills extends StatefulWidget {
  final List<String> filters;
  final Function(int)? onFilterSelected;
  
  const FilterPills({super.key, this.filters = const ['All', 'Earned', 'In Progress', 'Rare'], this.onFilterSelected});

  @override
  State<FilterPills> createState() => _FilterPillsState();
}

class _FilterPillsState extends State<FilterPills> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
              widget.onFilterSelected?.call(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.card : AppColors.background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1),
              ),
              child: Text(
                widget.filters[index],
                style: TextStyle(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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