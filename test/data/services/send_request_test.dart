import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

void main() {
  late Dio dio;
  late FakeHttpAdapter adapter;

  setUp(() {
    adapter = FakeHttpAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
      ..httpClientAdapter = adapter;
  });

  test('siker esetén a parse eredménye Ok-ban', () async {
    adapter.handler = (_) => jsonBody(200, {'value': 3});

    final result = await sendRequest(
      send: () => dio.get('/x'),
      parse: (data) => (data! as Map)['value'] as int,
    );

    expect(result, isA<Ok<int>>().having((r) => r.value, 'value', 3));
  });

  test('a szerver hibakódja magyar üzenet lesz', () async {
    adapter.handler = (_) => jsonBody(409, {
          'data': {'code': 'DUPLICATE_LINK'},
        });

    final result = await sendRequest(send: () => dio.post('/x'), parse: (_) {});

    expect(
        result,
        isA<Err<void>>().having(
            (r) => r.message, 'message', 'Ez a link már fel van véve.'));
  });

  test('a parse FormatException-je Err lesz, nem kivétel', () async {
    adapter.handler = (_) => jsonBody(200, 'nem objektum');

    final result = await sendRequest<int>(
      send: () => dio.get('/x'),
      parse: (_) => throw const FormatException('Rossz formátum.'),
    );

    expect(result,
        isA<Err<int>>().having((r) => r.message, 'message', 'Rossz formátum.'));
  });
}
