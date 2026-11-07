import 'package:flutter/material.dart';
import 'package:hintful/hintful.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart'
    show
        CurrentHourIndicatorParam,
        DayParam,
        DaysHeaderParam,
        EventsController,
        EventsPlanner,
        EventsPlannerState,
        FullDayParam,
        OffTimeRange,
        OffTimesParam,
        PinchToZoomParameters,
        HorizontalArrowsParam;
import 'package:intl/intl.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:itk_app/ui/calendar/widgets/day_snap_scroll_physics.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/brand_icon_button.dart';

/// Time grid of the calendar: [span] days side by side, horizontally
/// scrollable, starting at [initialDate].
class CalendarPlanner extends StatelessWidget {
  const CalendarPlanner({
    super.key,
    required this.plannerKey,
    required this.controller,
    required this.span,
    required this.showAllDayBar,
    required this.initialDate,
    required this.onDayChange,
    required this.onSpanChanged,
    required this.days,
  });

  static const heightPerMinute = 1.0;

  /// Lets the screen call `jumpToDate` on the planner.
  final GlobalKey<EventsPlannerState> plannerKey;
  final EventsController controller;
  final CalendarSpan span;
  final bool showAllDayBar;
  final DateTime initialDate;
  final ValueChanged<CalendarSpan> onSpanChanged;
  final int days;

  /// First visible day after a horizontal scroll.
  final ValueChanged<DateTime> onDayChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom + AppSpacing.lg;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return EventsPlanner(
      key: plannerKey,
      controller: controller,
      daysShowed: days,
      initialDate: initialDate,
      heightPerMinute: heightPerMinute,

      // Cognitive ergonomics: multiple ways
      horizontalArrowsParam: HorizontalArrowsParam(
        leftIcon: Icons.chevron_left_rounded,
        rightIcon: Icons.chevron_right_rounded,
        visible: true,
        daysToJump: days,
        holdSpeed: 300,
      ),

      // Pinching
      pinchToZoomParam: const PinchToZoomParameters(
        pinchToZoom: true,
        pinchToZoomMinHeightPerMinute: 0.5,
        pinchToZoomMaxHeightPerMinute: 2.5,
        pinchToZoomSpeed: 1,
      ),

      // Start at 08:00
      initialVerticalScrollOffset: heightPerMinute * 60 * 8.0,

      // Day changing behavior
      onDayChange: onDayChange,
      automaticAdjustHorizontalScrollToDay: false,
      horizontalScrollPhysics: DaySnapScrollPhysics(
        daysShowed: days,
        parent: const BouncingScrollPhysics(),
      ),

      // Headers
      daysHeaderParam: DaysHeaderParam(
        topLeftCellBuilder: (day) {
          return HintTarget(
            focusShape: FocusShape.circle,
            focusPadding: -AppSpacing.md,
            id: 'calendar-viewchange',
            child: BrandIconButton(
              iconColor: scheme.onSurface,
              backgroundColor: Colors.transparent,
              icon: span.icon,
              onPressed: () => onSpanChanged(span.next()),
              semanticLabel: 'Nézet váltása',
            ),
          );
        },
        daysHeaderHeight: landscape ? 32.0 : 70.0,
        dayHeaderBuilder: (day, isToday) {
          return Flex(
            spacing: AppSpacing.sm,
            direction: landscape ? Axis.horizontal : Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(DateFormat('EEE', 'hu').format(day)),
              Container(
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: isToday
                      ? scheme.primaryContainer
                      : scheme.surfaceContainer,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                ),
                width: 48,
                height: 24,
                child: Text('${day.day}'),
              ),
            ],
          );
        },
        daysHeaderColor: scheme.surface,
        daysHeaderForegroundColor: scheme.onSurface,
      ),

      // Nighttime
      offTimesParam: OffTimesParam(
        offTimesAllDaysRanges: const [
          OffTimeRange(
              TimeOfDay(hour: 0, minute: 0), TimeOfDay(hour: 8, minute: 0)),
          OffTimeRange(
              TimeOfDay(hour: 20, minute: 0), TimeOfDay(hour: 24, minute: 0)),
        ],
        offTimesColor: scheme.surfaceContainerLow,
      ),

      // Daytime
      dayParam: DayParam(
        dayColor: scheme.surface,
        todayColor: span.days > 1
            ? scheme.primaryContainer.withValues(alpha: 0.25)
            : scheme.surface,
        dayEventBuilder: (event, height, width, heightPerMinute) =>
            CalendarEventTile(
          title: event.title ?? '',
          location: event.description,
          height: height,
          width: width,
        ),
        dayBottomPadding: bottomInset,
      ),

      // Full day events
      fullDayParam: FullDayParam(
        fullDayEventsBarVisibility: showAllDayBar,
        fullDayEventsBarLeftText: 'Egész nap',
        fullDayEventsBarHeight: 32,
        fullDayEventHeight: 24,
        fullDayEventBuilder: (event, width) =>
            CalendarAllDayTile(title: event.title ?? '', width: width),
      ),

      // Current hour line
      currentHourIndicatorParam:
          CurrentHourIndicatorParam(currentHourIndicatorColor: scheme.primary),
    );
  }
}

/// One event block in the planner. Its height follows the event length and
/// the pinch zoom, so the content is chosen to fit: two title lines and the
/// location when there is room, fewer lines when not, only the colored block
/// when not even one line fits.
class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({
    super.key,
    required this.title,
    required this.location,
    required this.height,
    required this.width,
  });

  static const titleSize = 13.0;
  static const locationSize = 11.0;

  final String title;
  final String? location;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scaler = MediaQuery.textScalerOf(context);
    final place = location;

    // Line heights at the current text scale (1.25 = default line height
    // of these fonts, with a little room).
    final titleLine = scaler.scale(titleSize) * 1.25;
    final locationLine = scaler.scale(locationSize) * 1.25;

    final verticalPadding = height >= titleLine + 8 ? 4.0 : 1.0;
    final available = height - 2 * verticalPadding;
    final placeText = (place != null && place.isNotEmpty) ? place : null;

    // What fits, from most to least content. Prefer one title line plus the
    // location over two title lines alone.
    final (titleLines, showPlace) = switch (available) {
      final a when a >= 2 * titleLine + locationLine => (2, true),
      final a when placeText != null && a >= titleLine + locationLine => (
          1,
          true
        ),
      final a when a >= 2 * titleLine => (2, false),
      final a when a >= titleLine => (1, false),
      _ => (0, false),
    };

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.hardEdge,
      child: titleLines == 0
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer,
                  ),
                  maxLines: titleLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showPlace && placeText != null)
                  Text(
                    placeText,
                    style: TextStyle(
                      fontSize: locationSize,
                      height: 1.2,
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
    );
  }
}

/// One event in the all-day bar above the time grid.
class CalendarAllDayTile extends StatelessWidget {
  const CalendarAllDayTile({
    super.key,
    required this.title,
    required this.width,
  });

  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSecondaryContainer,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
