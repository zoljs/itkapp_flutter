import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/midterms/add_midterms_screen.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MidtermsScreen extends StatefulWidget {
  const MidtermsScreen({super.key});

  @override
  State<MidtermsScreen> createState() => _MidtermsScreenState();
}

class _MidtermsScreenState extends State<MidtermsScreen> {
  final bool _canModerate =
      AuthService.instance.cachedUser?.canModerateMidterms ?? false;
  final _searchController = TextEditingController();

  List<MidtermDate> _midterms = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    //await Completer().future;
    setState(() {
      _error = null;
      if (_midterms.isEmpty) _loading = true;
    });

    final result = await MidtermsService.instance.getMidterms();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _midterms = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  List<MidtermDate> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _midterms;
    return _midterms
        .where((m) =>
            m.subject.name.toLowerCase().contains(q) ||
            m.subject.code.toLowerCase().contains(q) ||
            (m.location?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  String get _todayLabel {
    final n = DateTime.now();
    return '${toBeginningOfSentenceCase(DateFormat('EEEE', 'hu').format(n))}, ${DateFormat('MMM d.', 'hu').format(n)}';
  }

  List<MidtermDate> get _skeletonItems => List.generate(
        4,
        (i) => MidtermDate(
          id: -i - 1,
          startsAt: DateTime.now().add(Duration(days: i * 3)),
          location: BoneMock.words(2),
          subject: Subject(
            id: -1,
            code: BoneMock.words(1),
            name: BoneMock.name,
          ),
        ),
      );

  Future<void> _openAddMidterm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMidtermScreen()),
    );
    _load();
  }

  Future<bool> _confirmAndDelete(MidtermDate m) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'ZH törlése',
      message: 'A ZH időpont mindenki számára törlődik. (${m.subject.name})',
      confirmLabel: 'Törlés',
      isDestructive: true,
    );
    if (confirmed != true) return false;

    final result =
        await MidtermsService.instance.deleteMidterm(midtermId: m.id);
    if (!mounted) return false;

    switch (result) {
      case Ok():
        return true;
      case Err(:final message):
        context.showMessage(message);
        return false;
    }
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 260,
      collapsedHeight: 66,
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      title: const Text('ZH-k'),
      actions: [
        if (_canModerate)
          IconButton(
            tooltip: 'Új ZH',
            icon: const Icon(Icons.add_rounded),
            onPressed: _openAddMidterm,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: scheme.primaryContainer),
            CustomPaint(
              painter: _CirclesPainter([
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
                  const _WeekStrip(),
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
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: 'Tárgy neve vagy kódja...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(_searchController.clear),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(MidtermDate m) {
    final card = _MidtermCard(midterm: m);
    if (!_canModerate || _loading) return card;

    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(Icons.delete_rounded, color: scheme.onError),
      ),
      confirmDismiss: (_) => _confirmAndDelete(m),
      onDismissed: (_) => setState(() {
        _midterms = _midterms.where((x) => x.id != m.id).toList();
      }),
      child: card,
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
    if (!_loading && _error != null) {
      return _buildMessage(Icons.cloud_off_rounded, _error!, onRetry: _load);
    }

    final items = _loading ? _skeletonItems : _filtered;
    final query = _searchController.text.trim();

    if (!_loading && items.isEmpty) {
      return query.isEmpty
          ? _buildMessage(Icons.event_available_rounded, 'Nincs közelgő ZH.')
          : _buildMessage(
              Icons.search_off_rounded, 'Nincs találat erre: „$query”');
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + 120,
      ),
      sliver: Skeletonizer.sliver(
        enabled: _loading,
        child: SliverList.separated(
          itemCount: items.length,
          itemBuilder: (context, index) => _buildCard(items[index]),
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildHeader(context),
            _buildListSliver(context),
          ],
        ),
      ),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  _CirclesPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final circles = [
      (Offset(w * 0.0, h * 0.55), w * 0.55, colors[0]),
      (Offset(w * 0.95, h * 0.05), w * 0.45, colors[1]),
      (Offset(w * 0.75, h * 1.05), w * 0.50, colors[2]),
    ];
    for (final (center, radius, color) in circles) {
      canvas.drawCircle(center, radius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_CirclesPainter old) => !listEquals(old.colors, colors);
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      children: List.generate(7, (i) {
        final day = DateUtils.addDaysToDate(weekStart, i);
        final isToday = day == today;

        return Expanded(
          child: Column(
            children: [
              Container(
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday
                      ? scheme.onPrimary
                      : scheme.onPrimary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MidtermCard extends StatelessWidget {
  const _MidtermCard({required this.midterm});

  final MidtermDate midterm;

  String _whenLabel(BuildContext context, DateTime local) {
    final today = DateUtils.dateOnly(DateTime.now());
    final diff = DateUtils.dateOnly(local).difference(today).inDays;
    return switch (diff) {
      0 => 'MA',
      1 => 'HOLNAP',
      < 7 => '$diff NAP MÚLVA',
      _ =>
        MaterialLocalizations.of(context).formatMediumDate(local).toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final local = midterm.startsAt.toLocal();
    final today = DateUtils.dateOnly(DateTime.now());
    final isSoon = DateUtils.dateOnly(local).difference(today).inDays <= 1;

    final background =
        isSoon ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final foreground = isSoon ? scheme.onPrimaryContainer : scheme.onSurface;
    final muted = isSoon
        ? scheme.onPrimaryContainer.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;

    final subtitle = [
      midterm.subject.code,
      if (midterm.location != null) midterm.location!,
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _whenLabel(context, local),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: muted,
                  ),
                ),
              ),
              Text(
                TimeOfDay.fromDateTime(local).format(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            midterm.subject.name,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
        ],
      ),
    );
  }
}
