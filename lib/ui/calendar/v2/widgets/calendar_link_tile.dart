import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

String _syncLabel(DateTime? syncedAt) {
  if (syncedAt == null) {
    return 'Még nincs szinkronizálva.';
  }
  return 'Utoljára szinkronizálva: ${DateFormat('MMM d. HH:mm', 'hu').format(syncedAt.toLocal())}';
}

class CalendarLinkTile extends StatelessWidget {
  const CalendarLinkTile({
    super.key,
    required this.link,
    required this.onDismissed,
    required this.confirmDismiss,
  });

  final CalendarLink link;
  final DismissDirectionCallback onDismissed;
  final ConfirmDismissCallback confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(link.id),
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(Icons.delete_rounded, color: scheme.onError),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.circle, size: 14, color: Colors.orange),
              ),
              const SizedBox(width: AppSpacing.md + 2),
              Expanded(
                child: Text(
                  link.name,
                  style: TextStyle(fontSize: 15, color: scheme.onSurface),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  _syncLabel(link.lastSyncedAt),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
