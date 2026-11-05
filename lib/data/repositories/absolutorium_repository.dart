import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/domain/models/averages.dart';
import 'package:itk_app/utils/result.dart';

class AbsolutoriumRepository {
  AbsolutoriumRepository(
      {required ApiClient apiClient, required SharedPreferencesService prefs})
      : _dio = apiClient.dio,
        _prefs = prefs,
        _diplomaInputs = ValueNotifier(
            DiplomaInputs.fromJsonString(prefs.getString(_diplomaKey)));

  static const _diplomaKey = 'absolutorium.diplomaInputs';

  final Dio _dio;
  final SharedPreferencesService _prefs;

  final ValueNotifier<AbsolutoriumProgress?> _progress = ValueNotifier(null);

  ValueListenable<AbsolutoriumProgress?> get progress => _progress;

  DateTime? _fetchedAt;
  Future<Result<AbsolutoriumProgress?>>? _inflight;
  List<CurriculumOption>? _curricula;

  final ValueNotifier<List<Completion>?> _completions = ValueNotifier(null);

  ValueListenable<List<Completion>?> get completions => _completions;

  DateTime? _completionsFetchedAt;
  Future<Result<List<Completion>>>? _completionsInflight;

  final ValueNotifier<DiplomaInputs> _diplomaInputs;

  ValueListenable<DiplomaInputs> get diplomaInputs => _diplomaInputs;

  void clearCache() {
    _curricula = null;
    _fetchedAt = null;
    _progress.value = null;
    _completionsFetchedAt = null;
    _completions.value = null;
    _diplomaInputs.value = DiplomaInputs.empty;
    unawaited(_prefs.remove(_diplomaKey));
  }

  bool isFresh([Duration maxAge = const Duration(minutes: 2)]) {
    final at = _fetchedAt;
    return at != null && DateTime.now().difference(at) < maxAge;
  }

  Future<Result<AbsolutoriumProgress?>> getProgress({
    bool forceReload = false,
    Duration maxAge = const Duration(minutes: 2),
  }) {
    if (!forceReload && isFresh(maxAge)) {
      return Future.value(Ok(_progress.value));
    }
    return _inflight ??= _fetchProgress().whenComplete(() => _inflight = null);
  }

  Future<Result<AbsolutoriumProgress?>> _fetchProgress() async {
    final result = await _send<AbsolutoriumProgress?>(
      send: () => _dio.get('/api/absolutorium/progress'),
      parse: AbsolutoriumProgress.parse,
      onNotFound: () => null,
    );
    if (result case Ok(:final value)) {
      _fetchedAt = DateTime.now();
      _progress.value = value;
    }
    return result;
  }

  Future<void> _refreshProgress() async {
    _fetchedAt = null;
    _completionsFetchedAt = null;
    await Future.wait([
      getProgress(forceReload: true),
      if (_completions.value != null) getCompletions(forceReload: true),
    ]);
  }

  Future<Result<List<CurriculumOption>>> getCurricula(
      {bool forceReload = false}) async {
    final cached = _curricula;
    if (cached != null && !forceReload) return Ok(cached);

    final result = await _send(
      send: () => _dio.get('/api/absolutorium/curricula'),
      parse: CurriculumOption.parseList,
    );
    if (result case Ok(:final value)) _curricula = value;
    return result;
  }

  Future<Result<void>> setCurriculum(
      {required int curriculumId, int? specializationGroupId}) async {
    final result = await _send<void>(
      send: () => _dio.put('/api/absolutorium/curriculum', data: {
        'curriculumId': curriculumId,
        'specializationGroupId': specializationGroupId,
      }),
      parse: (_) {},
    );
    if (result is Ok) await _refreshProgress();
    return result;
  }

  Future<Result<List<Completion>>> getCompletions({
    bool forceReload = false,
    Duration maxAge = const Duration(minutes: 2),
  }) {
    final at = _completionsFetchedAt;
    final cached = _completions.value;
    if (!forceReload &&
        cached != null &&
        at != null &&
        DateTime.now().difference(at) < maxAge) {
      return Future.value(Ok(cached));
    }
    return _completionsInflight ??=
        _fetchCompletions().whenComplete(() => _completionsInflight = null);
  }

  Future<Result<List<Completion>>> _fetchCompletions() async {
    final result = await _send(
      send: () => _dio.get('/api/absolutorium/completions'),
      parse: Completion.parseList,
    );
    if (result case Ok(:final value)) {
      _completionsFetchedAt = DateTime.now();
      _completions.value = value;
    }
    return result;
  }

  Future<void> setDiplomaInputs(DiplomaInputs inputs) async {
    _diplomaInputs.value = inputs;
    await _prefs.setString(_diplomaKey, inputs.toJsonString());
  }

  Future<Result<List<CurriculumSubject>>> searchSubjects(String query) => _send(
        send: () => _dio.get('/api/absolutorium/subjects',
            queryParameters: {'q': query.trim()}),
        parse: CurriculumSubject.parseList,
      );

  Future<Result<void>> addCompletion(
      {required int subjectId,
      required String semester,
      required int? grade}) async {
    final result = await _send<void>(
      send: () => _dio.post('/api/absolutorium/completions', data: {
        'subjectId': subjectId,
        'semester': semester,
        'grade': grade,
      }),
      parse: (_) {},
    );
    if (result is Ok) await _refreshProgress();
    return result;
  }

  Future<Result<void>> addCustomCompletion({
    required String name,
    String? code,
    required int credits,
    required String semester,
    required int? grade,
  }) async {
    final trimmedCode = code?.trim();
    final result = await _send<void>(
      send: () => _dio.post('/api/absolutorium/completions', data: {
        'custom': {
          'name': name.trim(),
          'code':
              (trimmedCode == null || trimmedCode.isEmpty) ? null : trimmedCode,
          'credits': credits,
        },
        'semester': semester,
        'grade': grade,
      }),
      parse: (_) {},
    );
    if (result is Ok) await _refreshProgress();
    return result;
  }

  Future<Result<void>> deleteCompletion(int completionId) async {
    final result = await _send<void>(
      send: () => _dio.delete('/api/absolutorium/completions/$completionId'),
      parse: (_) {},
    );
    if (result is Ok) await _refreshProgress();
    return result;
  }

  Future<Result<T>> _send<T>({
    required Future<Response<dynamic>> Function() send,
    required T Function(Object?) parse,
    T Function()? onNotFound,
  }) async {
    try {
      final response = await send();
      return Ok(parse(response.data));
    } on DioException catch (e) {
      if (onNotFound != null && e.response?.statusCode == 404) {
        return Ok(onNotFound());
      }
      return Err(_errorText(e));
    } on FormatException catch (e) {
      debugPrint('[AbsolutoriumRepository] parse error: ${e.message}');
      return const Err('Nem sikerült feldolgozni a szerver válaszát.');
    }
  }

  String _errorText(DioException e) {
    final body = e.response?.data;
    final status = e.response?.statusCode ?? 0;
    if (body is Map && status >= 400 && status < 500 && status != 401) {
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }
    return apiErrorMessage(e);
  }
}
