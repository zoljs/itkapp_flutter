import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/data/services/calendar_service.dart';

import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

import 'package:flutter/material.dart';

class CalendarScreenTest extends StatefulWidget {
  const CalendarScreenTest({super.key});

  @override
  State<CalendarScreenTest> createState() => _CalendarScreenTestState();
}

class _CalendarScreenTestState extends State<CalendarScreenTest> {
  final _dayViewKey = GlobalKey<DayViewState<CalendarEvent>>();
  List<CalendarEventData<CalendarEvent>> _lastLoadedEventData = [];
  DateTime _visibleDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents({bool forceReload = false}) async {
    final events =
        await CalendarService.instance.getCalendar(forceReload: forceReload);
    final eventData = events.map((e) {
      final isInstant = e.end.isAtSameMomentAs(e.start);
      final displayEnd =
          isInstant ? e.start.add(const Duration(minutes: 15)) : e.end;

      return CalendarEventData<CalendarEvent>(
        date: e.start,
        startTime: e.start,
        endTime: displayEnd,
        title: e.title,
        event: e,
      );
    }).toList();

    if (!mounted) return;
    final controller =
        CalendarControllerProvider.of<CalendarEvent>(context).controller;

    if (forceReload) {
      controller.removeAll(_lastLoadedEventData);
    }

    controller.addAll(eventData);
    _lastLoadedEventData = eventData;
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Már',
      'Ápr',
      'Máj',
      'Jún',
      'Júl',
      'Aug',
      'Szep',
      'Okt',
      'Nov',
      'Dec'
    ];
    return names[month - 1];
  }

  String _weekdayName(int weekday) {
    const names = [
      'Hétfő',
      'Kedd',
      'Szerda',
      'Csütörtök',
      'Péntek',
      'Szombat',
      'Vasárnap'
    ];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var isToday = DateUtils.isSameDay(_visibleDate, DateTime.now());

    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: SafeArea(
        bottom: false,
        // ignore: deprecated_member_use
        child: Stack(
          children: [
            Material(
              child: DayView<CalendarEvent>(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _weekdayName(date.weekday) +
                                    (isToday ? ' · Ma' : ''),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${date.day}. ${_monthName(date.month)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.merge(topBarTitleStyle),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.black87.withValues(alpha: .3),
                            foregroundColor: Colors.white70,
                          ),
                          constraints: BoxConstraints.tight(
                            const Size.square(AppSpacing.minimumAndroid),
                          ),
                          onPressed: () => _loadEvents(forceReload: true),
                          icon: const Icon(
                            Icons.refresh_rounded,
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.black87.withValues(alpha: .3),
                            foregroundColor: Colors.white70,
                          ),
                          constraints: BoxConstraints.tight(
                            const Size.square(AppSpacing.minimumAndroid),
                          ),
                          onPressed: () => _pickDate(date),
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                timeLineBuilder: (date) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4, left: 4),
                    child: Text(
                      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
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
            ),
            Positioned(
              bottom: 95,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  ignoring: isToday,
                  child: FilledButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black87.withValues(alpha: .3),
                      foregroundColor: Colors.white70,
                      disabledBackgroundColor:
                          Colors.black87.withValues(alpha: .15),
                      disabledForegroundColor: Colors.white38,
                    ),
                    onPressed: isToday ? null : _goToToday,
                    child: const Text(
                      'Ma',
                    ),
                  )
                      .animate(target: isToday ? 0 : 1)
                      .fadeIn(duration: 100.ms)
                      .slideY(
                        begin: .5,
                        end: 0,
                        duration: 300.ms,
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
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(2050, 12, 31),
    );

    if (picked != null) _dayViewKey.currentState?.jumpToDate(picked);
  }

  Future<DateTime?> showAdaptiveDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      return showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    }

    var selected = initialDate;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Kész'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: firstDate,
                maximumDate: lastDate,
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
