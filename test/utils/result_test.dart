import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/utils/result.dart';

String describe(Result<int> r) => switch (r) {
      Ok(:final value) => 'ok $value',
      Err(:final message) => 'hiba: $message',
    };

void main() {
  test('Ok és Err a switch-ben', () {
    expect(describe(const Ok(3)), 'ok 3');
    expect(describe(const Err('nincs net')), 'hiba: nincs net');
  });
}
