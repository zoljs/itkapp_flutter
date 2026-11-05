import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

void main() {
  test('futás közben running, utána az eredmény', () async {
    final completer = Completer<Result<int>>();
    final command = Command0<int>(() => completer.future);

    final future = command.execute();
    expect(command.running, isTrue);
    expect(command.result, isNull);

    completer.complete(const Ok(5));
    await future;

    expect(command.running, isFalse);
    expect(command.completed, isTrue);
    expect(command.errorMessage, isNull);
  });

  test('hiba esetén az üzenet elérhető', () async {
    final command = Command0<void>(() async => const Err('Nincs net.'));

    await command.execute();

    expect(command.completed, isFalse);
    expect(command.errorMessage, 'Nincs net.');
  });

  test('futás közben a második hívást figyelmen kívül hagyja', () async {
    var calls = 0;
    final completer = Completer<Result<void>>();
    final command = Command0<void>(() {
      calls++;
      return completer.future;
    });

    final first = command.execute();
    await command.execute();
    completer.complete(const Ok(null));
    await first;

    expect(calls, 1);
  });

  test('az új futás törli az előző eredményt', () async {
    var fail = true;
    final command =
        Command0<void>(() async => fail ? const Err('hiba') : const Ok(null));

    await command.execute();
    expect(command.errorMessage, 'hiba');

    fail = false;
    await command.execute();
    expect(command.errorMessage, isNull);
    expect(command.completed, isTrue);
  });

  test('indításkor és befejezéskor is szól a figyelőknek', () async {
    final command = Command1<void, int>((_) async => const Ok(null));
    var notified = 0;
    command.addListener(() => notified++);

    await command.execute(1);

    expect(notified, 2);
  });
}
