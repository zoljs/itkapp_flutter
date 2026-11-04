import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';

class MySubjectsFilter extends StatelessWidget {
  const MySubjectsFilter({
    super.key,
    required this.onSelected,
    required this.selected,
    required this.label,
  });

  final ValueChanged<bool> onSelected;
  final bool selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FilterChip(
        shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        onSelected: onSelected,
        selected: selected,
        label: Text(label),
      ),
    );
  }
}
