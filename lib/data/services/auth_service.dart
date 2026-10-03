import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/result.dart';
import 'api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult({required this.success, this.errorMessage});
}

class AuthService {
  AuthService.internal();
  static final AuthService instance = AuthService.internal();

  static const _cacheKey = 'cached_user';

  final Dio _dio = ApiClient.instance.dio;
  LdapUser? _cachedUser;
  LdapUser? get cachedUser => _cachedUser;

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
  Future<LdapUser?> getSessionUser() async {
    // Load from disk
    final fromDisk = await _loadUserFromDisk();

    // If disk has valid user, set cache
    if (fromDisk != null) {
      _cachedUser = fromDisk;
      unawaited(_fetchUserFromNetwork());
      return fromDisk;
    }

    // Else wait for network and return that
    return _fetchUserFromNetwork();
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } on DioException catch (e) {
      debugPrint('[AuthService] logout request failed: ${e.message}');
    } finally {
      await ApiClient.instance.clearCookies();
      _cachedUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    }
  }

  Future<LdapUser?> _fetchUserFromNetwork() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get('/api/auth/me');
    } on DioException catch (e) {
      debugPrint('[AuthService] /me failed: ${apiErrorMessage(e)}');
      return null;
    }

    final user = _parseUser(response.data);
    if (user == null) return null;

    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<LdapUser?> _loadUserFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      await prefs.remove(_cacheKey);
      return null;
    }

    final user = _parseUser(decoded);
    if (user == null) await prefs.remove(_cacheKey);
    return user;
  }

  LdapUser? _parseUser(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return LdapUser.fromJson(data);
    } catch (e) {
      debugPrint('[AuthService] bad user json: $e');
      return null;
    }
  }
}
