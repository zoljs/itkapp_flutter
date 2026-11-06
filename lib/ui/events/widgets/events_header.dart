import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/app_search_field.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/events/widgets/event_filter_chips.dart';
import 'package:itk_app/ui/events/widgets/events_header_background.dart';
import 'package:itk_app/utils/time_range.dart';
import 'package:itk_app/utils/value_changed_two.dart';

class EventsHeader extends StatelessWidget {
  const EventsHeader({
    super.key,
    required this.title,
    required this.eventLabel,
    required this.canModerate,
    required this.onAction,
    required this.searchController,
    required this.onQueryChanged,
    required this.showMySubjects,
    required this.onlyMySubjects,
    required this.onMySubjectsSelected,
    required this.types,
    required this.selectedTypes,
    required this.onTypeSelected,
    this.selectedTimeRange,
    required this.onTimeRangeChanged,
  });

  final String title;
  final String eventLabel;
  final bool canModerate;
  final VoidCallback onAction;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final bool showMySubjects;
  final bool onlyMySubjects;
  final ValueChanged<bool> onMySubjectsSelected;
  final Set<EventType> types;
  final Set<EventType> selectedTypes;
  final ValueChangedOf<EventType, bool> onTypeSelected;
  final TimeRange? selectedTimeRange;
  final ValueChanged<TimeRange> onTimeRangeChanged;

  double get _searchAreaHeight =>
      AppSpacing.searchBarHeight + AppSpacing.md + AppSpacing.chipHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 320,
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      title: Text(title),
      leading: buildBrandLeading(context),
      leadingWidth: AppSpacing.leadingWidth,
      actionsPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      actions: [
        if (canModerate)
          buildBrandAction(
            actionIcon: Icons.add_rounded,
            label: 'Új $eventLabel felvétele',
            onAction: onAction,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: EventsHeaderBackground(bottomInset: _searchAreaHeight),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_searchAreaHeight),
        child: Container(
          height: _searchAreaHeight,
          color: scheme.surface,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSearchField(
                searchController: searchController,
                onChanged: onQueryChanged,
                hintText: 'Tárgy neve vagy kódja...',
              ),
              const SizedBox(height: AppSpacing.md),
              EventFilterChips(
                showMySubjects: showMySubjects,
                onlyMySubjects: onlyMySubjects,
                onMySubjectsSelected: onMySubjectsSelected,
                types: types,
                selectedTypes: selectedTypes,
                onTypeSelected: onTypeSelected,
                selectedTimeRange: selectedTimeRange,
                onTimeRangeChanged: onTimeRangeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
