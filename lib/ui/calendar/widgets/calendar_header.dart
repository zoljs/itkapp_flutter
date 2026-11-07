import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';
import 'package:itk_app/ui/core/widgets/brand_icon_button.dart';
import 'package:itk_app/ui/core/widgets/rolling_text.dart';

/// Top of the calendar screen: visible date (or range), load error,
/// refresh and date picker buttons, and the day / 3 day switch.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.firstDay,
    required this.rollForward,
    required this.span,
    required this.showsToday,
    required this.errorMessage,
    required this.onRefresh,
    required this.onPickDate,
  });

  final DateTime firstDay;

  /// Direction of the title's odometer roll: `true` when [firstDay] moved
  /// to a later day.
  final bool rollForward;
  final CalendarSpan span;
  final bool showsToday;
  final String? errorMessage;

  /// `null` while a refresh is running.
  final VoidCallback? onRefresh;
  final VoidCallback onPickDate;

  /// "november 5." for one day, "november 5-7." or "okt. 30. - nov. 1."
  /// for several days.
  static String titleFor(DateTime firstDay, int days) {
    if (days <= 1) return DateFormat('MMM d.', 'hu').format(firstDay);
    final last =
        DateTime(firstDay.year, firstDay.month, firstDay.day + days - 1);
    if (last.month == firstDay.month) {
      return '${DateFormat('MMM d', 'hu').format(firstDay)}-${last.day}.';
    }
    final short = DateFormat('MMM d.', 'hu');
    return '${short.format(firstDay)} - ${short.format(last)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eyebrow = span.days == 1
        ? toBeginningOfSentenceCase(DateFormat('EEEE', 'hu').format(firstDay))
        : span.label;
    final message = errorMessage;

    return Container(
      color: scheme.primaryContainer,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 1,
          AppSpacing.screenHorizontal, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          /// Status bar + buttons
          Row(
            children: [
              Expanded(
                child: AppPressable(
                  showInk: false,
                  semanticLabel: 'Dátum választása',
                  color: Colors.transparent,
                  onTap: onPickDate,
                  child: Column(
                    spacing: AppSpacing.xxs,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow + (showsToday ? ' · Ma' : ''),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              scheme.onPrimaryContainer.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      RollingText(
                        titleFor(firstDay, span.days),
                        forward: rollForward,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.merge(topBarTitleStyle),
                      ),
                      if (message != null)
                        Text(
                          message,
                          style: TextStyle(fontSize: 12, color: scheme.error),
                        ),
                    ],
                  ),
                ),
              ),
              Row(
                spacing: AppSpacing.sm,
                children: [
                  BrandIconButton(
                    icon: Icons.link_rounded,
                    onPressed: () => context.push(Routes.calendarLinks),
                    semanticLabel: 'Naptárak kezelése',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
