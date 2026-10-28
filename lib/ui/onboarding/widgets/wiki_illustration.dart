import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart' show AppRadius;
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/wiki/widgets/user_site_card.dart';

class WikiIllustration extends StatelessWidget {
  const WikiIllustration({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final List<String> tags = ['Analízis I.', 'Computer Controlled Systems'];
    final List<Color> colors = [itkPrimary, scheme.surfaceContainerHighest, scheme.surfaceContainerHigh, scheme.surfaceContainer];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        for (var depth = colors.length - 1; depth > 0; depth--)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, -depth * 30.0),
              child: Transform.scale(
                scale: 1 - depth * 0.08,
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: colors[depth],
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
              ),
            ),
          ),
        UserSiteCard(
          color: colors[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Naszy oldala',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'users.itk.ppke.hu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .rotate(
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              begin: -0.01,
              end: 0.01,
            )
      ],
    );
  }
}
