import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/phoneme.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/utils/string_extensions.dart';

/// Details of the phonemes in the selected chart cell: symbol, description,
/// spelling and an example word.
class PhonemeDetails extends StatelessWidget {
  const PhonemeDetails({super.key, required this.phonemes});

  /// Empty when no cell is selected.
  final List<Phoneme> phonemes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SettingsGroup(
      header: 'Kiválasztott hang',
      children: [
        if (phonemes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Koppints egy hangra az ábrán a részletekért.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        for (final phoneme in phonemes) _PhonemeRow(phoneme: phoneme),
      ],
    );
  }
}

class _PhonemeRow extends StatelessWidget {
  const _PhonemeRow({required this.phoneme});

  final Phoneme phoneme;

  static const _symbolWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _symbolWidth,
            child: Text(
              '/${phoneme.ipa}/',
              semanticsLabel: phoneme.spelling,
              style: ipaStyle.copyWith(fontSize: 24, color: scheme.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phoneme.description.capitalize(),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Betű', style: muted),
                    _InlineChip(text: phoneme.spelling),
                    Text('Példa', style: muted),
                    _InlineChip(text: phoneme.example),
                    Text(
                      '[${phoneme.exampleIpa}]',
                      style: ipaStyle.copyWith(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlighted inline text instead of quotes (D12).
class _InlineChip extends StatelessWidget {
  const _InlineChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: scheme.onSurface),
        ),
      ),
    );
  }
}
