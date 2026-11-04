import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/widgets/swipe_to_delete.dart';
import 'package:itk_app/ui/events/widgets/event_card.dart';

class EventListCard extends StatelessWidget {
  const EventListCard({
    super.key,
    required this.event,
    required this.onDelete,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.deletable,
  });

  final Event event;
  final VoidCallback onDelete;
  final String confirmTitle;
  final String confirmMessage;
  final bool deletable;

  @override
  Widget build(BuildContext context) {
    final card = EventCard(event: event);

    final content = deletable
        ? SwipeToDelete(
            id: event.id,
            confirmTitle: confirmTitle,
            confirmMessage: confirmMessage,
            onDelete: onDelete,
            child: card,
          )
        : card;

    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: content,
    );
  }
}
