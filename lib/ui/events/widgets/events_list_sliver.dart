import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/events/widgets/event_list_card.dart';
import 'package:itk_app/utils/string_extensions.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EventsListSliver extends StatelessWidget {
  const EventsListSliver({
    super.key,
    required this.events,
    required this.loading,
    required this.query,
    required this.loadError,
    required this.subjectFilterActive,
    required this.eventLabel,
    required this.canDelete,
    required this.onRetry,
    required this.onDelete,
    required this.timeRangeActive,
  });

  final List<Event> events;
  final bool loading;
  final String query; // already trimmed
  final String? loadError;
  final bool subjectFilterActive;
  final String eventLabel;
  final bool canDelete;
  final VoidCallback onRetry;
  final Future<void> Function(Event event) onDelete;
  final bool timeRangeActive;

  List<Event> get _skeletonItems => List.generate(
        4,
        (i) => Event(
          id: -i - 1,
          startsAt: DateTime.now().add(const Duration(days: 2)),
          location: BoneMock.words(2),
          subject: Subject(
            id: -1,
            code: BoneMock.words(1),
            name: BoneMock.name,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final items = loading ? _skeletonItems : events;

    if (!loading && items.isEmpty) {
      final scope = switch ((
        subjectFilterActive,
        timeRangeActive,
      )) {
        (true, true) => ' a tárgyaidból a kiválasztott időszakban',
        (true, false) => ' a tárgyaidból',
        (false, true) => ' a kiválasztott időszakban',
        (false, false) => '',
      };

      final (icon, message) = switch ((
        loadError,
        query.isEmpty,
      )) {
        (final String error, _) => (Icons.cloud_off_rounded, error),
        (null, false) => (
            Icons.search_off_rounded,
            'Nincs találat erre: „$query”'
          ),
        (null, true) => (
            Icons.event_available_rounded,
            'Nincs közelgő $eventLabel$scope.'
          ),
      };
      return SliverStateMessage(
        icon: icon,
        message: message,
        onRetry: loadError == null ? null : onRetry,
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + 120,
      ),
      sliver: Skeletonizer.sliver(
        enabled: loading,
        child: SliverList.separated(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final event = items[index];
            return EventListCard(
              confirmTitle: '$eventLabel törlése'.capitalize(),
              confirmMessage:
                  'A $eventLabel időpont mindenki számára törlődik. (${event.subject.name})',
              event: event,
              deletable: canDelete && !loading,
              onDelete: () => onDelete(event),
            );
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
        ),
      ),
    );
  }
}
