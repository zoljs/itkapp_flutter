import 'package:flutter/material.dart';
import 'package:hintful/hintful.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';

Widget buildHintTooltip(
  BuildContext context,
  HintStep step,
  HintTooltipContext ctx,
) {
  final hint = Theme.of(context).hintTheme;
  final scheme = Theme.of(context).colorScheme;
  final text = Theme.of(context).textTheme;
  final title = step.content.title;
  final description = step.content.description;

  return TweenAnimationBuilder<double>(
    key: ValueKey(ctx.stepIndex),
    tween: Tween(begin: 0.0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 350),
    curve: Curves.easeOutBack,
    builder: (context, t, child) => Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: 6,
        shadowColor: Colors.black54,
        borderRadius: hint.tooltipRadius,
        child: Padding(
          padding: hint.tooltipPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!ctx.isSingle) ...[
                _StepDots(index: ctx.stepIndex, total: ctx.totalSteps),
                const SizedBox(height: AppSpacing.md),
              ],
              if (title != null)
                Text(
                  title,
                  style: text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (step.showSkip && !ctx.isLast)
                    TextButton(
                      onPressed: ctx.actions.skip,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                      ),
                      child: const Text('Kihagyás'),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: 112,
                    child: BrandButton(
                      onTap: ctx.actions.next,
                      child: Text(ctx.isLast ? 'Kész' : 'Tovább'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: '${index + 1} / $total',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              width: i == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == index ? itkPrimary : inactive,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}
