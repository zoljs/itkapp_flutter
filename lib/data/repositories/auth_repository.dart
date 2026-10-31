import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/result.dart';

class AuthRepository extends ChangeNotifier {
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

  Future<Result<void>> login(String username, String password) async {
    try {
      await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }

    final user = await _fetchUserFromNetwork();
    if (user == null) {
      return const Err('Nem sikerült lekérni a felhasználói adatokat.');
    }
    return const Ok(null);
  }

  // Logged in user, or null if session is invalid
  Future<LdapUser?> refreshUser() => _fetchUserFromNetwork();

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } on DioException catch (e) {
      debugPrint('[AuthRepository] logout request failed: ${e.message}');
    } finally {
      await _apiClient.clearCookies();
      _cachedUser = null;
      notifyListeners();

      await _prefs.remove(_cacheKey);
    }
  }

  Future<LdapUser?> _fetchUserFromNetwork() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get('/api/auth/me');
    } on DioException catch (e) {
      debugPrint('[AuthRepository] /me failed: ${apiErrorMessage(e)}');
      return null;
    }

    final user = _parseUser(response.data);
    if (user == null) return null;

    _cachedUser = user;
    notifyListeners();

    await _prefs.setString(_cacheKey, jsonEncode(user.toJson()));
    return user;
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
