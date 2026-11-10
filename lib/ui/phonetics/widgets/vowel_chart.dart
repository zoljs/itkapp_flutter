import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/hungarian_phonology.dart';
import 'package:itk_app/domain/models/phoneme.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/phonetics/widgets/phoneme_cell_button.dart';

/// IPA vowel trapezoid with the Hungarian vowels.
///
/// Rows are tongue height, the horizontal axis is backness. At each point the
/// unrounded vowels stand on the left and the rounded ones on the right, as
/// on the official IPA chart. A short and long pair shares one cell.
class VowelChart extends StatelessWidget {
  const VowelChart({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// The selected cell, empty when nothing is selected.
  final List<Phoneme> selected;
  final ValueChanged<List<Phoneme>> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = TextStyle(
      fontSize: 11,
      height: 1.1,
      color: scheme.onSurfaceVariant,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = _VowelGeometry(constraints.maxWidth);

        final cells = <Widget>[];
        for (final height in VowelHeight.values) {
          for (final backness in VowelBackness.values) {
            for (final rounded in const [false, true]) {
              final cell = HungarianPhonology.vowelsAt(
                height,
                backness,
                rounded: rounded,
              );
              if (cell.isEmpty) continue;

              final point = geometry.point(height, backness);
              final width = cell.length > 1
                  ? _VowelGeometry.pairWidth
                  : _VowelGeometry.singleWidth;

              cells.add(Positioned(
                left: rounded
                    ? point.dx + _VowelGeometry.dotGap
                    : point.dx - _VowelGeometry.dotGap - width,
                top: point.dy - _VowelGeometry.cellHeight / 2,
                width: width,
                height: _VowelGeometry.cellHeight,
                child: PhonemeCellButton(
                  phonemes: cell,
                  selected: isSameCell(cell, selected),
                  onTap: () => onSelect(cell),
                  // Opaque, so the chart lines stop at the symbols.
                  color: theme.scaffoldBackgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(AppRadius.md)),
                  ),
                  child: Center(
                    child: Text(
                      [for (final vowel in cell) vowel.ipa].join('  '),
                      maxLines: 1,
                    ),
                  ),
                ),
              ));
            }
          }
        }

        return SizedBox(
          height: _VowelGeometry.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _VowelChartPainter(
                    geometry: geometry,
                    lineColor: scheme.outlineVariant,
                    dotColor: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final backness in VowelBackness.values)
                Positioned(
                  left: geometry.point(VowelHeight.close, backness).dx -
                      _VowelGeometry.axisLabelWidth / 2,
                  top: 0,
                  width: _VowelGeometry.axisLabelWidth,
                  child: Text(
                    backness.axisLabel,
                    textAlign: TextAlign.center,
                    style: muted,
                  ),
                ),
              for (final height in VowelHeight.values)
                Positioned(
                  left: 0,
                  top: geometry.point(height, VowelBackness.front).dy -
                      _VowelGeometry.cellHeight / 2,
                  width: _VowelGeometry.labelWidth,
                  height: _VowelGeometry.cellHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(height.label, style: muted),
                  ),
                ),
              ...cells,
            ],
          ),
        );
      },
    );
  }
}

/// Maps a vowel position to a point of the chart for a given chart width.
class _VowelGeometry {
  const _VowelGeometry(this.width);

  final double width;

  static const labelWidth = 40.0;
  static const axisLabelWidth = 72.0;
  static const cellHeight = 44.0;
  static const pairWidth = 56.0;
  static const singleWidth = 44.0;
  static const dotGap = 6.0;

  static const _top = 44.0;
  static const _rowGap = 64.0;

  // Room for a pair cell beside the outermost points.
  static const _side = pairWidth + dotGap + 2;

  static const height = _top + 3 * _rowGap + cellHeight / 2 + 6;

  double get _backX => width - _side;
  double get _frontTopX => labelWidth + _side;

  Offset point(VowelHeight height, VowelBackness backness) {
    final t = height.index / (VowelHeight.values.length - 1);
    // The front edge slants: the bottom of the trapezoid is half as wide as
    // the top, the back edge is vertical.
    final frontX = _frontTopX + t * (_backX - _frontTopX) / 2;
    final x = switch (backness) {
      VowelBackness.front => frontX,
      VowelBackness.central => (frontX + _backX) / 2,
      VowelBackness.back => _backX,
    };
    return Offset(x, _top + height.index * _rowGap);
  }
}

class _VowelChartPainter extends CustomPainter {
  const _VowelChartPainter({
    required this.geometry,
    required this.lineColor,
    required this.dotColor,
  });

  final _VowelGeometry geometry;
  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outline = Path()
      ..addPolygon(
        [
          geometry.point(VowelHeight.close, VowelBackness.front),
          geometry.point(VowelHeight.close, VowelBackness.back),
          geometry.point(VowelHeight.open, VowelBackness.back),
          geometry.point(VowelHeight.open, VowelBackness.front),
        ],
        true,
      );
    canvas.drawPath(outline, line);

    for (final height in const [VowelHeight.closeMid, VowelHeight.openMid]) {
      canvas.drawLine(
        geometry.point(height, VowelBackness.front),
        geometry.point(height, VowelBackness.back),
        line,
      );
    }
    canvas.drawLine(
      geometry.point(VowelHeight.close, VowelBackness.central),
      geometry.point(VowelHeight.open, VowelBackness.central),
      line,
    );

    final dot = Paint()..color = dotColor;
    for (final vowel in HungarianPhonology.vowels) {
      canvas.drawCircle(
        geometry.point(vowel.height, vowel.backness),
        3,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(_VowelChartPainter oldDelegate) =>
      oldDelegate.geometry.width != geometry.width ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor;
}
