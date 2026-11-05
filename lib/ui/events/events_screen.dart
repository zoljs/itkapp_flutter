import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/events/add_event_screen.dart';
import 'package:itk_app/ui/events/viewmodels/events_viewmodel.dart';
import 'package:itk_app/ui/events/widgets/events_header.dart';
import 'package:itk_app/ui/events/widgets/events_list_sliver.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({
    super.key,
    required this.title,
    required this.types,
    required this.eventLabel,
  });

  final String title;
  final Set<EventType> types;
  final String eventLabel;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _searchController = TextEditingController();
  late final EventsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EventsViewModel(
        eventRepository: context.read<EventRepository>(),
        authRepository: context.read<AuthRepository>(),
        calendarRepository: context.read<CalendarRepository>(),
        types: widget.types);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAddEvent() async {
    await showAdaptiveSheet(
      context: context,
      builder: (context, controller) => AddEventScreen(
        scrollController: controller,
        types: widget.types,
        eventLabel: widget.eventLabel,
      ),
    );
    await _viewModel.load.execute(true);
  }

  Future<void> _deleteEvent(Event event) async {
    await _viewModel.delete.execute(event.id);
    if (!mounted) return;
    final error = _viewModel.delete.errorMessage;
    if (error != null) {
      context.showMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<ThemeRepository>().actionButtonAsFab,
      builder: (context, asFab, _) => ListenableBuilder(
          listenable: Listenable.merge([_viewModel, _viewModel.load]),
          builder: (context, _) {
            final customScrollView = CustomScrollView(
              slivers: [
                EventsHeader(
                  title: widget.title,
                  eventLabel: widget.eventLabel,
                  canModerate: _viewModel.canModerate && !asFab,
                  onAction: _openAddEvent,
                  showMySubjects: _viewModel.hasMySubjects,
                  types: _viewModel.types,
                  searchController: _searchController,
                  onQueryChanged: _viewModel.setQuery,
                  onlyMySubjects: _viewModel.onlyMySubjects,
                  onMySubjectsSelected: _viewModel.setOnlyMySubjects,
                  selectedTypes: _viewModel.selectedTypes,
                  onTypeSelected: _viewModel.setTypeSelected,
                  selectedTimeRange: _viewModel.selectedTimeRange,
                  onTimeRangeChanged: _viewModel.setSelectedTimeRange,
                ),
                if (isIOS)
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await _viewModel.load.execute(true);
                    },
                  ),
                EventsListSliver(
                  events: _viewModel.filteredEvents,
                  loading: _viewModel.initialLoading,
                  query: _viewModel.query.trim(),
                  loadError: _viewModel.load.errorMessage,
                  subjectFilterActive: _viewModel.isSubjectFilterActive,
                  eventLabel: widget.eventLabel,
                  canDelete: _viewModel.canModerate,
                  onRetry: () => _viewModel.load.execute(true),
                  onDelete: _deleteEvent,
                ),
              ],
            );
            return Scaffold(
              body: isIOS
                  ? customScrollView
                  : RefreshIndicator(
                      onRefresh: () => _viewModel.load.execute(true),
                      child: customScrollView,
                    ),
              floatingActionButton: _viewModel.canModerate && asFab
                  ? buildBrandFab(
                      icon: Icons.add_rounded,
                      semanticLabel: "Új ${widget.eventLabel} felvétele",
                      onPressed: _openAddEvent,
                    )
                  : null,
            );
          }),
    );
  }
}
