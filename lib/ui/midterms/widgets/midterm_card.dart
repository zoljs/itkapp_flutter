import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class MidtermCard extends StatelessWidget {
  const MidtermCard({super.key, required this.midterm});

  final MidtermDate midterm;

  String _whenLabel(BuildContext context, DateTime local) {
    final today = DateUtils.dateOnly(DateTime.now());
    final diff = DateUtils.dateOnly(local).difference(today).inDays;
    return switch (diff) {
      0 => 'MA',
      1 => 'HOLNAP',
      < 7 => '$diff NAP MÚLVA',
      _ => MaterialLocalizations.of(context).formatMediumDate(local).toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final local = midterm.startsAt.toLocal();
    final today = DateUtils.dateOnly(DateTime.now());
    final isSoon = DateUtils.dateOnly(local).difference(today).inDays <= 1;

    final background = isSoon ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final foreground = isSoon ? scheme.onPrimaryContainer : scheme.onSurface;
    final muted = isSoon ? scheme.onPrimaryContainer.withValues(alpha: 0.7) : scheme.onSurfaceVariant;

    final subtitle = [
      midterm.subject.code,
      if (midterm.location != null) midterm.location!,
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _whenLabel(context, local),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: muted,
                  ),
                ),
              ),
              Text(
                TimeOfDay.fromDateTime(local).format(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            midterm.subject.name,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
        ],
      ),
    );
  }
}
