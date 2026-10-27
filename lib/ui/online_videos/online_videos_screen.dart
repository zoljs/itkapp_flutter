import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/videos_repository.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:itk_app/domain/models/online_video.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class OnlineVideosScreen extends StatefulWidget {
  const OnlineVideosScreen({super.key, this.title = 'Online videók'});

  final String title;

  @override
  State<OnlineVideosScreen> createState() => _OnlineVideosScreenState();
}

class _OnlineVideosScreenState extends State<OnlineVideosScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  String? _semester;
  String? _subject;

  VideoFilters _filters = VideoFilters.empty;
  final List<OnlineVideo> _videos = [];
  int _total = 0;

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload({bool forceReload = false}) async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
    });

    try {
      final results = await Future.wait([
        context.read<VideosRepository>().getFilters(
              semester: _semester,
              subject: _subject,
              forceReload: forceReload,
            ),
        context.read<VideosRepository>().getVideos(
              semester: _semester,
              subject: _subject,
              query: _searchController.text,
            ),
      ]);
      if (!mounted || id != _requestId) return;

      final page = results[1] as VideoPage;
      setState(() {
        _filters = results[0] as VideoFilters;
        _videos
          ..clear()
          ..addAll(page.items);
        _total = page.total;
        _loading = false;
      });
    } on DioException {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = 'Nem sikerült betölteni a videókat.';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _error != null) return;
    if (_videos.length >= _total) return;

    final id = _requestId;
    setState(() => _loadingMore = true);

    try {
      final page = await context.read<VideosRepository>().getVideos(
            semester: _semester,
            subject: _subject,
            query: _searchController.text,
            offset: _videos.length,
          );
      if (!mounted || id != _requestId) return;
      setState(() {
        _videos.addAll(page.items);
        _total = page.total;
        _loadingMore = false;
      });
    } on DioException {
      if (!mounted || id != _requestId) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nem sikerült betölteni a további videókat.')));
    }
  }

  void _onSearchChanged(String _) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _reload);
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _reload();
  }

  void _selectSemester(String? key) {
    if (key == _semester) return;
    setState(() => _semester = key);
    _reload();
  }

  void _selectSubject(String? name) {
    if (name == _subject) return;
    setState(() => _subject = name);
    _reload();
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _semester = null;
      _subject = null;
    });
    _reload();
  }

  Future<void> _pickSubject() async {
    final choice = await showModalBottomSheet<(String?,)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _SubjectSheet(
        subjects: _filters.subjects,
        selected: _subject,
        semesterLabel: _semesterLabel(_semester),
      ),
    );
    if (choice != null) _selectSubject(choice.$1);
  }

  String? _semesterLabel(String? key) {
    if (key == null) return null;
    for (final s in _filters.semesters) {
      if (s.key == key) return s.label;
    }
    return key;
  }

  Future<void> _openVideo(OnlineVideo video) async {
    final uri = Uri.tryParse(video.url);
    final ok = uri != null &&
        uri.hasScheme &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nem sikerült megnyitni a videót.')));
    }
  }

  bool get _hasFilters =>
      _semester != null ||
      _subject != null ||
      _searchController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                canPop ? AppSpacing.xs : AppSpacing.screenHorizontal,
                1,
                AppSpacing.screenHorizontal,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (canPop) const BackButton(),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: textTheme.headlineSmall?.merge(topBarTitleStyle),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Videó címe, tárgy, feltöltő...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clearSearch,
                        ),
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: scheme.surface,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildList(context)),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _FilterBar(
                        semesters: _filters.semesters,
                        selectedSemester: _semester,
                        selectedSubject: _subject,
                        total: _loading ? null : _total,
                        onSemesterSelected: _selectSemester,
                        onSubjectTap: _pickSubject,
                        onSubjectCleared: () => _selectSubject(null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 600) _loadMore();
        return false;
      },
      child: RefreshIndicator(
        edgeOffset: _FilterBar.height,
        onRefresh: () => _reload(forceReload: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: _FilterBar.height),
            ),
            ..._buildContent(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    if (_error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.cloud_off_rounded,
            title: _error!,
            actionLabel: 'Újra',
            onAction: () => _reload(forceReload: true),
          ),
        ),
      ];
    }

    if (!_loading && _videos.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.video_library_outlined,
            title: 'Nincs találat',
            message: _hasFilters
                ? 'Próbálj másik félévet, tárgyat vagy keresést.'
                : 'Még nincsenek videók.',
            actionLabel: _hasFilters ? 'Szűrők törlése' : null,
            onAction: _hasFilters ? _clearFilters : null,
          ),
        ),
      ];
    }

    final entries = _loading ? _skeletonEntries : _groupEntries(_videos);

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          0,
        ),
        sliver: Skeletonizer.sliver(
          enabled: _loading,
          child: SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) => switch (entries[i]) {
              _HeaderEntry(:final subject, :final semesterLabel) =>
                _GroupHeader(subject: subject, semesterLabel: semesterLabel),
              _VideoEntry(:final video) => _VideoTile(
                  video: video,
                  onTap: _loading ? null : () => _openVideo(video),
                ),
            },
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: AppSpacing.bottomNavClearance,
        ),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: _loadingMore
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ];
  }

  static List<_Entry> _groupEntries(List<OnlineVideo> videos) {
    final entries = <_Entry>[];
    String? lastKey;
    for (final v in videos) {
      final key = '${v.semester}|${v.subject}';
      if (key != lastKey) {
        entries.add(_HeaderEntry(v.subject, v.semesterLabel));
        lastKey = key;
      }
      entries.add(_VideoEntry(v));
    }
    return entries;
  }

  static final List<_Entry> _skeletonEntries = [
    _HeaderEntry(BoneMock.words(3), BoneMock.words(2)),
    for (var i = 0; i < 6; i++)
      _VideoEntry(OnlineVideo(
        id: -i,
        semester: '',
        semesterLabel: '',
        subject: '',
        title: BoneMock.words(5),
        uploader: BoneMock.name,
        url: '',
      )),
  ];
}

