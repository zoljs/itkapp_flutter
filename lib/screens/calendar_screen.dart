import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/calendar_service.dart';
import 'package:kalender/kalender.dart';
import 'package:material_ui/material_ui.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final eventsController = DefaultEventsController();
  final kalenderController = KalenderController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await CalendarService.instance.getCalendar('perpa4');
    for (final event in events) {
      eventsController.addEvent(event);
    }
  }

  @override
  void dispose() {
    kalenderController.dispose();
    eventsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;

    return Scaffold(
      // ignore: deprecated_member_use
      body: MaterialUiCompatibilityBridge(
        child: KalenderTheme(
          data: KalenderThemeData(
            dayNumberStyle: DayNumberStyle(
              todayBackgroundColor: Theme.of(context).colorScheme.primary,
              todayForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            weekDayHeaderStyle: WeekDayHeaderStyle(
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.7),
              ),
            ),
            dayHeaderStyle: DayHeaderStyle(
              textStyle: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.7),
              ),
              numberTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            hourLinesStyle: HourLinesStyle(
              color: Theme.of(context).colorScheme.outlineVariant,
              thickness: 0.5,
            ),
          ),
          child: KalenderView(
            components: KalenderComponents(
              multiDayComponents: MultiDayComponents(
                bodyComponents: MultiDayBodyComponents(
                  timeline: _buildHourOnlyTimeline,
                ),
              ),
            ),
            locale: const Locale('hu-HU'),
            eventsController: eventsController,
            kalenderController: kalenderController,
            viewConfiguration: MultiDayViewConfiguration.custom(
              initialTimeOfDay: const KalenderTime(hour: 8, minute: 0),
              numberOfDays: 1,
              initialHeightPerMinute: 1.8,
            ),
            header: Container(
              padding: EdgeInsets.only(top: safeAreaPadding.top),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
                  _calendarToolbar(),
                  const KalenderHeader(),
                ],
              ),
            ),
            body: KalenderBody(
              multiDayTileComponents: TileComponents(
                tileBuilder: (context, event, tileRange) {
                  final myEvent = event as CalendarEvent;
                  final scheme = Theme.of(context).colorScheme;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  size: 12,
                                  color: scheme.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    myEvent.location!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: scheme.onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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

  Widget _buildHourOnlyTimeline(
    BuildContext context,
    double heightPerMinute,
    KalenderTimeRange timeOfDayRange,
    ValueNotifier<KalenderEvent?> eventBeingDragged,
    ValueNotifier<KalenderDateTimeRange?> visibleDateTimeRange,
  ) {
    final segments = timeOfDayRange.splitIntoSegments(60);
    var offset = 0.0;
    final textStyle = Theme.of(context).textTheme.labelMedium;

    final labels = segments.indexed.map((e) {
      final (index, range) = e;
      final pos = offset;
      offset += range.duration.inMinutes * heightPerMinute;
      if (index == 0) return null;

      final hour = range.start.hour.toString().padLeft(2, '0');

      return Positioned(
        top: pos - 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$hour:00', style: textStyle),
        ),
      );
    });

    return SizedBox(
      width: 48,
      child: Stack(children: labels.nonNulls.toList()),
    );
  }

  Widget _calendarToolbar() {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
      child: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: kalenderController.floatingVisibleRange,
            builder: (context, value, child) {
              if (value == null) return const SizedBox.shrink();
              final localRange = value.forLocation();
              final month =
                  localRange.start.monthNameShortLocalized(const Locale("hu"));
              final year = localRange.start.year;

              return Text(
                '$month $year',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => kalenderController.animateToDate(DateTime.now()),
            style: TextButton.styleFrom(
              backgroundColor: scheme.onPrimary,
              foregroundColor: scheme.onPrimaryContainer,
            ),
            child: const Text("Ma"),
          ),
        ],
      ),
    );
  }
}
