import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:training/services/tokens/auths_service.dart';

class ApiClient {
  final AuthService _auth = AuthService();
  AuthService get auth => _auth;

  static const Duration _timeout = Duration(seconds: 15);

  // ===========================
  // 🔵 GET
  // ===========================
  Future<http.Response> get(String url) async {
    try {
      final res = await http
          .get(
            Uri.parse(url),
            headers: {"Authorization": "Bearer ${_auth.token}"},
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        final retry = await _handleRefresh(() async {
          return await http.get(
            Uri.parse(url),
            headers: {"Authorization": "Bearer ${_auth.token}"},
          );
        });

        return retry;
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

  // ===========================
  // 🟢 POST
  // ===========================
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
              ...?headers,
            },
            body: body,
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        final retry = await _handleRefresh(() async {
          return await http.post(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
              ...?headers,
            },
            body: body,
          );
        });

        return retry;
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

  // ===========================
  // 🟡 PATCH
  // ===========================
  Future<http.Response> patch(String url, {required Object body}) async {
    try {
      final res = await http
          .patch(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
            },
            body: body,
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        final retry = await _handleRefresh(() async {
          return await http.patch(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
            },
            body: body,
          );
        });

        return retry;
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

  // ===========================
  // 🔴 DELETE
  // ===========================
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final res = await http
          .delete(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
              ...?headers,
            },
            body: body,
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        final retry = await _handleRefresh(() async {
          return await http.delete(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
              ...?headers,
            },
            body: body,
          );
        });

        return retry;
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

  // ===========================
  // 🔁 HANDLE REFRESH
  // ===========================
  Future<http.Response> _handleRefresh(
    Future<http.Response> Function() retryRequest,
  ) async {
    final ok = await _auth.refreshTokenIfNeeded();

    print("🔁 REFRESH RESULT: $ok");

    if (!ok) {
      print("❌ SESSION EXPIRED - LOGOUT");

      _auth.logout(); // 👈 مهم

      throw Exception("Session expired");
    }

    // ✅ retry request بعد refresh
    return await retryRequest().timeout(_timeout);
  }

  // ===========================
  // 🔍 TOKEN CHECK
  // ===========================
  bool _isExpired(http.Response res) {
    if (res.statusCode == 401) return true;

    try {
      final body = jsonDecode(res.body);
      return body['errors']?[0]?['extensions']?['code'] == 'TOKEN_EXPIRED';
    } catch (_) {
      return false;
    }
  }
}
