import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/utils/result.dart';

/// Answers every request with [handler] and records what was sent.
class FakeHttpAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  ResponseBody Function(RequestOptions options) handler = (_) => jsonBody(200, null);

  RequestOptions get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int statusCode, Object? body) => ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody textBody(int statusCode, String body) => ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['text/calendar; charset=utf-8'],
      },
    );

/// The real ApiClient needs path_provider for the cookie jar, which does not
/// exist in unit tests. This one has the same public surface on a fake Dio.
class TestApiClient implements ApiClient {
  TestApiClient() : dio = Dio(BaseOptions(baseUrl: 'https://test.local')) {
    dio.httpClientAdapter = adapter;
  }

  final adapter = FakeHttpAdapter();

  @override
  final Dio dio;

  @override
  Future<void> Function()? onUnauthorized;

  @override
  Future<void> clearCookies() async {}

  @override
  Future<Result<T>> getJson<T>(
    String path, {
    required T Function(Object?) parse,
    Map<String, dynamic>? queryParameters,
  }) =>
      sendRequest(
        parse: parse,
        send: () => dio.get(path, queryParameters: queryParameters),
      );
}

/// Lets the microtasks of fake repositories (and commands awaiting them) finish.
Future<void> flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
