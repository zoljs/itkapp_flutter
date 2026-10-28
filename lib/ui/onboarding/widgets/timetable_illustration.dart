import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

typedef _DemoEvent = ({String time, String title, String place, bool isMidterm});

class TimetableIllustration extends StatelessWidget {
  const TimetableIllustration({super.key});

  static const List<_DemoEvent> _events = [
    (time: '08:15', title: 'Analízis I.', place: 'ITK Simonyi ea.', isMidterm: false),
    (time: '10:15', title: 'Operációs rendszerek', place: 'ITK 220', isMidterm: false),
    (time: '12:15', title: 'Database ', place: 'ITK 322', isMidterm: true),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ma',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (i, event) in _events.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _EventRow(event: event).animate(delay: (250 * i).ms).fadeIn(duration: 300.ms).slideX(begin: 0.15, duration: 300.ms, curve: Curves.easeOut),
          ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final _DemoEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = event.isMidterm ? scheme.errorContainer : scheme.primaryContainer;
    final foreground = event.isMidterm ? scheme.onErrorContainer : scheme.onPrimaryContainer;

    Widget block = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, color: foreground),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(event.place, style: TextStyle(fontSize: 12, color: foreground)),
        ],
      ),
    );

    if (event.isMidterm) {
      block = block.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.04, duration: 900.ms, curve: Curves.easeInOut);
    }

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            event.time,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
        Expanded(child: block),
      ],
    );
  }
}
