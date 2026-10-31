import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/averages.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/diploma_viewmodel.dart';
import 'package:itk_app/ui/absolutorium/widgets/grade_chip.dart';
import 'package:itk_app/ui/absolutorium/widgets/progress_widgets.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:provider/provider.dart';

class DiplomaSheet extends StatefulWidget {
  const DiplomaSheet({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<DiplomaSheet> createState() => _DiplomaSheetState();
}

class _DiplomaSheetState extends State<DiplomaSheet> {
  late final DiplomaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        DiplomaViewModel(repository: context.read<AbsolutoriumRepository>());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _gradePicker({
    required String header,
    required String footer,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return SettingsGroup(
      header: header,
      footer: footer,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final g in DiplomaViewModel.grades)
                GradeChip(
                    grade: g,
                    selected: g == value,
                    emptyLabel: 'nincs még',
                    onTap: () => onChanged(g)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final inputs = _viewModel.inputs;
        final estimate = _viewModel.estimate;

        return Scaffold(
          backgroundColor: sheetBackgroundColor(context),
          appBar: buildBrandAppBar(
              context: context, title: 'Diplomaátlag', closesSheet: true),
          body: ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl,
            ),
            children: [
              _ResultCard(estimate: estimate, loading: _viewModel.loading),
              const SizedBox(height: AppSpacing.xxl),
              if (estimate != null)
                SettingsGroup(
                  header: 'Összetevők',
                  footer:
                      'A még meg nem adott jegyek helyén a jelenlegi súlyozott átlagod szerepel.',
                  children: [
                    for (final p in estimate.parts)
                      SettingsTile(
                        title: '${p.label} (${(p.weight * 100).round()}%)',
                        value: p.estimated
                            ? '≈ ${formatAverage(p.value)}'
                            : formatAverage(p.value),
                      ),
                  ],
                ),
              _gradePicker(
                header: 'Szakdolgozat / diplomamunka',
                footer: '40%',
                value: inputs.thesis,
                onChanged: _viewModel.setThesis,
              ),
              _gradePicker(
                header: 'Záróvizsga tárgy',
                footer:
                    '30%. A súlyozott tanulmányi átlag (30%) a teljesítéseidből számolódik, '
                    'a szakdolgozat-készítés tárgyai nélkül.',
                value: inputs.finalExam,
                onChanged: _viewModel.setFinalExam,
              ),
              _HonoursGroup(
                  conditions: _viewModel.honours, met: _viewModel.honoursMet),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'A PPKE ITK TVSZ 1. sz. melléklet 16. §-a szerint (alap- és mesterképzés). '
                  'Az eredményt két tizedesre csonkolva kell megadni (4,499 → 4,49). '
                  'A hivatalos eredményt a Tanulmányi Osztály állapítja meg; '
                  'az elismert (kreditátvitellel befogadott) tárgyak nem számítanak az átlagba. '
                  'A megadott jegyek csak ezen az eszközön tárolódnak.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.estimate, required this.loading});

  final DiplomaEstimate? estimate;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final e = estimate;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: ShapeDecoration(
        color: scheme.primaryContainer,
        shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl)),
      ),
      child: loading && e == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e == null
                      ? 'Még nincs elég adat'
                      : (e.isEstimate
                          ? 'Becsült diplomaátlag'
                          : 'Diplomaátlag'),
                  style: TextStyle(
                      fontSize: 13,
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  e == null ? '–' : formatAverage(e.value),
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                    height: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  e == null
                      ? 'Vigyél fel jeggyel zárult tárgyat.'
                      : 'Minősítés: ${e.classification}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
    );
  }
}

class _HonoursGroup extends StatelessWidget {
  const _HonoursGroup({required this.conditions, required this.met});

  final List<HonoursCondition> conditions;
  final bool? met;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SettingsGroup(
      header: 'Kitüntetéses oklevél',
      footer: switch (met) {
        true => 'Minden feltétel teljesül.',
        false => 'Legalább egy feltétel nem teljesül.',
        null => 'Még nem dönthető el – add meg a hiányzó jegyeket.',
      },
      children: [
        for (final c in conditions)
          SettingsTile(
            title: c.label,
            trailing: Icon(
              switch (c.met) {
                true => Icons.check_circle_rounded,
                false => Icons.cancel_rounded,
                null => Icons.help_outline_rounded,
              },
              color: switch (c.met) {
                true => kCompleteColor,
                false => scheme.error,
                null => scheme.outline,
              },
            ),
          ),
      ],
    );
  }
}
