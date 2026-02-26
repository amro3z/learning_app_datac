// lib/services/tokens/api_client.dart
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
          .get(
            Uri.parse(url),
            headers: {"Authorization": "Bearer ${_auth.token}"},
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        final ok = await _auth.refreshTokenIfNeeded();
        if (!ok) throw Exception("Session expired");

        return await http
            .get(
              Uri.parse(url),
              headers: {"Authorization": "Bearer ${_auth.token}"},
            )
            .timeout(_timeout);
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
        final ok = await _auth.refreshTokenIfNeeded();
        if (!ok) throw Exception("Session expired");

        return await http
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
        final ok = await _auth.refreshTokenIfNeeded();
        if (!ok) throw Exception("Session expired");

        return await http
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
    required Map<String, dynamic> body,
  }) async {
    try {
      final res = await http
          .patch(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer ${_auth.token}",
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (_isExpired(res)) {
        final ok = await _auth.refreshTokenIfNeeded();
        if (!ok) throw Exception("Session expired");

        return await http
            .patch(
              Uri.parse(url),
              headers: {
                "Authorization": "Bearer ${_auth.token}",
                "Content-Type": "application/json",
              },
              body: jsonEncode(body),
            )
            .timeout(_timeout);
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
