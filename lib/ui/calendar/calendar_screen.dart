import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/data/services/calendar_service.dart';

import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/adaptive_date_picker.dart';
import 'package:itk_app/ui/core/widgets/brand_icon_button.dart';
import 'package:itk_app/utils/result.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _dayViewKey = GlobalKey<DayViewState<CalendarEvent>>();

  DateTime _visibleDate = DateTime.now();

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  //correct approach
  Future<void> _loadEvents({bool forceReload = false}) async {
    setState(() => _error = null);

    final result =
        await CalendarService.instance.getCalendar(forceReload: forceReload);
    if (!mounted) return;

    final List<CalendarEvent> events;
    switch (result) {
      case Ok(:final value):
        events = value;
      case Err(:final message):
        setState(() => _error = message);
        return;
    }

    final eventData = events.map((e) {
      final start = e.start.toLocal();
      final end = e.end.toLocal();
      final isInstant = end.isAtSameMomentAs(start);
      final displayEnd =
          isInstant ? start.add(const Duration(minutes: 15)) : end;

      return CalendarEventData<CalendarEvent>(
        date: start,
        startTime: start,
        endTime: displayEnd,
        title: e.title,
        event: e,
      );
    }).toList();

    if (!mounted) return;
    final controller =
        CalendarControllerProvider.of<CalendarEvent>(context).controller;

    controller.removeWhere((_) => true);
    controller.addAll(eventData);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isToday = DateUtils.isSameDay(_visibleDate, DateTime.now());

    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            DayView<CalendarEvent>(
              onPageChange: (date, page) {
                setState(() {
                  _visibleDate = date;
                });
              },
              safeAreaOption: const SafeAreaOption(bottom: false),
              key: _dayViewKey,
              heightPerMinute: 2,
              backgroundColor: scheme.surface,
              showHalfHours: true,
              startHour: 8,
              endHour: 24,
              hourIndicatorSettings: HourIndicatorSettings(
                color: scheme.outlineVariant,
                height: 0.8,
              ),
              halfHourIndicatorSettings: HourIndicatorSettings(
                color: scheme.outlineVariant,
                height: 0.4,
              ),

              // Day view title
              dayTitleBuilder: (date) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      1,
                      AppSpacing.screenHorizontal,
                      18),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      // [ ----- ]
                      Expanded(
                        child: Column(
                          spacing: AppSpacing.xxs,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toBeginningOfSentenceCase(
                                      DateFormat('EEEE', 'hu').format(date)) +
                                  (isToday ? ' · Ma' : ''),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: scheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM d.', 'hu').format(date),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.merge(topBarTitleStyle),
                            ),
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: TextStyle(
                                    fontSize: 12, color: scheme.error),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // [ ----- ]    [ ] [ ]
                      Row(
                        spacing: AppSpacing.sm,
                        children: [
                          BrandIconButton(
                            icon: Icons.refresh_rounded,
                            onPressed: () => _loadEvents(forceReload: true),
                            semanticLabel: 'Frissítés',
                          ),
                          BrandIconButton(
                              icon: Icons.calendar_month,
                              onPressed: () => _pickDate(date),
                              semanticLabel: 'Dátum választása'),
                        ],
                      ),
                    ],
                  ),
                );
              },

              // Timeline e.g. 08:30
              timeLineBuilder: (date) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4, left: 4),
                  child: Text(
                    DateFormat.Hm().format(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },

              // Event Tile
              eventTileBuilder: (date, events, boundary, start, end) {
                if (events.isEmpty) return const SizedBox.shrink();
                final myEvent = events.first.event as CalendarEvent;

                final effectiveHeight =
                    boundary.height < 24 ? 24.0 : boundary.height;

                return Container(
                  width: boundary.width,
                  height: effectiveHeight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        myEvent.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (myEvent.location != null &&
                          myEvent.location!.isNotEmpty)
                        Text(
                          myEvent.location!,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                );
              },

              // Event
              fullDayEventBuilder: (events, date) {
                if (events.isEmpty) return const SizedBox.shrink();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: events.map(
                    (e) {
                      final myEvent = e.event as CalendarEvent;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event_rounded,
                                size: 14, color: scheme.onSecondaryContainer),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                myEvent.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSecondaryContainer,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),

            // 'Ma' Button
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  ignoring: isToday,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black87.withValues(alpha: .3),
                      foregroundColor: scheme.onSurface,
                    ),
                    onPressed: _goToToday,
                    child: const Text(
                      'Ma',
                    ),
                  )
                      .animate(target: isToday ? 0 : 1)
                      .fadeIn(duration: 250.ms)
                      .slideY(
                        begin: .5,
                        end: 0,
                        duration: 250.ms,
                        curve: Curves.easeOut,
                      ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _goToToday() {
    _dayViewKey.currentState?.jumpToDate(DateTime.now());
  }

  Future<void> _pickDate(DateTime current) async {
    final now = DateTime.now();

    final picked = await showAdaptiveDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(2050, 12, 31),
    );

    if (picked != null) _dayViewKey.currentState?.jumpToDate(picked);
  }
}
