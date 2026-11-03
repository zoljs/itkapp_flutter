import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/circles_painter.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/core/widgets/swipe_to_delete.dart';
import 'package:itk_app/ui/events/add_event_screen.dart';
import 'package:itk_app/ui/events/viewmodels/events_viewmodel.dart';
import 'package:itk_app/ui/events/widgets/event_card.dart';
import 'package:itk_app/ui/events/widgets/weekstrip.dart';
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
    _viewModel = EventsViewModel(eventRepository: context.read<EventRepository>(), authRepository: context.read<AuthRepository>(), types: widget.types);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String get _todayLabel {
    final n = DateTime.now();
    return '${toBeginningOfSentenceCase(DateFormat('EEEE', 'hu').format(n))}, ${DateFormat('MMM d.', 'hu').format(n)}';
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

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 260,
      collapsedHeight: AppSpacing.searchBarHeight,
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: scheme.primaryContainer),
            CustomPaint(
              painter: CirclesPainter([
                scheme.secondary.withValues(alpha: 0.55),
                itkDark.withValues(alpha: 0.44),
                itkPrimary.withValues(alpha: 0.66),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.searchBarHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _todayLabel,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const WeekStrip(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: _buildSearch(),
    );
  }

  PreferredSizeWidget _buildSearch() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          height: AppSpacing.searchFieldHeight,
          child: TextField(
            expands: true,
            minLines: null,
            maxLines: null,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            controller: _searchController,
            onChanged: _viewModel.setQuery,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: 'Tárgy neve vagy kódja...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.setQuery('');
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Event m) {
    final card = EventCard(event: m);

    final content = (!_viewModel.canModerate || _viewModel.initialLoading)
        ? card
        : SwipeToDelete(
            id: m.id,
            confirmTitle: '${widget.eventLabel} törlése'.capitalize(),
            confirmMessage: 'A ${widget.eventLabel} időpont mindenki számára törlődik. (${m.subject.name})',
            onDelete: () async {
              await _viewModel.delete.execute(m.id);
              if (!mounted) return;
              final error = _viewModel.delete.errorMessage;
              if (error != null) {
                context.showMessage(error);
              }
            },
            child: card,
          );

    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: content,
    );
  }

  Widget _buildMessage(IconData icon, String message, {VoidCallback? onRetry}) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: StateMessage(icon: icon, message: message, onRetry: onRetry),
      ),
    );
  }

  Widget _buildListSliver(BuildContext context) {
    if (!_viewModel.initialLoading && _viewModel.load.errorMessage != null) {
      return _buildMessage(
        Icons.cloud_off_rounded,
        _viewModel.load.errorMessage!,
        onRetry: () => _viewModel.load.execute(true),
      );
    }

    final items = _viewModel.initialLoading ? _skeletonItems : _viewModel.filteredEvents;
    final query = _viewModel.query.trim();

    if (!_viewModel.initialLoading && items.isEmpty) {
      return query.isEmpty ? _buildMessage(Icons.event_available_rounded, 'Nincs közelgő ${widget.eventLabel}.') : _buildMessage(Icons.search_off_rounded, 'Nincs találat erre: „$query”');
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + 120,
      ),
      sliver: Skeletonizer.sliver(
        enabled: _viewModel.initialLoading,
        child: SliverList.separated(
          itemCount: items.length,
          itemBuilder: (context, index) => _buildCard(items[index]),
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<ThemeRepository>().actionButtonAsFab,
      builder: (context, asFab, _) => ListenableBuilder(
          listenable: Listenable.merge([_viewModel, _viewModel.load]),
          builder: (context, _) {
            return Scaffold(
              body: RefreshIndicator.adaptive(
                onRefresh: () => _viewModel.load.execute(true),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _buildHeader(context, asFab: asFab),
                    _buildListSliver(context),
                  ],
                ),
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
