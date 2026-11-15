import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart' show AppRadius;
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.savedAt, this.color});
  final DateTime savedAt;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat('MMM d. HH:mm', 'hu').format(savedAt);

    return Container(
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        color: color ?? scheme.tertiaryContainer,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          Icon(Icons.cloud_off, color: scheme.onTertiaryContainer),
          Flexible(
            child: Text(
              'Offline. Utoljára frissítve: $date',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
