import 'dart:async';

import 'package:dio/dio.dart';
import 'package:itk_app/models/user.dart';
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

  final Dio _dio = ApiClient.instance.dio;

  LdapUser? _cachedUser;

  Future<void> _cacheUserToDisk(LdapUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedJson = jsonEncode(user.toJson());
    await prefs.setString('cached_user', encodedJson);
  }

  Future<void> _clearUserFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
  }

  Future<LdapUser?> _loadUserFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_user');

    if (jsonString == null) {
      return null;
    }

    final decodedJson = jsonDecode(jsonString);
    final user = LdapUser.fromJson(decodedJson as Map<String, dynamic>);

    return user;
  }

  Future<AuthResult> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        await getSessionUser();
        return const AuthResult(success: true);
      }

      final msg = response.data['message'];
      return AuthResult(success: false, errorMessage: msg);
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _networkErrorMessage(e),
      );
    }
  }

  Future<LdapUser?> _fetchUserFromNetwork() async {
    try {
      final response = await _dio.get('/api/auth/me');

      if (response.statusCode == 200 && response.data is Map) {
        _cachedUser = LdapUser.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        await _cacheUserToDisk(_cachedUser!);

        return _cachedUser;
      }

      return null;
    } on DioException catch (e) {
      // ignore: avoid_print
      print(
          '[/api/auth/me] DioException type=${e.type} message=${e.message} response=${e.response?.data}');
      return null;
    }
  }

  Future<LdapUser?> getSessionUser() async {
    // Load from disk
    final cachedUser = await _loadUserFromDisk();

    // If disk has not null user, set cache
    if (cachedUser != null) {
      _cachedUser = cachedUser;
      unawaited(_fetchUserFromNetwork());
      return _cachedUser;
    }

    // Else wait for network and return that
    return await _fetchUserFromNetwork();
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } on DioException {
      // Ignore
    } finally {
      await ApiClient.instance.clearCookies();
      _cachedUser = null;
      await _clearUserFromDisk();
    }
  }

  String _networkErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Időtúllépés - a szerver nem válaszol.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Nem sikerült kapcsolódni a szerverhez.';
    }
    return 'Váratlan hiba történt: ${e.message}';
  }

  LdapUser? get cachedUser => _cachedUser;
}