sealed class _Entry {}

class _HeaderEntry extends _Entry {
  _HeaderEntry(this.subject, this.semesterLabel);
  final String subject;
  final String semesterLabel;
}

class _VideoEntry extends _Entry {
  _VideoEntry(this.video);
  final OnlineVideo video;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.semesters,
    required this.selectedSemester,
    required this.selectedSubject,
    required this.total,
    required this.onSemesterSelected,
    required this.onSubjectTap,
    required this.onSubjectCleared,
  });

  static const _chipRowHeight = 52.0;
  static const _subjectRowHeight = 44.0;
  static const _fadeHeight = 16.0;
  static const height = _chipRowHeight + _subjectRowHeight;

  final List<SemesterFacet> semesters;
  final String? selectedSemester;
  final String? selectedSubject;
  final int? total;
  final ValueChanged<String?> onSemesterSelected;
  final VoidCallback onSubjectTap;
  final VoidCallback onSubjectCleared;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const fullHeight = height + _fadeHeight;

    final options = <(String?, String)>[
      (null, 'Minden félév'),
      for (final s in semesters) (s.key, s.label),
      if (selectedSemester != null &&
          !semesters.any((s) => s.key == selectedSemester))
        (selectedSemester, selectedSemester!),
    ];

    return Container(
      height: fullHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.surface, scheme.surface.withValues(alpha: 0)],
          stops: const [height / fullHeight, 1],
        ),
      ),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(
            height: _chipRowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.sm,
              ),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final (key, label) = options[i];
                return _FilterChip(
                  icon: key == null
                      ? Icons.apps_rounded
                      : Icons.calendar_month_rounded,
                  label: label,
                  selected: key == selectedSemester,
                  onSelected: () => onSemesterSelected(key),
                );
              },
            ),
          ),
          SizedBox(
            height: _subjectRowHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  Flexible(
                    child: _SubjectButton(
                      subject: selectedSubject,
                      onTap: onSubjectTap,
                      onCleared: onSubjectCleared,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (total != null)
                    Text(
                      '$total videó',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: fg),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerHigh,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );
  }
}

class _SubjectButton extends StatelessWidget {
  const _SubjectButton({
    required this.subject,
    required this.onTap,
    required this.onCleared,
  });

  final String? subject;
  final VoidCallback onTap;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = subject != null;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.xxs, AppSpacing.xxs, AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 18, color: fg),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  subject ?? 'Minden tárgy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
              if (selected)
                Semantics(
                  button: true,
                  label: 'Tárgy törlése',
                  child: InkResponse(
                    onTap: onCleared,
                    radius: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(Icons.close_rounded, size: 18, color: fg),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.expand_more_rounded, size: 18, color: fg),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.subject, required this.semesterLabel});

  final String subject;
  final String semesterLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              subject,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            semesterLabel,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onTap});

  static const _thumbWidth = 128.0;

  final OnlineVideo video;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.play_circle_outline_rounded,
            size: 32, color: scheme.onSurfaceVariant),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: _thumbWidth,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: video.thumbnailUrl == null
                      ? placeholder
                      : Image.network(
                          video.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => placeholder,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : placeholder,
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (video.uploader != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      video.uploader!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.bottomNavClearance,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 56, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _SubjectSheet extends StatefulWidget {
  const _SubjectSheet({
    required this.subjects,
    required this.selected,
    required this.semesterLabel,
  });

  final List<SubjectFacet> subjects;
  final String? selected;
  final String? semesterLabel;

  @override
  State<_SubjectSheet> createState() => _SubjectSheetState();
}

class _SubjectSheetState extends State<_SubjectSheet> {
  final _controller = TextEditingController();

  static const _fold = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ö': 'o',
    'ő': 'o',
    'ú': 'u',
    'ü': 'u',
    'ű': 'u',
  };

  static String _normalize(String s) =>
      s.toLowerCase().split('').map((c) => _fold[c] ?? c).join();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final query = _normalize(_controller.text.trim());
    final visible = query.isEmpty
        ? widget.subjects
        : widget.subjects
            .where((s) => _normalize(s.name).contains(query))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal),
            child: Text(
              widget.semesterLabel == null
                  ? 'Tárgyak'
                  : 'Tárgyak · ${widget.semesterLabel}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Tárgy keresése...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                if (query.isEmpty)
                  _SubjectTile(
                    title: 'Minden tárgy',
                    selected: widget.selected == null,
                    onTap: () => Navigator.pop<(String?,)>(context, (null,)),
                  ),
                for (final s in visible)
                  _SubjectTile(
                    title: s.name,
                    count: s.count,
                    selected: s.name == widget.selected,
                    onTap: () => Navigator.pop<(String?,)>(context, (s.name,)),
                  ),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Text(
                      'Nincs ilyen tárgy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String title;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      selected: selected,
      selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: count == null
          ? (selected ? const Icon(Icons.check_rounded) : null)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                if (selected) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.check_rounded),
                ],
              ],
            ),
      onTap: onTap,
    );
  }
}
