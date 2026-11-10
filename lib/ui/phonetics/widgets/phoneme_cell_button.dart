import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/phoneme.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';

/// Tappable chart cell. The [child] shows the IPA symbols; screen readers get
/// the spelling and the description of every phoneme instead.
class PhonemeCellButton extends StatelessWidget {
  const PhonemeCellButton({
    super.key,
    required this.phonemes,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.shape,
    required this.child,
  });

  final List<Phoneme> phonemes;
  final bool selected;
  final VoidCallback onTap;

  /// Background while not selected.
  final Color color;
  final ShapeBorder shape;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      selected: selected,
      child: AppPressable(
        onTap: onTap,
        semanticLabel: [
          for (final phoneme in phonemes)
            '${phoneme.spelling}: ${phoneme.description}',
        ].join('; '),
        color: selected ? scheme.primaryContainer : color,
        shape: shape,
        child: ExcludeSemantics(
          child: DefaultTextStyle.merge(
            style: ipaStyle.copyWith(
              fontSize: 18,
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
