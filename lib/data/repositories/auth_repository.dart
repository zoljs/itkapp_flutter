import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/result.dart';

class AuthRepository extends ChangeNotifier {
  static const _path = '/api/auth';

  AuthRepository({required ApiClient apiClient, required SharedPreferencesService prefs})
      : _apiClient = apiClient,
        _dio = apiClient.dio,
        _prefs = prefs {
    _cachedUser = _loadUserFromDisk();
  }

  static const _cacheKey = 'cached_user';

  final SharedPreferencesService _prefs;
  final ApiClient _apiClient;
  final Dio _dio;
  LdapUser? _cachedUser;

  // Getters
  LdapUser? get cachedUser => _cachedUser;
  bool get isAuthenticated => _cachedUser != null;

  /// Two-request method, early return if first is Err
  Future<Result<void>> login(String username, String password) async {
    // POST the login, save the result (null or error)
    final Result<void> loginResult = await sendRequest(
      send: () => _dio.post('$_path/login', data: {'username': username, 'password': password}),
      parse: (_) {},
    );
    if (loginResult is Err) return loginResult;

    // If login POST is OK, get /me, save the result (ldapUser or error, so this void cannot return it)
    final Result<LdapUser> meResult = await _fetchUserFromNetwork();
    if (meResult case Err(:final message)) return Err(message); // must return new Err<void> with the extracted message

    // If all passed, return Ok therefore we are logged in
    return const Ok(null);
  }

  /// Single request method, however we must extract the message and print it, as the method is NOT of type Result
  Future<void> logout() async {
    // POST the logout, save the result (null or error)
    final result = await sendRequest(
      send: () => _dio.post('$_path/logout'),
      parse: (_) {},
    );
    if (result case Err(:final message)) debugPrint('[AuthRepository] logout request failed: $message');

    await _apiClient.clearCookies();
    _cachedUser = null;
    notifyListeners();

    await _prefs.remove(_cacheKey);
  }

  /// Either returns the user, or returns the thrown FormatExceptions or DioExceptions error message in an Err
  Future<Result<LdapUser>> refreshUser() => _fetchUserFromNetwork();
  Future<Result<LdapUser>> _fetchUserFromNetwork() async {
    final result = await _apiClient.getJson('$_path/me', parse: LdapUser.parse);
    if (result case Ok(:final value)) {
      _cachedUser = value;
      notifyListeners();
      await _prefs.setString(_cacheKey, jsonEncode(value.toJson()));
    }

    return result;
  }

  LdapUser? _loadUserFromDisk() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      unawaited(_prefs.remove(_cacheKey));
      return null;
    }

    final user = _parseUser(decoded);
    if (user == null) unawaited(_prefs.remove(_cacheKey));
    return user;
  }

  LdapUser? _parseUser(Object? data) {
    try {
      return LdapUser.parse(data);
    } on FormatException catch (e) {
      debugPrint('[AuthRepository] bad user json: $e');
      return null;
    }
  }
}
