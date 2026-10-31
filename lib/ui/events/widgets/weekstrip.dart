import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      children: List.generate(7, (i) {
        final day = DateUtils.addDaysToDate(weekStart, i);
        final isToday = day == today;

        return Expanded(
          child: Column(
            children: [
              Container(
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? scheme.onPrimary : scheme.onPrimary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isToday ? scheme.primary : scheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
