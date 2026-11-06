// lib/ui/calendar/widgets/day_snap_scroll_physics.dart
import 'package:flutter/widgets.dart';

/// Horizontal planner physics: a fling keeps its natural momentum, but always
/// comes to rest exactly on a day boundary, and moves at most [daysShowed]
/// days, so a hard fling never skips far.
class DaySnapScrollPhysics extends ScrollPhysics {
  const DaySnapScrollPhysics({required this.daysShowed, super.parent});

  final int daysShowed;

  @override
  DaySnapScrollPhysics applyTo(ScrollPhysics? ancestor) => DaySnapScrollPhysics(
      daysShowed: daysShowed, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // Overscroll at the ends: let the parent bounce back.
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    final dayWidth = position.viewportDimension / daysShowed;
    final startDay = (position.pixels / dayWidth).round();

    // Where the parent's momentum would stop, rounded to a day,
    // limited to one screen of days from where the drag ended.
    final natural = super
            .createBallisticSimulation(position, velocity)
            ?.x(double.infinity) ??
        position.pixels;
    final targetDay = (natural / dayWidth)
        .round()
        .clamp(startDay - daysShowed, startDay + daysShowed);
    final target = (targetDay * dayWidth)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    final tolerance = toleranceFor(position);
    if ((target - position.pixels).abs() < tolerance.distance) return null;

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
