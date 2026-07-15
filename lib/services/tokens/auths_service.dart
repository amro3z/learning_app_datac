import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:training/data/api/api_constant.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _token;
  String? _refreshToken;
  bool _initialized = false;
  bool _isRefreshing = false;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    if (_initialized) return;

    _token = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    _initialized = true;
  }

  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    _token = accessToken;
    _refreshToken = refreshToken;
    _initialized = true;

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<bool> refreshTokenIfNeeded() async {
    await init();

    if (_isRefreshing) {
      while (_isRefreshing) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return hasToken;
    }

    final currentRefreshToken = _refreshToken;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      return false;
    }

    _isRefreshing = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': currentRefreshToken,
          'mode': 'json',
        }),
      );

      if (response.statusCode != 200) {
        await clearTokens();
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['data'] is! Map<String, dynamic>) {
        await clearTokens();
        return false;
      }

      final data = decoded['data'] as Map<String, dynamic>;
      final newAccessToken = data['access_token']?.toString();
      final newRefreshToken =
          data['refresh_token']?.toString() ?? currentRefreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await clearTokens();
        return false;
      }

      await saveTokens(newAccessToken, newRefreshToken);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    _initialized = true;

    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<void> logout() async {
    final currentRefreshToken = _refreshToken;

    if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'refresh_token': currentRefreshToken,
            'mode': 'json',
          }),
        );
      } catch (_) {}
    }

    await clearTokens();
  }
}
