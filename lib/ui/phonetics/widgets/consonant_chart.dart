import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/hungarian_phonology.dart';
import 'package:itk_app/domain/models/phoneme.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/phonetics/widgets/phoneme_cell_button.dart';

/// IPA consonant table with the Hungarian consonants.
///
/// Columns are places of articulation, rows are manners. Inside a cell the
/// voiceless consonant stands on the left and the voiced one on the right, as
/// on the official IPA chart.
class ConsonantChart extends StatelessWidget {
  const ConsonantChart({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// The selected cell, empty when nothing is selected.
  final List<Phoneme> selected;
  final ValueChanged<List<Phoneme>> onSelect;

  static const _labelWidth = 68.0;
  static const _cellHeight = 44.0;
  static const _labelPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.sm,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 11, color: scheme.onSurfaceVariant);
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));

    return ClipRRect(
      borderRadius: radius,
      child: Table(
        columnWidths: const {0: FixedColumnWidth(_labelWidth)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          color: scheme.outlineVariant,
          borderRadius: radius,
        ),
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              for (final column in ConsonantColumn.values)
                Padding(
                  padding: _labelPadding,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      column.shortLabel,
                      semanticsLabel: column.label,
                      style: muted,
                    ),
                  ),
                ),
            ],
          ),
          for (final manner in ConsonantManner.values)
            TableRow(
              children: [
                Padding(
                  padding: _labelPadding,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(manner.rowLabel, style: muted),
                  ),
                ),
                for (final column in ConsonantColumn.values)
                  _ConsonantCell(
                    cell: HungarianPhonology.consonantsAt(column, manner),
                    selected: selected,
                    onSelect: onSelect,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ConsonantCell extends StatelessWidget {
  const _ConsonantCell({
    required this.cell,
    required this.selected,
    required this.onSelect,
  });

  final List<Consonant> cell;
  final List<Phoneme> selected;
  final ValueChanged<List<Phoneme>> onSelect;

  @override
  Widget build(BuildContext context) {
    if (cell.isEmpty) {
      return const SizedBox(height: ConsonantChart._cellHeight);
    }

    return PhonemeCellButton(
      phonemes: cell,
      selected: isSameCell(cell, selected),
      onTap: () => onSelect(cell),
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SizedBox(
        height: ConsonantChart._cellHeight,
        child: Row(
          children: [
            // Voiceless on the left, voiced on the right.
            for (final voiced in const [false, true])
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      [
                        for (final consonant in cell)
                          if (consonant.voiced == voiced) consonant.ipa,
                      ].join(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
