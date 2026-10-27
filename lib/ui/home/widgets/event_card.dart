import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.e,
    required this.scheme,
    required this.day,
    required this.muted,
    required this.time,
  });

  final CalendarEvent e;
  final ColorScheme scheme;
  final String day;
  final TextStyle muted;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.Hm().format(e.start),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            Text(day, style: muted),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [time, if (e.location?.isNotEmpty ?? false) e.location!].join(' · '),
                style: muted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
