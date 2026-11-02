import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/ui/absolutorium/add_completion_sheet.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/group_detail_viewmodel.dart';
import 'package:itk_app/ui/absolutorium/widgets/completion_dismissible.dart';
import 'package:itk_app/ui/absolutorium/widgets/progress_widgets.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/semester.dart';
import 'package:provider/provider.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late final GroupDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GroupDetailViewModel(repository: context.read<AbsolutoriumRepository>(), groupId: widget.groupId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAdd([MissingSubject? subject]) async {
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => AddCompletionSheet(scrollController: controller, initialSubject: subject),
    );
  }

  Future<void> _delete(int completionId) async {
    await _viewModel.delete.execute(completionId);
    if (!mounted) return;
    if (_viewModel.delete.errorMessage case final message?) context.showMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _viewModel.refresh]),
      builder: (context, _) {
        final group = _viewModel.group;
        final loading = group == null && _viewModel.refresh.running;

        return Scaffold(
          appBar: buildBrandAppBar(
            context: context,
            title: group?.name ?? 'Tárgycsoport',
            actionIcon: Icons.add_rounded,
            onAction: group == null ? null : _openAdd,
          ),
          body: loading
              ? const Center(child: AppSpinner())
              : group == null
                  ? StateMessage(
                      icon: Icons.info_outline_rounded,
                      message: _viewModel.refresh.errorMessage ?? 'Ez a csoport már nem része a tantervednek.',
                      onRetry: _viewModel.refresh.errorMessage == null ? null : _viewModel.refresh.execute,
                    )
                  : RefreshIndicator.adaptive(
                      onRefresh: _viewModel.refresh.execute,
                      child: _buildList(context, group),
                    ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, GroupProgress group) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xxxxl,
      ),
      children: [
        _GroupSummary(group: group),
        const SizedBox(height: AppSpacing.xxl),
        for (final s in group.subgroups)
          _SubgroupSection(
            subgroup: s,
            completed: _viewModel.visibleCompleted(s),
            onAddMissing: _openAdd,
            onDelete: _delete,
          ),
        if (_viewModel.hasCompleted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Teljesítés törléséhez húzd balra a sort.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.group});

  final GroupProgress group;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${group.countedCredits}',
                style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xxs),
                child: Text(
                  '/ ${group.requiredCredits} kredit',
                  style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
                ),
              ),
              const Spacer(),
              if (group.isComplete) const DoneBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CreditBar(value: group.countedCredits, max: group.requiredCredits, complete: group.isComplete, height: 10),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [
              '${group.completedSubgroupCount}/${group.requiredSubgroupCount} tárgycsoport kész',
              if (group.earnedCredits > group.countedCredits) '${group.earnedCredits} kr szerezve',
            ].join(' · '),
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SubgroupSection extends StatelessWidget {
  const _SubgroupSection({
    required this.subgroup,
    required this.completed,
    required this.onAddMissing,
    required this.onDelete,
  });

  final SubgroupProgress subgroup;

  final List<CompletedSubject> completed;
  final ValueChanged<MissingSubject> onAddMissing;
  final Future<void> Function(int completionId) onDelete;

  List<String> get _footerLines {
    final s = subgroup;
    return [
      if (s.overflowCredits > 0) '${s.overflowCredits} kr többlet átszámítva a szabadon választhatóba.',
      if (s.receivedOverflowCredits > 0) 'Ebből ${s.receivedOverflowCredits} kr többlet kötelezően választhatóból.',
      if (s.type == SubgroupType.freeElective) 'Ide számít minden saját tárgy és minden tantervi tárgy, ami máshová nem sorolható.',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = subgroup;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    final progressText = [
      if (s.requiredCredits > 0) '${s.earnedCredits}/${s.requiredCredits} kr',
      if (s.requiredCount != null) '${s.completedCount}/${s.requiredCount} tárgy',
      if (s.requiredCredits == 0 && s.requiredCount == null) '${s.earnedCredits} kr',
    ].join(' · ');

    final rows = <Widget>[
      for (final c in completed)
        CompletionDismissible(
          completionId: c.completionId,
          name: c.name,
          semester: c.semester,
          onDelete: onDelete,
          child: SubjectRow(
            name: c.name,
            code: c.code,
            credits: c.credits,
            done: true,
            subtitle: [
              semesterLabel(c.semester),
              gradeLabel(c.grade),
              if (c.isCustom) 'saját' else if (c.countedAsFreeElective) 'szabvál.-ként',
            ].join(' · '),
          ),
        ),
      for (final m in s.missing)
        SubjectRow(
          name: m.name,
          code: m.code,
          credits: m.credits,
          subtitle: m.recommendedSemester == null ? null : '${m.recommendedSemester}. félév',
          trailing: Icon(Icons.add_circle_outline_rounded, size: 22, color: scheme.primary),
          onTap: () => onAddMissing(m),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(s.name, style: muted.copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: AppSpacing.sm),
                TypeBadge(type: s.type),
              ],
            ),
          ),
          ClipRSuperellipse(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Material(
              color: scheme.surfaceContainerHigh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: CreditBar(
                            value: s.requiredCredits > 0 ? s.earnedCredits : s.completedCount,
                            max: s.requiredCredits > 0 ? s.requiredCredits : (s.requiredCount ?? 0),
                            complete: s.isComplete,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        if (s.isComplete) const DoneBadge() else Text(progressText, style: muted),
                      ],
                    ),
                  ),
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                      child: Text('Még nincs teljesített tárgy ebből a blokkból.', style: muted),
                    ),
                  for (final row in rows) ...[
                    Divider(height: 1, indent: 50, color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    row,
                  ],
                ],
              ),
            ),
          ),
          for (final line in _footerLines)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Text(line, style: muted),
            ),
        ],
      ),
    );
  }
}
