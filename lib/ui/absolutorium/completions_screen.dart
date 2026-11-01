import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/domain/models/averages.dart';
import 'package:itk_app/ui/absolutorium/add_completion_sheet.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/completions_viewmodel.dart';
import 'package:itk_app/ui/absolutorium/widgets/averages_widgets.dart';
import 'package:itk_app/ui/absolutorium/widgets/completion_dismissible.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/semester.dart';
import 'package:provider/provider.dart';

class CompletionsScreen extends StatefulWidget {
  const CompletionsScreen({super.key});

  @override
  State<CompletionsScreen> createState() => _CompletionsScreenState();
}

class _CompletionsScreenState extends State<CompletionsScreen> {
  late final CompletionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CompletionsViewModel(repository: context.read<AbsolutoriumRepository>());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => AddCompletionSheet(scrollController: controller),
    );
  }

  Future<void> _delete(int id) async {
    await _viewModel.delete.execute(id);
    if (!mounted) return;
    if (_viewModel.delete.errorMessage case final message?) context.showMessage(message);
  }

  Widget _buildBody(BuildContext context) {
    if (_viewModel.initialLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_viewModel.items.isEmpty && _viewModel.load.errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _viewModel.load.errorMessage!,
        onRetry: () => _viewModel.load.execute(true),
      );
    }
    if (_viewModel.items.isEmpty) {
      return const StateMessage(
        icon: Icons.playlist_add_check_rounded,
        message: 'Még nem vittél fel teljesítést.\nKezdd a + gombbal!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.load.execute(true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          MediaQuery.paddingOf(context).bottom + AppSpacing.xxxxl,
        ),
        children: [
          _OverallSummary(averages: _viewModel.averages),
          const SizedBox(height: AppSpacing.xxl),
          for (final entry in _viewModel.bySemester.entries)
            _SemesterSection(
              semester: entry.key,
              items: entry.value,
              stats: _viewModel.averages.forSemester(entry.key),
              onDelete: _delete,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Törléshez húzd balra a sort.',
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _viewModel.load]),
      builder: (context, _) => Scaffold(
        appBar: buildBrandAppBar(
          context: context,
          title: 'Teljesítések',
          actionIcon: Icons.add_rounded,
          onAction: _openAdd,
        ),
        body: _buildBody(context),
      ),
    );
  }
}

class _OverallSummary extends StatelessWidget {
  const _OverallSummary({required this.averages});

  final AverageSummary averages;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatRow(
            large: true,
            values: [
              StatValue('Halmozott átlag', formatAverage(averages.overallWeightedAverage), highlight: true),
              StatValue('Össz. korr. KI', formatAverage(averages.cumulativeCorrectedCreditIndex)),
              StatValue('Teljesített', '${averages.totalCompletedCredits}/${averages.totalEnrolledCredits} kr'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'TVSZ 38. § szerint. Súlyozott átlag: Σ(teljesített kredit × jegy) / teljesített kredit '
            '(az elégtelen és az aláírásos tárgyak nélkül). Kreditindex: Σ(teljesített kredit × jegy) / 30. '
            'Korrigált KI: kreditindex × teljesített / felvett kredit. '
            'Összesített korrigált KI: Σ(kredit × jegy) / (30 × aktív félévek) × teljesített / felvett.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SemesterSection extends StatelessWidget {
  const _SemesterSection({required this.semester, required this.items, required this.stats, required this.onDelete});

  final String semester;
  final List<Completion> items;
  final SemesterStats? stats;
  final Future<void> Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text(semesterLabel(semester), style: muted.copyWith(letterSpacing: 0.4))),
                if (stats != null) Text('${stats!.completedCredits}/${stats!.enrolledCredits} kr', style: muted),
              ],
            ),
          ),
          ClipRSuperellipse(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Material(
              color: scheme.surfaceContainerHigh,
              child: Column(
                children: [
                  if (stats != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: StatRow(values: semesterStatValues(stats!)),
                    ),
                    Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ],
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) Divider(height: 1, indent: AppSpacing.lg, color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    CompletionDismissible(
                      completionId: items[i].id,
                      name: items[i].name,
                      semester: items[i].semester,
                      onDelete: onDelete,
                      child: _CompletionRow(completion: items[i]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionRow extends StatelessWidget {
  const _CompletionRow({required this.completion});

  final Completion completion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = completion;
    final failed = !c.isPassing;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: failed ? scheme.onSurfaceVariant : scheme.onSurface,
                      decoration: failed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    [
                      c.code ?? 'saját tárgy',
                      '${c.credits} kr',
                      if (c.isCustom && c.code != null) 'saját',
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _GradeBubble(grade: c.grade),
          ],
        ),
      ),
    );
  }
}

class _GradeBubble extends StatelessWidget {
  const _GradeBubble({required this.grade});

  final int? grade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = grade;
    final failed = value != null && value < 2;

    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      height: 36,
      padding: EdgeInsets.symmetric(horizontal: value == null ? AppSpacing.sm : 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: failed ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: value == null
          ? Icon(Icons.draw_rounded, size: 18, color: scheme.onSurfaceVariant)
          : Text(
              '$value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: failed ? scheme.error : scheme.onSurface),
            ),
    );
  }
}
