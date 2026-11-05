enum TimeRange {
  thisWeek('Ez a hét'),
  thisMonth('Ez a hónap');

  final String label;

  const TimeRange(this.label);

  bool contains(DateTime date, {required DateTime now}) {
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final (start, end) = switch (this) {
      TimeRange.thisWeek => (
          monday,
          DateTime(monday.year, monday.month, monday.day + 7),
        ),
      TimeRange.thisMonth => (
          DateTime(now.year, now.month),
          DateTime(now.year, now.month + 1),
        ),
    };
    return !date.isBefore(start) && date.isBefore(end);
  }
}
