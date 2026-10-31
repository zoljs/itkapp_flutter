import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/utils/semester.dart';

class CompletionDismissible extends StatelessWidget {
  const CompletionDismissible({
    super.key,
    required this.completionId,
    required this.name,
    required this.semester,
    required this.onDelete,
    required this.child,
  });

  final int? completionId;
  final String name;
  final String semester;
  final Future<void> Function(int completionId) onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final id = completionId;
    if (id == null) return child;

    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('completion-$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(Icons.delete_rounded, color: scheme.onError),
      ),
      confirmDismiss: (_) async =>
          await showConfirmDialog(
            context,
            title: 'Teljesítés törlése',
            message: '$name (${semesterLabel(semester)})',
            confirmLabel: 'Törlés',
            isDestructive: true,
          ) ==
          true,
      onDismissed: (_) async => onDelete(id),
      child: child,
    );
  }
}
