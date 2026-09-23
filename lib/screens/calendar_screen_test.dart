import 'package:calendar_view/calendar_view.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/calendar_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy;

class CalendarScreenTest extends StatefulWidget {
  const CalendarScreenTest({super.key});

  @override
  State<CalendarScreenTest> createState() => _CalendarScreenTestState();
}

class _CalendarScreenTestState extends State<CalendarScreenTest> {
  final _dayViewKey = GlobalKey<DayViewState<CalendarEvent>>();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await CalendarService.instance.getCalendar('perpa4');
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
    CalendarControllerProvider.of<CalendarEvent>(context)
        .controller
        .addAll(eventData);
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

    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      // ignore: deprecated_member_use
      body: SafeArea(
        child: MaterialUiCompatibilityBridge(
          child: legacy.Material(
            child: DayView<CalendarEvent>(
              key: _dayViewKey,
              heightPerMinute: 1.8,
              backgroundColor: scheme.surface,
              startHour: 8,
              hourIndicatorSettings: HourIndicatorSettings(
                color: scheme.outlineVariant,
                height: 0.8,
              ),
              dayTitleBuilder: (date) {
                final isToday = date.compareWithoutTime(DateTime.now());
                return legacy.Container(
                  padding: const legacy.EdgeInsets.fromLTRB(20, 16, 16, 20),
                  decoration: legacy.BoxDecoration(
                    color: scheme.primaryContainer,
                  ),
                  child: legacy.Row(
                    children: [
                      legacy.Expanded(
                        child: legacy.Column(
                          crossAxisAlignment: legacy.CrossAxisAlignment.start,
                          children: [
                            legacy.Text(
                              _weekdayName(date.weekday) +
                                  (isToday ? ' · Ma' : ''),
                              style: legacy.TextStyle(
                                fontSize: 13,
                                fontWeight: legacy.FontWeight.w600,
                                color: scheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const legacy.SizedBox(height: 2),
                            legacy.Text(
                              '${date.day}. ${_monthName(date.month)}',
                              style: legacy.TextStyle(
                                fontSize: 26,
                                fontWeight: legacy.FontWeight.w800,
                                color: scheme.onPrimaryContainer,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      legacy.Container(
                        padding: const legacy.EdgeInsets.all(4),
                        decoration: legacy.BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.5),
                          borderRadius: legacy.BorderRadius.circular(24),
                        ),
                        child: legacy.Row(
                          mainAxisSize: legacy.MainAxisSize.min,
                          children: [
                            legacy.IconButton(
                              onPressed: () =>
                                  _dayViewKey.currentState?.previousPage(),
                              icon: const legacy.Icon(
                                  legacy.Icons.chevron_left_rounded),
                              style: legacy.IconButton.styleFrom(
                                foregroundColor: scheme.onPrimaryContainer,
                                minimumSize: const legacy.Size(40, 40),
                              ),
                            ),
                            legacy.IconButton(
                              onPressed: () =>
                                  _dayViewKey.currentState?.nextPage(),
                              icon: const legacy.Icon(
                                  legacy.Icons.chevron_right_rounded),
                              style: legacy.IconButton.styleFrom(
                                foregroundColor: scheme.onPrimaryContainer,
                                minimumSize: const legacy.Size(40, 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const legacy.SizedBox(width: 8),
                      legacy.IconButton.filled(
                        onPressed: () => _dayViewKey.currentState
                            ?.animateToDate(DateTime.now()),
                        icon: const legacy.Icon(legacy.Icons.today_rounded,
                            size: 20),
                        style: legacy.IconButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          minimumSize: const legacy.Size(44, 44),
                          shape: const legacy.RoundedRectangleBorder(
                            borderRadius: legacy.BorderRadius.all(
                                legacy.Radius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              timeLineBuilder: (date) {
                return legacy.Padding(
                  padding: const legacy.EdgeInsets.only(right: 8),
                  child: legacy.Text(
                    '${date.hour.toString().padLeft(2, '0')}:00',
                    style: legacy.TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
              eventTileBuilder: (date, events, boundary, start, end) {
                if (events.isEmpty) return const legacy.SizedBox.shrink();
                final myEvent = events.first.event as CalendarEvent;

                return legacy.Container(
                  width: boundary.width,
                  height: boundary.height,
                  padding: const legacy.EdgeInsets.all(8),
                  decoration: legacy.BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: legacy.BorderRadius.circular(14),
                  ),
                  child: legacy.Column(
                    crossAxisAlignment: legacy.CrossAxisAlignment.start,
                    mainAxisSize: legacy.MainAxisSize.min,
                    children: [
                      legacy.Text(
                        myEvent.title,
                        style: legacy.TextStyle(
                          fontSize: 13,
                          fontWeight: legacy.FontWeight.w700,
                          color: scheme.onPrimaryContainer,
                        ),
                        maxLines: 1,
                        overflow: legacy.TextOverflow.ellipsis,
                      ),
                      if (myEvent.location != null &&
                          myEvent.location!.isNotEmpty)
                        legacy.Text(
                          myEvent.location!,
                          style: legacy.TextStyle(
                            fontSize: 11,
                            color: scheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                          overflow: legacy.TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
