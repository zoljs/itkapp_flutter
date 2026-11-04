import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/app_filter_chip.dart';

class EventFilterChips extends StatelessWidget {
  const EventFilterChips({
    super.key,
    required this.showMySubjects,
    required this.onlyMySubjects,
    required this.onMySubjectsSelected,
    required this.types,
    required this.selectedTypes,
    required this.onTypeSelected,
  });

  final bool showMySubjects;
  final bool onlyMySubjects;
  final ValueChanged<bool> onMySubjectsSelected;

  /// Type chips are shown only when there is more than one type to choose from.
  final Set<EventType> types;
  final Set<EventType> selectedTypes;
  final void Function(EventType type, bool selected) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          if (showMySubjects)
            AppFilterChip(
              selected: onlyMySubjects,
              onSelected: onMySubjectsSelected,
              label: 'Tárgyaim',
            ),
          if (types.length > 1)
            for (final type in types)
              AppFilterChip(
                selected: selectedTypes.contains(type),
                onSelected: (selected) => onTypeSelected(type, selected),
                label: type.label,
              ),
        ],
      ),
    );
  }
}
