import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/ui/absolutorium/widgets/progress_widgets.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';

class HeaderSummary extends StatelessWidget {
  const HeaderSummary({super.key, required this.progress});

  final AbsolutoriumProgress progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = progress;
    final onHeader = scheme.onPrimaryContainer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CreditRing(
          value:
              p.requiredCredits == 0 ? 0 : p.earnedCredits / p.requiredCredits,
          size: 132,
          strokeWidth: 12,
          trackColor: onHeader.withValues(alpha: 0.18),
          color: p.isComplete ? kCompleteColor : itkPrimary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${p.percent}%',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: onHeader,
                  height: 1.1,
                ),
              ),
              Text(
                '${p.earnedCredits}/${p.requiredCredits} kr',
                style: TextStyle(
                  fontSize: 12,
                  color: onHeader.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.isComplete ? 'Kész!' : 'Még ${p.remainingCredits} kredit',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: onHeader,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                p.curriculum.major,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onHeader.withValues(alpha: 0.9),
                ),
              ),
              if (p.chosenSpecialization != null)
                Text(
                  p.chosenSpecialization!.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: onHeader.withValues(alpha: 0.75),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TypeTotalsRow extends StatelessWidget {
  const TypeTotalsRow({super.key, required this.byType});

  final Map<SubgroupType, TypeTotals> byType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in SubgroupType.values) ...[
          if (t != SubgroupType.values.first)
            const SizedBox(width: AppSpacing.sm),
          Expanded(child: _TypeTile(type: t, totals: byType[t])),
        ],
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.totals});

  final SubgroupType type;
  final TypeTotals? totals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final counted = totals?.countedCredits ?? 0;
    final target = totals?.requiredCredits ?? 0;
    final done = target > 0 && counted >= target;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$counted',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: done ? kCompleteColor : scheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: '/$target',
                  style:
                      TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CreditBar(value: counted, max: target, complete: done, height: 6),
        ],
      ),
    );
  }
}

class GroupTile extends StatelessWidget {
  const GroupTile({super.key, required this.group, required this.onTap});

  final GroupProgress group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final g = group;
    final muted = TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);
    final missing = g.missingMandatoryCount;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (g.isComplete) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const DoneBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CreditBar(
                    value: g.countedCredits,
                    max: g.requiredCredits,
                    complete: g.isComplete,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    [
                      g.requiredCredits > 0
                          ? '${g.countedCredits}/${g.requiredCredits} kr'
                          : '${g.completedSubgroupCount}/${g.requiredSubgroupCount} feltétel',
                      if (missing > 0) '$missing kötelező hiányzik',
                      if (g.isSpecialization) 'specializáció',
                    ].join(' · '),
                    style: muted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded, size: 22, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: color.withValues(alpha: 0.14),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        message,
                        style: TextStyle(
                            fontSize: 13, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoCurriculumView extends StatelessWidget {
  const NoCurriculumView({super.key, required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.xxxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.school_outlined, size: 56, color: scheme.outline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Kövesd, mennyi van még hátra',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Válaszd ki a mintatantervedet, vidd fel a teljesített tárgyaidat, '
            'és látod, melyik tárgycsoportból mennyi kredit hiányzik még.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xxl),
          BrandButton(
            onTap: onChoose,
            height: 52,
            backgroundColor: itkPrimary,
            child: const Text(
              'Tanterv kiválasztása',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: itkDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
