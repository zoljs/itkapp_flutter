import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  static const _rows = [
    ['Órarend', 'ZH-k', 'Wiki', 'Naptár', 'Online videók'],
    ['Analízis I.', 'Diszkrét matek', 'Prog. alapjai', 'Fizika'],
    ['Saját oldal', 'Fájlok', 'Címkék', 'Évfolyamfelelős'],
    ['Lineáris algebra', 'Digitális rendszerek', 'Algoritmusok'],
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fade the rows out at both edges.
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.15, 0.85, 1],
            ).createShader(bounds),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, words) in _rows.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: _MarqueeRow(
                      words: words,
                      reverse: i.isOdd,
                      duration: Duration(seconds: 18 + i * 4),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icons/itkapp-small.png',
              errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, size: 64, color: itkDark),
            ),
          ).animate().scale(
                begin: const Offset(0.6, 0.6),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}

class _MarqueeRow extends StatelessWidget {
  const _MarqueeRow({
    required this.words,
    required this.reverse,
    required this.duration,
  });

  final List<String> words;
  final bool reverse;
  final Duration duration;

  static const _copies = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final copy = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final word in words)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );

    const oneCopy = 1 / _copies;

    return SizedBox(
      height: 32,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.filled(_copies, copy),
          ).animate(onPlay: (c) => c.repeat()).slideX(
                begin: reverse ? -oneCopy : 0,
                end: reverse ? 0 : -oneCopy,
                duration: duration,
              ),
        ),
      ),
    );
  }
}
