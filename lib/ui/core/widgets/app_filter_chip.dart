import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
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
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: scheme.surfaceContainer,
      selectedColor: itkPrimary,
      checkmarkColor: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      onSelected: onSelected,
      side: BorderSide.none,
      selected: selected,
      label: Text(
        label,
        style: TextStyle(color: selected ? Colors.black87 : scheme.onSurface),
      ),
    );
  }
}
