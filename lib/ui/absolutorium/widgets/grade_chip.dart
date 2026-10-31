import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';

class GradeChip extends StatelessWidget {
  const GradeChip({super.key, required this.grade, required this.selected, required this.onTap, this.emptyLabel});

  final int? grade;
  final bool selected;
  final VoidCallback onTap;

  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = grade == null;
    final shape = RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(AppRadius.lg));

    return Semantics(
      button: true,
      selected: selected,
      label: grade == null ? (emptyLabel ?? 'Aláírás') : 'Jegy: $grade',
      child: Material(
        color: selected ? itkPrimary : scheme.surfaceContainerHighest,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: SizedBox(
            height: 48,
            width: isWide ? 96 : 48,
            child: Center(
              child: Text(
                grade == null ? (emptyLabel ?? gradeLabel(null)) : gradeLabel(grade),
                style: TextStyle(
                  fontSize: isWide ? 14 : 18,
                  fontWeight: FontWeight.w700,
                  color: selected ? itkDark : scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}