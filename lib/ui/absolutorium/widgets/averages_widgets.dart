import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/averages.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/utils/semester.dart';

class StatValue {
  const StatValue(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;
}

class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.values, this.large = false});

  final List<StatValue> values;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final v in values)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  v.value,
                  style: TextStyle(
                    fontSize: large ? 22 : 16,
                    fontWeight: FontWeight.w800,
                    color: v.highlight ? itkPrimary : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

List<StatValue> semesterStatValues(SemesterStats s) => [
      StatValue('Átlag', formatAverage(s.weightedAverage)),
      StatValue('Kreditindex', formatAverage(s.creditIndex)),
      StatValue('Korr. KI', formatAverage(s.correctedCreditIndex)),
    ];

class AveragesCard extends StatelessWidget {
  const AveragesCard({
    super.key,
    required this.averages,
    required this.diploma,
    required this.onOpenDiploma,
    required this.onOpenCompletions,
  });

  final AverageSummary averages;
  final DiplomaEstimate? diploma;
  final VoidCallback onOpenDiploma;
  final VoidCallback onOpenCompletions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);
    final latest = averages.latest;
    final d = diploma;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Text('Átlagok',
                style: muted.copyWith(
                    letterSpacing: 0.4, fontWeight: FontWeight.w600)),
          ),
          ClipRSuperellipse(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Material(
              color: scheme.surfaceContainerHigh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: onOpenCompletions,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StatRow(
                            large: true,
                            values: [
                              StatValue(
                                'Halmozott átlag',
                                formatAverage(averages.overallWeightedAverage),
                                highlight: true,
                              ),
                              StatValue('Kreditindex', latest == null ? '–' : formatAverage(latest.creditIndex)),
                              StatValue(
                                'Korr. KI',
                                latest == null ? '–' : formatAverage(latest.correctedCreditIndex),
                              ),
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
                    ),
                  ),
                  Divider(
                      height: 1,
                      indent: AppSpacing.lg,
                      color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  InkWell(
                    onTap: onOpenDiploma,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                            AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded,
                                color: scheme.tertiary),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Diplomaátlag',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: scheme.onSurface)),
                                  Text(
                                    d == null
                                        ? 'Még nincs elég adat'
                                        : d.isEstimate
                                            ? 'becslés · ${d.classification}'
                                            : d.classification,
                                    style: muted,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              d == null ? '–' : formatAverage(d.value),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: scheme.outline),
                          ],
                        ),
                      ),
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
