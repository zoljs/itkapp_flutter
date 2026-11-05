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
import 'package:itk_app/ui/core/widgets/app_search_field.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/events/add_event_screen.dart';
import 'package:itk_app/ui/events/viewmodels/events_viewmodel.dart';
import 'package:itk_app/ui/events/widgets/event_filter_chips.dart';
import 'package:itk_app/ui/events/widgets/event_list_card.dart';
import 'package:itk_app/ui/events/widgets/events_header_background.dart';
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

  double _searchAreaHeight(bool showChips) =>
      AppSpacing.md * 2 +
      AppSpacing.searchFieldHeight +
      (showChips ? AppSpacing.md + AppSpacing.chipHeight : 0);

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

  Widget _buildHeader(BuildContext context, {required bool asFab}) {
    final scheme = Theme.of(context).colorScheme;
    final showChips = _viewModel.hasMySubjects || _viewModel.types.length > 1;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 320,
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      title: Text(widget.title),
      leading: buildBrandLeading(context),
      leadingWidth: AppSpacing.minimumAndroid + 2 * AppSpacing.sm,
      actionsPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      actions: [
        if (_viewModel.canModerate && !asFab)
          buildBrandAction(
            actionIcon: Icons.add_rounded,
            label: 'Új ${widget.eventLabel} felvétele',
            onAction: () => _openAddEvent(),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background:
            EventsHeaderBackground(bottomInset: _searchAreaHeight(showChips)),
      ),
      bottom: _buildSearch(showChips),
    );
  }

  PreferredSizeWidget _buildSearch(bool showChips) {
    final scheme = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: Size.fromHeight(_searchAreaHeight(showChips)),
      child: Container(
        height: _searchAreaHeight(showChips),
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
              searchController: _searchController,
              onChanged: _viewModel.setQuery,
              hintText: 'Tárgy neve vagy kódja...',
            ),
            if (showChips) ...[
              const SizedBox(height: AppSpacing.md),
              EventFilterChips(
                showMySubjects: _viewModel.hasMySubjects,
                onlyMySubjects: _viewModel.onlyMySubjects,
                onMySubjectsSelected: _viewModel.setOnlyMySubjects,
                types: _viewModel.types,
                selectedTypes: _viewModel.selectedTypes,
                onTypeSelected: _viewModel.setTypeSelected,
              ),
            ],
          ],
        ),
      ),
    );
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
                _buildHeader(context, asFab: asFab),
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
