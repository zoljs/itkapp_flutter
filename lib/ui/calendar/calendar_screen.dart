import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart'
    show EventsPlannerState;
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_header.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_planner.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_date_picker.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarViewModel _viewModel;
  bool _rollForward = true;

  // One key per span: switching the span builds a fresh planner (it does not
  // react to a changed `daysShowed`), starting at the day that was visible.
  final _plannerKeys = {
    for (final span in CalendarSpan.values)
      for (final landscape in [false, true])
        (span, landscape): GlobalKey<EventsPlannerState>(),
  };

  DateTime _visibleDate = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _viewModel =
        CalendarViewModel(repository: context.read<CalendarRepository>());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  bool _showsToday(int days) {
    final today = DateUtils.dateOnly(DateTime.now());
    final end = DateTime(
        _visibleDate.year, _visibleDate.month, _visibleDate.day + days);
    return !today.isBefore(_visibleDate) && today.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      backgroundColor: landscape ? scheme.surface : scheme.primaryContainer,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final span = _viewModel.span;
            final days = _viewModel.visibleDays(landscape: landscape);
            final showsToday = _showsToday(days);

            final customScrollView = CustomScrollView(
              slivers: [
                if (isIOS)
                  CupertinoSliverRefreshControl(
                    onRefresh: () => _viewModel.load.execute(true),
                  ),
                SliverFillRemaining(
                  child: Column(
                    children: [
                      if (!landscape)
                        CalendarHeader(
                          firstDay: _visibleDate,
                          rollForward: _rollForward,
                          span: span,
                          showsToday: showsToday,
                          errorMessage: _viewModel.load.errorMessage,
                          onRefresh: _viewModel.load.running
                              ? null
                              : () => unawaited(_viewModel.load.execute(true)),
                          onPickDate: _pickDate,
                        ),
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: scheme.surface,
                            shape: RoundedSuperellipseBorder(
                              borderRadius: landscape
                                  ? BorderRadius.zero
                                  : const BorderRadius.vertical(
                                      top: Radius.circular(AppRadius.xxl),
                                    ),
                            ),
                          ),
                          child: CalendarPlanner(
                            onSpanChanged: _viewModel.setSpan,
                            onPickDate: _pickDate,
                            plannerKey: _plannerKeys[(span, landscape)]!,
                            controller: _viewModel.eventController,
                            span: span,
                            days: days,
                            showAllDayBar: _viewModel.hasAllDayEvents,
                            initialDate: _visibleDate,
                            onDayChange: _setVisibleDate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            return Stack(
              children: [
                isIOS
                    ? customScrollView
                    : RefreshIndicator(
                        onRefresh: () => _viewModel.load.execute(true),
                        child: customScrollView,
                      ),

                // 'Today' Button
                Positioned(
                  bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IgnorePointer(
                      ignoring: showsToday,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black87.withValues(alpha: .3),
                          foregroundColor: scheme.onSurface,
                        ),
                        onPressed: _goToToday,
                        child: const Text('Ma'),
                      )
                          .animate(target: showsToday ? 0 : 1)
                          .fadeIn(duration: 250.ms)
                          .slideY(
                            begin: .5,
                            end: 0,
                            duration: 250.ms,
                            curve: Curves.easeOut,
                          ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Stores the first visible day and the direction the header title rolls:
  /// up for a later day, down for an earlier one.
  void _setVisibleDate(DateTime date) {
    final day = DateUtils.dateOnly(date);
    if (day == _visibleDate) return;
    setState(() {
      _rollForward = day.isAfter(_visibleDate);
      _visibleDate = day;
    });
  }

  void _jumpTo(DateTime date) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final day = DateUtils.dateOnly(date);
    _plannerKeys[(_viewModel.span, landscape)]?.currentState?.jumpToDate(day);
    // jumpToDate does not call onDayChange.
    _setVisibleDate(day);
  }

  void _goToToday() => _jumpTo(DateTime.now());

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showAdaptiveDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(2050, 12, 31),
      initialDate: _visibleDate,
    );

    if (picked != null && mounted) _jumpTo(picked);
  }
}
