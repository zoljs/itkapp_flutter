import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/events/add_event_screen.dart';
import 'package:itk_app/ui/events/viewmodels/events_viewmodel.dart';
import 'package:itk_app/ui/events/widgets/event_list_card.dart';
import 'package:itk_app/ui/events/widgets/events_header.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  Widget _buildListSliver(BuildContext context) {
    final items =
        _viewModel.initialLoading ? _skeletonItems : _viewModel.filteredEvents;
    final query = _viewModel.query.trim();

    if (!_viewModel.initialLoading && items.isEmpty) {
      final (icon, message) = switch ((
        _viewModel.load.errorMessage,
        query.isEmpty,
        _viewModel.isSubjectFilterActive,
      )) {
        (final String error, _, _) => (Icons.cloud_off_rounded, error),
        (null, false, _) => (
            Icons.search_off_rounded,
            'Nincs találat erre: „$query”'
          ),
        (null, true, true) => (
            Icons.event_available_rounded,
            'Nincs közelgő ${widget.eventLabel} a tárgyaidból.'
          ),
        (null, true, false) => (
            Icons.event_available_rounded,
            'Nincs közelgő ${widget.eventLabel}.'
          ),
      };
      return SliverStateMessage(
        icon: icon,
        message: message,
        onRetry: _viewModel.load.errorMessage == null
            ? null
            : () => _viewModel.load.execute(true),
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
        enabled: _viewModel.initialLoading,
        child: SliverList.separated(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final event = items[index];
            return EventListCard(
              confirmTitle: '${widget.eventLabel} törlése'.capitalize(),
              confirmMessage:
                  'A ${widget.eventLabel} időpont mindenki számára törlődik. (${event.subject.name})',
              event: event,
              deletable: _viewModel.canModerate && !_viewModel.initialLoading,
              onDelete: () async {
                await _viewModel.delete.execute(event.id);
                if (!context.mounted) return;
                final error = _viewModel.delete.errorMessage;
                if (error != null) {
                  context.showMessage(error);
                }
              },
            );
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
        ),
      ),
    );
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
                ),
                if (isIOS)
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await _viewModel.load.execute(true);
                    },
                  ),
                _buildListSliver(context),
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
