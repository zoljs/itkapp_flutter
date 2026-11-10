import 'package:flutter/foundation.dart';
import 'package:itk_app/domain/models/phoneme.dart';

enum PhoneticsChart {
  vowels('Magánhangzók'),
  consonants('Mássalhangzók');

  const PhoneticsChart(this.label);

  final String label;
}

class PhoneticsViewModel extends ChangeNotifier {
  PhoneticsChart _chart = PhoneticsChart.vowels;
  final _selected = <PhoneticsChart, List<Phoneme>>{};

  PhoneticsChart get chart => _chart;

  /// The selected cell of the visible chart, empty when nothing is selected.
  /// Each chart keeps its own selection.
  List<Phoneme> get selected => _selected[_chart] ?? const [];

  void setChart(PhoneticsChart chart) {
    if (chart == _chart) return;
    _chart = chart;
    notifyListeners();
  }

  /// Selects a cell of the visible chart. Selecting the active cell again
  /// clears the selection.
  void select(List<Phoneme> cell) {
    if (isSameCell(cell, selected)) {
      _selected.remove(_chart);
    } else {
      _selected[_chart] = cell;
    }
    notifyListeners();
  }
}
