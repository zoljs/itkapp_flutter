import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/platform_appbar.dart';
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

  List<MidtermDate> _midterms = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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

  Future<void> _openAddMidterm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMidtermScreen()),
    );
    _load();
  }

  /// HIG: destruktív művelet megerősítése action sheettel (iOS),
  /// máshol a meglévő confirm dialógus.
  Future<bool> _confirmDelete(MidtermDate m) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final bool? confirmed;
    if (isIOS) {
      confirmed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(m.subject.name),
          message: const Text('A ZH időpont mindenki számára törlődik.'),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ZH törlése'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
        ),
      );
    } else {
      confirmed = await showConfirmDialog(
        context,
        title: 'ZH törlése',
        message: 'A ZH időpont mindenki számára törlődik. (${m.subject.name})',
        confirmLabel: 'Törlés',
        isDestructive: true,
      );
    }
    return confirmed == true;
  }

  /// true → a sor eltűnhet, false → visszaugrik a helyére.
  Future<bool> _confirmAndDelete(MidtermDate m) async {
    if (!await _confirmDelete(m)) return false;

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

  // ---------- Segédek ----------

  Map<DateTime, List<MidtermDate>> _groupByDay(List<MidtermDate> list) {
    final groups = <DateTime, List<MidtermDate>>{};
    for (final m in list) {
      final day = DateUtils.dateOnly(m.startsAt.toLocal());
      (groups[day] ??= []).add(m);
    }
    return groups;
  }

  String _relativeDay(DateTime d) {
    final today = DateUtils.dateOnly(DateTime.now());
    final diff = DateUtils.dateOnly(d.toLocal()).difference(today).inDays;
    return switch (diff) {
      0 => 'Ma',
      1 => 'Holnap',
      _ => '$diff nap múlva',
    };
  }

  List<MidtermDate> get _skeletonItems => List.generate(
        4,
        (i) => MidtermDate(
          id: -i - 1,
          startsAt: DateTime.now().add(Duration(days: i ~/ 2)),
          location: BoneMock.words(2),
          subject: Subject(
            id: -1,
            code: BoneMock.words(1),
            name: BoneMock.name,
          ),
        ),
      );

  // ---------- UI ----------

  Widget _buildNextCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final next = _midterms.isEmpty ? null : _midterms.first;

    final Widget content;
    if (_loading) {
      content = const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    } else if (next == null) {
      content = Text(
        'Nincs közelgő ZH',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      );
    } else {
      final time =
          TimeOfDay.fromDateTime(next.startsAt.toLocal()).format(context);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'KÖVETKEZŐ ZH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            next.subject.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [
              '${_relativeDay(next.startsAt)}, $time',
              if (next.location != null) next.location!,
            ].join(' · '),
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: content,
    );
  }

  Widget _buildRow(MidtermDate m) {
    final tile = _MidtermTile(midterm: m);
    if (!_canModerate || _loading) return tile;

    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(Icons.delete_rounded, color: scheme.onError),
      ),
      confirmDismiss: (_) => _confirmAndDelete(m),
      onDismissed: (_) => setState(() {
        _midterms = _midterms.where((x) => x.id != m.id).toList();
      }),
      child: tile,
    );
  }

  Widget _buildListSliver(BuildContext context) {
    if (!_loading && _error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
            MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
          ),
          child: StateMessage(
            icon: Icons.cloud_off_rounded,
            message: _error!,
            onRetry: _load,
          ),
        ),
      );
    }

    final localizations = MaterialLocalizations.of(context);
    final items = _loading ? _skeletonItems : _midterms;
    final groups = _groupByDay(items);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.bottomNavClearance,
      ),
      sliver: Skeletonizer.sliver(
        enabled: _loading,
        child: SliverList.list(
          children: [
            for (final entry in groups.entries)
              SettingsGroup(
                header: localizations.formatFullDate(entry.key),
                children: [for (final m in entry.value) _buildRow(m)],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            ShrinkingSliverAppBar(
              middleValue: .8,
              title: Text(
                'ZH időpontok',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.merge(topBarTitleStyle),
              ),
              actions: [
                if (_canModerate)
                  IconButton(
                    tooltip: 'Új ZH',
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _openAddMidterm,
                  ),
              ],
              centeredWidget: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: _buildNextCard(context),
              ),
            ),
            _buildListSliver(context),
          ],
        ),
      ),
    );
  }
}

/// A SettingsTile tipográfiáját követi, alcímmel kiegészítve.
class _MidtermTile extends StatelessWidget {
  const _MidtermTile({required this.midterm});

  final MidtermDate midterm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time =
        TimeOfDay.fromDateTime(midterm.startsAt.toLocal()).format(context);
    final subtitle = [
      midterm.subject.code,
      if (midterm.location != null) midterm.location!,
    ].join(' · ');

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    midterm.subject.name,
                    style: TextStyle(fontSize: 15, color: scheme.onSurface),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              time,
              style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
