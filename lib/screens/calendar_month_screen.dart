import 'package:calendar_view/calendar_view.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/calendar_service.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy;

class CalendarScreenMonth extends StatefulWidget {
  const CalendarScreenMonth({super.key});

  @override
  State<CalendarScreenMonth> createState() => _CalendarScreenMonthState();
}

class _CalendarScreenMonthState extends State<CalendarScreenMonth> {
  final _monthViewKey = GlobalKey<MonthViewState<CalendarEvent>>();
  List<CalendarEventData<CalendarEvent>> _lastLoadedEventData = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents({bool forceReload = false}) async {
    final events =
        await CalendarService.instance.getCalendar(forceReload: forceReload);
    final eventData = events
        .map((e) => CalendarEventData<CalendarEvent>(
              date: e.start,
              startTime: e.start,
              endTime: e.end,
              title: e.title,
              event: e,
            ))
        .toList();

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: SafeArea(
        // ignore: deprecated_member_use
        child: MaterialUiCompatibilityBridge(
          child: legacy.Material(
            child: MonthView<CalendarEvent>(
              key: _monthViewKey,
              monthViewStyle: const MonthViewStyle(
                cellAspectRatio: 0.75,
                showBorder: false,
                startDay: WeekDays.monday,
              ),
              monthViewThemeSettings: MonthViewThemeSettings(
                cellsInMonthTileColor: scheme.primary,
                cellsInMonthHighlightColor: scheme.primary,
                weekDayTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              monthViewBuilders: MonthViewBuilders(
                headerBuilder: (date) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal, 16, AppSpacing.sm, 16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_monthName(date.month)} ${date.year}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.merge(topBarTitleStyle),
                          ),
                        ),
                        SizedBox.square(
                          dimension: 40,
                          child: IconButton(
                            onPressed: () => _loadEvents(forceReload: true),
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: scheme.surfaceContainer,
                              foregroundColor: scheme.onSurface,
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () =>
                              _monthViewKey.currentState?.previousPage(),
                          icon: const Icon(Icons.chevron_left_rounded),
                          style: IconButton.styleFrom(
                            foregroundColor: scheme.onPrimaryContainer,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _monthViewKey.currentState?.nextPage(),
                          icon: const Icon(Icons.chevron_right_rounded),
                          style: IconButton.styleFrom(
                            foregroundColor: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                cellBuilder: (
                  date,
                  events,
                  isToday,
                  isInMonth,
                  hideDaysNotInMonth,
                ) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isToday ? scheme.primary : null,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? scheme.onPrimary
                                  : isInMonth
                                      ? scheme.onSurface
                                      : scheme.onSurfaceVariant
                                          .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: events.take(3).map((e) {
                              final myEvent = e.event as CalendarEvent;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  myEvent.title,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
