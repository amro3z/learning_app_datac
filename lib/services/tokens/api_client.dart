import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:training/services/tokens/auths_service.dart';

class ApiClient {
  final AuthService _auth = AuthService();

  AuthService get auth => _auth;

  static const Duration _timeout = Duration(seconds: 15);

  Future<http.Response> get(String url) async {
    try {
      final res = await http
          .get(Uri.parse(url), headers: _headers())
          .timeout(_timeout);

      if (_isExpired(res)) {
        return await _handleRefresh(() async {
          return await http.get(Uri.parse(url), headers: _headers());
        });
      }

      return res;
    } on SocketException {
      throw const SocketException('NO_INTERNET');
    } on http.ClientException {
      throw const SocketException('NO_INTERNET');
    } on TimeoutException {
      throw const SocketException('NO_INTERNET');
    }
  }

  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final encodedBody = _encodeBody(body);

      final res = await http
          .post(
            Uri.parse(url),
            headers: _headers(extraHeaders: headers),
            body: encodedBody,
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        return await _handleRefresh(() async {
          return await http.post(
            Uri.parse(url),
            headers: _headers(extraHeaders: headers),
            body: encodedBody,
          );
        });
      }

      return res;
    } on SocketException {
      throw const SocketException('NO_INTERNET');
    } on http.ClientException {
      throw const SocketException('NO_INTERNET');
    } on TimeoutException {
      throw const SocketException('NO_INTERNET');
    }
  }

  Future<http.Response> patch(
    String url, {
    required Object body,
    Map<String, String>? headers,
  }) async {
    try {
      final encodedBody = _encodeBody(body);

      final res = await http
          .patch(
            Uri.parse(url),
            headers: _headers(extraHeaders: headers),
            body: encodedBody,
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        return await _handleRefresh(() async {
          return await http.patch(
            Uri.parse(url),
            headers: _headers(extraHeaders: headers),
            body: encodedBody,
          );
        });
      }

      return res;
    } on SocketException {
      throw const SocketException('NO_INTERNET');
    } on http.ClientException {
      throw const SocketException('NO_INTERNET');
    } on TimeoutException {
      throw const SocketException('NO_INTERNET');
    }
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final encodedBody = _encodeBody(body);

      final res = await http
          .delete(
            Uri.parse(url),
            headers: _headers(extraHeaders: headers),
            body: encodedBody,
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        return await _handleRefresh(() async {
          return await http.delete(
            Uri.parse(url),
            headers: _headers(extraHeaders: headers),
            body: encodedBody,
          );
        });
      }

      return res;
    } on SocketException {
      throw const SocketException('NO_INTERNET');
    } on http.ClientException {
      throw const SocketException('NO_INTERNET');
    } on TimeoutException {
      throw const SocketException('NO_INTERNET');
    }
  }

  Map<String, String> _headers({Map<String, String>? extraHeaders}) {
    return {
      if (_auth.token != null && _auth.token!.isNotEmpty)
        'Authorization': 'Bearer ${_auth.token}',

      'Content-Type': 'application/json',
      'Accept': 'application/json',

      ...?extraHeaders,
    };
  }

  String? _encodeBody(Object? body) {
    if (body == null) {
      return null;
    }
    if (body is String) {
      return body;
    }

    return jsonEncode(body);
  }

  Future<http.Response> _handleRefresh(
    Future<http.Response> Function() retryRequest,
  ) async {
    final ok = await _auth.refreshTokenIfNeeded();

    print('🔁 REFRESH RESULT: $ok');

    if (!ok) {
      print('❌ SESSION EXPIRED - LOGOUT');

      await _auth.logout();

      throw Exception('Session expired');
    }

    return await retryRequest().timeout(_timeout);
  }

  bool _isExpired(http.Response res) {
    if (res.statusCode == 401) {
      return true;
    }

    try {
      final body = jsonDecode(res.body);

      return body['errors']?[0]?['extensions']?['code'] == 'TOKEN_EXPIRED';
    } catch (_) {
      return false;
    }
  }
}
