import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/hungarian_phonology.dart';
import 'package:itk_app/domain/models/phoneme.dart';
import 'package:itk_app/ui/phonetics/viewmodels/phonetics_viewmodel.dart';

void main() {
  final closeFront = HungarianPhonology.vowelsAt(
    VowelHeight.close,
    VowelBackness.front,
    rounded: false,
  );
  final closeBack = HungarianPhonology.vowelsAt(
    VowelHeight.close,
    VowelBackness.back,
    rounded: true,
  );
  final labialPlosives = HungarianPhonology.consonantsAt(
    ConsonantColumn.labial,
    ConsonantManner.plosive,
  );

  late PhoneticsViewModel viewModel;
  late int notifications;

  setUp(() {
    notifications = 0;
    viewModel = PhoneticsViewModel()..addListener(() => notifications++);
  });

  tearDown(() => viewModel.dispose());

  test('alapból a magánhangzó ábra látszik, kijelölés nélkül', () {
    expect(viewModel.chart, PhoneticsChart.vowels);
    expect(viewModel.selected, isEmpty);
  });

  test('setChart vált és értesít', () {
    viewModel.setChart(PhoneticsChart.consonants);
    expect(viewModel.chart, PhoneticsChart.consonants);
    expect(notifications, 1);
  });

  test('setChart ugyanarra az ábrára nem értesít', () {
    viewModel.setChart(PhoneticsChart.vowels);
    expect(notifications, 0);
  });

  test('select kijelöli a cellát és értesít', () {
    viewModel.select(closeFront);
    expect(viewModel.selected, closeFront);
    expect(notifications, 1);
  });

  test('másik cella kijelölése lecseréli az előzőt', () {
    viewModel.select(closeFront);
    viewModel.select(closeBack);
    expect(viewModel.selected, closeBack);
  });

  test('a kijelölt cella újbóli kijelölése törli a kijelölést', () {
    viewModel.select(closeFront);
    viewModel.select(closeFront);
    expect(viewModel.selected, isEmpty);
    expect(notifications, 2);
  });

  test('mindkét ábra megtartja a saját kijelölését', () {
    viewModel.select(closeFront);
    viewModel.setChart(PhoneticsChart.consonants);
    expect(viewModel.selected, isEmpty);

    viewModel.select(labialPlosives);
    expect(viewModel.selected, labialPlosives);

    viewModel.setChart(PhoneticsChart.vowels);
    expect(viewModel.selected, closeFront);
  });
}
