import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/calendar/widgets/day_snap_scroll_physics.dart';

/// Three days over a 300 px viewport: a day is 100 px wide.
ScrollMetrics _metrics({
  required double pixels,
  double min = 0,
  double max = 10000,
}) =>
    FixedScrollMetrics(
      minScrollExtent: min,
      maxScrollExtent: max,
      pixels: pixels,
      viewportDimension: 300,
      axisDirection: AxisDirection.right,
      devicePixelRatio: 1.0,
    );

/// Where the simulation ends up once it has settled.
double? _settledAt(Simulation? simulation) => simulation?.x(10);

void main() {
  const physics = DaySnapScrollPhysics(daysShowed: 3);

  group('megállás napi határon (szülő nélkül, nincs lendület)', () {
    test('a közelebbi nap elejére igazít lefelé', () {
      final target = _settledAt(
          physics.createBallisticSimulation(_metrics(pixels: 140), 0));

      expect(target, closeTo(100, 1));
    });

    test('a közelebbi nap elejére igazít felfelé', () {
      final target = _settledAt(
          physics.createBallisticSimulation(_metrics(pixels: 160), 0));

      expect(target, closeTo(200, 1));
    });

    test('napi határon állva nincs mozgás', () {
      expect(physics.createBallisticSimulation(_metrics(pixels: 200), 0),
          isNull);
    });

    test('a tűrésen belüli eltérés sem indít mozgást', () {
      expect(physics.createBallisticSimulation(_metrics(pixels: 200.5), 0),
          isNull);
    });

    test('a görgetési tartományon belül marad', () {
      final target = _settledAt(physics.createBallisticSimulation(
          _metrics(pixels: 260, max: 270), 0));

      expect(target, closeTo(270, 1));
    });

    test('a tartományon kívül a szülőre bízza (itt nincs szülő: null)', () {
      expect(physics.createBallisticSimulation(_metrics(pixels: -50), 0),
          isNull);
    });
  });

  group('lendülettel (ClampingScrollPhysics szülővel)', () {
    final withMomentum = physics.applyTo(const ClampingScrollPhysics());

    test('erős előre pöccintés legfeljebb daysShowed napot ugrik', () {
      final target = _settledAt(
          withMomentum.createBallisticSimulation(_metrics(pixels: 0), 100000));

      expect(target, closeTo(300, 1));
    });

    test('erős hátra pöccintés legfeljebb daysShowed napot ugrik', () {
      final target = _settledAt(withMomentum.createBallisticSimulation(
          _metrics(pixels: 500), -100000));

      expect(target, closeTo(200, 1));
    });
  });

  group('alap tulajdonságok', () {
    test('az applyTo megtartja a daysShowed-et és átveszi a szülőt', () {
      final applied = physics.applyTo(const ClampingScrollPhysics());

      expect(applied.daysShowed, 3);
      expect(applied.parent, isA<ClampingScrollPhysics>());
    });

    test('nem engedi az implicit görgetést', () {
      expect(physics.allowImplicitScrolling, isFalse);
    });
  });
}
